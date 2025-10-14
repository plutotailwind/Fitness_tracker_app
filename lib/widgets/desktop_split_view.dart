import 'package:flutter/material.dart';
import '../models/reference_video.dart';
import '../services/desktop_camera_service.dart';

/// Desktop-compatible split view widget
class DesktopSplitView extends StatefulWidget {
  final DesktopCameraService? cameraService;
  final ReferenceVideo? referenceVideo;
  final bool isRecording;
  final bool isGuided;
  final VoidCallback? onReferenceTap;
  final bool autoPlayReference;

  const DesktopSplitView({
    super.key,
    this.cameraService,
    this.referenceVideo,
    this.isRecording = false,
    this.isGuided = false,
    this.onReferenceTap,
    this.autoPlayReference = false,
  });

  @override
  State<DesktopSplitView> createState() => _DesktopSplitViewState();
}

class _DesktopSplitViewState extends State<DesktopSplitView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Live camera view (left side)
          Expanded(
            flex: 1,
            child: _buildCameraView(),
          ),
          
          // Divider
          Container(
            width: 2,
            color: Colors.grey.shade300,
          ),
          
          // Reference video view (right side)
          Expanded(
            flex: 1,
            child: _buildReferenceView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.videocam,
                  size: 16,
                  color: widget.isRecording ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Camera',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isRecording ? Colors.red : Colors.black87,
                  ),
                ),
                if (widget.isRecording) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Camera content
          Expanded(
            child: _buildCameraContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraContent() {
    if (widget.cameraService == null || !widget.cameraService!.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera not available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Desktop mode: Use file upload instead',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Camera Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Desktop simulation mode',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceView() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.video_library,
                  size: 16,
                  color: widget.referenceVideo != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reference Video',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.referenceVideo != null ? Colors.green : Colors.black87,
                  ),
                ),
                if (widget.referenceVideo != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Reference content
          Expanded(
            child: _buildReferenceContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceContent() {
    if (widget.referenceVideo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No reference video',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: widget.onReferenceTap,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Reference'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              widget.referenceVideo!.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Reference video loaded',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 12,
              ),
            ),
            if (widget.autoPlayReference) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement video playback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video playback not implemented yet')),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

