import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class VideoMessageWidget extends StatefulWidget {
  final String videoUrl;
  const VideoMessageWidget({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _VideoMessageWidgetState createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  Uint8List? _videoThumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.PNG,
      maxWidth: 120, // specify the max width for the thumbnail
      quality: 75,
    );

    if (thumbnail != null) {
      setState(() {
        _videoThumbnail = thumbnail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _videoThumbnail != null
        ? Image.memory(
      _videoThumbnail!,
      height: 120,
      width: 120,
      fit: BoxFit.cover,
    )
        : const SizedBox(
      height: 120,
      width: 120,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
