import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String userId;
  final String title;
  final String storageUrl;
  final String netlifyUrl;
  final String shortUrl;      // ADD THIS
  final int size;
  final int views;
  final int uniqueViews;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.storageUrl,
    required this.netlifyUrl,
    required this.shortUrl,     // REQUIRED
    required this.size,
    required this.views,
    required this.uniqueViews,
    required this.createdAt,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map, String docId) {
    return VideoModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      storageUrl: map['storageUrl'] ?? '',
      netlifyUrl: map['netlifyUrl'] ?? '',
      shortUrl: map['shortUrl'] ?? '',    // NEW
      size: (map['size'] ?? 0) as int,
      views: (map['views'] ?? 0) as int,
      uniqueViews: (map['uniqueViews'] ?? 0) as int,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'storageUrl': storageUrl,
      'netlifyUrl': netlifyUrl,
      'shortUrl': shortUrl,
      'size': size,
      'views': views,
      'uniqueViews': uniqueViews,
      'createdAt': createdAt,
    };
  }
}
