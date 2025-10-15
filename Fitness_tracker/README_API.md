# Fitness Tracker REST API

A comprehensive REST API for real-time exercise analysis, pose estimation, and feedback generation using computer vision and machine learning.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Start the API Server

```bash
python start_api_server.py
```

Or directly:

```bash
python api_server.py
```

### 3. Access the API

- **API Server**: http://localhost:8000
- **Interactive Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## 📋 Features

### Core Functionality
- **Real-time Pose Analysis**: Analyze user pose against trainer templates
- **Exercise Feedback**: Generate specific, actionable feedback for form improvement
- **Session Management**: Track exercise sessions with rep counting and scoring
- **Priority-based Scoring**: Focus analysis on specific joints/body parts
- **Weights Detection**: Detect whether user is holding weights
- **Performance Analytics**: Comprehensive session summaries and statistics

### API Endpoints

#### Session Management
- `POST /sessions/start` - Start a new exercise session
- `GET /sessions/{session_id}/status` - Get session status
- `POST /sessions/{session_id}/analyze` - Analyze user pose
- `POST /sessions/{session_id}/complete_rep` - Mark rep as completed
- `GET /sessions/{session_id}/summary` - Get session summary
- `POST /sessions/{session_id}/end` - End session

#### Standalone Analysis
- `POST /analysis/pose` - Analyze pose without session

#### System
- `GET /health` - Health check
- `GET /sessions` - List active sessions
- `DELETE /sessions/{session_id}` - Delete session

## 🔧 Configuration

### Exercise Configuration

```python
{
    "priority_joints": ["elbow", "shoulder"],  # Joints to prioritize
    "priority_weight": 1.8,                   # Weight for priority joints
    "nonpriority_weight": 0.2,                # Weight for non-priority joints
    "require_weights": False,                 # Whether to require weights detection
    "device": "cpu"                           # Processing device (cpu/cuda)
}
```

### Supported Joints
- `elbow_l`, `elbow_r` - Left/Right elbows
- `shoulder_l`, `shoulder_r` - Left/Right shoulders  
- `hip_l`, `hip_r` - Left/Right hips
- `knee_l`, `knee_r` - Left/Right knees

## 📊 Data Models

### Pose Landmarks
The API expects pose landmarks in the format:
```python
[
    [  # Frame 1
        [x, y, z],  # Landmark 0
        [x, y, z],  # Landmark 1
        ...        # 33 landmarks total
    ],
    [  # Frame 2
        ...
    ]
]
```

### Analysis Results
```python
{
    "score": 0.85,                    # Form score (0.0-1.0)
    "feedback": "Excellent form!",     # Generated feedback
    "joint_analysis": {                # Per-joint analysis
        "elbow_l": 12.5,
        "elbow_r": 8.3,
        ...
    },
    "motion_amplitude": 0.45,         # Motion amplitude
    "rep_detected": false             # Whether a rep was detected
}
```

## 💻 Usage Examples

### Python Client

```python
import requests

# Start session
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

# Complete rep
requests.post(f"http://localhost:8000/sessions/{session_id}/complete_rep", 
              data={"score": 0.85})
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

// Start session
const session = await axios.post('http://localhost:8000/sessions/start', {
    trainer_video_path: 'trainer_lateralraise.mp4',
    config: {
        priority_joints: ['elbow', 'shoulder'],
        priority_weight: 1.8,
        nonpriority_weight: 0.2,
        require_weights: false
    }
});

// Analyze pose
const analysis = await axios.post(`http://localhost:8000/sessions/${session.data.session_id}/analyze`, {
    session_id: session.data.session_id,
    user_landmarks: userLandmarks,
    trainer_landmarks: trainerLandmarks
});
```

## 🔍 Integration with Existing Code

The API server integrates with the existing fitness tracker modules:

- **`exercise.py`**: Core exercise analysis and session management
- **`scoring.py`**: Pose scoring and DTW distance calculations
- **`feedback_system.py`**: Real-time feedback generation
- **`ui_priority.py`**: Priority joint configuration
- **`orientation.py`**: 3D orientation calculations
- **`weights_detection.py`**: Weights detection algorithms

## 🛠️ Development

### Running in Development Mode

```bash
python start_api_server.py
```

This enables auto-reload for development.

### Production Deployment

```bash
uvicorn api_server:app --host 0.0.0.0 --port 8000 --workers 4
```

### Docker Deployment

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 📈 Performance Considerations

- **CPU Usage**: Pose analysis is computationally intensive
- **Memory**: Sessions store pose data in memory
- **Concurrency**: Multiple sessions supported with thread safety
- **Cleanup**: Sessions auto-cleanup after 1 hour of inactivity

## 🔒 Security

- **CORS**: Configured for cross-origin requests
- **Input Validation**: All inputs validated with Pydantic
- **Error Handling**: Comprehensive error responses
- **Session Isolation**: Each session is isolated

## 📚 API Documentation

Full API documentation is available at:
- **Interactive Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## 🐛 Troubleshooting

### Common Issues

1. **ModuleNotFoundError: No module named 'starlette'**
   ```bash
   pip install starlette>=0.27.0
   ```

2. **MediaPipe not found**
   ```bash
   pip install mediapipe>=0.8.0
   ```

3. **CUDA not available**
   - Set `device: "cpu"` in configuration
   - Install CUDA-compatible PyTorch if needed

### Logs

The server provides detailed logging for debugging:
- Session lifecycle events
- Analysis results
- Error messages
- Performance metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is part of the Fitness Tracker application.

## 🆘 Support

For issues and questions:
1. Check the API documentation at `/docs`
2. Review the troubleshooting section
3. Check server logs for error details
4. Ensure all dependencies are installed correctly
