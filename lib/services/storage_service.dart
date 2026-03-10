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
      print('🔄 StorageService: Starting upload from $folder');
      
      // Generate a unique file name
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('$folder/$fileName');

      print('📤 Uploading file: $fileName');
      
      // Upload the file
      final uploadTask = await ref.putFile(file);

      print('✅ File uploaded. Getting download URL...');
      
      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('🔗 Download URL: $downloadUrl');
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Error uploading image: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
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
