import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/screens/item_detail_screen.dart';
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

    // 1. Refresh the user immediately when screen opens
    AuthService().refreshCurrentUser().then((_) {
      if (mounted) {
        setState(() {}); // This re-builds the screen once the User ID is found
      }
    });

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
                        child: const Text(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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
                      // FIXED: Removed SizedBox(width: 110) to prevent red text overflow
                      Container(
                        height: 42,
                        width:
                            125, // Increased width slightly to fit "Claimable"
                        child: DropdownButtonFormField<String>(
                          isExpanded: true, // Prevents overflow red lines
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
                          // ADDED: Requested and Claimable options
                          items: [
                            'All Types',
                            'Lost',
                            'Found',
                            'Requested',
                            'Claimable'
                          ]
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
                              if (_endDate != null &&
                                  picked.isAfter(_endDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Start date cannot be after end date'),
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
                              if (_startDate != null &&
                                  picked.isBefore(_startDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'End date cannot be before start date'),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading items: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
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
                    status: data['status'] ??
                        (data['type'] == 'found' ? 'Found' : 'Lost'),
                    imageUrl: data['imageUrl'],
                    claimerUid: data['claimerUid'],
                  );
                }).toList();

                List<_ItemCard> filteredItems = allItems.where((item) {
                  // EXCLUDE claimed or handed_over items from search results
                  if (item.status == 'claimed' || item.status == 'handed_over') {
                    return false;
                  }

                  final searchText = _searchCtrl.text.toLowerCase();
                  if (searchText.isNotEmpty &&
                      !item.title.toLowerCase().contains(searchText) &&
                      !item.description.toLowerCase().contains(searchText) &&
                      !item.location.toLowerCase().contains(searchText)) {
                    return false;
                  }
                  if (_selectedCategory != 'All Category' &&
                      item.category != _selectedCategory) {
                    return false;
                  }

                  // UPDATED FILTER LOGIC
                  if (_selectedItemType != 'All Types') {
                    if (_selectedItemType == 'Lost' ||
                        _selectedItemType == 'Found') {
                      if (item.itemType != _selectedItemType) return false;
                    } else {
                      // Filters by status (Requested/Claimable)
                      if (item.status != _selectedItemType) return false;
                    }
                  }

                  if (_startDate != null || _endDate != null) {
                    try {
                      final itemDate =
                          DateFormat('MM/dd/yyyy').parse(item.dateFound);
                      if (_startDate != null && itemDate.isBefore(_startDate!))
                        return false;
                      if (_endDate != null) {
                        final endOfDay = _endDate!.add(const Duration(days: 1));
                        if (itemDate.isAfter(endOfDay)) return false;
                      }
                    } catch (e) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const _EmptySearchState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item =
                        filteredItems[index]; // Get the item for this row

                    return _ItemResultCard(
                      item: item,
                      // Pass the functions from this State class down to the card
                      onCommentPressed: (selectedItem) =>
                          _showCommentBox(context, selectedItem),
                      onActionPressed: (selectedItem, userAlreadyClaimed) =>
                          _handleAction(context, selectedItem, userAlreadyClaimed: userAlreadyClaimed),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentBox(BuildContext context, _ItemCard item) {
    final TextEditingController commentCtrl = TextEditingController();
    final currentUser = AuthService().currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Comments",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Comment List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('item_comments')
                    .where('itemId', isEqualTo: item.id)
                    .where('status', isEqualTo: 'Comment')
                    .orderBy('claimDate', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No comments yet."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final String commentId = docs[index].id;
                      final String commenterUid = data['claimerUid'] ?? '';
                      final String commenterName =
                          data['claimerName'] ?? 'Anonymous';

                      // FIX: Use currentUser for both UID and Role check
                      bool canDelete = (currentUser?.uid == commenterUid) ||
                          (currentUser?.role == 'admin');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: "$commenterName: ",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue),
                                    ),
                                    TextSpan(text: data['comment'] ?? ''),
                                  ],
                                ),
                              ),
                            ),
                            if (canDelete)
                              GestureDetector(
                                onTap: () => _deleteComment(context, commentId),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // INPUT AREA
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 15,
                right: 15,
                top: 10,
              ),
              child: TextField(
                controller: commentCtrl,
                decoration: InputDecoration(
                  hintText: "Write a message...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: AppTheme.primaryBlue),
                    onPressed: () async {
                      if (commentCtrl.text.trim().isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('item_comments')
                            .add({
                          'itemId': item.id,
                          'itemName': item.title,
                          'claimerUid': currentUser?.uid,
                          'claimerName': currentUser?.fullName ?? 'Anonymous',
                          'comment': commentCtrl.text.trim(),
                          'status': 'Comment',
                          'claimDate': FieldValue.serverTimestamp(),
                        });
                        commentCtrl.clear();
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteComment(BuildContext context, String docId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Comment"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // CHANGE 'transaction_logs' TO 'item_comments' BELOW
      await FirebaseFirestore.instance
          .collection('item_comments')
          .doc(docId)
          .delete();
    }
  }

  void _handleAction(BuildContext context, _ItemCard item, {bool userAlreadyClaimed = false}) {
    if (userAlreadyClaimed) {
      _showRevertDialog(context, item); // User already claimed, can cancel
    } else {
      _showRequestDialog(context, item); // User request to claim
    }
  }

  void _showRequestDialog(BuildContext context, _ItemCard item) async {
    final bool isFoundPost = item.itemType == 'Found';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isFoundPost ? 'Request Claim Item?' : 'Claim Found Item?'),
        content: Text(isFoundPost
            ? 'Are you sure you want to claim "${item.title}"?'
            : 'Are you sure you want to claim the found?'),
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

    // ONLY run the update if the user clicked "Yes"
    if (confirmed == true) {
      // 1. Get the current user and verify they are logged in
      final currentUser = AuthService().currentUser;

      // SAFETY CHECK: If the UID is missing, stop the process
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
        // 2. Only update the Item status to show something is being requested
        // DON'T store claimerUid on the item - this allows multiple students to claim
        await FirebaseFirestore.instance
            .collection('items')
            .doc(item.id)
            .update({
          'status': item.itemType == 'Found' ? 'Requested' : 'Claimable',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Add to the Transaction Logs for the Admin (source of truth for claims)
        await FirebaseFirestore.instance.collection('transaction_logs').add({
          'itemId': item.id,
          'itemName': item.title,
          'itemCategory': item.category,
          'itemDescription': item.description,
          'itemLocation': item.location,
          'itemOriginalImage': item.imageUrl,
          'itemAuthorName': item.reportedBy,
          'itemAuthorType': item.itemType, // 'Found' or 'Lost'
          'claimerUid': currentUser.uid, // Use the same verified UID
          'claimerName': currentUser.fullName ?? 'Anonymous',
          'status': 'Pending',
          'claimDate': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Claim request submitted successfully!')),
        );
      } catch (e) {
        debugPrint('Update failed: $e');
      }
    }
  }

  void _showRevertDialog(BuildContext context, _ItemCard item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Action?'),
        content: const Text(
            'Cancel this request and remove it from Office of Student Affairs(OSA) claim request logs?'),
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
        // 1. Find only THIS user's transaction_log for this item
        var logQuery = await FirebaseFirestore.instance
            .collection('transaction_logs')
            .where('itemId', isEqualTo: item.id)
            .where('claimerUid', isEqualTo: currentUser?.uid)
            .get();

        // 2. Delete only the current user's claim entry
        for (var doc in logQuery.docs) {
          await doc.reference.delete();
        }

        // 3. Only update item status if NO OTHER pending claims exist
        var allPendingClaims = await FirebaseFirestore.instance
            .collection('transaction_logs')
            .where('itemId', isEqualTo: item.id)
            .where('status', isEqualTo: 'Pending')
            .get();

        if (allPendingClaims.docs.isEmpty) {
          // No other claims, revert item to active
          await FirebaseFirestore.instance
              .collection('items')
              .doc(item.id)
              .update({
            'status': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Claim request cancelled.')),
          );
          // Refresh the search results
          setState(() {});
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
}

class _ItemResultCard extends StatefulWidget {
  final _ItemCard item;
  final Function(_ItemCard) onCommentPressed;
  final Function(_ItemCard, bool) onActionPressed; // bool = userAlreadyClaimed

  const _ItemResultCard({
    required this.item,
    required this.onCommentPressed,
    required this.onActionPressed,
  });

  @override
  State<_ItemResultCard> createState() => _ItemResultCardState();
}

class _ItemResultCardState extends State<_ItemResultCard> {
  late Future<bool> _userAlreadyClaimedFuture;

  @override
  void initState() {
    super.initState();
    _userAlreadyClaimedFuture = _checkIfUserAlreadyClaimed();
  }

  /// Check if the current user already has a pending/claimed request for this item
  Future<bool> _checkIfUserAlreadyClaimed() async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null || currentUser.uid.isEmpty) return false;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transaction_logs')
          .where('itemId', isEqualTo: widget.item.id)
          .where('claimerUid', isEqualTo: currentUser.uid)
          .get();

      // If any transaction_log exists (not rejected), user already claimed it
      return snapshot.docs.any((doc) => doc['status'] != 'Rejected');
    } catch (e) {
      debugPrint('Error checking claims: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final bool isFoundPost = widget.item.itemType == 'Found';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _navigateToDetail(context),
      child: Container(
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
                // Image Section
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
                      ? Image.network(
                          widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: Colors.white, size: 30)),
                        )
                      : const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Colors.white, size: 30)),
                ),
                const SizedBox(width: 12),
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
                                  widget.item.title,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.item.category,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppTheme.textGrey.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ),
                          // BADGE AND COMMENT SECTION
                          // BADGE AND COMMENT SECTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // REMOVED the 'if itemType == Lost' check so it shows for BOTH
                                  // Location: around
                                  IconButton(
                                      icon: const Icon(Icons.comment_outlined,
                                          size: 18,
                                          color: AppTheme.primaryBlue),
                                      onPressed: () => widget.onCommentPressed(
                                          widget.item) // Pass the 'item' object here
                                      ),
                                  const SizedBox(
                                      width:
                                          8), // Now always gives spacing to the badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isFoundPost
                                          ? AppTheme.accentGreen
                                          : AppTheme.errorRed,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.item.itemType,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              // ... [Processing Badges logic stays the same below this]
                              // Processing Badges (Requested/Claimable)
                              if (widget.item.status == 'Claimable') ...[
                                const SizedBox(height: 4),
                                _StatusBadge(
                                    text: 'Claimable', color: Colors.blue),
                              ],
                              if (widget.item.status == 'Requested') ...[
                                const SizedBox(height: 4),
                                _StatusBadge(
                                    text: 'Requested', color: Colors.orange),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey.withOpacity(0.9)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: widget.item.location),
                      _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          text: widget.item.dateFound),
                      _InfoRow(
                          icon: Icons.person_outline, text: widget.item.reportedBy),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Button Section
          FutureBuilder<bool>(
            future: _userAlreadyClaimedFuture,
            builder: (context, snapshot) {
              final userAlreadyClaimed = snapshot.data ?? false;

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: userAlreadyClaimed
                      ? Colors.orange.withOpacity(0.1)
                      : AppTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                ),
                child: TextButton(
                  onPressed: () => widget.onActionPressed(widget.item, userAlreadyClaimed),
                  child: Text(
                    userAlreadyClaimed
                        ? 'Cancel Request' // User already claimed, can cancel
                        : (isFoundPost
                            ? 'Claim Request item'
                            : 'Claim Found Item'),
                    style: TextStyle(
                        color: userAlreadyClaimed
                            ? Colors.orange
                            : AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              );
              },
            ),
          ]),
        ),
      );
  }
  

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          itemId: widget.item.id,
          title: widget.item.title,
          category: widget.item.category,
          description: widget.item.description,
          location: widget.item.location,
          dateFound: widget.item.dateFound,
          reportedBy: widget.item.reportedBy,
          reporterUid: widget.item.reporterUid,
          itemType: widget.item.itemType,
          status: widget.item.status,
          imageUrl: widget.item.imageUrl,
        ),
      ),
    );
  }
  

  // Helper widget for badges to keep code clean
  Widget _StatusBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

// 1. Fixed Model Class
class _ItemCard {
  final String id;
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
  final String? claimerUid;

  _ItemCard({
    required this.id,
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
    this.claimerUid,
  });
}

// 2. InfoRow Helper
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

// 3. Empty State Helper
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
            const Text(
              'No items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Status Badge Helper
class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
