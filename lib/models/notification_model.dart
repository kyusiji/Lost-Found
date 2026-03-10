import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String recipientUid; // User who receives notification
  final String type; // 'item_claimed', 'item_handed_over', 'message'
  final String title;
  final String body;
  final String? itemId; // Reference to item if applicable
  final String? relatedUserUid; // User who triggered notification
  final String? relatedUserName;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    this.itemId,
    this.relatedUserUid,
    this.relatedUserName,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      recipientUid: map['recipientUid'] as String? ?? '',
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      itemId: map['itemId'] as String?,
      relatedUserUid: map['relatedUserUid'] as String?,
      relatedUserName: map['relatedUserName'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientUid': recipientUid,
      'type': type,
      'title': title,
      'body': body,
      'itemId': itemId,
      'relatedUserUid': relatedUserUid,
      'relatedUserName': relatedUserName,
      'isRead': isRead,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientUid,
    String? type,
    String? title,
    String? body,
    String? itemId,
    String? relatedUserUid,
    String? relatedUserName,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientUid: recipientUid ?? this.recipientUid,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      itemId: itemId ?? this.itemId,
      relatedUserUid: relatedUserUid ?? this.relatedUserUid,
      relatedUserName: relatedUserName ?? this.relatedUserName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'NotificationModel(id: $id, type: $type, isRead: $isRead)';
}
