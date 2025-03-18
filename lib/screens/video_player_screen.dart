// screens/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

import '../models/video.dart';
import '../providers/likes_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.video.videoUrl);
    
    await _controller.initialize();
    await _controller.setLooping(true);
    
    setState(() {
      _isInitialized = true;
    });
    
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likesProvider = Provider.of<LikesProvider>(context);
    final isLiked = likesProvider.isVideoLiked(widget.video.id);
    final likeCount = likesProvider.getLikeCount(widget.video.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isInitialized
                ? VideoPlayer(_controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          
          // Video controls
          if (_isInitialized)
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            
          // Play/pause button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                iconSize: 40,
              ),
            ],
          ),
          
          // Video info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Like button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () {
                        likesProvider.toggleLike(widget.video.id);
                      },
                    ),
                    Text('$likeCount likes'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
