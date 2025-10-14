import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoMessageBubble extends StatefulWidget {
  final String url;

  const VideoMessageBubble({super.key, required this.url});

  @override
  State<VideoMessageBubble> createState() => _VideoMessageBubbleState();
}

class _VideoMessageBubbleState extends State<VideoMessageBubble> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isWebVideoSupported = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoController!.initialize();

      // If it's web and failed to get duration or metadata, mark as unsupported
      if (kIsWeb && !_videoController!.value.isInitialized) {
        _isWebVideoSupported = false;
        return;
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: _videoController!.value.aspectRatio,
        autoPlay: false,
        looping: false,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kIsWeb) {
        // On web, unsupported formats will throw here
        _isWebVideoSupported = false;
      } else {
        debugPrint('Video init error: $e');
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double maxWidth = kIsWeb ? screenWidth * 0.5 : screenWidth * 0.8;
    final double maxHeight = kIsWeb ? screenHeight * 0.4 : screenHeight * 0.25;

    if (kIsWeb && !_isWebVideoSupported) {
      // Fallback for unsupported web formats
      return Container(
        width: maxWidth,
        height: maxHeight,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "This video format is not supported in your browser.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return Container(
        width: maxWidth,
        height: maxHeight,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
