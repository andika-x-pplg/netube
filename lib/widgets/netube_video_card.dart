import 'package:flutter/material.dart';

import '../models/youtube_video_model.dart';
import '../theme/netube_theme.dart';

class NetubeVideoCard extends StatelessWidget {
  final YoutubeVideo video;
  final VoidCallback onTap;
  final bool featured;
  final bool isLive;

  const NetubeVideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.featured = false,
    this.isLive = false,
  });

  String get _publishedLabel {
    final date = DateTime.tryParse(video.publishedAt)?.toLocal();
    if (date == null) return '';
    final difference = DateTime.now().difference(date);
    if (difference.inDays >= 365) return '${difference.inDays ~/ 365}y ago';
    if (difference.inDays >= 30) return '${difference.inDays ~/ 30}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(featured ? 20 : 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'youtube-${video.id}',
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: NetubeColors.surfaceHigh,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white38,
                                size: 36,
                              ),
                            ),
                          ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xAA000000)],
                        stops: [.55, 1],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: featured ? 48 : 42,
                      height: featured ? 48 : 42,
                      decoration: const BoxDecoration(
                        color: Color(0xAA050505),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      left: 12,
                      bottom: 11,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sensors, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 11, 2, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: featured ? 17 : 15,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: NetubeColors.surfaceHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: NetubeColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: NetubeColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      if (_publishedLabel.isNotEmpty)
                        Text(
                          _publishedLabel,
                          style: const TextStyle(
                            color: Color(0xFF747474),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
