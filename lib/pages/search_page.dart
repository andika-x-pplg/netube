import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/netube_theme.dart';
import '../widgets/movie_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  List movies = [];
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchMovie() async {
    if (searchController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await ApiService.searchMovies(
        searchController.text.trim(),
      );
      if (mounted) setState(() => movies = result);
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load search results.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Search',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: TextField(
              controller: searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchMovie(),
              decoration: InputDecoration(
                hintText: 'Movies, titles, genres...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() => movies = []);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: error != null
                ? Center(
                    child: Text(
                      error!,
                      style: const TextStyle(color: NetubeColors.textSecondary),
                    ),
                  )
                : movies.isEmpty
                ? const _SearchEmpty()
                : GridView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                          childAspectRatio: .57,
                        ),
                    itemBuilder: (_, index) => MovieCard(movie: movies[index]),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.movie_filter_outlined, size: 48, color: Colors.white24),
        SizedBox(height: 12),
        Text(
          'Find your next story',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 5),
        Text(
          'Search the Netube movie catalog',
          style: TextStyle(color: NetubeColors.textSecondary),
        ),
      ],
    ),
  );
}
