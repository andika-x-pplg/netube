import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/youtube_video_model.dart';

class YoutubeService {
  final String _apiKey = 'AIzaSyC73tIbrfgQ-mA0D1m30WUJutYt0NVeRUg';
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // Fungsi untuk mengambil video populer / trending umum
  Future<List<YoutubeVideo>> fetchTrendingVideos() async {
    final url = Uri.parse(
      '$_baseUrl/videos?part=snippet&chart=mostPopular&maxResults=10&regionCode=ID&key=$_apiKey',
    );

    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> items = data['items'];
      return items.map((item) => YoutubeVideo.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat video trending');
    }
  }

  // Fungsi untuk mengambil video berdasarkan kategori teks (Music, Gaming, Anime, dll)
  Future<List<YoutubeVideo>> fetchVideosByCategory(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search?part=snippet&q=$query&type=video&maxResults=10&regionCode=ID&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> items = data['items'];
      return items.map((item) => YoutubeVideo.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat video kategori $query');
    }
  }

  // Fungsi untuk mengambil video live streaming
  Future<List<YoutubeVideo>> fetchLiveVideos() async {
    final url = Uri.parse(
      '$_baseUrl/search?part=snippet&q=live indonesia&type=video&eventType=live&maxResults=20&key=$_apiKey',
    );

    final response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> items = data['items'];

      return items.map((item) => YoutubeVideo.fromJson(item)).toList();
    }

    throw Exception('Gagal memuat live stream');
  }

  // Fungsi untuk mengambil video berdasarkan channel ID
  Future<List<YoutubeVideo>> fetchChannelVideos(String channelId) async {
    final url = Uri.parse(
      '$_baseUrl/search?part=snippet&channelId=$channelId&type=video&maxResults=20&order=date&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> items = data['items'];

      return items.map((item) => YoutubeVideo.fromJson(item)).toList();
    }

    throw Exception('Gagal memuat video channel');
  }
}
