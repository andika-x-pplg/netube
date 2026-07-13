import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'movie_detail_page.dart';
import 'youtube_player_page.dart';

class WatchLaterPage extends StatelessWidget {
  const WatchLaterPage({super.key});

  Future<void> _showRemoveDialog({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            "Remove from Watch Later",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to remove this item?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await FirebaseFirestore.instance
          .collection("watchlater")
          .doc(uid)
          .collection(type)
          .doc(id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Watch Later", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ===========================
            // MOVIES
            // ===========================
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "🎬 Watch Later Movies",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("watchlater")
                  .doc(uid)
                  .collection("movies")
                  .orderBy("savedAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Belum ada film.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final movies = snapshot.data!.docs;

                return SizedBox(
                  height: 300,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    itemCount: movies.length,

                    itemBuilder: (context, index) {
                      final movie =
                          movies[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(movie: movie),
                            ),
                          );
                        },

                        child: Container(
                          width: 170,
                          margin: const EdgeInsets.only(left: 20),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),

                                child: Image.network(
                                  "https://image.tmdb.org/t/p/w500${movie["poster_path"]}",
                                  height: 230,
                                  width: 170,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      movie["title"] ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      _showRemoveDialog(
                                        context: context,
                                        type: "movies",
                                        id: movie["id"].toString(),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.bookmark,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // ===========================
            // YOUTUBE
            // ===========================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "▶ Watch Later YouTube",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("watchlater")
                  .doc(uid)
                  .collection("videos")
                  .orderBy("savedAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Belum ada video.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final videos = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: videos.length,

                  itemBuilder: (context, index) {
                    final video = videos[index].data() as Map<String, dynamic>;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => YoutubePlayerPage(
                              videoId: video["videoId"],
                              title: video["title"],
                              thumbnailUrl: video["thumbnail"],
                              channelId: video["channelId"],
                              channelTitle: video["channelTitle"],
                            ),
                          ),
                        );
                      },

                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),

                          child: Image.network(
                            video["thumbnail"],
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),

                        title: Text(
                          video["title"],
                          style: const TextStyle(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        subtitle: Text(
                          video["channelTitle"],
                          style: const TextStyle(color: Colors.grey),
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.bookmark,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            _showRemoveDialog(
                              context: context,
                              type: "videos",
                              id: video["videoId"],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
