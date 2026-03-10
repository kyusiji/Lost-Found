import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id; // Firestore doc ID
  final String title;
  final String description;
  final String category;
  final String type; // 'lost' or 'found'
  final String location;
  final String date; // User's date input (MM/dd/yyyy)
  final String? imageUrl; // Firebase Storage URL
  final String reporterUid;
  final String reporterName;
  final String status; // 'active', 'claimed', 'handed_over'
  final String? claimedBy; // UID of user who claimed it
  final String? claimedAt; // When it was claimed
  final String? handoverStatus; // For found items: 'Office Of Student Affairs', etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? itemType; // 'All Types', etc.

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.reporterUid,
    required this.reporterName,
    required this.status,
    this.claimedBy,
    this.claimedAt,
    this.handoverStatus,
    this.createdAt,
    this.updatedAt,
    this.itemType,
  });

  /// Convert Firestore document to ItemModel
  factory ItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ItemModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Uncategorized',
      type: map['type'] as String? ?? 'lost',
      location: map['location'] as String? ?? '',
      date: map['date'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      reporterUid: map['reporterUid'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? 'Unknown',
      status: map['status'] as String? ?? 'active',
      claimedBy: map['claimedBy'] as String?,
      claimedAt: map['claimedAt'] as String?,
      handoverStatus: map['handoverStatus'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      itemType: map['itemType'] as String?,
    );
  }

  /// Convert ItemModel to Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'location': location,
      'date': date,
      'imageUrl': imageUrl ?? '',
      'reporterUid': reporterUid,
      'reporterName': reporterName,
      'status': status,
      'claimedBy': claimedBy,
      'claimedAt': claimedAt,
      'handoverStatus': handoverStatus,
      'itemType': itemType,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Copy with method for updates
  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? location,
    String? date,
    String? imageUrl,
    String? reporterUid,
    String? reporterName,
    String? status,
    String? claimedBy,
    String? claimedAt,
    String? handoverStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? itemType,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      location: location ?? this.location,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      reporterUid: reporterUid ?? this.reporterUid,
      reporterName: reporterName ?? this.reporterName,
      status: status ?? this.status,
      claimedBy: claimedBy ?? this.claimedBy,
      claimedAt: claimedAt ?? this.claimedAt,
      handoverStatus: handoverStatus ?? this.handoverStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemType: itemType ?? this.itemType,
    );
  }

  @override
  String toString() => 'ItemModel(id: $id, title: $title, type: $type, status: $status)';
}
