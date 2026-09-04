import 'package:cloud_firestore/cloud_firestore.dart';

class NetubeContent {
  const NetubeContent({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.title,
    required this.description,
    required this.category,
    required this.visibility,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.createdAt,
  });

  final String id;
  final String ownerUid;
  final String ownerName;
  final String title;
  final String description;
  final String category;
  final String visibility;
  final String thumbnailUrl;
  final String videoUrl;
  final DateTime? createdAt;

  factory NetubeContent.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final timestamp = data['createdAt'];
    return NetubeContent(
      id: document.id,
      ownerUid: data['ownerUid']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? 'Creator',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      visibility: data['visibility']?.toString() ?? 'private',
      thumbnailUrl: data['thumbnailUrl']?.toString() ?? '',
      videoUrl: data['videoUrl']?.toString() ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
