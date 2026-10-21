import 'package:flutter/material.dart';
import '../../screens/dashboard/team/team_screen.dart';
import '../../screens/dashboard/notifications/notifications_screen.dart';
import '../../screens/dashboard/support/support_screen.dart';
import '../../screens/dashboard/vtu/vtu_screen.dart';

// Design tokens (same as dashboard)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kRed = Color(0xFFE5484D);
const Color _kRedSoft = Color(0xFFFDECEC);

/// Slide-out menu. Items either switch a dashboard tab via callbacks or
/// push a full page. Logout triggers [onLogout].
class AppDrawer extends StatelessWidget {
  final bool hasActivePlan;
  final VoidCallback onSelectHome;
  final VoidCallback onSelectEarn;
  final VoidCallback onSelectProfile;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.hasActivePlan,
    required this.onSelectHome,
    required this.onSelectEarn,
    required this.onSelectProfile,
    required this.onLogout,
  });

  void _push(BuildContext context, Widget page) {
    // Drawer is already closed by _item's Navigator.pop before onTap runs.
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _kBg,
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                children: [
                  _sectionLabel('Main'),
                  _item(
                    context,
                    Icons.home_rounded,
                    'Home',
                    'Your dashboard overview',
                    onSelectHome,
                  ),
                  _item(
                    context,
                    hasActivePlan
                        ? Icons.list_alt_rounded
                        : Icons.play_circle_rounded,
                    hasActivePlan ? 'Tasks' : 'Watch and Earn',
                    hasActivePlan
                        ? 'Complete your daily tasks'
                        : 'Watch ads and get paid',
                    onSelectEarn,
                  ),
                  _item(
                    context,
                    Icons.people_alt_rounded,
                    'Team & Referrals',
                    'Invite friends and earn',
                    () => _push(context, const TeamScreen()),
                  ),
                  const SizedBox(height: 8),
                  _sectionLabel('Services'),
                  _item(
                    context,
                    Icons.phone_android_rounded,
                    'Data & Airtime',
                    'Instant top-up',
                    () => _push(context, const VTUScreen()),
                  ),
                  _item(
                    context,
                    Icons.notifications_rounded,
                    'Notifications',
                    'Account updates',
                    () => _push(context, const NotificationsScreen()),
                  ),
                  _item(
                    context,
                    Icons.support_agent_rounded,
                    'Customer Care',
                    "We're here to help",
                    () => _push(context, const SupportScreen()),
                  ),
                  const SizedBox(height: 8),
                  _sectionLabel('Account'),
                  _item(
                    context,
                    Icons.person_rounded,
                    'Profile',
                    'Settings and security',
                    onSelectProfile,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: _logoutButton(context),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kOrange,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: _circle(110, Colors.white.withOpacity(0.12)),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _circle(120, Colors.white.withOpacity(0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: _kOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ATOX Earning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Watch. Invite. Earn.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ───────────────────────── ITEMS ─────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: _kMuted,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.pop(context); // close drawer first
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _kOrangeSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: _kOrange, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: _kMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _kMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Material(
      color: _kRedSoft,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () {
          Navigator.pop(context);
          onLogout();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 20, color: _kRed),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}