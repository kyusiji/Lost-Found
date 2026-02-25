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
  //bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is UserModel) _user = arg;
  }

  Future<void> _pickFromCamera() async {
    // TODO: implement image_picker camera
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.camera);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera picker — coming soon!')),
    );
  }

  Future<void> _pickFromGallery() async {
    // TODO: implement image_picker gallery
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.gallery);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery picker — coming soon!')),
    );
  }

  Future<void> _removePhoto() async {
    // TODO: remove from Firebase Storage + update user doc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo removed — coming soon!')),
    );
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