import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final Timestamp? createdAt;

  AppNotification({
    required this.userId,
    required this.title,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'],
    );
  }
}
