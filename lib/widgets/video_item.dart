// widgets/video_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/video.dart';
import '../providers/likes_provider.dart';

class VideoItem extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoItem({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likesProvider = Provider.of<LikesProvider>(context);
    final isLiked = likesProvider.isVideoLiked(video.id);
    final likeCount = likesProvider.getLikeCount(video.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Thumbnail
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, _) => Container(
                      color: Colors.grey,
                      child: const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                
                // Like button and count
                Padding(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                video.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
