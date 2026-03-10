import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/models/message_model.dart';
import 'package:lost_and_found/services/notification_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._();
  factory MessageService() => _instance;
  MessageService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// Generate conversation ID (sorted UIDs to ensure consistency)
  String _generateConversationId(String user1Uid, String user2Uid) {
    final uids = [user1Uid, user2Uid];
    uids.sort();
    return '${uids[0]}_${uids[1]}';
  }

  /// Send message
  Future<void> sendMessage({
    required String senderUid,
    required String senderName,
    required String receiverUid,
    required String receiverName,
    required String message,
    String? itemId,
    String? itemTitle,
  }) async {
    try {
      final conversationId = _generateConversationId(senderUid, receiverUid);

      // Create message
      final messageData = MessageModel(
        id: '',
        conversationId: conversationId,
        senderUid: senderUid,
        senderName: senderName,
        receiverUid: receiverUid,
        message: message,
        itemId: itemId,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('messages').add(messageData.toMap());

      // Update or create conversation
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final conversationExists = await conversationRef.get();

      if (conversationExists.exists) {
        // Update existing conversation
        await conversationRef.update({
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new conversation
        await conversationRef.set({
          'user1Uid': senderUid,
          'user1Name': senderName,
          'user2Uid': receiverUid,
          'user2Name': receiverName,
          'itemId': itemId,
          'itemTitle': itemTitle ?? '',
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': 1,
        });
      }

      // Send notification
      await _notificationService.notifyNewMessage(receiverUid, senderName);

      print('✅ Message sent');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Get conversation messages
  Future<List<MessageModel>> getConversationMessages(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching messages: $e');
      return [];
    }
  }

  /// Stream conversation messages
  Stream<List<MessageModel>> streamConversationMessages(String conversationId) {
    try {
      return _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print('❌ Error streaming messages: $e');
      return Stream.value([]);
    }
  }

  /// Get user's conversations
  Future<List<ConversationModel>> getUserConversations(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where(Filter.or(
            Filter('user1Uid', isEqualTo: uid),
            Filter('user2Uid', isEqualTo: uid),
          ))
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching conversations: $e');
      return [];
    }
  }

  /// Stream user's conversations
  Stream<List<ConversationModel>> streamUserConversations(String uid) {
    try {
      return _firestore
          .collection('conversations')
          .where(Filter.or(
            Filter('user1Uid', isEqualTo: uid),
            Filter('user2Uid', isEqualTo: uid),
          ))
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print('❌ Error streaming conversations: $e');
      return Stream.value([]);
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String receiverUid) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverUid', isEqualTo: receiverUid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('✅ Messages marked as read');
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
      print('✅ Message deleted');
    } catch (e) {
      print('❌ Error deleting message: $e');
    }
  }

  /// Get conversation by ID
  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final doc = await _firestore.collection('conversations').doc(conversationId).get();
      if (!doc.exists) return null;
      return ConversationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error fetching conversation: $e');
      return null;
    }
  }
}
