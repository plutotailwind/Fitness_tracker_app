"""
Fitness Tracker API Client Example

This example demonstrates how to use the Fitness Tracker REST API
to interact with the exercise analysis and feedback system.
"""

import requests
import json
import numpy as np
import cv2
import mediapipe as mp
from typing import List, Dict, Any
import time

class FitnessTrackerClient:
    """Client for interacting with the Fitness Tracker API."""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session_id = None
        
    def start_session(self, trainer_video_path: str, config: Dict[str, Any] = None) -> str:
        """Start a new exercise session."""
        if config is None:
            config = {
                "priority_joints": ["elbow", "shoulder"],
                "priority_weight": 1.8,
                "nonpriority_weight": 0.2,
                "require_weights": False,
                "device": "cpu"
            }
        
        request_data = {
            "trainer_video_path": trainer_video_path,
            "config": config
        }
        
        response = requests.post(f"{self.base_url}/sessions/start", json=request_data)
        response.raise_for_status()
        
        result = response.json()
        self.session_id = result["session_id"]
        return self.session_id
    
    def get_session_status(self) -> Dict[str, Any]:
        """Get current session status."""
        if not self.session_id:
            raise ValueError("No active session")
        
        response = requests.get(f"{self.base_url}/sessions/{self.session_id}/status")
        response.raise_for_status()
        return response.json()
    
    def analyze_pose(self, user_landmarks: List[List[List[float]]], 
                    trainer_landmarks: List[List[List[float]]]) -> Dict[str, Any]:
        """Analyze user pose and get feedback."""
        if not self.session_id:
            raise ValueError("No active session")
        
        request_data = {
            "session_id": self.session_id,
            "user_landmarks": user_landmarks,
            "trainer_landmarks": trainer_landmarks
        }
        
        response = requests.post(f"{self.base_url}/sessions/{self.session_id}/analyze", 
                               json=request_data)
        response.raise_for_status()
        return response.json()
    
    def complete_rep(self, score: float) -> Dict[str, Any]:
        """Mark a rep as completed."""
        if not self.session_id:
            raise ValueError("No active session")
        
        response = requests.post(f"{self.base_url}/sessions/{self.session_id}/complete_rep",
                               data={"score": score})
        response.raise_for_status()
        return response.json()
    
    def get_summary(self) -> Dict[str, Any]:
        """Get session summary."""
        if not self.session_id:
            raise ValueError("No active session")
        
        response = requests.get(f"{self.base_url}/sessions/{self.session_id}/summary")
        response.raise_for_status()
        return response.json()
    
    def end_session(self) -> Dict[str, Any]:
        """End the current session."""
        if not self.session_id:
            raise ValueError("No active session")
        
        response = requests.post(f"{self.base_url}/sessions/{self.session_id}/end")
        response.raise_for_status()
        return response.json()

def extract_landmarks_from_image(image_path: str) -> List[List[List[float]]]:
    """Extract pose landmarks from an image using MediaPipe."""
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose()
    
    # Load image
    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    # Process image
    results = pose.process(image_rgb)
    
    if results.pose_landmarks:
        landmarks = []
        for landmark in results.pose_landmarks.landmark:
            landmarks.append([landmark.x, landmark.y, landmark.z])
        return [landmarks]  # Return as sequence of one frame
    else:
        return []

def demo_api_usage():
    """Demonstrate how to use the API client."""
    print("Fitness Tracker API Demo")
    print("=" * 50)
    
    # Initialize client
    client = FitnessTrackerClient()
    
    try:
        # Start a session
        print("1. Starting session...")
        session_id = client.start_session(
            trainer_video_path="trainer_lateralraise.mp4",
            config={
                "priority_joints": ["elbow", "shoulder"],
                "priority_weight": 1.8,
                "nonpriority_weight": 0.2,
                "require_weights": False
            }
        )
        print(f"Session started: {session_id}")
        
        # Wait for session to be ready
        print("2. Waiting for session to be ready...")
        while True:
            status = client.get_session_status()
            print(f"Status: {status['status']}")
            if status['status'] == 'ready':
                break
            elif status['status'] == 'error':
                print("Session failed to initialize")
                return
            time.sleep(1)
        
        # Simulate pose analysis
        print("3. Simulating pose analysis...")
        
        # Create dummy landmarks for demonstration
        # In real usage, you would extract these from camera frames
        dummy_user_landmarks = [
            [[0.5, 0.3, 0.1] for _ in range(33)]  # 33 landmarks, 3D coordinates
        ]
        dummy_trainer_landmarks = [
            [[0.5, 0.3, 0.1] for _ in range(33)]
        ]
        
        # Analyze pose
        analysis = client.analyze_pose(dummy_user_landmarks, dummy_trainer_landmarks)
        print(f"Analysis result: {analysis}")
        
        # Complete a rep
        print("4. Completing a rep...")
        rep_result = client.complete_rep(analysis['score'])
        print(f"Rep completed: {rep_result}")
        
        # Get summary
        print("5. Getting session summary...")
        summary = client.get_summary()
        print(f"Session summary: {summary}")
        
        # End session
        print("6. Ending session...")
        end_result = client.end_session()
        print(f"Session ended: {end_result}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    demo_api_usage()

