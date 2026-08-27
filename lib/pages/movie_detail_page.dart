import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';
import 'trailer_player_page.dart';
import '../services/history_service.dart';
import '../services/watch_later_service.dart';
import '../services/rating_service.dart';
import '../services/review_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/review_like_service.dart';
import '../services/reply_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/reply_like_service.dart';

class MovieDetailPage extends StatefulWidget {
  final Map movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isFavorite = false;
  bool isWatchLater = false;
  double myRating = 0;

  String selectedReviewSort = "Newest";

  double communityRating = 0;
  int totalRatings = 0;
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  bool hasReviewed = false;
  String? reviewDocId;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkFavorite();
    checkWatchLater();
    loadRatings();
    loadMyReview();
  }

  Future<void> checkFavorite() async {
    final result = await FavoriteService.isFavorite(widget.movie['id']);

    setState(() {
      isFavorite = result;
    });
  }

  Future<void> checkWatchLater() async {
    final result = await WatchLaterService.isMovieSaved(widget.movie['id']);

    setState(() {
      isWatchLater = result;
    });
  }

  Future<void> loadRatings() async {
    myRating = await RatingService.getUserRating(widget.movie['id']);

    final result = await RatingService.getCommunityRating(widget.movie['id']);

    communityRating = result["average"];
    totalRatings = result["count"];

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadMyReview() async {
    final snapshot = await ReviewService.getMyReview(widget.movie["id"]);

    if (snapshot != null) {
      reviewDocId = snapshot.id;

      final data = snapshot.data() as Map<String, dynamic>;

      myRating = (data["rating"] as num).toDouble();

      reviewController.text = data["review"];

      hasReviewed = true;

      if (mounted) {
        setState(() {});
      }
    }
  }

  // ==========================
  // buildStars()
  // ==========================

  Widget buildStars() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            index < myRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 34,
          ),
          onPressed: () async {
            myRating = (index + 1).toDouble();

            setState(() {});

            await RatingService.rateMovie(
              movieId: widget.movie['id'],
              rating: myRating,
            );

            await loadRatings();

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("You rated ${index + 1} ⭐")));
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        "https://image.tmdb.org/t/p/w500${widget.movie['poster_path']}";

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      body: CustomScrollView(
        slivers: [
          // =====================
          // NETFLIX HEADER
          // =====================
          SliverAppBar(
            expandedHeight: 500,

            pinned: true,

            backgroundColor: const Color(0xFF050B18),

            leading: Container(
              margin: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),

              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,

                children: [
                  Hero(
                    tag: widget.movie['id'].toString(),

                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,

                        end: Alignment.bottomCenter,

                        colors: [Colors.transparent, Color(0xFF050B18)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================
          // CONTENT
          // =====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // TITLE
                  Text(
                    widget.movie['title'] ?? "No Title",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // DATE
                  Text(
                    widget.movie['release_date'] ?? "Unknown Date",

                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // RATING BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 18),

                        const SizedBox(width: 6),

                        Text(
                          "${widget.movie['vote_average'].toStringAsFixed(1)} IMDb",

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ======================
                  // NETUBE COMMUNITY RATING
                  // ======================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Community Netube",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedReviewSort,

                            dropdownColor: const Color(0xFF111827),

                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                            ),

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: "Newest",
                                child: Text("Newest"),
                              ),
                              DropdownMenuItem(
                                value: "Oldest",
                                child: Text("Oldest"),
                              ),
                              DropdownMenuItem(
                                value: "Most Liked",
                                child: Text("Most Liked"),
                              ),
                              DropdownMenuItem(
                                value: "Highest Rating",
                                child: Text("Highest Rating"),
                              ),
                            ],

                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                selectedReviewSort = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),

                      const SizedBox(width: 8),

                      Text(
                        communityRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "($totalRatings ratings)",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ======================
                  // YOUR RATING
                  // ======================
                  const Text(
                    "Your Rating",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  buildStars(),

                  const SizedBox(height: 30),

                  // BUTTONS
                  Row(
                    children: [
                      // PLAY
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          onPressed: () async {
                            final trailerKey = await ApiService.getMovieTrailer(
                              widget.movie['id'],
                            );

                            if (trailerKey != null) {
                              // ==========================
                              // SIMPAN KE WATCH HISTORY
                              // ==========================
                              await HistoryService.addMovieHistory(
                                movie: widget.movie,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TrailerPlayerPage(youtubeKey: trailerKey),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Trailer not found"),
                                ),
                              );
                            }
                          },

                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),

                          label: const Text(
                            "Play Trailer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // FAVORITE
                      GestureDetector(
                        onTap: () async {
                          if (isFavorite) {
                            await FavoriteService.removeFavorite(
                              widget.movie['id'],
                            );

                            setState(() {
                              isFavorite = false;
                            });
                          } else {
                            await FavoriteService.addFavorite(widget.movie);

                            setState(() {
                              isFavorite = true;
                            });
                          }
                        },

                        child: Container(
                          width: 55,
                          height: 55,

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,

                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ], // children Row
                  ), // Row

                  const SizedBox(height: 35),

                  // WATCH LATER
                  GestureDetector(
                    onTap: () async {
                      if (isWatchLater) {
                        await WatchLaterService.removeMovie(widget.movie['id']);

                        setState(() {
                          isWatchLater = false;
                        });
                      } else {
                        await WatchLaterService.addMovie(widget.movie);

                        setState(() {
                          isWatchLater = true;
                        });
                      }
                    },

                    child: Container(
                      width: 55,
                      height: 55,

                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Icon(
                        isWatchLater
                            ? Icons.watch_later
                            : Icons.watch_later_outlined,
                        color: isWatchLater ? Colors.orange : Colors.white,
                      ),
                    ),
                  ),

                  // OVERVIEW TITLE
                  const Text(
                    "Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // OVERVIEW
                  Text(
                    widget.movie['overview'] ?? "No description",

                    style: TextStyle(
                      color: Colors.grey.shade300,

                      fontSize: 16,

                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ===================================
                  // WRITE REVIEW
                  // ===================================
                  const Text(
                    "Write Review",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: reviewController,
                    maxLines: 4,

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: "Share your opinion...",

                      hintStyle: const TextStyle(color: Colors.grey),

                      filled: true,
                      fillColor: const Color(0xFF111827),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size.fromHeight(55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          onPressed: () async {
                            print("STEP 1");

                            if (reviewController.text.trim().isEmpty) {
                              print("TEXT KOSONG");
                              return;
                            }

                            print("STEP 2");

                            if (hasReviewed) {
                              print("UPDATE REVIEW");

                              await ReviewService.updateReview(
                                movieId: widget.movie["id"],
                                rating: myRating,
                                review: reviewController.text.trim(),
                              );
                            } else {
                              print("ADD REVIEW");

                              await ReviewService.addReview(
                                movieId: widget.movie["id"],
                                rating: myRating,
                                review: reviewController.text.trim(),
                              );
                            }

                            print("STEP 3");

                            await loadMyReview();

                            print("STEP 4");

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("DONE")),
                            );
                          },

                          child: Text(
                            hasReviewed ? "Update Review" : "Submit Review",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      if (hasReviewed) ...[
                        const SizedBox(width: 12),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text("Delete Review"),
                                  content: const Text(
                                    "Are you sure you want to delete this review?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text("Cancel"),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),

                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },

                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm != true) return;

                            await ReviewService.deleteReview(
                              widget.movie["id"],
                            );

                            await loadMyReview();

                            reviewController.clear();

                            setState(() {
                              hasReviewed = false;
                              myRating = 0;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Review deleted")),
                            );
                          },
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Community Reviews",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: ReviewService.getReviews(
                      widget.movie["id"],
                      selectedReviewSort,
                    ),

                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text(
                          "No reviews yet.",
                          style: TextStyle(color: Colors.white70),
                        );
                      }

                      final reviews = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: reviews.length,

                        itemBuilder: (context, index) {
                          final review =
                              reviews[index].data() as Map<String, dynamic>;

                          final reviewOwnerUid = reviews[index].id;

                          print("Review Owner UID: $reviewOwnerUid");

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),

                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),

                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.red,

                                      child: Text(
                                        (review["username"] ?? "U")
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase(),

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            review["username"],

                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Text(
                                            review["createdAt"] == null
                                                ? "Just now"
                                                : timeago.format(
                                                    (review["createdAt"]
                                                            as Timestamp)
                                                        .toDate(),
                                                  ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),

                                          Row(
                                            children: List.generate(
                                              review["rating"].toInt(),

                                              (i) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  review["review"],

                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    // ========================
                                    // LIKE BUTTON
                                    // ========================
                                    ReviewLikeButton(
                                      movieId: widget.movie["id"],
                                      reviewOwnerUid: reviewOwnerUid,
                                    ),

                                    const SizedBox(width: 10),

                                    // ========================
                                    // TOTAL LIKE
                                    // ========================
                                    Text(
                                      "❤️ ${review["likeCount"] ?? 0}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.reply,
                                        color: Colors.blue,
                                      ),
                                      label: const Text(
                                        "Reply",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        replyController.clear();

                                        showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              backgroundColor: const Color(
                                                0xFF111827,
                                              ),

                                              title: const Text(
                                                "Reply",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),

                                              content: TextField(
                                                controller: replyController,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),

                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          "Write a reply...",
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                              ),

                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),

                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (replyController.text
                                                        .trim()
                                                        .isEmpty) {
                                                      return;
                                                    }

                                                    await ReplyService.addReply(
                                                      movieId:
                                                          widget.movie["id"],
                                                      reviewOwnerUid:
                                                          reviewOwnerUid,
                                                      reply: replyController
                                                          .text
                                                          .trim(),
                                                    );

                                                    Navigator.pop(context);
                                                  },

                                                  child: const Text("Send"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                // ========================
                                // NAMA USER YANG LIKE
                                // ========================
                                StreamBuilder<QuerySnapshot>(
                                  stream: ReviewLikeService.getLikerNames(
                                    movieId: widget.movie["id"],
                                    reviewOwnerUid: reviewOwnerUid,
                                  ),

                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    final filteredLikers = snapshot.data!.docs
                                        .where((doc) {
                                          final data =
                                              doc.data()
                                                  as Map<String, dynamic>;

                                          final likerUid = data["uid"]
                                              ?.toString();

                                          // Kalau yang like adalah pemilik review sendiri,
                                          // jangan tampilkan namanya
                                          return likerUid != reviewOwnerUid;
                                        })
                                        .toList();

                                    final allLikerNames = filteredLikers
                                        .map((doc) {
                                          final data =
                                              doc.data()
                                                  as Map<String, dynamic>;

                                          return data["username"]?.toString();
                                        })
                                        .where(
                                          (name) =>
                                              name != null && name!.isNotEmpty,
                                        )
                                        .cast<String>()
                                        .toList();

                                    // Ambil hanya 5 nama pertama
                                    final displayedNames = allLikerNames
                                        .take(5)
                                        .toList();

                                    // Apakah liker lebih dari 5?
                                    final hasMore = allLikerNames.length > 5;

                                    if (displayedNames.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        "Disukai oleh ${displayedNames.join(", ")}${hasMore ? ", More..." : ""}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // ==========================
                                // REPLIES
                                // ==========================
                                StreamBuilder<QuerySnapshot>(
                                  stream: ReplyService.getReplies(
                                    movieId: widget.movie["id"],
                                    reviewOwnerUid: reviewOwnerUid,
                                  ),

                                  builder: (context, replySnapshot) {
                                    if (replySnapshot.hasError) {
                                      return Text(
                                        "Gagal memuat balasan",
                                        style: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 12,
                                        ),
                                      );
                                    }

                                    if (replySnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.only(left: 45),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    }

                                    if (!replySnapshot.hasData ||
                                        replySnapshot.data!.docs.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    final replies = replySnapshot.data!.docs;

                                    return Column(
                                      children: replies.map((replyDoc) {
                                        final reply =
                                            replyDoc.data()
                                                as Map<String, dynamic>;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: 35,
                                            top: 8,
                                          ),

                                          padding: const EdgeInsets.all(12),

                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0B1220),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),

                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Colors.red,

                                                child: Text(
                                                  (reply["username"] ?? "U")
                                                      .toString()
                                                      .substring(0, 1)
                                                      .toUpperCase(),

                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            reply["username"] ??
                                                                "User",
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                ),
                                                          ),
                                                        ),

                                                        // ==========================
                                                        // DELETE REPLY
                                                        // ==========================
                                                        if (reply["uid"] ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid)
                                                          IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color: Colors.red,
                                                              size: 18,
                                                            ),

                                                            onPressed: () async {
                                                              final confirm = await showDialog<bool>(
                                                                context:
                                                                    context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                      "Delete Reply",
                                                                    ),

                                                                    content:
                                                                        const Text(
                                                                          "Are you sure you want to delete this reply?",
                                                                        ),

                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                            context,
                                                                            false,
                                                                          );
                                                                        },

                                                                        child: const Text(
                                                                          "Cancel",
                                                                        ),
                                                                      ),

                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                        ),

                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                            context,
                                                                            true,
                                                                          );
                                                                        },

                                                                        child: const Text(
                                                                          "Delete",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );

                                                              if (confirm !=
                                                                  true)
                                                                return;

                                                              await ReplyService.deleteReply(
                                                                movieId: widget
                                                                    .movie["id"],
                                                                reviewOwnerUid:
                                                                    reviewOwnerUid,
                                                                replyId:
                                                                    replyDoc.id,
                                                              );
                                                            },
                                                          ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 4),

                                                    Text(
                                                      reply["reply"] ?? "",
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        height: 1.4,
                                                        fontSize: 13,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 8),

                                                    const SizedBox(height: 6),

                                                    // ==========================
                                                    // NESTED REPLIES
                                                    // ==========================
                                                    StreamBuilder<
                                                      QuerySnapshot
                                                    >(
                                                      stream:
                                                          ReplyService.getNestedReplies(
                                                            movieId: widget
                                                                .movie["id"],
                                                            reviewOwnerUid:
                                                                reviewOwnerUid,
                                                            parentReplyId:
                                                                replyDoc.id,
                                                          ),

                                                      builder: (context, nestedSnapshot) {
                                                        if (nestedSnapshot
                                                            .hasError) {
                                                          return const SizedBox.shrink();
                                                        }

                                                        if (!nestedSnapshot
                                                                .hasData ||
                                                            nestedSnapshot
                                                                .data!
                                                                .docs
                                                                .isEmpty) {
                                                          return const SizedBox.shrink();
                                                        }

                                                        final nestedReplies =
                                                            nestedSnapshot
                                                                .data!
                                                                .docs;

                                                        return Column(
                                                          children: nestedReplies.map((
                                                            nestedDoc,
                                                          ) {
                                                            final nested =
                                                                nestedDoc.data()
                                                                    as Map<
                                                                      String,
                                                                      dynamic
                                                                    >;

                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    left: 25,
                                                                    top: 8,
                                                                  ),

                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    10,
                                                                  ),

                                                              decoration: BoxDecoration(
                                                                color:
                                                                    const Color(
                                                                      0xFF080E1A,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),

                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,

                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 14,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blueGrey,

                                                                    child: Text(
                                                                      (nested["username"] ??
                                                                              "U")
                                                                          .toString()
                                                                          .substring(
                                                                            0,
                                                                            1,
                                                                          )
                                                                          .toUpperCase(),

                                                                      style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),

                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,

                                                                      children: [
                                                                        Text(
                                                                          nested["username"] ??
                                                                              "User",

                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),

                                                                        const SizedBox(
                                                                          height:
                                                                              3,
                                                                        ),

                                                                        Text(
                                                                          nested["reply"] ??
                                                                              "",

                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.white70,
                                                                            fontSize:
                                                                                12,
                                                                            height:
                                                                                1.4,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }).toList(),
                                                        );
                                                      },
                                                    ),

                                                    // ==========================
                                                    // JUMLAH LIKE REPLY
                                                    // ==========================
                                                    Row(
                                                      children: [
                                                        ReplyLikeButton(
                                                          movieId: widget
                                                              .movie["id"],
                                                          reviewOwnerUid:
                                                              reviewOwnerUid,
                                                          replyId: replyDoc.id,
                                                        ),

                                                        const SizedBox(
                                                          width: 12,
                                                        ),

                                                        TextButton.icon(
                                                          onPressed: () {
                                                            replyController
                                                                .clear();

                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      const Color(
                                                                        0xFF111827,
                                                                      ),

                                                                  title: Text(
                                                                    "Reply to ${reply["username"] ?? "User"}",
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),

                                                                  content: TextField(
                                                                    controller:
                                                                        replyController,
                                                                    maxLines: 3,
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    decoration: const InputDecoration(
                                                                      hintText:
                                                                          "Write a reply...",
                                                                      hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: const Text(
                                                                        "Cancel",
                                                                      ),
                                                                    ),

                                                                    ElevatedButton(
                                                                      onPressed: () async {
                                                                        final text = replyController
                                                                            .text
                                                                            .trim();

                                                                        if (text
                                                                            .isEmpty)
                                                                          return;

                                                                        await ReplyService.addNestedReply(
                                                                          movieId:
                                                                              widget.movie["id"],
                                                                          reviewOwnerUid:
                                                                              reviewOwnerUid,
                                                                          parentReplyId:
                                                                              replyDoc.id,
                                                                          reply:
                                                                              text,
                                                                        );

                                                                        if (!context
                                                                            .mounted)
                                                                          return;

                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },

                                                                      child: const Text(
                                                                        "Send",
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            Icons.reply,
                                                            size: 17,
                                                            color: Colors.blue,
                                                          ),
                                                          label: const Text(
                                                            "Reply",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
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
          ),
        ],
      ),
    );
  }
}

// ==========================
// WIDGET KHUSUS LIKE
// ==========================
class ReviewLikeButton extends StatefulWidget {
  final int movieId;
  final String reviewOwnerUid;

  const ReviewLikeButton({
    super.key,
    required this.movieId,
    required this.reviewOwnerUid,
  });

  @override
  State<ReviewLikeButton> createState() => _ReviewLikeButtonState();
}

class _ReviewLikeButtonState extends State<ReviewLikeButton> {
  bool liked = false;
  bool loading = true;
  bool animating = false;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final result = await ReviewLikeService.isLiked(
      movieId: widget.movieId,
      reviewOwnerUid: widget.reviewOwnerUid,
    );

    if (!mounted) return;

    setState(() {
      liked = result;
      loading = false;
    });
  }

  Future<void> _toggleLike() async {
    if (loading || animating) return;

    final newLiked = !liked;

    // Langsung ubah icon supaya responsif
    setState(() {
      liked = newLiked;
      animating = true;
    });

    try {
      if (newLiked) {
        await ReviewLikeService.likeReview(
          movieId: widget.movieId,
          reviewOwnerUid: widget.reviewOwnerUid,
        );
      } else {
        await ReviewLikeService.unlikeReview(
          movieId: widget.movieId,
          reviewOwnerUid: widget.reviewOwnerUid,
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Kalau Firebase gagal, kembalikan kondisi sebelumnya
      setState(() {
        liked = !newLiked;
      });
    }

    await Future.delayed(const Duration(milliseconds: 220));

    if (!mounted) return;

    setState(() {
      animating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(width: 80, height: 40);
    }

    return TextButton.icon(
      onPressed: _toggleLike,

      icon: AnimatedScale(
        scale: animating ? 1.35 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,

        child: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
      ),

      label: Text(
        liked ? "Liked" : "Like",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

// ==========================
// WIDGET LIKE REPLY
// ==========================
class ReplyLikeButton extends StatefulWidget {
  final int movieId;
  final String reviewOwnerUid;
  final String replyId;

  const ReplyLikeButton({
    super.key,
    required this.movieId,
    required this.reviewOwnerUid,
    required this.replyId,
  });

  @override
  State<ReplyLikeButton> createState() => _ReplyLikeButtonState();
}

class _ReplyLikeButtonState extends State<ReplyLikeButton> {
  bool liked = false;
  bool loading = true;
  bool animating = false;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  // ==========================
  // CEK STATUS LIKE
  // ==========================
  Future<void> _loadLikeStatus() async {
    final result = await ReplyLikeService.isLiked(
      movieId: widget.movieId,
      reviewOwnerUid: widget.reviewOwnerUid,
      replyId: widget.replyId,
    );

    if (!mounted) return;

    setState(() {
      liked = result;
      loading = false;
    });
  }

  // ==========================
  // LIKE / UNLIKE
  // ==========================
  Future<void> _toggleLike() async {
    if (loading || animating) return;

    final newLiked = !liked;

    setState(() {
      liked = newLiked;
      animating = true;
    });

    try {
      if (newLiked) {
        await ReplyLikeService.likeReply(
          movieId: widget.movieId,
          reviewOwnerUid: widget.reviewOwnerUid,
          replyId: widget.replyId,
        );
      } else {
        await ReplyLikeService.unlikeReply(
          movieId: widget.movieId,
          reviewOwnerUid: widget.reviewOwnerUid,
          replyId: widget.replyId,
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Kalau Firebase gagal,
      // kembalikan status sebelumnya
      setState(() {
        liked = !newLiked;
      });
    }

    await Future.delayed(const Duration(milliseconds: 220));

    if (!mounted) return;

    setState(() {
      animating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(width: 50, height: 30);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: ReplyLikeService.getLikes(
        movieId: widget.movieId,
        reviewOwnerUid: widget.reviewOwnerUid,
        replyId: widget.replyId,
      ),

      builder: (context, snapshot) {
        final totalLikes = snapshot.data?.docs.length ?? 0;

        return InkWell(
          onTap: _toggleLike,
          borderRadius: BorderRadius.circular(20),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                AnimatedScale(
                  scale: animating ? 1.4 : 1.0,

                  duration: const Duration(milliseconds: 180),

                  curve: Curves.easeOutBack,

                  child: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,

                    color: Colors.red,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  "$totalLikes",

                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
