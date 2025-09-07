import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../models/reference_video.dart';

class SplitView extends StatefulWidget {
  final CameraController? cameraController;
  final ReferenceVideo? referenceVideo;
  final bool isRecording;
  final bool isGuided;
  final VoidCallback? onReferenceTap;
  final bool autoPlayReference;

  const SplitView({
    super.key,
    this.cameraController,
    this.referenceVideo,
    this.isRecording = false,
    this.isGuided = false,
    this.onReferenceTap,
    this.autoPlayReference = false,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.referenceVideo?.id != widget.referenceVideo?.id) {
      _initializeVideo();
    }
    // Auto play/pause when guided state changes
    if (oldWidget.isGuided != widget.isGuided && _videoController != null && _isVideoInitialized) {
      if (widget.isGuided && widget.autoPlayReference) {
        _videoController!.play();
      } else {
        _videoController!.pause();
      }
      setState(() {});
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.referenceVideo == null) return;

    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(widget.referenceVideo!.videoPath));
      await _videoController!.initialize();
      setState(() => _isVideoInitialized = true);
    } catch (e) {
      print('Error initializing video: $e');
      setState(() => _isVideoInitialized = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Live Camera (Left side - 60% width)
        Expanded(
          flex: 6,
          child: _buildCameraView(),
        ),
        
        const SizedBox(width: 8),
        
        // Reference Video (Right side - 40% width)
        Expanded(
          flex: 4,
          child: _buildReferenceView(),
        ),
      ],
    );
  }

  Widget _buildCameraView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Camera preview
            if (widget.cameraController != null && 
                widget.cameraController!.value.isInitialized)
              CameraPreview(widget.cameraController!)
            else
              Container(
                color: Colors.black12,
                child: const Center(
                  child: Text('Camera unavailable', style: TextStyle(color: Colors.grey)),
                ),
              ),
            
            // Recording indicator
            if (widget.isRecording)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('REC', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            
            // Guided session indicator
            if (widget.isGuided)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('GUIDED', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Reference video or placeholder
            if (widget.referenceVideo != null && _isVideoInitialized)
              _buildVideoPlayer()
            else
              _buildPlaceholder(),
            
            // Video controls overlay
            if (widget.referenceVideo != null && _isVideoInitialized)
              _buildVideoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.referenceVideo != null ? Icons.video_library : Icons.video_library_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              widget.referenceVideo != null ? 'Reference Video' : 'No Reference',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.referenceVideo != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.referenceVideo!.title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.onReferenceTap != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onReferenceTap,
                child: const Text('Select Reference'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
                setState(() {});
              },
              icon: Icon(
                _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
            IconButton(
              onPressed: () async {
                await _videoController!.seekTo(Duration.zero);
                if (widget.isGuided || widget.autoPlayReference) {
                  _videoController!.play();
                }
                setState(() {});
              },
              icon: const Icon(Icons.replay, color: Colors.white, size: 18),
            ),
            Expanded(
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
