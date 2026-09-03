import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'search_page.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Explore',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    ),
    body: FutureBuilder<List<dynamic>>(
      future: ApiService.getFeaturedMovies(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Unable to load movies'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: snapshot.data!.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 20,
            childAspectRatio: .57,
          ),
          itemBuilder: (_, index) => MovieCard(movie: snapshot.data![index]),
        );
      },
    ),
  );
}
