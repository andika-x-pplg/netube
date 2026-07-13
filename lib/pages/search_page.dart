import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/movie_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  List movies = [];

  bool isLoading = false;

  // SEARCH FUNCTION
  Future<void> searchMovie() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.searchMovies(searchController.text);

    setState(() {
      movies = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),

        title: const Text(
          "Search Movies",

          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              controller: searchController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Search movie...",

                hintStyle: const TextStyle(color: Colors.grey),

                filled: true,

                fillColor: Colors.white10,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),

                suffixIcon: IconButton(
                  onPressed: searchMovie,

                  icon: const Icon(Icons.search, color: Colors.orange),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // LOADING
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // MOVIES
            else
              Expanded(
                child: GridView.builder(
                  itemCount: movies.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,

                    childAspectRatio: 0.58,
                  ),

                  itemBuilder: (context, index) {
                    final movie = movies[index];

                    return MovieCard(movie: movie);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
