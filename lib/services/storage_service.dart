import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String?> uploadImage(File file, String folder) async {
    try {
      // Generate a unique file name
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('$folder/$fileName');

      // Upload the file
      final uploadTask = await ref.putFile(file);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  /// Deletes an image from Firebase Storage using its URL
  Future<void> deleteImageFromUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
