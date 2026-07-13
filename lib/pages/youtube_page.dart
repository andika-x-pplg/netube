import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../models/youtube_video_model.dart';
import 'youtube_player_page.dart';
import 'youtube_search_page.dart';

class YoutubeHomePage extends StatefulWidget {
  const YoutubeHomePage({super.key});

  @override
  State<YoutubeHomePage> createState() => _YoutubeHomePageState();
}

class _YoutubeHomePageState extends State<YoutubeHomePage> {
  final YoutubeService _youtubeService = YoutubeService();

  final List<String> _categories = [
    'Popular',
    'Trending',
    'Live',
    'Music',
    'Gaming',
    'Movies',
    'Anime',
  ];

  String _selectedCategory = 'Popular';

  List<YoutubeVideo> _videos = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<YoutubeVideo> fetchedVideos;

      if (_selectedCategory == 'Popular' || _selectedCategory == 'Trending') {
        fetchedVideos = await _youtubeService.fetchTrendingVideos();
      } else if (_selectedCategory == 'Live') {
        fetchedVideos = await _youtubeService.fetchLiveVideos();
      } else {
        fetchedVideos = await _youtubeService.fetchVideosByCategory(
          _selectedCategory,
        );
      }

      setState(() {
        _videos = fetchedVideos;
        _isLoading = false;
      });

      for (var video in fetchedVideos) {
        debugPrint("VIDEO ID: ${video.id} | TITLE: ${video.title}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat video: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          'NETUBE VIDEO',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const YoutubeSearchPage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // =====================
          // CATEGORY BAR
          // =====================
          SizedBox(
            height: 60,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,

              itemCount: _categories.length,

              itemBuilder: (context, index) {
                final category = _categories[index];

                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    if (_selectedCategory != category) {
                      setState(() {
                        _selectedCategory = category;
                      });

                      _loadVideos();
                    }
                  },

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey.shade900,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Center(
                      child: Text(
                        category,

                        style: TextStyle(
                          color: Colors.white,

                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // =====================
          // VIDEO LIST
          // =====================
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : ListView.builder(
                    itemCount: _videos.length,

                    itemBuilder: (context, index) {
                      final video = _videos[index];

                      return GestureDetector(
                        onTap: () {
                          if (video.id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Video ID tidak ditemukan"),
                              ),
                            );

                            return;
                          }

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

                          color: Colors.grey,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        video.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[800],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                      ),
                                    ),

                                    // LIVE BADGE
                                    if (_selectedCategory == 'Live')
                                      Positioned(
                                        top: 45,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            "1.2K watching",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 45,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          "1.2K watching",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      video.title,

                                      maxLines: 2,

                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 15,

                                        fontWeight: FontWeight.bold,
                                      ),
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
