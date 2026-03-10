import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:lost_and_found/services/item_service.dart';
import 'package:lost_and_found/utils/app_theme.dart';

class TrackMyReportScreen extends StatefulWidget {
  final UserModel? user;
  const TrackMyReportScreen({super.key, this.user});

  @override
  State<TrackMyReportScreen> createState() => _TrackMyReportScreenState();
}

class _TrackMyReportScreenState extends State<TrackMyReportScreen> {
  bool _showingFoundItems = true; // true = Found Items, false = Lost Items

  /// Fetch user's reports from Firestore
  /// Returns a list of items filtered by reporterUid and type
  Future<List<_TrackedItem>> _fetchUserReports(String itemType) async {
    try {
      // Use AuthService to get current user's UID (consistent with report_item_screen)
      final uid = AuthService().currentFirebaseUser?.uid;
      if (uid == null) {
        print('❌ No user logged in');
        return [];
      }

      print('🔍 Fetching $itemType items for UID: $uid');

      // Try without orderBy first to check if it's an index issue
      final query = await FirebaseFirestore.instance
          .collection('items')
          .where('reporterUid', isEqualTo: uid)
          .where('type', isEqualTo: itemType)
          .get();

      print('✅ Found ${query.docs.length} $itemType items');

      // Sort manually in Dart
      final items = query.docs.map((doc) {
        final data = doc.data();
        return _TrackedItem(
          id: doc.id,
          title: data['title'] ?? 'Untitled',
          location: data['location'] ?? 'Unknown location',
          dateFound: data['date'] ?? 'No date',
          handover: data['handoverStatus'],
          status: _mapStatus(data['status']),
          imageUrl: data['imageUrl'],
          createdAt: data['createdAt'] as Timestamp?,
        );
      }).toList();

      // Sort by createdAt descending
      items.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(1990);
        final bTime = b.createdAt?.toDate() ?? DateTime(1990);
        return bTime.compareTo(aTime);
      });

      return items;
    } catch (e) {
      print('❌ Error fetching reports: $e');
      return [];
    }
  }

  /// Map Firestore status to display status
  String _mapStatus(String? firestoreStatus) {
    switch (firestoreStatus) {
      case 'claimed':
        return 'Claimed';
      case 'handed_over':
        return 'Handed Over';
      case 'active':
      default:
        return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemType = _showingFoundItems ? 'found' : 'lost';

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
                    Icons.track_changes_rounded,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Track My Report',
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
          Container(
            color: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Found Items',
                    isActive: _showingFoundItems,
                    onTap: () => setState(() => _showingFoundItems = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Lost Items',
                    isActive: !_showingFoundItems,
                    onTap: () => setState(() => _showingFoundItems = false),
                  ),
                ),
              ],
            ),
          ),

          // ── Content using FutureBuilder ────────────────────────────
          Expanded(
            child: FutureBuilder<List<_TrackedItem>>(
              key: Key(_showingFoundItems ? 'found' : 'lost'), // Force rebuild on tab change
              future: _fetchUserReports(itemType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.errorRed.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading reports',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textGrey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = snapshot.data ?? [];
                final hasItems = items.isNotEmpty;

                if (!hasItems) {
                  return _EmptyState(isFoundTab: _showingFoundItems);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) =>
                      _TrackedItemCard(item: items[i]),
                );
              },
            ),
          ),
        ],
      ),
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

// ════════════════════════════════════════════════════════════════════════════
// TRACKED ITEM CARD
// ════════════════════════════════════════════════════════════════════════════

class _TrackedItemCard extends StatelessWidget {
  final _TrackedItem item;
  const _TrackedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isClaimed = item.status == 'Claimed';
    final statusColor = isClaimed ? AppTheme.primaryBlue : AppTheme.accentGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 90,
            height: 110,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.imageUrl == null || item.imageUrl!.isEmpty
                ? const Center(
                    child: Text(
                      '[Image]',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : null,
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(icon: Icons.location_on_outlined, text: item.location),
                  _InfoRow(icon: Icons.calendar_today_outlined, text: item.dateFound),
                  if (item.handover != null)
                    _InfoRow(icon: Icons.person_outline, text: item.handover!),
                  const SizedBox(height: 8),
                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _showDeleteConfirmation(context, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show delete confirmation
void _showDeleteConfirmation(BuildContext context, _TrackedItem item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Delete Item',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
      ),
      content: Text(
        'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
        style: TextStyle(color: AppTheme.textGrey.withOpacity(0.9)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.primaryBlue),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Close dialog
            await _deleteItem(context, item.id);
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

// Helper function to delete an item from Firestore
Future<void> _deleteItem(BuildContext context, String itemId) async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Deleting item...'),
        duration: Duration(seconds: 2),
      ),
    );

    await ItemService().deleteItem(itemId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Item deleted successfully'),
          backgroundColor: AppTheme.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error deleting item: $e'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// INFO ROW
// ════════════════════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppTheme.textGrey.withOpacity(0.7)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textGrey.withOpacity(0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final bool isFoundTab;
  const _EmptyState({required this.isFoundTab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFoundTab ? Icons.search_off_rounded : Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textGrey.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track my report is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ════════════════════════════════════════════════════════════════════════════

class _TrackedItem {
  final String id; // Firestore document ID
  final String title;
  final String location;
  final String dateFound;
  final String? handover;
  final String status; // 'Active', 'Claimed', 'Handed Over'
  final String? imageUrl; // URL from Firebase Storage or base64 data
  final Timestamp? createdAt; // For sorting

  _TrackedItem({
    required this.id,
    required this.title,
    required this.location,
    required this.dateFound,
    this.handover,
    required this.status,
    this.imageUrl,
    this.createdAt,
  });
}