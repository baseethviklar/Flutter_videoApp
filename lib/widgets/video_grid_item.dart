// widgets/video_grid_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/video.dart';
import '../providers/likes_provider.dart';

class VideoGridItem extends StatelessWidget {
  final Video video;

  const VideoGridItem({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likesProvider = Provider.of<LikesProvider>(context);
    final isLiked = likesProvider.isVideoLiked(video.id);
    final likeCount = likesProvider.getLikeCount(video.id);

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, _) => Container(
                    color: Colors.grey,
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
                
                // Play icon overlay
                Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                
                // Like button and count
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          likeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            likesProvider.toggleLike(video.id);
                          },
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              video.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
