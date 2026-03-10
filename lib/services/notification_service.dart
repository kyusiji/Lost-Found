import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create notification for item claimed
  Future<void> notifyItemClaimed(
    String itemId,
    String recipientUid,
    String claimedByUid,
    String claimedByName,
    String itemTitle,
  ) async {
    try {
      final notification = NotificationModel(
        id: '',
        recipientUid: recipientUid,
        type: 'item_claimed',
        title: 'Item Claimed',
        body: '$claimedByName claimed your "$itemTitle"',
        itemId: itemId,
        relatedUserUid: claimedByUid,
        relatedUserName: claimedByName,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
      print('✅ Notification sent: Item claimed');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Create notification for item handed over
  Future<void> notifyItemHandedOver(
    String itemId,
    String recipientUid,
    String itemTitle,
  ) async {
    try {
      final notification = NotificationModel(
        id: '',
        recipientUid: recipientUid,
        type: 'item_handed_over',
        title: 'Item Handed Over',
        body: 'Your "$itemTitle" has been handed over',
        itemId: itemId,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
      print('✅ Notification sent: Item handed over');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Create notification for new message
  Future<void> notifyNewMessage(
    String recipientUid,
    String senderName,
  ) async {
    try {
      final notification = NotificationModel(
        id: '',
        recipientUid: recipientUid,
        type: 'message',
        title: 'New Message',
        body: '$senderName sent you a message',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
      print('✅ Notification sent: New message');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Get user's notifications
  Future<List<NotificationModel>> getUserNotifications(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  /// Stream notifications in real-time
  Stream<List<NotificationModel>> streamNotifications(String uid) {
    try {
      return _firestore
          .collection('notifications')
          .where('recipientUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print('❌ Error streaming notifications: $e');
      return Stream.value([]);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('✅ Notification deleted');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientUid', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }
}
