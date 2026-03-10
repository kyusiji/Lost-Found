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
    // Load user only once
    if (_user == null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    try {
      // First try to get from route arguments
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is UserModel) {
        _user = arg;
        print('✅ User loaded from arguments: ${_user?.fullName}');
      } else {
        // Fall back to AuthService
        final authUser = AuthService().currentUser;
        if (authUser != null) {
          _user = authUser;
          print('✅ User loaded from AuthService: ${_user?.fullName}');
        } else {
          print('⚠️ No user data available');
          _user = null;
        }
      }
      setState(() {});
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 30,
        maxWidth: 400,
      );

      if (pickedFile != null) {
        setState(() => _isLoading = true);

        final uid = AuthService().currentFirebaseUser?.uid;
        if (uid == null) {
          throw Exception('User not logged in');
        }

        print('📸 Starting upload to Storage...');
        print('📁 Folder: profile_pictures/$uid');

        // 1. Upload to Firebase Storage
        final photoUrl = await StorageService().uploadImage(
          File(pickedFile.path),
          'profile_pictures/$uid',
        );

        print('✅ Upload successful. URL: $photoUrl');

        if (photoUrl != null && photoUrl.isNotEmpty) {
          print('💾 Saving URL to Firestore...');
          
          // 2. Update Firestore User Document with photo URL
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'photoUrl': photoUrl,
          });

          print('✅ Firestore updated successfully');

          if (mounted) {
            final updatedUser = UserModel(
              uid: _user!.uid,
              surname: _user!.surname,
              firstName: _user!.firstName,
              studentNumber: _user!.studentNumber,
              ncstEmail: _user!.ncstEmail,
              photoUrl: photoUrl,
            );

            setState(() {
              _user = updatedUser;
            });

            // Update AuthService cache so photo persists when navigating
            AuthService().updateCachedUser(updatedUser);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profile picture updated successfully!')),
            );
          }
        } else {
          throw Exception('Image upload returned empty URL');
        }
      }
    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase error: ${e.message}')),
        );
      }
    } catch (e) {
      print('❌ Error updating photo: $e');
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

  /// Build profile avatar with proper image loading and error handling
  Widget _buildProfileAvatar(UserModel? user) {
    if (user == null) {
      return CircleAvatar(
        radius: 70,
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
        child: const Text(
          'LF',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
      );
    }

    final hasPhoto = user.photoUrl.isNotEmpty;

    if (!hasPhoto) {
      return CircleAvatar(
        radius: 70,
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
        child: Text(
          user.initials,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 70,
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
      backgroundImage: NetworkImage(user.photoUrl),
      onBackgroundImageError: (exception, stackTrace) {
        print('❌ Error loading image: $exception');
      },
    );
  }

  Future<void> _removePhoto() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not available')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = AuthService().currentFirebaseUser?.uid;
      if (uid == null) {
        throw Exception('User not logged in');
      }

      // Delete from Firebase Storage if URL exists
      if (_user!.photoUrl.isNotEmpty) {
        print('🗑️ Deleting from Storage: ${_user!.photoUrl}');
        await StorageService().deleteImageFromUrl(_user!.photoUrl);
        print('✅ Deleted from Storage');
      }

      // Delete from Firestore
      print('💾 Updating Firestore...');
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': FieldValue.delete(),
      });
      print('✅ Updated Firestore');

      if (mounted) {
        setState(() {
          _user = UserModel(
            uid: _user!.uid,
            surname: _user!.surname,
            firstName: _user!.firstName,
            studentNumber: _user!.studentNumber,
            ncstEmail: _user!.ncstEmail,
            photoUrl: '',
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo removed.')),
        );
      }
    } catch (e) {
      print('❌ Error removing photo: $e');
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
      body: _user == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Current avatar
                  _buildProfileAvatar(_user),
                  const SizedBox(height: 40),

                  // Options
                  PrimaryButton(
                    label: 'Take a Photo',
                    onPressed: _isLoading ? null : _pickFromCamera,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Choose from Gallery',
                    onPressed: _isLoading ? null : _pickFromGallery,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Remove Photo',
                    onPressed: _isLoading ? null : _removePhoto,
                  ),
                ],
              ),
            ),
    );
  }
}
