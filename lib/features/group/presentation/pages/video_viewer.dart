import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatefulWidget {
  final VideoPlayerController videoUrl;
  const VideoViewer(this.videoUrl, {Key? key}) : super(key: key);

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  @override
  void initState() {
    setState(() {
      widget.videoUrl.play();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerController video = widget.videoUrl;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Video Viewer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: AspectRatio(
            aspectRatio: video.value.aspectRatio,
            child: VideoPlayer(video),
          ),
        ),
      ),
    );
  }
}
