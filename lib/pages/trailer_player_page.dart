import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../services/history_service.dart';

class TrailerPlayerPage extends StatefulWidget {
  final String youtubeKey;

  const TrailerPlayerPage({
    super.key,
    required this.youtubeKey,
  });

  @override
  State<TrailerPlayerPage> createState() => _TrailerPlayerPageState();
}

class _TrailerPlayerPageState extends State<TrailerPlayerPage> {
  YoutubePlayerController? _controller;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final lastPosition =
        await HistoryService.getMovieProgress(widget.youtubeKey);

    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeKey,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: lastPosition,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_controller == null) return;

      final value = _controller!.value;

      if (!value.isReady) return;

      await HistoryService.saveMovieProgress(
        movieId: widget.youtubeKey,
        seconds: value.position.inSeconds,
      );

      // Jika trailer sudah selesai, reset progress ke 0
      if (value.position >= value.metaData.duration &&
          value.metaData.duration.inSeconds > 0) {
        await HistoryService.saveMovieProgress(
          movieId: widget.youtubeKey,
          seconds: 0,
        );
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (_controller != null) {
      HistoryService.saveMovieProgress(
        movieId: widget.youtubeKey,
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
      body: SafeArea(
        child: Center(
          child: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }
}