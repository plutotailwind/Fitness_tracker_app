# Fitness Tracker REST API Documentation

## Overview

The Fitness Tracker API provides REST endpoints for real-time exercise analysis, pose estimation, and feedback generation. The API allows external applications to interact with the fitness tracker's computer vision and machine learning capabilities.

## Base URL

```
http://localhost:8000
```

## Authentication

Currently, the API does not require authentication. For production use, implement proper authentication mechanisms.

## API Endpoints

### 1. Health Check

#### GET `/health`

Check if the API server is running.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 2. Session Management

#### POST `/sessions/start`

Start a new exercise session.

**Request Body:**
```json
{
  "trainer_video_path": "path/to/trainer/video.mp4",
  "config": {
    "priority_joints": ["elbow", "shoulder"],
    "priority_weight": 1.8,
    "nonpriority_weight": 0.2,
    "require_weights": false,
    "device": "cpu"
  }
}
```

**Response:**
```json
{
  "session_id": "uuid-string",
  "status": "starting"
}
```

#### GET `/sessions/{session_id}/status`

Get the current status of a session.

**Response:**
```json
{
  "session_id": "uuid-string",
  "status": "ready",
  "total_reps": 0,
  "current_rep_scores": [],
  "average_score": 0.0,
  "start_time": "2024-01-15T10:30:00Z",
  "last_activity": "2024-01-15T10:30:00Z"
}
```

#### POST `/sessions/{session_id}/analyze`

Analyze user pose and provide feedback.

**Request Body:**
```json
{
  "session_id": "uuid-string",
  "user_landmarks": [
    [
      [0.5, 0.3, 0.1],
      [0.6, 0.4, 0.2],
      ...
    ]
  ],
  "trainer_landmarks": [
    [
      [0.5, 0.3, 0.1],
      [0.6, 0.4, 0.2],
      ...
    ]
  ]
}
```

**Response:**
```json
{
  "score": 0.85,
  "feedback": "Excellent form! Keep it up!",
  "joint_analysis": {
    "elbow_l": 12.5,
    "elbow_r": 8.3,
    "shoulder_l": 15.2,
    "shoulder_r": 10.1,
    "hip_l": 5.8,
    "hip_r": 6.2,
    "knee_l": 3.1,
    "knee_r": 2.9
  },
  "motion_amplitude": 0.45,
  "rep_detected": false
}
```

#### POST `/sessions/{session_id}/complete_rep`

Mark a rep as completed with its score.

**Request Body:**
```
score=0.85
```

**Response:**
```json
{
  "rep_number": 1,
  "score": 0.85,
  "total_reps": 1,
  "average_score": 0.85
}
```

#### GET `/sessions/{session_id}/summary`

Get session summary statistics.

**Response:**
```json
{
  "total_reps": 10,
  "average_score": 0.72,
  "excellent_reps": 3,
  "good_reps": 5,
  "poor_reps": 2,
  "best_score": 0.95,
  "worst_score": 0.45,
  "improvement_trend": "improving"
}
```

#### POST `/sessions/{session_id}/end`

End a session and get final summary.

**Response:**
```json
{
  "session_id": "uuid-string",
  "status": "completed",
  "summary": {
    "total_reps": 10,
    "average_score": 0.72,
    "excellent_reps": 3,
    "good_reps": 5,
    "poor_reps": 2,
    "best_score": 0.95,
    "worst_score": 0.45,
    "improvement_trend": "improving"
  }
}
```

### 3. Standalone Analysis

#### POST `/analysis/pose`

Analyze pose without a session (standalone analysis).

**Request Body:**
```json
{
  "user_landmarks": [
    [
      [0.5, 0.3, 0.1],
      [0.6, 0.4, 0.2],
      ...
    ]
  ],
  "trainer_landmarks": [
    [
      [0.5, 0.3, 0.1],
      [0.6, 0.4, 0.2],
      ...
    ]
  ]
}
```

**Response:**
```json
{
  "score": 0.75,
  "feedback": "Good form, keep it up!",
  "joint_analysis": {
    "elbow_l": 15.2,
    "elbow_r": 12.8,
    ...
  },
  "motion_amplitude": 0.38,
  "rep_detected": false
}
```

### 4. Session Management

#### GET `/sessions`

List all active sessions.

**Response:**
```json
{
  "active_sessions": ["uuid1", "uuid2"],
  "total_sessions": 2
}
```

#### DELETE `/sessions/{session_id}`

Delete a session.

**Response:**
```json
{
  "message": "Session deleted successfully"
}
```

## Data Models

### ExerciseConfig

```json
{
  "priority_joints": ["elbow", "shoulder", "hip", "knee"],
  "priority_weight": 1.8,
  "nonpriority_weight": 0.2,
  "require_weights": false,
  "device": "cpu"
}
```

### RepScore

```json
{
  "rep_number": 1,
  "score": 0.85,
  "timestamp": "2024-01-15T10:30:00Z",
  "feedback": "Excellent form!"
}
```

### SessionStatus

```json
{
  "session_id": "uuid-string",
  "status": "ready",
  "total_reps": 5,
  "current_rep_scores": [...],
  "average_score": 0.72,
  "start_time": "2024-01-15T10:30:00Z",
  "last_activity": "2024-01-15T10:35:00Z"
}
```

### AnalysisResult

```json
{
  "score": 0.85,
  "feedback": "Excellent form!",
  "joint_analysis": {
    "elbow_l": 12.5,
    "elbow_r": 8.3,
    ...
  },
  "motion_amplitude": 0.45,
  "rep_detected": false
}
```

### SummaryStats

```json
{
  "total_reps": 10,
  "average_score": 0.72,
  "excellent_reps": 3,
  "good_reps": 5,
  "poor_reps": 2,
  "best_score": 0.95,
  "worst_score": 0.45,
  "improvement_trend": "improving"
}
```

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "detail": "Session not ready"
}
```

### 404 Not Found
```json
{
  "detail": "Session not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Analysis failed: error message"
}
```

## Usage Examples

### Python Client Example

```python
import requests
import json

# Start a session
response = requests.post("http://localhost:8000/sessions/start", json={
    "trainer_video_path": "trainer_lateralraise.mp4",
    "config": {
        "priority_joints": ["elbow", "shoulder"],
        "priority_weight": 1.8,
        "nonpriority_weight": 0.2,
        "require_weights": False
    }
})
session_id = response.json()["session_id"]

# Analyze pose
analysis = requests.post(f"http://localhost:8000/sessions/{session_id}/analyze", json={
    "session_id": session_id,
    "user_landmarks": user_landmarks,
    "trainer_landmarks": trainer_landmarks
})

# Complete a rep
requests.post(f"http://localhost:8000/sessions/{session_id}/complete_rep", 
              data={"score": 0.85})

# Get summary
summary = requests.get(f"http://localhost:8000/sessions/{session_id}/summary")
```

### JavaScript/Node.js Example

```javascript
const axios = require('axios');

// Start a session
const sessionResponse = await axios.post('http://localhost:8000/sessions/start', {
    trainer_video_path: 'trainer_lateralraise.mp4',
    config: {
        priority_joints: ['elbow', 'shoulder'],
        priority_weight: 1.8,
        nonpriority_weight: 0.2,
        require_weights: false
    }
});
const sessionId = sessionResponse.data.session_id;

// Analyze pose
const analysis = await axios.post(`http://localhost:8000/sessions/${sessionId}/analyze`, {
    session_id: sessionId,
    user_landmarks: userLandmarks,
    trainer_landmarks: trainerLandmarks
});

// Complete a rep
await axios.post(`http://localhost:8000/sessions/${sessionId}/complete_rep`, 
    new URLSearchParams({ score: 0.85 }));

// Get summary
const summary = await axios.get(`http://localhost:8000/sessions/${sessionId}/summary`);
```

## Running the API Server

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Start the server:
```bash
python api_server.py
```

3. The API will be available at `http://localhost:8000`

4. View interactive API documentation at `http://localhost:8000/docs`

## Notes

- The API uses MediaPipe for pose estimation
- Landmarks are 33 3D points representing human pose
- Scores range from 0.0 to 1.0 (higher is better)
- Sessions automatically clean up after 1 hour of inactivity
- The API supports real-time analysis and feedback generation
- Priority joints allow focusing on specific body parts for analysis

