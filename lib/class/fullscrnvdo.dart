import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoScreen extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _FullScreenVideoScreenState createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Automatically play the video
      });

    _controller.addListener(() {
      setState(() {}); // Update the slider and video UI in real-time
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player in full screen
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(),
          ),
          // Overlay the slider on top of the video
          Positioned(
            bottom: 50,
            left: 10,
            right: 10,
            child: _controller.value.isInitialized
                ? Slider(
              value: _controller.value.position.inSeconds.toDouble(),
              max: _controller.value.duration.inSeconds.toDouble(),
              activeColor: Colors.indigo,
              inactiveColor: Colors.white,
              onChanged: (value) {
                _controller.seekTo(Duration(seconds: value.toInt()));
              },
            )
                : const SizedBox.shrink(),
          ),
          // Play/Pause floating button
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

