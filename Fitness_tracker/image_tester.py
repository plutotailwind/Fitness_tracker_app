import cv2
import base64
import requests
import json

# FastAPI server URL
API_URL = "http://127.0.0.1:8000/analysis/base64_frame"

# OpenCV window and webcam capture
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Cannot open webcam")
    exit()

while True:
    ret, frame = cap.read()
    if not ret:
        print("Failed to grab frame")
        break

    # Show frame in OpenCV window
    cv2.imshow("Webcam", frame)

    # Encode frame to JPEG
    _, buffer = cv2.imencode(".jpg", frame)
    frame_b64 = base64.b64encode(buffer).decode("utf-8")

    # Send to FastAPI
    try:
        response = requests.post(
            API_URL,
            headers={"Content-Type": "application/json"},
            data=json.dumps({"frame_b64": frame_b64})
        )
        if response.status_code == 200:
            data = response.json()
            print(f"Landmarks detected: {data.get('landmarks', [])}")
        else:
            print(f"Error {response.status_code}: {response.text}")
    except Exception as e:
        print("Request failed:", e)

    # Press 'q' to quit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()