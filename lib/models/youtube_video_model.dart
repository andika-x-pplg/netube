class YoutubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelId;
  final String channelTitle;
  final String publishedAt;

  YoutubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelId,
    required this.channelTitle,
    required this.publishedAt,
  });

  factory YoutubeVideo.fromJson(
    Map<String, dynamic> json,
  ) {

    String videoId = '';

    if (json['id'] is Map) {
      videoId =
          json['id']['videoId'] ?? '';
    } else {
      videoId =
          json['id'] ?? '';
    }

    return YoutubeVideo(
      id: videoId,

      title:
          json['snippet']['title'] ?? '',

      thumbnailUrl:
          json['snippet']['thumbnails']
                  ['medium']['url'] ??
              '',

      channelId:
          json['snippet']
                  ['channelId'] ??
              '',

      channelTitle:
          json['snippet']
                  ['channelTitle'] ??
              '',

      publishedAt:
          json['snippet']
                  ['publishedAt'] ??
              '',
    );
  }
}