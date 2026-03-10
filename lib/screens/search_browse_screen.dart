import 'package:cloud_firestore/cloud_firestore.dart'; //  Added for Firestore
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/services/auth_service.dart';
import 'package:lost_and_found/services/item_service.dart';
import 'package:lost_and_found/services/notification_service.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:intl/intl.dart';

class SearchBrowseScreen extends StatefulWidget {
  final UserModel? user;
  const SearchBrowseScreen({super.key, this.user});

  @override
  State<SearchBrowseScreen> createState() => _SearchBrowseScreenState();
}

class _SearchBrowseScreenState extends State<SearchBrowseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedCategory = 'All Category';
  String _selectedItemType = 'All Types';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Rebuild the screen whenever the user types in the search bar
    _searchCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          // ── Search header ──────────────────────────────────────────
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: AppTheme.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Search/Browse Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Active filters badge
                    if (_startDate != null ||
                        _endDate != null ||
                        _selectedCategory != 'All Category' ||
                        _selectedItemType != 'All Types' ||
                        _searchCtrl.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.errorRed.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Filters Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Filter row ─────────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Search field
                      SizedBox(
                        width: 140,
                        height: 42,
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'desc., loc., reporter...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey.withOpacity(0.6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                  color: AppTheme.borderColor, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                  color: AppTheme.textGrey.withOpacity(0.3),
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                  color: AppTheme.primaryBlue, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Category dropdown
                      SizedBox(
                        width: 130,
                        height: 42,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textDark),
                          items: [
                            'All Category',
                            'Electronics',
                            'Clothing',
                            'Books',
                            'Others'
                          ]
                              .map((c) => DropdownMenuItem(
                                  value: c,
                                  child:
                                      Text(c, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Item Type dropdown
                      SizedBox(
                        width: 110,
                        height: 42,
                        child: DropdownButtonFormField<String>(
                          value: _selectedItemType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textDark),
                          items: ['All Types', 'Lost', 'Found']
                              .map((t) => DropdownMenuItem(
                                  value: t,
                                  child:
                                      Text(t, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedItemType = v!),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // From Date picker
                      SizedBox(
                        width: 100,
                        height: 42,
                        child: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              // Validate: start date should not be after end date
                              if (_endDate != null && picked.isAfter(_endDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Start date cannot be after end date'),
                                    backgroundColor: AppTheme.errorRed,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                setState(() => _startDate = picked);
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            side: BorderSide(
                                color: AppTheme.textGrey.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            _startDate != null
                                ? DateFormat('MM/dd/yyyy').format(_startDate!)
                                : 'From Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: _startDate != null
                                  ? AppTheme.textDark
                                  : AppTheme.textGrey.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // To Date picker
                      SizedBox(
                        width: 100,
                        height: 42,
                        child: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              // Validate: end date should not be before start date
                              if (_startDate != null && picked.isBefore(_startDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('End date cannot be before start date'),
                                    backgroundColor: AppTheme.errorRed,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                setState(() => _endDate = picked);
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            side: BorderSide(
                                color: AppTheme.textGrey.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            _endDate != null
                                ? DateFormat('MM/dd/yyyy').format(_endDate!)
                                : 'To Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: _endDate != null
                                  ? AppTheme.textDark
                                  : AppTheme.textGrey.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Clear Filters button
                      SizedBox(
                        height: 42,
                        child: TextButton(
                          onPressed: (_startDate != null ||
                                  _endDate != null ||
                                  _selectedCategory != 'All Category' ||
                                  _selectedItemType != 'All Types' ||
                                  _searchCtrl.text.isNotEmpty)
                              ? () {
                                  setState(() {
                                    _startDate = null;
                                    _endDate = null;
                                    _selectedCategory = 'All Category';
                                    _selectedItemType = 'All Types';
                                    _searchCtrl.clear();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✓ Filters cleared'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              : null,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            side: BorderSide(
                                color: AppTheme.textGrey.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: (_startDate != null ||
                                      _endDate != null ||
                                      _selectedCategory != 'All Category' ||
                                      _selectedItemType != 'All Types' ||
                                      _searchCtrl.text.isNotEmpty)
                                  ? AppTheme.errorRed
                                  : AppTheme.textGrey.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Results list from FIRESTORE ────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Show loading spinner while fetching
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error handling
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading items: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // 3. Map Firestore data to _ItemCard format
                List<_ItemCard> allItems = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _ItemCard(
                    id: doc.id,
                    title: data['title'] ?? 'No Title',
                    category: data['category'] ?? 'Uncategorized',
                    itemType: data['type'] == 'found' ? 'Found' : 'Lost',
                    description: data['description'] ?? '',
                    location: data['location'] ?? 'Unknown',
                    dateFound: data['date'] ?? 'Unknown date',
                    reportedBy: data['reporterName'] ?? 'Student',
                    reporterUid: data['reporterUid'] ?? '',
                    status: data['type'] == 'found' ? 'Found' : 'Lost',
                    imageUrl: data['imageUrl'], // Storage URL, not base64
                  );
                }).toList();

                // 4. Apply search and dropdown filters
                List<_ItemCard> filteredItems = allItems.where((item) {
                  // Search filter
                  final searchText = _searchCtrl.text.toLowerCase();
                  if (searchText.isNotEmpty &&
                      !item.title.toLowerCase().contains(searchText) &&
                      !item.description.toLowerCase().contains(searchText) &&
                      !item.location.toLowerCase().contains(searchText)) {
                    return false;
                  }

                  // Category filter
                  if (_selectedCategory != 'All Category' &&
                      item.category != _selectedCategory) {
                    return false;
                  }

                  // Item Type filter
                  if (_selectedItemType != 'All Types' &&
                      item.itemType != _selectedItemType) {
                    return false;
                  }

                  // Date filter - Only include items within the selected date range
                  if (_startDate != null || _endDate != null) {
                    try {
                      // Parse item date with robust error handling
                      final itemDate = DateFormat('MM/dd/yyyy').parse(item.dateFound);
                      
                      // Include item only if it falls within BOTH start and end dates
                      // Start date check: item must be on or after start date (if set)
                      if (_startDate != null) {
                        if (itemDate.isBefore(_startDate!)) {
                          print('❌ Item ${ item.title} (${item.dateFound}) is BEFORE start date ${DateFormat('MM/dd/yyyy').format(_startDate!)}');
                          return false; // Exclude: item is before start date
                        }
                      }
                      
                      // End date check: item must be on or before end date (if set)
                      // Add 1 day to end date to include the entire end day (up to 23:59:59)
                      if (_endDate != null) {
                        final endOfDay = _endDate!.add(const Duration(days: 1));
                        if (itemDate.isAfter(endOfDay)) {
                          print('❌ Item ${item.title} (${item.dateFound}) is AFTER end date ${DateFormat('MM/dd/yyyy').format(_endDate!)}');
                          return false; // Exclude: item is after end date
                        }
                      }
                      
                      // Item passed all date range checks - include it
                      print('✅ Item ${item.title} (${item.dateFound}) is WITHIN date range');
                    } catch (e) {
                      // If date parsing fails, log and skip this item
                      print('⚠️ Date parse error for item "${item.title}" with date "${item.dateFound}": $e');
                      return false; // Exclude items with unparseable dates
                    }
                  }

                  return true;
                }).toList();

                // 5. Display Empty State or List
                if (filteredItems.isEmpty) {
                  return const _EmptySearchState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return _ItemResultCard(item: filteredItems[index]);
                  },
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
// ITEM RESULT CARD
// ════════════════════════════════════════════════════════════════════════════

class _ItemResultCard extends StatelessWidget {
  final _ItemCard item;
  const _ItemResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFound = item.status == 'Found';
    final statusColor = isFound ? AppTheme.accentGreen : AppTheme.errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── UPDATED IMAGE VIEWER ──
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Error loading image: $error');
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textGrey.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  item.itemType,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textGrey.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: item.location),
                      _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          text: item.dateFound),
                      _InfoRow(
                          icon: Icons.person_outline, text: item.reportedBy),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Claim button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: TextButton(
              onPressed: () => _showClaimDialog(context, item),
              child: Text(
                isFound ? 'Claim Item' : 'Found Item',
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClaimDialog(BuildContext context, _ItemCard item) async {
    // Ensure user is logged in
    final firebaseUser = AuthService().currentFirebaseUser;
    final userModel = AuthService().currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to claim an item.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Claim Item'),
        content: Text('Are you sure you want to claim "${item.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Yes, Claim'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator while claiming
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ItemService().claimItem(item.id, firebaseUser.uid, userModel?.fullName ?? '');
      if (Navigator.canPop(context)) Navigator.pop(context); // remove loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${item.title}" claimed successfully'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim item: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}

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
// EMPTY SEARCH STATE
// ════════════════════════════════════════════════════════════════════════════

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textGrey.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
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

class _ItemCard {
  final String id;
  final String title;
  final String category;
  final String itemType;
  final String description;
  final String location;
  final String dateFound;
  final String reportedBy;
  final String reporterUid;
  final String status;
  final String? imageUrl;

  _ItemCard({
    required this.id,
    required this.title,
    required this.category,
    required this.itemType,
    required this.description,
    required this.location,
    required this.dateFound,
    required this.reportedBy,
    required this.reporterUid,
    required this.status,
    this.imageUrl,
  });
}
