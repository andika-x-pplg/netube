import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../services/history_service.dart';
import '../services/subscription_service.dart';
import '../services/watch_later_service.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String channelId;
  final String channelTitle;

  const YoutubePlayerPage({
    super.key,
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.channelId,
    required this.channelTitle,
  });

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  YoutubePlayerController? _controller;

  bool isSubscribed = false;
  bool isWatchLater = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    initializePlayer();
    checkSubscription();
    checkWatchLater();
  }

  Future<void> initializePlayer() async {
    // ==========================
    // SIMPAN KE WATCH HISTORY
    // ==========================
    await HistoryService.addVideoHistory(
      videoId: widget.videoId,
      title: widget.title,
      thumbnail: widget.thumbnailUrl,
      channelId: widget.channelId,
      channelTitle: widget.channelTitle,
    );

    // ==========================
    // AMBIL PROGRESS TERAKHIR
    // ==========================
    final lastPosition =
        await HistoryService.getVideoProgress(widget.videoId);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: lastPosition,
      ),
    );

    // ==========================
    // AUTO SAVE PROGRESS
    // ==========================
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) async {
        if (_controller == null) return;

        final value = _controller!.value;

        if (!value.isReady) return;

        await HistoryService.saveVideoProgress(
          videoId: widget.videoId,
          seconds: value.position.inSeconds,
        );

        // reset progress kalau video selesai
        if (value.position >= value.metaData.duration &&
            value.metaData.duration.inSeconds > 0) {
          await HistoryService.saveVideoProgress(
            videoId: widget.videoId,
            seconds: 0,
          );
        }
      },
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> checkSubscription() async {
    final result =
        await SubscriptionService.isSubscribed(widget.channelId);

    if (!mounted) return;

    setState(() {
      isSubscribed = result;
    });
  }

  Future<void> checkWatchLater() async {
    final result =
        await WatchLaterService.isVideoSaved(widget.videoId);

    if (!mounted) return;

    setState(() {
      isWatchLater = result;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (_controller != null) {
      HistoryService.saveVideoProgress(
        videoId: widget.videoId,
        seconds: _controller!.value.position.inSeconds,
      );

      _controller!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.channelTitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // WATCH LATER
                      IconButton(
                        onPressed: () async {
                          if (isWatchLater) {
                            await WatchLaterService.removeVideo(
                              widget.videoId,
                            );

                            if (!mounted) return;

                            setState(() {
                              isWatchLater = false;
                            });
                          } else {
                            await WatchLaterService.addVideo(
                              videoId: widget.videoId,
                              title: widget.title,
                              thumbnail: widget.thumbnailUrl,
                              channelId: widget.channelId,
                              channelTitle: widget.channelTitle,
                            );

                            if (!mounted) return;

                            setState(() {
                              isWatchLater = true;
                            });
                          }
                        },

                        icon: Icon(
                          isWatchLater
                              ? Icons.watch_later
                              : Icons.watch_later_outlined,
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // SUBSCRIBE
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubscribed
                              ? Colors.grey
                              : Colors.red,
                        ),

                        onPressed: () async {
                          if (isSubscribed) {
                            await SubscriptionService.unsubscribe(
                              widget.channelId,
                            );

                            if (!mounted) return;

                            setState(() {
                              isSubscribed = false;
                            });
                          } else {
                            await SubscriptionService.subscribe(
                              channelId: widget.channelId,
                              channelName: widget.channelTitle,
                            );

                            if (!mounted) return;

                            setState(() {
                              isSubscribed = true;
                            });
                          }
                        },

                        child: Text(
                          isSubscribed
                              ? "Subscribed"
                              : "Subscribe",
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