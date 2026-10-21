import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../utils/constants.dart';
import '../../../../services/database_service.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/user_provider.dart';

// Design tokens (same as dashboard)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kBtnDark = Color(0xFF1B1B1F);
const Color _kGreen = Color(0xFF2BB673);

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<UserModel> _referrals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  Future<void> _fetchReferrals() async {
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    if (user != null && user.uid != null) {
      final refs = await DatabaseService().getUserReferrals(user.uid!);
      if (mounted) {
        setState(() {
          _referrals = refs;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _kOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userData;
    final uid = user?.uid;
    final fallbackCode = (uid != null && uid.length >= 6)
        ? uid.substring(0, 6).toUpperCase()
        : 'CODE';
    final inviteCode = user?.myInvitationCode ?? 'ATOX-$fallbackCode';
    final inviteLink = 'https://atox-earning.com/register?ref=$inviteCode';

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _kOrange,
          onRefresh: _fetchReferrals,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 18),
                _buildStatRow(),
                const SizedBox(height: 16),
                _buildCodeCard(inviteCode, inviteLink),
                const SizedBox(height: 24),
                _sectionHeader('Your referrals', '${_referrals.length} total'),
                const SizedBox(height: 12),
                _buildReferralList(),
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
    // Works both as a pushed screen (back button) and as a bottom-nav tab.
    final canPop = Navigator.of(context).canPop();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        canPop
            ? _circleBtn(
                Icons.arrow_back_ios_new_rounded,
                () => Navigator.of(context).pop(),
              )
            : const SizedBox(width: 44, height: 44),
        const Text(
          'Team & Referrals',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
        _circleBtn(Icons.refresh_rounded, () {
          setState(() => _loading = true);
          _fetchReferrals();
        }),
      ],
    );
  }

  // ───────────────────────── STATS ─────────────────────────

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Referrals',
            '${_referrals.length}',
            Icons.north_east_rounded,
            _kGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard('Level 1', '10%', Icons.north_east_rounded, _kGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Level 2',
            '3%',
            Icons.south_east_rounded,
            const Color(0xFFE5484D),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData arrow, Color color) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
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
              Text(label, style: const TextStyle(fontSize: 12, color: _kMuted)),
              Icon(arrow, size: 15, color: color),
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

  // ───────────────────────── CODE CARD ─────────────────────────

  Widget _buildCodeCard(String inviteCode, String inviteLink) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          const Text(
            'Your referral code',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Share this code or link. When they register with it, you earn 10% of their first purchase (level 2 gets 3%).',
            style: TextStyle(fontSize: 12, color: _kMuted, height: 1.45),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _kOrangeSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              inviteCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: _kOrange,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Black pill with orange circle (like "Get started")
          Material(
            color: _kBtnDark,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => _copyToClipboard(inviteCode, 'Referral Code Copied!'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 7, 7, 7),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Copy Code',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: _kOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: _kOrangeSoft,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () =>
                  _copyToClipboard(inviteLink, 'Referral Link Copied!'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link_rounded, size: 20, color: _kOrange),
                    SizedBox(width: 8),
                    Text(
                      'Copy Invite Link',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kOrange,
                      ),
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

  // ───────────────────────── REFERRALS LIST ─────────────────────────

  Widget _sectionHeader(String title, String trailing) {
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
          trailing,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildReferralList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: _kOrange)),
      );
    }

    if (_referrals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 32,
              backgroundColor: _kOrangeSoft,
              child: Icon(Icons.people_alt_rounded, size: 30, color: _kOrange),
            ),
            SizedBox(height: 16),
            Text(
              'No referrals yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kInk,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Share your code and start earning',
              style: TextStyle(fontSize: 12, color: _kMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _referrals.length,
      itemBuilder: (context, index) {
        final refUser = _referrals[index];
        final email = refUser.email ?? 'Unknown User';
        final initial = (refUser.email != null && refUser.email!.isNotEmpty)
            ? refUser.email!.substring(0, 1).toUpperCase()
            : 'U';
        final joined = refUser.createdAt?.toString().substring(0, 10) ?? 'Unknown';

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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kOrangeSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _kOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Joined $joined',
                        style: const TextStyle(fontSize: 11, color: _kMuted),
                      ),
                    ],
                  ),
                ),
                if (refUser.referralBonusPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Bonus paid',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}