import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/models/item_model.dart';
import 'package:lost_and_found/services/storage_service.dart';

class ItemService {
  static final ItemService _instance = ItemService._();
  factory ItemService() => _instance;
  ItemService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();

  /// Create a new item report
  Future<String> createItem(ItemModel item) async {
    try {
      print('💾 Creating item: ${item.title}');
      final docRef = await _firestore.collection('items').add(item.toMap());
      print('✅ Item created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating item: $e');
      rethrow;
    }
  }

  /// Get single item by ID
  Future<ItemModel?> getItem(String itemId) async {
    try {
      final doc = await _firestore.collection('items').doc(itemId).get();
      if (!doc.exists) return null;
      return ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error fetching item: $e');
      return null;
    }
  }

  /// Get all items by reporter UID
  Future<List<ItemModel>> getUserItems(String uid, {String? type}) async {
    try {
      Query query = _firestore.collection('items').where('reporterUid', isEqualTo: uid);
      
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching user items: $e');
      return [];
    }
  }

  /// Search items with multiple filters
  Future<List<ItemModel>> searchItems({
    String? searchText,
    String? category,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('items');

      // Apply filters
      if (category != null && category != 'All Category') {
        query = query.where('category', isEqualTo: category);
      }
      if (type != null && type != 'All Types') {
        query = query.where('type', isEqualTo: type == 'Found' ? 'found' : 'lost');
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      var items = snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Apply date range filter (client-side)
      if (startDate != null || endDate != null) {
        items = items.where((item) {
          try {
            final itemDate = DateTime.parse(item.date);
            if (startDate != null && itemDate.isBefore(startDate)) return false;
            if (endDate != null) {
              final endOfDay = endDate.add(const Duration(days: 1));
              if (itemDate.isAfter(endOfDay)) return false;
            }
            return true;
          } catch (e) {
            return true;
          }
        }).toList();
      }

      // Apply search text filter (client-side)
      if (searchText != null && searchText.isNotEmpty) {
        final query = searchText.toLowerCase();
        items = items.where((item) =>
            item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query) ||
            item.reporterName.toLowerCase().contains(query)).toList();
      }

      return items;
    } catch (e) {
      print('❌ Error searching items: $e');
      return [];
    }
  }

  /// Get all items (browse)
  Future<List<ItemModel>> getAllItems() async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching all items: $e');
      return [];
    }
  }

  /// Stream items in real-time
  Stream<List<ItemModel>> streamItems() {
    try {
      return _firestore
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print('❌ Error streaming items: $e');
      return Stream.value([]);
    }
  }

  /// Update item status (active, claimed, handed_over)
  Future<void> updateItemStatus(String itemId, String status) async {
    try {
      print('🔄 Updating item $itemId status to: $status');
      await _firestore.collection('items').doc(itemId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Item status updated');
    } catch (e) {
      print('❌ Error updating item status: $e');
      rethrow;
    }
  }

  /// Claim item (mark as claimed by user)
  Future<void> claimItem(String itemId, String claimedByUid, String claimedByName) async {
    try {
      print('🤝 Claiming item $itemId by $claimedByUid');
      await _firestore.collection('items').doc(itemId).update({
        'status': 'claimed',
        'claimedBy': claimedByUid,
        'claimedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Item claimed');
    } catch (e) {
      print('❌ Error claiming item: $e');
      rethrow;
    }
  }

  /// Mark as handed over
  Future<void> markAsHandedOver(String itemId) async {
    try {
      print('📦 Marking item $itemId as handed over');
      await _firestore.collection('items').doc(itemId).update({
        'status': 'handed_over',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Item marked as handed over');
    } catch (e) {
      print('❌ Error marking as handed over: $e');
      rethrow;
    }
  }

  /// Delete item and its image
  Future<void> deleteItem(String itemId) async {
    try {
      print('🗑️ Deleting item $itemId');
      
      // Get item first to find image URL
      final item = await getItem(itemId);
      
      // Delete image if exists
      if (item?.imageUrl != null && item!.imageUrl!.isNotEmpty) {
        try {
          await _storage.deleteImageFromUrl(item.imageUrl!);
          print('✅ Image deleted');
        } catch (e) {
          print('⚠️ Warning: Could not delete image: $e');
        }
      }
      
      // Delete document
      await _firestore.collection('items').doc(itemId).delete();
      print('✅ Item deleted');
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    }
  }

  /// Update item details
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      print('✏️ Updating item $itemId');
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('items').doc(itemId).update(updates);
      print('✅ Item updated');
    } catch (e) {
      print('❌ Error updating item: $e');
      rethrow;
    }
  }

  /// Get claimed items (items claimed by specific user)
  Future<List<ItemModel>> getClaimedItems(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .where('claimedBy', isEqualTo: uid)
          .orderBy('claimedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching claimed items: $e');
      return [];
    }
  }
}
