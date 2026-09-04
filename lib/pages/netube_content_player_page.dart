import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/netube_content_model.dart';
import '../widgets/library_widgets.dart';
import '../widgets/video_comments_section.dart';

class NetubeContentPlayerPage extends StatefulWidget {
  const NetubeContentPlayerPage({super.key, required this.content});
  final NetubeContent content;

  @override
  State<NetubeContentPlayerPage> createState() =>
      _NetubeContentPlayerPageState();
}

class _NetubeContentPlayerPageState extends State<NetubeContentPlayerPage> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.content.videoUrl))
          ..initialize()
              .then((_) {
                if (!mounted) return;
                setState(() {});
                _controller.play();
              })
              .catchError((_) {
                if (mounted) setState(() => _failed = true);
              });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: libraryBackground,
    appBar: AppBar(
      backgroundColor: libraryBackground,
      surfaceTintColor: Colors.transparent,
      title: Text(
        widget.content.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.isInitialized
                ? _controller.value.aspectRatio
                : 16 / 9,
            child: _failed
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: libraryAccent,
                          size: 38,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Unable to play this video',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : !_controller.value.isInitialized
                ? const Center(
                    child: CircularProgressIndicator(color: libraryAccent),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      GestureDetector(
                        onTap: () => setState(
                          () => _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play(),
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _controller.value.isPlaying ? 0 : 1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0x99050B18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: libraryAccent,
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${widget.content.ownerName} • ${widget.content.category}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                if (widget.content.description.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    widget.content.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          VideoCommentsSection(videoId: 'netube_${widget.content.id}'),
        ],
      ),
    ),
  );
}
