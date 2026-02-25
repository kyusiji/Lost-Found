import 'package:flutter/material.dart';
import 'package:lost_and_found/models/user_model.dart';
import 'package:lost_and_found/utils/app_theme.dart';

class TrackMyReportScreen extends StatefulWidget {
  final UserModel? user;
  const TrackMyReportScreen({super.key, this.user});

  @override
  State<TrackMyReportScreen> createState() => _TrackMyReportScreenState();
}

class _TrackMyReportScreenState extends State<TrackMyReportScreen> {
  bool _showingFoundItems = true; // true = Found Items, false = Lost Items

  // Mock data - replace with Firebase query filtered by user.uid
  // Mock data - replace with Firebase query filtered by user.uid
  final List<_TrackedItem> _foundItems = [];


  final List<_TrackedItem> _lostItems = [];

  @override
  Widget build(BuildContext context) {
    final items = _showingFoundItems ? _foundItems : _lostItems;
    final hasItems = items.isNotEmpty;

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

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: hasItems
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        _TrackedItemCard(item: items[i]),
                  )
                : _EmptyState(isFoundTab: _showingFoundItems),
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
            ),
            child: const Center(
              child: Text(
                '[Image]',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
                      onPressed: () {
                        // TODO: confirm delete dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delete — coming soon!')),
                        );
                      },
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
  final String title;
  final String location;
  final String dateFound;
  final String? handover;
  final String status; // 'Active' or 'Claimed'

  _TrackedItem({
    required this.title,
    required this.location,
    required this.dateFound,
    this.handover,
    required this.status,
  });
}