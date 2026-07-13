import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  // API KEY TMDB
  static const String apiKey =
      'ff766181e957ab73a559ee08c3cbfc3f';

  // BASE URL
  static const String baseUrl =
      'https://api.themoviedb.org/3';

  // =========================
  // TRENDING MOVIES
  // =========================
  static Future<List<dynamic>>
      getTrendingMovies() async {

    final response = await http.get(
      Uri.parse(
        '$baseUrl/trending/movie/day?api_key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      return data['results'];

    } else {

      throw Exception(
        'Failed to load trending movies',
      );
    }
  }

  // =========================
  // FEATURED / POPULAR MOVIES
  // =========================
  static Future<List<dynamic>>
      getFeaturedMovies() async {

    final response = await http.get(
      Uri.parse(
        '$baseUrl/movie/popular?api_key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      return data['results'];

    } else {

      throw Exception(
        'Failed to load featured movies',
      );
    }
  }

  // =========================
  // SEARCH MOVIES
  // =========================
  static Future<List<dynamic>>
      searchMovies(String query) async {

    final response = await http.get(
      Uri.parse(
        '$baseUrl/search/movie?api_key=$apiKey&query=$query',
      ),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      return data['results'];

    } else {

      throw Exception(
        'Failed to search movies',
      );
    }
  }

  // =========================
  // GET MOVIE TRAILER
  // =========================
  static Future<String?>
    getMovieTrailer(int movieId) async {

  final response = await http.get(
    Uri.parse(
      '$baseUrl/movie/$movieId/videos?api_key=$apiKey',
    ),
  );

  if (response.statusCode == 200) {

    final data =
        jsonDecode(response.body);

    final results =
        data['results'];

    for (var video in results) {

      if (video['site'] == 'YouTube' &&
          video['type'] == 'Trailer') {

        return video['key'];
      }
    }
  }

  return null;
}

 // =========================
  // MOVIES BY GENRE
  // =========================
  static Future<List<dynamic>> getMoviesByGenre(int genreId) async {

    final response = await http.get(
      Uri.parse(
        '$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId',
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['results'];

    } else {

      throw Exception('Failed to load genre movies');
    }
  }
}