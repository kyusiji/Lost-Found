import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderUid;
  final String senderName;
  final String receiverUid;
  final String message;
  final String? itemId; // Reference to item being discussed
  final DateTime? createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderUid,
    required this.senderName,
    required this.receiverUid,
    required this.message,
    this.itemId,
    this.createdAt,
    required this.isRead,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      conversationId: map['conversationId'] as String? ?? '',
      senderUid: map['senderUid'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      receiverUid: map['receiverUid'] as String? ?? '',
      message: map['message'] as String? ?? '',
      itemId: map['itemId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderUid': senderUid,
      'senderName': senderName,
      'receiverUid': receiverUid,
      'message': message,
      'itemId': itemId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderUid,
    String? senderName,
    String? receiverUid,
    String? message,
    String? itemId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderUid: senderUid ?? this.senderUid,
      senderName: senderName ?? this.senderName,
      receiverUid: receiverUid ?? this.receiverUid,
      message: message ?? this.message,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() => 'MessageModel(id: $id, conversationId: $conversationId)';
}

class ConversationModel {
  final String id;
  final String user1Uid;
  final String user1Name;
  final String user2Uid;
  final String user2Name;
  final String? itemId;
  final String itemTitle;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.user1Uid,
    required this.user1Name,
    required this.user2Uid,
    required this.user2Name,
    this.itemId,
    required this.itemTitle,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(String id, Map<String, dynamic> map) {
    return ConversationModel(
      id: id,
      user1Uid: map['user1Uid'] as String? ?? '',
      user1Name: map['user1Name'] as String? ?? '',
      user2Uid: map['user2Uid'] as String? ?? '',
      user2Name: map['user2Name'] as String? ?? '',
      itemId: map['itemId'] as String?,
      itemTitle: map['itemTitle'] as String? ?? '',
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: map['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Uid': user1Uid,
      'user1Name': user1Name,
      'user2Uid': user2Uid,
      'user2Name': user2Name,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
    };
  }

  @override
  String toString() => 'ConversationModel(id: $id, with: $user2Name)';
}
