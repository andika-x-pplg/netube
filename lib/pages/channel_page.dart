import 'package:flutter/material.dart';

import '../models/youtube_video_model.dart';
import '../services/youtube_service.dart';
import 'youtube_player_page.dart';

class ChannelPage extends StatefulWidget {
  final String channelId;
  final String channelName;

  const ChannelPage({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  final YoutubeService _youtubeService = YoutubeService();

  List<YoutubeVideo> videos = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      final result = await _youtubeService.fetchChannelVideos(widget.channelId);

      setState(() {
        videos = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.channelName),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : ListView.builder(
              itemCount: videos.length,

              itemBuilder: (context, index) {
                final video = videos[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => YoutubePlayerPage(
                          videoId: video.id,
                          title: video.title,
                          thumbnailUrl: video.thumbnailUrl,
                          channelId: video.channelId,
                          channelTitle: video.channelTitle,
                        ),
                      ),
                    );
                  },

                  child: Card(
                    color: Colors.grey[900],

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Image.network(video.thumbnailUrl),

                        Padding(
                          padding: const EdgeInsets.all(10),

                          child: Text(
                            video.title,

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
