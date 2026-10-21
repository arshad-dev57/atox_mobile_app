import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../ads/ad_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import 'tasks/tasks_screen.dart';
import 'profile/profile_screen.dart';
import 'team/team_screen.dart';
import 'notifications/notifications_screen.dart';
import 'support/support_screen.dart';
import 'vtu/vtu_screen.dart';
import 'freemode/free_mode_screen.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/modals/recharge_modal.dart';
import '../../widgets/modals/withdraw_modal.dart';
import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Design tokens (orange theme)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kNavDark = Color(0xFF1B1B1F);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  int _range = 0; // UI-only segmented filter (Today/Week/Month/Year)
  bool _hasActivePlan = false;
  double _todayEarnings = 0;
  int _activePlansCount = 0;

  static const _ranges = ['Today', 'Week', 'Month', 'Year'];

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkActivePlan();
  }

  Future<void> _checkActivePlan() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dbService = DatabaseService();
    final purchases = await dbService.getUserPurchases(user.uid);

    final activePurchases = purchases
        .where(
          (p) => p.expiresAt == null || p.expiresAt!.isAfter(DateTime.now()),
        )
        .toList();

    double todayTotal = 0;
    final todayKey = DateTime.now().toIso8601String().split('T')[0];

    final results = await Future.wait(
      activePurchases.map(
        (plan) => dbService.getAdProgress(user.uid, plan.productId, todayKey),
      ),
    );
    for (final progress in results) {
      todayTotal += (progress['earned'] as num?)?.toDouble() ?? 0;
    }

    // Always include Watch & Earn (freemode) — previously missing, so
    // dashboard "Today's earnings" stayed 0 for free users after watching ads.
    final freemodeProgress = await dbService.getAdProgress(
      user.uid,
      AppConstants.watchAndEarnId,
      todayKey,
    );
    todayTotal += (freemodeProgress['earned'] as num?)?.toDouble() ?? 0;

    if (mounted) {
      setState(() {
        _hasActivePlan = activePurchases.isNotEmpty;
        _activePlansCount = activePurchases.length;
        _todayEarnings = todayTotal;
      });
    }
  }

  void _openSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBg,
      drawer: AppDrawer(
        hasActivePlan: _hasActivePlan,
        onSelectHome: () => _onTabSelected(0),
        onSelectEarn: () => _onTabSelected(1),
        onSelectProfile: () => _onTabSelected(3),
        onLogout: _logout,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _hasActivePlan
              ? TasksScreen(onOpenMenu: _openDrawer)
              : FreeModeScreen(onOpenMenu: _openDrawer),
          const TeamScreen(),
          ProfileScreen(onOpenMenu: _openDrawer),
        ],
      ),
      // Banner sits above the pill nav with clear spacing (policy-safe).
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          _buildFloatingNav(),
        ],
      ),
    );
  }

  /// Called when the bottom tab index changes — counts toward interstitial cap.
  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    // Refresh home stats when returning (includes Watch & Earn freemode earnings).
    if (index == 0) _checkActivePlan();
    if (Get.isRegistered<AdService>()) {
      AdService.to.onScreenChanged();
    }
  }

  // ───────────────────────── FLOATING PILL NAV ─────────────────────────

  Widget _buildFloatingNav() {
    final items = <IconData>[
      Icons.home_rounded,
      Icons.play_arrow_rounded,
      Icons.people_alt_rounded,
      Icons.person_rounded,
    ];
    return Container(
      color: _kBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(60, 6, 60, 14),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _kNavDark,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (i) {
                final active = _currentIndex == i;
                return GestureDetector(
                  onTap: () => _onTabSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? _kOrange : const Color(0xFF2C2C31),
                    ),
                    child: Icon(
                      items[i],
                      size: 22,
                      color: active ? Colors.white : const Color(0xFFD9D9DE),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── HOME TAB ─────────────────────────

  Widget _buildHomeTab() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, _) {
        final user = userProvider.userData;

        if (userProvider.isLoading && user == null) {
          return const Center(child: CircularProgressIndicator(color: _kOrange));
        }

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: _kOrange,
            onRefresh: _checkActivePlan,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 18),
                  _buildRangePills(),
                  const SizedBox(height: 16),
                  _buildStatGrid(user),
                  const SizedBox(height: 16),
                  _buildBalanceCard(user),
                  const SizedBox(height: 24),
                  _sectionHeader('Quick access', 'View more'),
                  const SizedBox(height: 12),
                  _buildQuickList(),
                  const SizedBox(height: 16),
                  _buildWithdrawNote(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: _kInk),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(Icons.menu_rounded, _openDrawer),
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
        _circleBtn(Icons.logout_rounded, _logout),
      ],
    );
  }

  // ───────────────────────── RANGE PILLS ─────────────────────────

  Widget _buildRangePills() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(_ranges.length, (i) {
          final active = _range == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _range = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _kOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    _ranges[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : _kMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────────── STAT GRID ─────────────────────────

  Widget _buildStatGrid(dynamic user) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.75,
      children: [
        _statCard(
          'Referral',
          CurrencyFormatter.format(user?.referralBalance ?? 0),
          Icons.north_east_rounded,
          const Color(0xFF2BB673),
        ),
        _statCard(
          'Active plans',
          _activePlansCount.toString(),
          Icons.north_east_rounded,
          const Color(0xFF2BB673),
        ),
        _statCard(
          "Today's earnings",
          CurrencyFormatter.format(_todayEarnings),
          Icons.north_east_rounded,
          const Color(0xFF2BB673),
        ),
        _statCard(
          'Min. withdraw',
          '₦2,000',
          Icons.south_east_rounded,
          const Color(0xFFE5484D),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData arrow, Color arrowColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
              Icon(arrow, size: 16, color: arrowColor),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _kInk,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BALANCE CARD (wave) ─────────────────────────

  Widget _buildBalanceCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                    const Text(
                      'Overall balance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.format(user?.balance ?? 0),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(fontSize: 10, color: _kMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(_todayEarnings),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Decorative wave (not real data)
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(painter: _WavePainter()),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _pillAction(
                  'Recharge',
                  Icons.add_rounded,
                  true,
                  () => _openSheet(const RechargeModal()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pillAction(
                  'Withdraw',
                  Icons.arrow_upward_rounded,
                  false,
                  () => _openSheet(const WithdrawModal()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillAction(
    String label,
    IconData icon,
    bool filled,
    VoidCallback onTap,
  ) {
    return Material(
      color: filled ? _kOrange : _kOrangeSoft,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: filled ? Colors.white : _kOrange),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : _kOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── QUICK ACCESS LIST ─────────────────────────

  Widget _sectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _kInk,
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickList() {
    return Column(
      children: [
        _listRow(
          Icons.people_alt_rounded,
          'Team & Referrals',
          'Invite friends and earn commissions',
          () => _push(const TeamScreen()),
        ),
        _listRow(
          Icons.notifications_rounded,
          'Notifications',
          'Updates on your requests and account',
          () => _push(const NotificationsScreen()),
        ),
        _listRow(
          Icons.support_agent_rounded,
          'Customer Care',
          "We're here to help — reach us anytime",
          () => _push(const SupportScreen()),
        ),
        _listRow(
          Icons.phone_android_rounded,
          'Data & Airtime',
          'Purchase airtime and data instantly',
          () => _push(const VTUScreen()),
        ),
      ],
    );
  }

  Widget _listRow(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kOrangeSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: _kOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: _kMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: _kOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kOrangeSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.schedule_rounded, color: _kOrange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Withdrawals: Daily • Minimum ₦2,000 • 1 per day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── WAVE PAINTER ─────────────────────────

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const pts = [0.55, 0.62, 0.5, 0.38, 0.52, 0.66, 0.5, 0.42, 0.34, 0.4];
    final dx = size.width / (pts.length - 1);
    final points = [
      for (int i = 0; i < pts.length; i++)
        Offset(i * dx, size.height * pts[i]),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      line.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kOrange.withOpacity(0.25), _kOrange.withOpacity(0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = _kOrange.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // highlighted point
    final dot = points[6];
    canvas.drawCircle(dot, 9, Paint()..color = _kOrange.withOpacity(0.2));
    canvas.drawCircle(dot, 5, Paint()..color = _kOrange);
    canvas.drawCircle(dot, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}