import 'package:atox_mobile_app/utils/constants.dart';
import 'package:atox_mobile_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../ads/ad_service.dart';
import '../../../providers/user_provider.dart';
import '../../../services/database_service.dart';

// Design tokens (same as dashboard)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kBtnDark = Color(0xFF1B1B1F);

/// "Watch and Earn" (formerly "Free Mode"): for users with no active VIP plan.
/// Watch a full AdMob rewarded video ad, then earn ₦10 automatically.
class FreeModeScreen extends StatefulWidget {
  final VoidCallback? onOpenMenu;
  const FreeModeScreen({super.key, this.onOpenMenu});

  @override
  State<FreeModeScreen> createState() => _FreeModeScreenState();
}

class _FreeModeScreenState extends State<FreeModeScreen> {
  final DatabaseService _db = DatabaseService();

  bool _loading = true;
  int _adsWatched = 0;
  double _todayEarned = 0;
  bool _busy = false;

  String get _todayKey => DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    _loadProgress();
    // Prefetch rewarded ad so Watch is ready faster.
    if (Get.isRegistered<AdService>()) {
      AdService.to.loadRewarded();
    }
  }

  Future<void> _loadProgress() async {
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    if (user?.uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final progress = await _db.getAdProgress(
        user!.uid!,
        AppConstants.watchAndEarnId,
        _todayKey,
      );
      if (mounted) {
        setState(() {
          _adsWatched = (progress['adsWatched'] as num?)?.toInt() ?? 0;
          _todayEarned = (progress['earned'] as num?)?.toDouble() ?? 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Shows AdMob rewarded video; credits balance only after the reward callback.
  Future<void> _watchAndEarn() async {
    if (_busy) return;

    if (!Get.isRegistered<AdService>() || !AdService.to.isSupported) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ads only work on Android/iOS. Run on a phone or emulator.',
          ),
        ),
      );
      return;
    }

    setState(() => _busy = true);

    var earnedFromAd = false;
    try {
      final shown = await AdService.to.showRewardedAd(
        onReward: () {
          earnedFromAd = true;
        },
      );

      if (!mounted) return;

      if (!shown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not ready yet — try again in a moment.'),
          ),
        );
        return;
      }

      if (!earnedFromAd) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watch the full ad to earn your reward.'),
          ),
        );
        return;
      }

      await _creditReward();
    } catch (e) {
      debugPrint('[WatchAndEarn] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not complete reward: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Writes adProgress + increments user balance / totalEarned in Firestore.
  Future<void> _creditReward() async {
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    if (user?.uid == null) {
      throw Exception('User not loaded. Please reopen the app and try again.');
    }

    final uid = user!.uid!;
    final earning = AppConstants.watchAndEarnPerAd.toDouble();
    final newWatched = _adsWatched + 1;
    final newEarned = _todayEarned + earning;

    // 1) Daily progress doc (adProgress/{uid}_freemode_{date})
    await _db.updateAdProgress(
      uid,
      AppConstants.watchAndEarnId,
      _todayKey,
      newWatched,
      newEarned,
    );

    // 2) Credit wallet — UserProvider stream updates dashboard balance live.
    await _db.incrementUserData(
      uid,
      balanceDelta: earning,
      totalEarnedDelta: earning,
    );

    if (!mounted) return;
    setState(() {
      _adsWatched = newWatched;
      _todayEarned = newEarned;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned ${CurrencyFormatter.format(earning)}!'),
        backgroundColor: _kOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final perAd = AppConstants.watchAndEarnPerAd.toDouble();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _kOrange))
            : RefreshIndicator(
                color: _kOrange,
                onRefresh: _loadProgress,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 18),
                      _buildHeroCard(perAd),
                      const SizedBox(height: 12),
                      _buildStatRow(),
                      const SizedBox(height: 24),
                      _sectionHeader('How it works'),
                      const SizedBox(height: 12),
                      _stepRow(
                        Icons.touch_app_rounded,
                        'Tap Watch',
                        'Press the button to start an AdMob video ad',
                        '1',
                      ),
                      _stepRow(
                        Icons.play_circle_rounded,
                        'Watch the full video',
                        'Stay until the rewarded ad finishes',
                        '2',
                      ),
                      _stepRow(
                        Icons.emoji_events_rounded,
                        'Earn automatically',
                        'Get ${CurrencyFormatter.format(perAd)} added to your balance',
                        '3',
                      ),
                      const SizedBox(height: 8),
                      _buildWarning(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
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
                color: Colors.black.withValues(alpha: 0.04),
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
        widget.onOpenMenu != null
            ? _circleBtn(Icons.menu_rounded, widget.onOpenMenu)
            : const SizedBox(width: 44, height: 44),
        const Text(
          'Watch & Earn',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
        _circleBtn(Icons.refresh_rounded, () {
          setState(() => _loading = true);
          _loadProgress();
        }),
      ],
    );
  }

  // ───────────────────────── HERO CARD ─────────────────────────

  Widget _buildHeroCard(double perAd) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                      "Today's earnings",
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
                        CurrencyFormatter.format(_todayEarned),
                        style: const TextStyle(
                          fontSize: 34,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _kOrangeSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Per ad',
                      style: TextStyle(fontSize: 10, color: _kMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(perAd),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _kOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildActionButton(perAd),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Example: 1,000 ads ≈ ${CurrencyFormatter.format(1000 * perAd)}',
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(double perAd) {
    return Material(
      color: _kBtnDark,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: _busy ? null : _watchAndEarn,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Watch Ad & Earn ${CurrencyFormatter.format(perAd)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _kOrange,
                  shape: BoxShape.circle,
                ),
                child: _busy
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── STAT ROW ─────────────────────────

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Ads watched',
            '$_adsWatched',
            Icons.north_east_rounded,
            const Color(0xFF2BB673),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Status',
            _busy ? 'Playing' : 'Ready',
            _busy ? Icons.more_horiz_rounded : Icons.check_rounded,
            _busy ? _kMuted : const Color(0xFF2BB673),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Text(label, style: const TextStyle(fontSize: 12, color: _kMuted)),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kInk,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── HOW IT WORKS ─────────────────────────

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _kInk,
      ),
    );
  }

  Widget _stepRow(IconData icon, String title, String subtitle, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
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
                    style: const TextStyle(fontSize: 11, color: _kMuted),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kOrangeSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _kOrange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Watch and Earn is for users without a VIP plan. Buy any plan from Products for higher daily income.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kInk,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
