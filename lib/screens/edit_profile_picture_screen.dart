import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/services/storage_service.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/widgets/primary_button.dart';

class EditProfilePictureScreen extends StatefulWidget {
  const EditProfilePictureScreen({super.key});

  @override
  State<EditProfilePictureScreen> createState() =>
      _EditProfilePictureScreenState();
}

class _EditProfilePictureScreenState extends State<EditProfilePictureScreen> {
  UserModel? _user;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is UserModel) _user = arg;
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() => _isLoading = true);

        final uid = AuthService().currentFirebaseUser?.uid;
        if (uid == null) throw Exception('User not logged in');

        // 1. Upload to Storage
        final imageUrl = await StorageService()
            .uploadImage(File(pickedFile.path), 'profile_pictures/$uid');

        // 2. Update Firestore User Document
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'photoUrl': imageUrl,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile picture updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFromCamera() async =>
      _handleImageSelection(ImageSource.camera);
  Future<void> _pickFromGallery() async =>
      _handleImageSelection(ImageSource.gallery);

  Future<void> _removePhoto() async {
    // Note: Assuming you save the photoUrl in the UserModel.
    // You will need to fetch it or pass it.
    setState(() => _isLoading = true);
    try {
      final uid = AuthService().currentFirebaseUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'photoUrl': FieldValue.delete(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo removed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Picture',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Current avatar
            CircleAvatar(
              radius: 70,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
              child: Text(
                _user?.initials ?? 'LF',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Options
            PrimaryButton(
              label: 'Take a Photo',
              onPressed: _pickFromCamera,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Choose from Gallery',
              onPressed: _pickFromGallery,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Remove Photo',
              onPressed: _removePhoto,
            ),
          ],
        ),
      ),
    );
  }
}
