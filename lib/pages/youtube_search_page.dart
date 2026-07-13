import 'package:flutter/material.dart';

import '../models/youtube_video_model.dart';
import '../services/youtube_service.dart';
import 'youtube_player_page.dart';

class YoutubeSearchPage extends StatefulWidget {
  const YoutubeSearchPage({super.key});

  @override
  State<YoutubeSearchPage> createState() => _YoutubeSearchPageState();
}

class _YoutubeSearchPageState extends State<YoutubeSearchPage> {
  final YoutubeService _youtubeService = YoutubeService();

  final TextEditingController _searchController = TextEditingController();

  List<YoutubeVideo> _videos = [];

  bool _isLoading = false;

  Future<void> searchVideos() async {
    if (_searchController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _youtubeService.fetchVideosByCategory(
        _searchController.text,
      );

      setState(() {
        _videos = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          "Search YouTube",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              controller: _searchController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Search videos...",
                hintStyle: const TextStyle(color: Colors.grey),

                filled: true,

                fillColor: Colors.grey.shade900,

                prefixIcon: const Icon(Icons.search, color: Colors.white),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.red),

                  onPressed: searchVideos,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),

              onSubmitted: (_) {
                searchVideos();
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : ListView.builder(
                    itemCount: _videos.length,

                    itemBuilder: (context, index) {
                      final video = _videos[index];

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

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),

                          color: Colors.grey[950],

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,

                                child: Image.network(
                                  video.thumbnailUrl,

                                  fit: BoxFit.cover,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      video.title,

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 15,

                                        fontWeight: FontWeight.bold,
                                      ),

                                      maxLines: 2,

                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      video.channelTitle,

                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
