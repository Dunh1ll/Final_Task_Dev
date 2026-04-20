import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// VideoBackground
///
/// Plays a looping, muted video asset as a full-screen background.
///
/// ✅ NEW: Optional [onInitialized] callback.
///   Called once, immediately after the video has been initialized
///   and playback has started.
///   Used by login/register/forgot-password screens to know when
///   the background is ready so they can dismiss their loading overlay.
class VideoBackground extends StatefulWidget {
  final String videoPath;

  /// Called once when the video player has finished initializing
  /// and the video starts playing. Use this to hide any loading
  /// overlay that was shown while waiting for the video.
  final VoidCallback? onInitialized;

  const VideoBackground({
    super.key,
    required this.videoPath,
    this.onInitialized,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = VideoPlayerController.asset(widget.videoPath);
    await _controller.initialize();
    if (mounted) {
      setState(() => _initialized = true);
      _controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      // ✅ Notify caller that the video is ready
      widget.onInitialized?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Black fallback while initializing
      return Container(color: Colors.black);
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
