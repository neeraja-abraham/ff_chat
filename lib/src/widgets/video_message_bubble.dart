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

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.network(widget.url);
    await _videoController!.initialize();

    // Compute max dimensions for web
    double maxWidth = kIsWeb ? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.8;
    double maxHeight = kIsWeb ? MediaQuery.of(context).size.height * 0.4 : MediaQuery.of(context).size.height * 0.25;

    double aspectRatio = _videoController!.value.aspectRatio;
    double width = maxWidth;
    double height = width / aspectRatio;

    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      aspectRatio: aspectRatio,
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 600 : MediaQuery.of(context).size.width * 0.8,
          maxHeight: kIsWeb ? 400 : MediaQuery.of(context).size.height * 0.25,
        ),
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return Container(
        height: kIsWeb ? 200 : 180,
        width: kIsWeb ? 300 : 300,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
