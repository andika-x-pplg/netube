import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/movie_card.dart';

import '../pages/profile_page.dart';
import '../pages/featured_movies_page.dart';
import '../pages/trending_now_page.dart';

import '../pages/search_page.dart';
import '../services/api_service.dart';

import '../pages/genre_movies_page.dart';
import '../widgets/movie_shimmer.dart';

import '../pages/favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController featuredController = ScrollController();
  final ScrollController trendingController = ScrollController();
  final ScrollController actionController = ScrollController();
  final ScrollController horrorController = ScrollController();
  final ScrollController animationController = ScrollController();
  final ScrollController comedyController = ScrollController();
  final ScrollController romanceController = ScrollController();
  final ScrollController sciFiController = ScrollController();
  final ScrollController animeController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      drawer: const CustomDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),
        elevation: 0,

        // MENU BUTTON
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),

            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        centerTitle: true,

        // NETUBE GRADIENT
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.red, Colors.orange],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),

          child: const Text(
            "Netube",

            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // PROFILE ICON
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // SEARCH BAR
              TextField(
                readOnly: true,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: "Search movies...",

                  hintStyle: const TextStyle(color: Colors.grey),

                  prefixIcon: const Icon(Icons.search, color: Colors.grey),

                  filled: true,
                  fillColor: Colors.white10,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Featured Movies",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeaturedMoviesPage(),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT BUTTON
                      GestureDetector(
                        onTap: () {
                          featuredController.animateTo(
                            featuredController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT BUTTON
                      GestureDetector(
                        onTap: () {
                          featuredController.animateTo(
                            featuredController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MOVIE LIST
              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getFeaturedMovies(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: featuredController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // TRENDING NOW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Trending Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrendingNowPage(),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT BUTTON
                      GestureDetector(
                        onTap: () {
                          trendingController.animateTo(
                            trendingController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT BUTTON
                      GestureDetector(
                        onTap: () {
                          trendingController.animateTo(
                            trendingController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MOVIE LIST
              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getTrendingMovies(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: trendingController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= ACTION =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Action",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                                  GenreMoviesPage(title: "Action", genreId: 27),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          actionController.animateTo(
                            actionController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          actionController.animateTo(
                            actionController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(27),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: actionController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= HORROR =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Horrors",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => GenreMoviesPage(
                                title: "Horrors",
                                genreId: 28,
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          horrorController.animateTo(
                            horrorController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          horrorController.animateTo(
                            horrorController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(28),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: horrorController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= ANIMATION =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Animation",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => GenreMoviesPage(
                                title: "Animation",
                                genreId: 16,
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          animationController.animateTo(
                            animationController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          animationController.animateTo(
                            animationController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(16),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: animationController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= COMEDY =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Comedy",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                                  GenreMoviesPage(title: "Comedy", genreId: 35),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          comedyController.animateTo(
                            comedyController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          comedyController.animateTo(
                            comedyController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(35),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: comedyController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= ROMANCE =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Romance",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => GenreMoviesPage(
                                title: "Romance",
                                genreId: 10749,
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          romanceController.animateTo(
                            romanceController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          romanceController.animateTo(
                            romanceController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(10749),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: romanceController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= SCI-FI =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Sci-Fi",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => GenreMoviesPage(
                                title: "Sci-Fi",
                                genreId: 878,
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          sciFiController.animateTo(
                            sciFiController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          sciFiController.animateTo(
                            sciFiController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(878),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: sciFiController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ================= ANIME =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Anime",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                                  GenreMoviesPage(title: "Anime", genreId: 16),
                            ),
                          );
                        },

                        child: const Text(
                          "See All",

                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // LEFT
                      GestureDetector(
                        onTap: () {
                          animeController.animateTo(
                            animeController.offset - 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT
                      GestureDetector(
                        onTap: () {
                          animeController.animateTo(
                            animeController.offset + 200,

                            duration: const Duration(milliseconds: 400),

                            curve: Curves.easeInOut,
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,

                child: FutureBuilder(
                  future: ApiService.getMoviesByGenre(16),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const MovieShimmer();
                    }

                    final movies = snapshot.data!;

                    return ListView.builder(
                      controller: animeController,

                      scrollDirection: Axis.horizontal,

                      itemCount: movies.length,

                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(movie: movie);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const BottomNavbar(),
    );
  }
}
