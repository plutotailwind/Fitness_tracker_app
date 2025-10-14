import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
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
  final void Function(String path)? onReferencePicked;

  const DesktopSplitView({
    super.key,
    this.cameraService,
    this.referenceVideo,
    this.isRecording = false,
    this.isGuided = false,
    this.onReferenceTap,
    this.autoPlayReference = false,
    this.onReferencePicked,
  });

  @override
  State<DesktopSplitView> createState() => _DesktopSplitViewState();
}

class _DesktopSplitViewState extends State<DesktopSplitView> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  String? _videoError;
  String? _resolvedVideoPath;
  bool _resolvedFileExists = false;

  @override
  void didUpdateWidget(covariant DesktopSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.referenceVideo?.videoPath != widget.referenceVideo?.videoPath) {
      _disposeVideo();
      _initVideoIfAvailable();
    }
  }

  @override
  void initState() {
    super.initState();
    _initVideoIfAvailable();
  }

  Future<void> _initVideoIfAvailable() async {
    if (widget.referenceVideo == null) return;
    _videoError = null;
    _isVideoReady = false;

    // Try primary copied path first
    final primaryPath = widget.referenceVideo!.videoPath;
    final primaryFile = File(primaryPath);

    // If missing, try original source path from metadata
    String? fallbackPath;
    try {
      final meta = widget.referenceVideo!.metadata;
      final raw = meta['originalPath'];
      if (raw is String && raw.isNotEmpty) fallbackPath = raw;
    } catch (_) {}

    String? chosenPath;
    if (await primaryFile.exists()) {
      chosenPath = primaryPath;
    } else if (fallbackPath != null && await File(fallbackPath).exists()) {
      chosenPath = fallbackPath;
    }

    if (chosenPath == null) {
      // Log path diagnostics
      // ignore: avoid_print
      print('[Video] No playable path. primary="$primaryPath" exists=${await primaryFile.exists()} fallback="$fallbackPath"');
      setState(() => _videoError = 'Video file not found');
      return;
    }

    try {
      _resolvedVideoPath = chosenPath;
      _resolvedFileExists = await File(chosenPath).exists();
      // ignore: avoid_print
      print('[Video] Initialize file controller with path=${_resolvedVideoPath}, exists=${_resolvedFileExists}');
      final controller = VideoPlayerController.file(File(chosenPath));
      _videoController = controller;
      controller.setLooping(true);
      controller.addListener(() {
        if (!mounted) return;
        if (controller.value.hasError) {
          // ignore: avoid_print
          print('[Video] Controller error: ${controller.value.errorDescription}');
        }
        setState(() {});
      });
      await controller.initialize();
      if (!mounted) return;
      // ignore: avoid_print
      print('[Video] Initialized. size=${controller.value.size} aspect=${controller.value.aspectRatio}');
      setState(() => _isVideoReady = true);
      if (widget.autoPlayReference) {
        // ignore: avoid_print
        print('[Video] Auto-play');
        controller.play();
      }
    } catch (e) {
      // Retry with file:// URI form
      // ignore: avoid_print
      print('[Video] File controller failed: $e. Retrying with file:// URI');
      try {
        final uri = Uri.file(chosenPath);
        final controller = VideoPlayerController.networkUrl(uri);
        _videoController = controller;
        controller.setLooping(true);
        controller.addListener(() {
          if (!mounted) return;
          if (controller.value.hasError) {
            // ignore: avoid_print
            print('[Video] URI controller error: ${controller.value.errorDescription}');
          }
          setState(() {});
        });
        await controller.initialize();
        if (!mounted) return;
        // ignore: avoid_print
        print('[Video] URI initialized. size=${controller.value.size} aspect=${controller.value.aspectRatio}');
        setState(() => _isVideoReady = true);
        if (widget.autoPlayReference) {
          // ignore: avoid_print
          print('[Video] URI auto-play');
          controller.play();
        }
      } catch (_) {
        if (!mounted) return;
        final exists = await File(chosenPath).exists();
        // ignore: avoid_print
        print('[Video] Both initializations failed. path=$chosenPath exists=$exists');
        setState(() => _videoError = exists ? 'Failed to load video' : 'Video file not found');
      }
    }
  }

  void _disposeVideo() {
    _isVideoReady = false;
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Live camera view (left)
          Expanded(
            flex: 3,
            child: _buildCameraView(),
          ),
          // Divider
          Container(
            width: 2,
            color: Colors.grey.shade300,
          ),
          // Reference video view (right)
          Expanded(
            flex: 2,
            child: _buildReferenceView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      height: 220,
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

    final controller = widget.cameraService!.cameraController;
    if (controller != null && controller.value.isInitialized) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
        ),
        child: CameraPreview(controller),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Camera initialized, waiting for stream...',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onReferenceTap,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Reference'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickReferenceFromFileSystem,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Browse...'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_resolvedVideoPath != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _resolvedFileExists ? Icons.check_circle : Icons.error_outline,
                      size: 14,
                      color: _resolvedFileExists ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 260,
                      child: Text(
                        _resolvedVideoPath!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_videoError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_videoError!, style: const TextStyle(color: Colors.redAccent)),
            )
          else if (_isVideoReady && _videoController != null)
            AspectRatio(
              aspectRatio: (_videoController!.value.aspectRatio == 0 || _videoController!.value.aspectRatio.isNaN)
                  ? 16 / 9
                  : _videoController!.value.aspectRatio,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  widget.referenceVideo!.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('Loading video...', style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
              ],
            ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _isVideoReady && _videoController != null
                      ? () {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                          setState(() {});
                        }
                      : null,
                  icon: Icon(
                    _videoController?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.referenceVideo!.videoPath,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickReferenceFromFileSystem,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Change', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReferenceFromFileSystem() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'],
        allowMultiple: false,
      );
      final path = res?.files.single.path;
      if (path == null) return;
      // ignore: avoid_print
      print('[Video] Picked file: $path');
      widget.onReferencePicked?.call(path);
    } catch (e) {
      // ignore: avoid_print
      print('[Video] FilePicker error: $e');
    }
  }
}

