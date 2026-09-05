import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/netube_content_model.dart';
import '../services/netube_content_service.dart';
import '../theme/netube_theme.dart';

class ShortsPage extends StatelessWidget {
  const ShortsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: StreamBuilder<List<NetubeContent>>(
      stream: NetubeContentService.publicShorts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Shorts tidak dapat dimuat.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: NetubeColors.accent),
          );
        }
        final shorts = snapshot.data!;
        if (shorts.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada Shorts publik.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: shorts.length,
          itemBuilder: (context, index) => ShortVideoPlayer(
            key: ValueKey(shorts[index].id),
            content: shorts[index],
          ),
        );
      },
    ),
  );
}

class ShortVideoPlayer extends StatefulWidget {
  const ShortVideoPlayer({super.key, required this.content});

  final NetubeContent content;

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.content.videoUrl))
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {});
            controller
              ..setLooping(true)
              ..play();
          });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => controller.value.isInitialized
      ? Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${widget.content.ownerName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      : const Center(
          child: CircularProgressIndicator(color: NetubeColors.accent),
        );
}
