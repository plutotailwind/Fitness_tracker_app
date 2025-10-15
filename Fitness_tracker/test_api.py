#!/usr/bin/env python3
"""
Test script for the Fitness Tracker API

This script tests the basic functionality of the API server.
"""

import requests
import time
import json
import numpy as np

def test_health_check():
    """Test the health check endpoint."""
    print("🔍 Testing health check...")
    try:
        response = requests.get("http://localhost:8000/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_session_management():
    """Test session management endpoints."""
    print("\n🔍 Testing session management...")
    
    try:
        # Test starting a session
        print("  Starting session...")
        session_data = {
            "trainer_video_path": "trainer_lateralraise.mp4",
            "config": {
                "priority_joints": ["elbow", "shoulder"],
                "priority_weight": 1.8,
                "nonpriority_weight": 0.2,
                "require_weights": False,
                "device": "cpu"
            }
        }
        
        response = requests.post("http://localhost:8000/sessions/start", json=session_data)
        if response.status_code != 200:
            print(f"❌ Failed to start session: {response.status_code}")
            print(f"   Response: {response.text}")
            return None
        
        session_id = response.json()["session_id"]
        print(f"✅ Session started: {session_id}")
        
        # Test getting session status
        print("  Getting session status...")
        response = requests.get(f"http://localhost:8000/sessions/{session_id}/status")
        if response.status_code == 200:
            print("✅ Session status retrieved")
        else:
            print(f"❌ Failed to get session status: {response.status_code}")
        
        # Wait for session to be ready
        print("  Waiting for session to be ready...")
        max_wait = 30  # 30 seconds max
        wait_time = 0
        
        while wait_time < max_wait:
            response = requests.get(f"http://localhost:8000/sessions/{session_id}/status")
            if response.status_code == 200:
                status = response.json()
                if status["status"] == "ready":
                    print("✅ Session is ready")
                    break
                elif status["status"] == "error":
                    print("❌ Session failed to initialize")
                    return None
                else:
                    print(f"  Status: {status['status']}")
            time.sleep(1)
            wait_time += 1
        
        if wait_time >= max_wait:
            print("❌ Session did not become ready in time")
            return None
        
        return session_id
        
    except Exception as e:
        print(f"❌ Session management error: {e}")
        return None

def test_pose_analysis(session_id):
    """Test pose analysis endpoint."""
    print("\n🔍 Testing pose analysis...")
    
    try:
        # Create dummy landmarks for testing
        dummy_landmarks = []
        for frame in range(1):  # Single frame
            frame_landmarks = []
            for i in range(33):  # 33 MediaPipe landmarks
                # Create realistic-looking dummy data
                x = 0.5 + np.random.normal(0, 0.1)
                y = 0.3 + np.random.normal(0, 0.1)
                z = 0.1 + np.random.normal(0, 0.05)
                frame_landmarks.append([x, y, z])
            dummy_landmarks.append(frame_landmarks)
        
        analysis_data = {
            "session_id": session_id,
            "user_landmarks": dummy_landmarks,
            "trainer_landmarks": dummy_landmarks  # Use same for simplicity
        }
        
        response = requests.post(f"http://localhost:8000/sessions/{session_id}/analyze", 
                               json=analysis_data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Pose analysis successful")
            print(f"   Score: {result['score']:.3f}")
            print(f"   Feedback: {result['feedback']}")
            print(f"   Motion amplitude: {result['motion_amplitude']:.3f}")
            return True
        else:
            print(f"❌ Pose analysis failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Pose analysis error: {e}")
        return False

def test_rep_completion(session_id):
    """Test rep completion endpoint."""
    print("\n🔍 Testing rep completion...")
    
    try:
        response = requests.post(f"http://localhost:8000/sessions/{session_id}/complete_rep",
                               data={"score": 0.85})
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Rep completion successful")
            print(f"   Rep number: {result['rep_number']}")
            print(f"   Total reps: {result['total_reps']}")
            print(f"   Average score: {result['average_score']:.3f}")
            return True
        else:
            print(f"❌ Rep completion failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Rep completion error: {e}")
        return False

def test_summary(session_id):
    """Test session summary endpoint."""
    print("\n🔍 Testing session summary...")
    
    try:
        response = requests.get(f"http://localhost:8000/sessions/{session_id}/summary")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Session summary retrieved")
            print(f"   Total reps: {result['total_reps']}")
            print(f"   Average score: {result['average_score']:.3f}")
            print(f"   Excellent reps: {result['excellent_reps']}")
            print(f"   Improvement trend: {result['improvement_trend']}")
            return True
        else:
            print(f"❌ Session summary failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Session summary error: {e}")
        return False

def test_standalone_analysis():
    """Test standalone pose analysis."""
    print("\n🔍 Testing standalone analysis...")
    
    try:
        # Create dummy landmarks
        dummy_landmarks = []
        for frame in range(1):
            frame_landmarks = []
            for i in range(33):
                x = 0.5 + np.random.normal(0, 0.1)
                y = 0.3 + np.random.normal(0, 0.1)
                z = 0.1 + np.random.normal(0, 0.05)
                frame_landmarks.append([x, y, z])
            dummy_landmarks.append(frame_landmarks)
        
        analysis_data = {
            "user_landmarks": dummy_landmarks,
            "trainer_landmarks": dummy_landmarks
        }
        
        response = requests.post("http://localhost:8000/analysis/pose", json=analysis_data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Standalone analysis successful")
            print(f"   Score: {result['score']:.3f}")
            print(f"   Feedback: {result['feedback']}")
            return True
        else:
            print(f"❌ Standalone analysis failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Standalone analysis error: {e}")
        return False

def main():
    """Run all tests."""
    print("🧪 Fitness Tracker API Test Suite")
    print("=" * 50)
    
    # Test health check
    if not test_health_check():
        print("\n❌ Health check failed. Is the server running?")
        print("   Start the server with: python start_api_server.py")
        return
    
    # Test session management
    session_id = test_session_management()
    if not session_id:
        print("\n❌ Session management failed")
        return
    
    # Test pose analysis
    test_pose_analysis(session_id)
    
    # Test rep completion
    test_rep_completion(session_id)
    
    # Test summary
    test_summary(session_id)
    
    # Test standalone analysis
    test_standalone_analysis()
    
    # Test session list
    print("\n🔍 Testing session list...")
    try:
        response = requests.get("http://localhost:8000/sessions")
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Session list retrieved: {result['total_sessions']} active sessions")
        else:
            print(f"❌ Session list failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Session list error: {e}")
    
    print("\n🎉 Test suite completed!")
    print("=" * 50)

if __name__ == "__main__":
    main()
