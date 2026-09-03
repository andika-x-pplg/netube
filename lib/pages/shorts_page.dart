import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/netube_theme.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  late List<String> shuffledVideos;

  final List<String> videos = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",

    "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",

    "https://samplelib.com/lib/preview/mp4/sample-10s.mp4",
  ];

  @override
  void initState() {
    super.initState();

    // RANDOM VIDEO ORDER
    shuffledVideos = List.from(videos);

    shuffledVideos.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: PageView.builder(
        scrollDirection: Axis.vertical,

        itemCount: shuffledVideos.length,

        itemBuilder: (context, index) {
          return ShortVideoPlayer(videoUrl: shuffledVideos[index]);
        },
      ),
    );
  }
}

// ============================
// VIDEO PLAYER
// ============================

class ShortVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ShortVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});

        controller.play();

        controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Stack(
            children: [
              // VIDEO
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,

                  child: SizedBox(
                    width: controller.value.size.width,

                    height: controller.value.size.height,

                    child: VideoPlayer(controller),
                  ),
                ),
              ),

              // OVERLAY
              Positioned(
                bottom: 80,
                left: 20,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "@netube",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Amazing Shorts",

                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),

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
}
