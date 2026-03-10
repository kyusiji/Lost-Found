import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/models/item_model.dart';

void main() {
  group('ItemModel', () {
    test('ItemModel.fromMap should create valid ItemModel', () {
      final map = {
        'title': 'Lost Phone',
        'description': 'A black iPhone 13 lost near the main building',
        'category': 'Electronics',
        'type': 'lost',
        'location': 'Main Building',
        'date': '03/10/2024',
        'imageUrl': 'https://example.com/image.jpg',
        'reporterUid': 'user123',
        'reporterName': 'John Doe',
        'status': 'active',
        'itemType': 'Lost',
      };

      final item = ItemModel.fromMap('item1', map);

      expect(item.id, 'item1');
      expect(item.title, 'Lost Phone');
      expect(item.description, 'A black iPhone 13 lost near the main building');
      expect(item.category, 'Electronics');
      expect(item.type, 'lost');
      expect(item.location, 'Main Building');
      expect(item.date, '03/10/2024');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.reporterUid, 'user123');
      expect(item.reporterName, 'John Doe');
      expect(item.status, 'active');
    });

    test('ItemModel.toMap should return valid map', () {
      final item = ItemModel(
        id: 'item1',
        title: 'Lost Keys',
        description: 'Lost my car keys with a blue keychain',
        category: 'Accessories',
        type: 'lost',
        location: 'Parking Lot A',
        date: '03/10/2024',
        imageUrl: null,
        reporterUid: 'user456',
        reporterName: 'Jane Smith',
        status: 'active',
      );

      final map = item.toMap();

      expect(map['title'], 'Lost Keys');
      expect(map['description'], 'Lost my car keys with a blue keychain');
      expect(map['category'], 'Accessories');
      expect(map['type'], 'lost');
      expect(map['location'], 'Parking Lot A');
      expect(map['date'], '03/10/2024');
      expect(map['reporterUid'], 'user456');
      expect(map['reporterName'], 'Jane Smith');
      expect(map['status'], 'active');
    });

    test('ItemModel.copyWith should create new instance with updated fields', () {
      final original = ItemModel(
        id: 'item1',
        title: 'Found Wallet',
        description: 'Black leather wallet',
        category: 'Accessories',
        type: 'found',
        location: 'Library',
        date: '03/10/2024',
        imageUrl: null,
        reporterUid: 'user789',
        reporterName: 'Admin',
        status: 'active',
      );

      final updated = original.copyWith(
        status: 'claimed',
        claimedBy: 'user123',
      );

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.status, 'claimed');
      expect(updated.claimedBy, 'user123');
    });

    test('ItemModel can handle null optional fields', () {
      final map = {
        'title': 'Item',
        'description': 'Description',
        'category': 'Category',
        'type': 'lost',
        'location': 'Location',
        'date': '03/10/2024',
        'reporterUid': 'uid123',
        'reporterName': 'Name',
        'status': 'active',
      };

      final item = ItemModel.fromMap('item1', map);

      expect(item.imageUrl, isNull);
      expect(item.claimedBy, isNull);
      expect(item.handoverStatus, isNull);
    });
  });
}
