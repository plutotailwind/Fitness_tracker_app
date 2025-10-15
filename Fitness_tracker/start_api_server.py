#!/usr/bin/env python3
"""
Startup script for the Fitness Tracker API Server

This script provides an easy way to start the API server with proper configuration.
"""

import uvicorn
import sys
import os
from pathlib import Path

def main():
    """Start the Fitness Tracker API server."""
    
    # Get the directory where this script is located
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    print("🏃‍♂️ Starting Fitness Tracker API Server...")
    print("=" * 50)
    print("Server will be available at: http://localhost:8000")
    print("API Documentation: http://localhost:8000/docs")
    print("Health Check: http://localhost:8000/health")
    print("=" * 50)
    print("Press Ctrl+C to stop the server")
    print()
    
    try:
        # Start the server
        uvicorn.run(
            "api_server:app",
            host="0.0.0.0",
            port=8000,
            reload=True,  # Enable auto-reload for development
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
