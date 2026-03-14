import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';
import 'package:intl/intl.dart';

class AdminLogsScreen extends StatefulWidget {
  final UserModel? user;
  const AdminLogsScreen({super.key, this.user});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  DateTime? _filterDate;
  String _statusFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // --- LOGIC: DELETE ---
  Future<void> _deleteLog(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record?"),
        content: const Text("This will permanently remove this log."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('transaction_logs')
          .doc(docId)
          .delete();
    }
  }

  // --- LOGIC: REVERT ---
  Future<void> _handleRevert(String docId, String itemId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Revert Claim?"),
        content: const Text("Reset status to Pending and restore item to claimable?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text("Revert", style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
    if (confirm == true) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      // 1. Revert the transaction log
      batch.update(
        FirebaseFirestore.instance.collection('transaction_logs').doc(docId),
        {
          'status': 'Pending',
          'verificationPhoto': null,
          'approvedAt': null,
          'processedByAdmin': null,
        }
      );
      
      // 2. Restore the item to claimable status
      batch.update(
        FirebaseFirestore.instance.collection('items').doc(itemId),
        {
          'status': 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        }
      );
      
      await batch.commit();
    }
  }

  // --- LOGIC: APPROVE & AUTO-REJECT DUPLICATES ---
  Future<void> _handleApproval(String docId, String itemId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()));

      String fileName =
          'verifications/${docId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(await photo.readAsBytes());
      String downloadUrl = await ref.getDownloadURL();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Approve the selected log
      DocumentReference approvedRef =
          FirebaseFirestore.instance.collection('transaction_logs').doc(docId);
      batch.update(approvedRef, {
        'status': 'Claimed',
        'verificationPhoto': downloadUrl,
        'approvedAt': FieldValue.serverTimestamp(),
        'processedByAdmin': widget.user?.firstName ?? 'Admin',
      });

      // 2. Update the Item status to 'claimed' so it doesn't appear as claimable anymore
      DocumentReference itemRef =
          FirebaseFirestore.instance.collection('items').doc(itemId);
      batch.update(itemRef, {
        'status': 'claimed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Allow other "Pending" requests to remain pending for admin review
      // (Removed auto-rejection to allow admin to review multiple claims)
      // This gives admin flexibility to approve the legitimate claimant and manually reject trolls

      await batch.commit();
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
    }
  }

  // --- LOGIC: REJECT CLAIM ---
  Future<void> _handleRejectClaim(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Claim?"),
        content: const Text("Mark this claim request as rejected?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text("Reject", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('transaction_logs')
            .doc(docId)
            .update({
          'status': 'Rejected',
          'approvedAt': FieldValue.serverTimestamp(),
          'processedByAdmin': widget.user?.firstName ?? 'Admin',
        });
      } catch (e) {
        debugPrint('Error rejecting claim: $e');
      }
    }
  }


  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        title: const Text("Transaction Logs",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin: ${widget.user?.firstName ?? 'Admin'}",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: "Search item...",
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: AppTheme.bgLight,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          onChanged: (val) =>
                              setState(() => _statusFilter = val!),
                          // ADDED: 'Rejected' to the items list
                          items: ['All', 'Pending', 'Claimed', 'Rejected']
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 13))))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                          _filterDate == null
                              ? Icons.calendar_month_outlined
                              : Icons.close,
                          color: AppTheme.primaryBlue),
                      onPressed: () => _filterDate == null
                          ? _selectDate(context)
                          : setState(() => _filterDate = null),
                    ),
                  ],
                ),
                if (_filterDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        "Date: ${DateFormat('MM/dd/yyyy').format(_filterDate!)}",
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name =
                      (data['itemName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (docs.isEmpty)
                  return const Center(child: Text("No records found."));

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isClaimed = data['status'] == 'Claimed';
                    bool isRejected = data['status'] == 'Rejected';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: ExpansionTile(
                        shape: const Border(),
                        title: Text(data['itemName'] ?? "Item",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Status: ${data['status']}",
                            style: TextStyle(
                                color: isClaimed
                                    ? Colors.green
                                    : (isRejected ? Colors.red : Colors.orange),
                                fontSize: 13)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildImageColumn(
                                            "Item", data['itemOriginalImage'])),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: _buildImageColumn("Verification",
                                            data['verificationPhoto'],
                                            isPlaceholder: true)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _iconRow(Icons.location_on_outlined,
                                    data['itemLocation'] ?? "Unknown"),
                                const SizedBox(height: 8),
                                _iconRow(Icons.calendar_today_outlined,
                                    _formatTimestamp(data['claimDate'])),
                                const SizedBox(height: 8),
                                _iconRow(Icons.description_outlined,
                                    data['itemDescription'] ?? "No description",
                                    isEllipsis: true),
                                const SizedBox(height: 15),
                                Text(
                                    "${(data['itemAuthorType'] ?? 'Found').toLowerCase()} by: ${data['itemAuthorName'] ?? 'N/A'}",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                                Text("claimer: ${data['claimerName'] ?? 'N/A'}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                if (isClaimed || isRejected)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                          "${isRejected ? 'rejected' : 'approved'} by: ${data['processedByAdmin'] ?? 'Admin'}",
                                          style: TextStyle(
                                              color: isRejected
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(
                                          "${isRejected ? 'rejected' : 'approved'} date: ${_formatTimestamp(data['approvedAt'])}",
                                          style: TextStyle(
                                              color: isRejected
                                                  ? Colors.red
                                                      .withOpacity(0.7)
                                                  : Colors.green
                                                      .withOpacity(0.7),
                                              fontSize: 12)),
                                    ],
                                  ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    if (!isClaimed && !isRejected)
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () => _handleApproval(
                                                  doc.id, data['itemId'] ?? ''),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green),
                                              child: const Text("APPROVE",
                                                  style: TextStyle(
                                                      color: Colors.white)))),
                                    if (!isClaimed && !isRejected)
                                      const SizedBox(width: 8),
                                    if (!isClaimed && !isRejected)
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () =>
                                                  _handleRejectClaim(doc.id),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red),
                                              child: const Text("REJECT",
                                                  style: TextStyle(
                                                      color: Colors.white)))),
                                    if (isClaimed)
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () =>
                                                  _handleRevert(doc.id, data['itemId'] ?? ''),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange),
                                              child: const Text("REVERT",
                                                  style: TextStyle(
                                                      color: Colors.white)))),
                                    const SizedBox(width: 8),
                                    IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _deleteLog(doc.id)),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
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

  Widget _iconRow(IconData icon, String text, {bool isEllipsis = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: isEllipsis ? 1 : null,
            overflow: isEllipsis ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    DateTime date = (timestamp as Timestamp).toDate();
    return DateFormat('MM/dd/yyyy').format(date);
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = FirebaseFirestore.instance.collection('transaction_logs');
    if (_statusFilter != 'All')
      query = query.where('status', isEqualTo: _statusFilter);
    if (_filterDate != null) {
      Timestamp start = Timestamp.fromDate(
          DateTime(_filterDate!.year, _filterDate!.month, _filterDate!.day));
      Timestamp end = Timestamp.fromDate(DateTime(
          _filterDate!.year, _filterDate!.month, _filterDate!.day + 1));
      query = query
          .where('claimDate', isGreaterThanOrEqualTo: start)
          .where('claimDate', isLessThan: end);
    }
    return query.orderBy('claimDate', descending: true).snapshots();
  }

  Widget _buildImageColumn(String label, String? url,
      {bool isPlaceholder = false}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url != null
              ? Image.network(url,
                  height: 100, width: double.infinity, fit: BoxFit.cover)
              : Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Icon(isPlaceholder ? Icons.camera_alt : Icons.image,
                      color: Colors.grey)),
        ),
      ],
    );
  }
}
