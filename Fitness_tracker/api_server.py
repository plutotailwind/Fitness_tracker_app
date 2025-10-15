"""
Fitness Tracker REST API Server

This FastAPI server provides REST endpoints for the fitness tracker application,
allowing external applications to interact with the exercise analysis, feedback,
and session management features.
"""

from fastapi import FastAPI, HTTPException, UploadFile, File, Form, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any, Tuple
import numpy as np
import cv2
import tempfile
import os
import json
import time
from datetime import datetime
import uuid
from collections import deque
import asyncio
import threading
from concurrent.futures import ThreadPoolExecutor
from fastapi import Body
import base64
# Import existing modules
from exercise import (
    run_live_session, extract_pose_sequence, RepDetector, 
    derive_angle_thresholds, extract_landmarks
)
from scoring import (
    compute_angles_for_seq, smooth_angles, resample_to_length,
    dtw_distance_l1, masked_motion_amplitude, build_priority_mask,
    total_motion_amplitude
)
from feedback_system import create_feedback_system, ExerciseFeedbackSystem
from ui_priority import build_weights_from_priority
from orientation import average_forward_vector
from weights_detection import detect_weights
from summary_window import show_exercise_summary
import mediapipe as mp

# Initialize FastAPI app
app = FastAPI(
    title="Fitness Tracker API",
    description="REST API for real-time exercise analysis and feedback",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global state for active sessions
active_sessions: Dict[str, Dict[str, Any]] = {}
session_lock = threading.Lock()

# Pydantic models for API schemas
class ExerciseConfig(BaseModel):
    priority_joints: List[str] = Field(default=[], description="List of joints to prioritize")
    priority_weight: float = Field(default=1.8, ge=0.1, le=5.0, description="Weight for priority joints")
    nonpriority_weight: float = Field(default=0.2, ge=0.0, le=1.0, description="Weight for non-priority joints")
    require_weights: bool = Field(default=False, description="Whether to require weights detection")
    device: str = Field(default="cpu", description="Device to use for processing")

class SessionStartRequest(BaseModel):
    trainer_video_path: str = Field(..., description="Path to trainer video file")
    config: ExerciseConfig = Field(default_factory=ExerciseConfig, description="Exercise configuration")

class RepScore(BaseModel):
    rep_number: int
    score: float = Field(ge=0.0, le=1.0)
    timestamp: datetime
    feedback: Optional[str] = None

class SessionStatus(BaseModel):
    session_id: str
    status: str  # "starting", "running", "paused", "completed", "error"
    total_reps: int
    current_rep_scores: List[RepScore]
    average_score: float
    start_time: datetime
    last_activity: datetime

class FeedbackRequest(BaseModel):
    session_id: str
    user_landmarks: List[List[List[float]]]  # [T, 33, 3] - sequence of pose landmarks
    trainer_landmarks: List[List[List[float]]]  # [T, 33, 3] - trainer template landmarks

class AnalysisResult(BaseModel):
    score: float
    feedback: str
    joint_analysis: Dict[str, float]
    motion_amplitude: float
    rep_detected: bool

class SummaryStats(BaseModel):
    total_reps: int
    average_score: float
    excellent_reps: int  # score >= 0.8
    good_reps: int  # score >= 0.5
    poor_reps: int  # score < 0.5
    best_score: float
    worst_score: float
    improvement_trend: str  # "improving", "declining", "stable"

# Initialize MediaPipe
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils

@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "Fitness Tracker API",
        "version": "1.0.0",
        "endpoints": {
            "sessions": "/sessions",
            "analysis": "/analysis",
            "feedback": "/feedback",
            "health": "/health"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "timestamp": datetime.now()}

@app.post("/sessions/start")
async def start_session(request: SessionStartRequest) -> Dict[str, str]:
    """Start a new exercise session."""
    session_id = str(uuid.uuid4())
    
    try:
        # Validate trainer video exists
        if not os.path.exists(request.trainer_video_path):
            raise HTTPException(status_code=404, detail="Trainer video file not found")
        
        # Initialize session
        with session_lock:
            active_sessions[session_id] = {
                "status": "starting",
                "config": request.config,
                "trainer_video_path": request.trainer_video_path,
                "rep_scores": [],
                "start_time": datetime.now(),
                "last_activity": datetime.now(),
                "feedback_system": None,
                "trainer_template": None
            }
        
        # Load trainer template in background
        asyncio.create_task(load_trainer_template(session_id, request.trainer_video_path, request.config))
        
        return {"session_id": session_id, "status": "starting"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to start session: {str(e)}")

async def load_trainer_template(session_id: str, trainer_video_path: str, config: ExerciseConfig):
    """Load trainer template and initialize feedback system."""
    try:
        with session_lock:
            if session_id not in active_sessions:
                return
            
            session = active_sessions[session_id]
            session["status"] = "loading"
        
        # Extract trainer sequence
        trainer_seq = extract_pose_sequence(trainer_video_path)
        if len(trainer_seq) == 0:
            raise Exception("Could not extract trainer landmarks")
        
        # Build weights and priority mask
        D = 8  # Number of joint angles
        weights = build_weights_from_priority(
            config.priority_joints, 
            config.priority_weight, 
            config.nonpriority_weight, 
            D
        )
        priority_mask = build_priority_mask(config.priority_joints, D)
        
        # Create feedback system
        feedback_system = create_feedback_system(config.priority_joints, weights)
        
        # Compute trainer angles
        trainer_angles = compute_angles_for_seq(trainer_seq)
        trainer_angles = smooth_angles(trainer_angles, window=5)
        
        # Store in session
        with session_lock:
            if session_id in active_sessions:
                active_sessions[session_id].update({
                    "status": "ready",
                    "feedback_system": feedback_system,
                    "trainer_template": {
                        "sequence": trainer_seq,
                        "angles": trainer_angles,
                        "weights": weights,
                        "priority_mask": priority_mask
                    }
                })
    
    except Exception as e:
        with session_lock:
            if session_id in active_sessions:
                active_sessions[session_id]["status"] = "error"
                active_sessions[session_id]["error"] = str(e)


@app.post("/analysis/base64_frame")
async def analyze_base64_frame(data: Dict[str, str] = Body(...)):
    """
    Accepts a base64-encoded image, extracts pose landmarks using MediaPipe,
    and returns the list of (x, y, z) coordinates for each landmark.
    """
    try:
        frame_b64 = data.get("frame_b64")
        if not frame_b64:
            raise HTTPException(status_code=400, detail="Missing 'frame_b64' field")

        # Decode base64 to image
        img_data = base64.b64decode(frame_b64)
        np_arr = np.frombuffer(img_data, np.uint8)
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is None:
            raise HTTPException(status_code=400, detail="Failed to decode image")

        # Process frame with Mediapipe
        with mp_pose.Pose(static_image_mode=False, min_detection_confidence=0.5) as pose:
            results = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if not results.pose_landmarks:
                return {"message": "No pose detected", "landmarks": []}

            landmarks = [
                [lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark
            ]

        return {
            "message": "Pose extracted successfully",
            "num_landmarks": len(landmarks),
            "landmarks": landmarks
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Frame analysis failed: {str(e)}")

@app.get("/sessions/{session_id}/status")
async def get_session_status(session_id: str) -> SessionStatus:
    """Get current session status."""
    with session_lock:
        if session_id not in active_sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        
        session = active_sessions[session_id]
        
        # Convert rep scores to RepScore objects
        rep_scores = []
        for i, score in enumerate(session["rep_scores"]):
            rep_scores.append(RepScore(
                rep_number=i+1,
                score=score,
                timestamp=session["last_activity"]
            ))
        
        average_score = np.mean(session["rep_scores"]) if session["rep_scores"] else 0.0
        
        return SessionStatus(
            session_id=session_id,
            status=session["status"],
            total_reps=len(session["rep_scores"]),
            current_rep_scores=rep_scores,
            average_score=average_score,
            start_time=session["start_time"],
            last_activity=session["last_activity"]
        )

@app.post("/sessions/{session_id}/analyze")
async def analyze_pose(session_id: str, request: FeedbackRequest) -> AnalysisResult:
    """Analyze user pose and provide feedback."""
    with session_lock:
        if session_id not in active_sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        
        session = active_sessions[session_id]
        if session["status"] != "ready":
            raise HTTPException(status_code=400, detail="Session not ready")
    
    try:
        # Convert landmarks to numpy arrays
        user_landmarks = np.array(request.user_landmarks, dtype=np.float32)
        trainer_landmarks = np.array(request.trainer_landmarks, dtype=np.float32)
        
        # Get session data
        trainer_template = session["trainer_template"]
        feedback_system = session["feedback_system"]
        
        # Compute user angles
        user_angles = compute_angles_for_seq([user_landmarks])
        user_angles = smooth_angles(user_angles, window=5)
        user_angles = resample_to_length(user_angles, len(trainer_template["angles"]))
        
        # Calculate DTW distance
        dist = dtw_distance_l1(
            user_angles, 
            trainer_template["angles"], 
            weights=trainer_template["weights"]
        )
        
        # Calculate similarity score
        score = np.exp(-0.03 * dist)
        
        # Calculate motion amplitude
        user_motion_amp = masked_motion_amplitude(
            user_angles, 
            trainer_template["priority_mask"]
        )
        trainer_motion_amp = masked_motion_amplitude(
            trainer_template["angles"], 
            trainer_template["priority_mask"]
        )
        
        # Generate feedback
        feedback = feedback_system.analyze_rep_performance(
            user_angles, 
            trainer_template["angles"],
            user_motion_amp,
            trainer_motion_amp,
            score,
            trainer_template["priority_mask"]
        )
        
        # Joint analysis
        joint_analysis = {}
        joint_names = ['elbow_l', 'elbow_r', 'shoulder_l', 'shoulder_r', 
                      'hip_l', 'hip_r', 'knee_l', 'knee_r']
        
        for i, joint_name in enumerate(joint_names):
            if i < user_angles.shape[1]:
                user_joint = user_angles[:, i]
                trainer_joint = trainer_template["angles"][:, i]
                joint_diff = np.mean(np.abs(user_joint - trainer_joint))
                joint_analysis[joint_name] = float(joint_diff)
        
        # Update session
        with session_lock:
            active_sessions[session_id]["last_activity"] = datetime.now()
        
        return AnalysisResult(
            score=float(score),
            feedback=feedback,
            joint_analysis=joint_analysis,
            motion_amplitude=float(user_motion_amp),
            rep_detected=False  # This would need more sophisticated rep detection
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.post("/sessions/{session_id}/complete_rep")
async def complete_rep(session_id: str, score: float = Form(...)) -> Dict[str, Any]:
    """Mark a rep as completed with its score."""
    with session_lock:
        if session_id not in active_sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        
        session = active_sessions[session_id]
        session["rep_scores"].append(score)
        session["last_activity"] = datetime.now()
        
        return {
            "rep_number": len(session["rep_scores"]),
            "score": score,
            "total_reps": len(session["rep_scores"]),
            "average_score": np.mean(session["rep_scores"])
        }

@app.get("/sessions/{session_id}/summary")
async def get_session_summary(session_id: str) -> SummaryStats:
    """Get session summary statistics."""
    with session_lock:
        if session_id not in active_sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        
        session = active_sessions[session_id]
        rep_scores = session["rep_scores"]
    
    if not rep_scores:
        return SummaryStats(
            total_reps=0,
            average_score=0.0,
            excellent_reps=0,
            good_reps=0,
            poor_reps=0,
            best_score=0.0,
            worst_score=0.0,
            improvement_trend="stable"
        )
    
    # Calculate statistics
    total_reps = len(rep_scores)
    average_score = np.mean(rep_scores)
    excellent_reps = sum(1 for s in rep_scores if s >= 0.8)
    good_reps = sum(1 for s in rep_scores if s >= 0.5)
    poor_reps = sum(1 for s in rep_scores if s < 0.5)
    best_score = max(rep_scores)
    worst_score = min(rep_scores)
    
    # Calculate improvement trend
    if len(rep_scores) >= 3:
        first_half = np.mean(rep_scores[:len(rep_scores)//2])
        second_half = np.mean(rep_scores[len(rep_scores)//2:])
        if second_half > first_half + 0.1:
            improvement_trend = "improving"
        elif second_half < first_half - 0.1:
            improvement_trend = "declining"
        else:
            improvement_trend = "stable"
    else:
        improvement_trend = "stable"
    
    return SummaryStats(
        total_reps=total_reps,
        average_score=average_score,
        excellent_reps=excellent_reps,
        good_reps=good_reps,
        poor_reps=poor_reps,
        best_score=best_score,
        worst_score=worst_score,
        improvement_trend=improvement_trend
    )

@app.post("/sessions/{session_id}/end")
async def end_session(session_id: str) -> Dict[str, Any]:
    """End a session and return final summary."""
    with session_lock:
        if session_id not in active_sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        
        session = active_sessions[session_id]
        session["status"] = "completed"
        
        # Get final summary
        summary = await get_session_summary(session_id)
        
        # Clean up session (optional - you might want to keep for history)
        # del active_sessions[session_id]
        
        return {
            "session_id": session_id,
            "status": "completed",
            "summary": summary
        }

@app.post("/analysis/pose")
async def analyze_pose_standalone(request: FeedbackRequest) -> AnalysisResult:
    """Analyze pose without a session (standalone analysis)."""
    try:
        # Convert landmarks to numpy arrays
        user_landmarks = np.array(request.user_landmarks, dtype=np.float32)
        trainer_landmarks = np.array(request.trainer_landmarks, dtype=np.float32)
        
        # Compute angles for both
        user_angles = compute_angles_for_seq([user_landmarks])
        trainer_angles = compute_angles_for_seq([trainer_landmarks])
        
        # Calculate DTW distance
        dist = dtw_distance_l1(user_angles, trainer_angles)
        score = np.exp(-0.03 * dist)
        
        # Calculate motion amplitude
        user_motion_amp = total_motion_amplitude(user_angles)
        trainer_motion_amp = total_motion_amplitude(trainer_angles)
        
        # Simple feedback based on score
        if score >= 0.8:
            feedback = "Excellent form!"
        elif score >= 0.6:
            feedback = "Good form, keep it up!"
        elif score >= 0.4:
            feedback = "Not bad, try to improve your form"
        else:
            feedback = "Focus on matching the trainer's movement"
        
        # Joint analysis
        joint_analysis = {}
        joint_names = ['elbow_l', 'elbow_r', 'shoulder_l', 'shoulder_r', 
                      'hip_l', 'hip_r', 'knee_l', 'knee_r']
        
        for i, joint_name in enumerate(joint_names):
            if i < user_angles.shape[1] and i < trainer_angles.shape[1]:
                user_joint = user_angles[:, i]
                trainer_joint = trainer_angles[:, i]
                joint_diff = np.mean(np.abs(user_joint - trainer_joint))
                joint_analysis[joint_name] = float(joint_diff)
        
        return AnalysisResult(
            score=float(score),
            feedback=feedback,
            joint_analysis=joint_analysis,
            motion_amplitude=float(user_motion_amp),
            rep_detected=False
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.get("/sessions")
async def list_sessions() -> Dict[str, List[str]]:
    """List all active sessions."""
    with session_lock:
        return {
            "active_sessions": list(active_sessions.keys()),
            "total_sessions": len(active_sessions)
        }

@app.delete("/sessions/{session_id}")
async def delete_session(session_id: str) -> Dict[str, str]:
    """Delete a session."""
    with session_lock:
        if session_id not in active_sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        
        del active_sessions[session_id]
        return {"message": "Session deleted successfully"}

# Background task to clean up old sessions
@app.on_event("startup")
async def startup_event():
    """Initialize background tasks."""
    asyncio.create_task(cleanup_old_sessions())

async def cleanup_old_sessions():
    """Clean up sessions older than 1 hour."""
    while True:
        await asyncio.sleep(300)  # Check every 5 minutes
        current_time = datetime.now()
        
        with session_lock:
            sessions_to_remove = []
            for session_id, session in active_sessions.items():
                if (current_time - session["last_activity"]).seconds > 3600:  # 1 hour
                    sessions_to_remove.append(session_id)
            
            for session_id in sessions_to_remove:
                del active_sessions[session_id]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
