import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:lost_and_found/services/item_service.dart';
import 'package:lost_and_found/services/notification_service.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  final String title;
  final String category;
  final String description;
  final String location;
  final String dateFound;
  final String reportedBy;
  final String reporterUid;
  final String itemType;
  final String status;
  final String? imageUrl;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.dateFound,
    required this.reportedBy,
    required this.reporterUid,
    required this.itemType,
    required this.status,
    this.imageUrl,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Future<UserModel?> _posterFuture;
  late Future<bool> _userAlreadyClaimedFuture;

  @override
  void initState() {
    super.initState();
    _posterFuture = AuthService().getUserByUid(widget.reporterUid);
    _userAlreadyClaimedFuture = _checkIfUserAlreadyClaimed();
  }

  Future<bool> _checkIfUserAlreadyClaimed() async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null || currentUser.uid.isEmpty) return false;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transaction_logs')
          .where('itemId', isEqualTo: widget.itemId)
          .where('claimerUid', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs.any((doc) => doc['status'] != 'Rejected');
    } catch (e) {
      debugPrint('Error checking claims: $e');
      return false;
    }
  }

  void _showRequestDialog(BuildContext context) async {
    final bool isFoundPost = widget.itemType == 'Found';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isFoundPost ? 'Request Claim Item?' : 'Claim Found Item?'),
        content: Text(isFoundPost
            ? 'Are you sure you want to claim "${widget.title}"?'
            : 'Are you sure you want to claim the found item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUser = AuthService().currentUser;

      if (currentUser == null || currentUser.uid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error: Could not verify your User ID. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(widget.itemId)
            .update({
          'status': widget.itemType == 'Found' ? 'Requested' : 'Claimable',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final transactionLog = {
          'itemId': widget.itemId,
          'itemName': widget.title,
          'itemCategory': widget.category,
          'itemDescription': widget.description,
          'itemLocation': widget.location,
          'itemOriginalImage': widget.imageUrl ?? '',
          'itemAuthorName': widget.reportedBy,
          'itemAuthorType': widget.itemType, // 'Found' or 'Lost'

          'claimerUid': currentUser.uid,
          'claimerName': currentUser.fullName,
          'status': 'Pending',
          'claimDate': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('transaction_logs')
            .add(transactionLog);

        await NotificationService().notifyItemClaimed(
          widget.itemId,
          widget.reporterUid,
          currentUser.uid,
          currentUser.fullName,
          widget.title,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Claim request submitted!')),
          );
          setState(() {
            _userAlreadyClaimedFuture = _checkIfUserAlreadyClaimed();
          });
        }
      } catch (e) {
        debugPrint('Error submitting claim: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error submitting claim'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showRevertDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Action?'),
        content: const Text(
            'Cancel this request and remove it from claim request logs?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUser = AuthService().currentUser;

      try {
        var logQuery = await FirebaseFirestore.instance
            .collection('transaction_logs')
            .where('itemId', isEqualTo: widget.itemId)
            .where('claimerUid', isEqualTo: currentUser?.uid)
            .get();

        for (var doc in logQuery.docs) {
          await doc.reference.delete();
        }

        var allPendingClaims = await FirebaseFirestore.instance
            .collection('transaction_logs')
            .where('itemId', isEqualTo: widget.itemId)
            .where('status', isEqualTo: 'Pending')
            .get();

        if (allPendingClaims.docs.isEmpty) {
          await FirebaseFirestore.instance
              .collection('items')
              .doc(widget.itemId)
              .update({
            'status': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Claim request cancelled.')),
          );
          setState(() {
            _userAlreadyClaimedFuture = _checkIfUserAlreadyClaimed();
          });
        }
      } catch (e) {
        debugPrint('Error cancelling claim: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error cancelling claim'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppTheme.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 300,
                color: AppTheme.primaryBlue.withOpacity(0.1),
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white, size: 60),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: AppTheme.primaryBlue.withOpacity(0.1),
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.white, size: 60),
                ),
              ),

            // MAIN CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE AND TYPE BADGE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.itemType == 'Found'
                              ? AppTheme.accentGreen
                              : AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.itemType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // CATEGORY AND STATUS
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.category),
                        backgroundColor:
                            AppTheme.primaryBlue.withOpacity(0.15),
                        labelStyle: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(widget.status),
                        backgroundColor: AppTheme.accentGreen.withOpacity(0.15),
                        labelStyle: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // DESCRIPTION SECTION
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LOCATION AND DATE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: widget.location,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          text: widget.dateFound,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // POSTER PROFILE CARD
                  const Text(
                    'Posted By',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<UserModel?>(
                    future: _posterFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.borderColor.withOpacity(0.3),
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.borderColor.withOpacity(0.3),
                            ),
                          ),
                          child: const Center(
                            child: Text('User profile not found'),
                          ),
                        );
                      }

                      final user = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            // PROFILE PICTURE
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                border: Border.all(
                                  color:
                                      AppTheme.primaryBlue.withOpacity(0.3),
                                ),
                              ),
                              child: (user.photoUrl.isNotEmpty)
                                  ? ClipOval(
                                      child: Image.network(
                                        user.photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              user.initials,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryBlue,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // USER INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Student ID: ${user.studentNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.ncstEmail,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textGrey
                                          .withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ACTION BUTTON
                  FutureBuilder<bool>(
                    future: _userAlreadyClaimedFuture,
                    builder: (context, snapshot) {
                      final userAlreadyClaimed = snapshot.data ?? false;
                      final isFoundPost = widget.itemType == 'Found';

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: userAlreadyClaimed
                                ? Colors.orange
                                : AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: userAlreadyClaimed
                              ? () => _showRevertDialog(context)
                              : () => _showRequestDialog(context),
                          child: Text(
                            userAlreadyClaimed
                                ? 'Cancel Request'
                                : (isFoundPost
                                    ? 'Claim Request Item'
                                    : 'Claim Found Item'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textGrey.withOpacity(0.85),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
