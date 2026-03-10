import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/services/storage_service.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:lost_and_found/utils/validators.dart';
import 'package:lost_and_found/widgets/primary_button.dart';

class ReportItemScreen extends StatefulWidget {
  final UserModel? user;
  const ReportItemScreen({super.key, this.user});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  bool _isFoundTab = true; // true = Found Items, false = Lost Items

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _itemTitleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String _selectedCategory = 'All Category';
  String _selectedItemType = 'All Types';
  String _selectedHandoverStatus = 'Office Of Student Affairs';

  bool _isLoading = false;

  @override
  void dispose() {
    _itemTitleCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30, // Compress image slightly to save space
        maxWidth: 600,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Replace your existing _submit method with this:
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = AuthService().currentFirebaseUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to report an item.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? base64ImageString;

      // 1. Upload Image to Storage (if selected)
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        // Convert to base64 string
        base64ImageString = base64Encode(bytes);
      }

      // 2. Save Item details to Firestore
      await FirebaseFirestore.instance.collection('items').add({
        'type': _isFoundTab ? 'found' : 'lost',
        'title': _itemTitleCtrl.text.trim(),
        'category': _selectedCategory,
        'itemType': _selectedItemType,
        'description': _descriptionCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'date': _dateCtrl.text.trim(),
        'handoverStatus': _isFoundTab ? _selectedHandoverStatus : null,
        'imageUrl': base64ImageString,
        'reporterUid': currentUser.uid,
        'status': 'active', // default status
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFoundTab
                  ? 'Found item reported successfully!'
                  : 'Lost item reported successfully!',
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
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
          'Lost & Found',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_box_outlined,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Report Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),

          // ── Tab buttons ────────────────────────────────────────────
          // ── Tab buttons ────────────────────────────────────────────
          Container(
            color: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Found Items',
                    isActive: _isFoundTab,
                    onTap: () => setState(() {
                      _isFoundTab = true;
                      _formKey.currentState?.reset();

                      // Clear all inputs and the image when switching to Found
                      _itemTitleCtrl.clear();
                      _descriptionCtrl.clear();
                      _locationCtrl.clear();
                      _dateCtrl.clear();
                      _selectedImage = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Lost Items',
                    isActive: !_isFoundTab,
                    onTap: () => setState(() {
                      _isFoundTab = false;
                      _formKey.currentState?.reset();

                      // Clear all inputs and the image when switching to Lost
                      _itemTitleCtrl.clear();
                      _descriptionCtrl.clear();
                      _locationCtrl.clear();
                      _dateCtrl.clear();
                      _selectedImage = null;
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ── Form ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isFoundTab
                            ? AppTheme.accentGreen
                            : AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isFoundTab
                                  ? 'Found Item Information'
                                  : 'Lost Item Information',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item Images section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.borderColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.image_outlined,
                                  color: AppTheme.primaryBlue, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Item Images',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppTheme.primaryBlue, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isFoundTab
                                        ? 'Upload clear images of found item. You can upload multiple images.'
                                        : 'Upload clear images of lost item. You can upload multiple images.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          AppTheme.primaryBlue.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Upload button
                          GestureDetector(
                            onTap: _uploadImage,
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.borderColor.withOpacity(0.4),
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined,
                                        color:
                                            AppTheme.textGrey.withOpacity(0.6),
                                        size: 36),
                                    const SizedBox(height: 6),
                                    Text(
                                      '[Upload]',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            AppTheme.textGrey.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (_selectedImage != null) ...[
                            const SizedBox(height: 12),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Item Information section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.borderColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  color: AppTheme.primaryBlue, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Item Information',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Item Title, Category, Item Type row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: _buildField('Item Title',
                                      _itemTitleCtrl, 'e.g. Black Wallet'),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 130,
                                  child: _buildDropdown(
                                      'Category',
                                      _selectedCategory,
                                      [
                                        'All Category',
                                        'Electronics',
                                        'Clothing',
                                        'Books',
                                        'Others'
                                      ],
                                      (v) => setState(
                                          () => _selectedCategory = v!)),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 110,
                                  child: _buildDropdown(
                                      'Item Type',
                                      _selectedItemType,
                                      [
                                        'All Types',
                                        'Watch',
                                        'Phone',
                                        'Wallet',
                                        'Keys',
                                        'ID'
                                      ],
                                      (v) => setState(
                                          () => _selectedItemType = v!)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description
                          _buildField(
                            'Description',
                            _descriptionCtrl,
                            'add123',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),

                          // Location & Date
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  _isFoundTab ? 'Found at:' : 'Lost at:',
                                  _locationCtrl,
                                  '[location]',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildField(
                                  _isFoundTab ? 'Date found:' : 'Date lost:',
                                  _dateCtrl,
                                  '[mm/dd/yyyy]',
                                ),
                              ),
                            ],
                          ),

                          // Handover Status (ONLY for Found Items)
                          if (_isFoundTab) ...[
                            const SizedBox(height: 12),
                            _buildDropdown(
                              'Handover Status:',
                              _selectedHandoverStatus,
                              [
                                'Office Of Student Affairs',
                              ],
                              (v) =>
                                  setState(() => _selectedHandoverStatus = v!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    PrimaryButton(
                      label: 'Submit Item',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 12, color: AppTheme.textGrey.withOpacity(0.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: AppTheme.bgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: AppTheme.borderColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: AppTheme.borderColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppTheme.primaryBlue),
            ),
          ),
          validator: (v) => Validators.validateRequired(v, fieldName: label),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: AppTheme.bgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: AppTheme.borderColor.withOpacity(0.3)),
            ),
          ),
          style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
          items: items
              .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i, style: const TextStyle(fontSize: 12))))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB BUTTON
// ════════════════════════════════════════════════════════════════════════════

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? AppTheme.primaryBlue : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
