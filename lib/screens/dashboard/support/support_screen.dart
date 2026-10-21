import 'package:atox_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// Design tokens (same as the rest of the app)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kBtnDark = Color(0xFF1B1B1F);

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 18),
              _buildHeroCard(context),
              const SizedBox(height: 14),
              _buildFeatureRow(),
              const SizedBox(height: 14),
              _buildChannelButton(context),
              const SizedBox(height: 26),
              const Text(
                'Common topics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kInk,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap a topic to message us about it on WhatsApp',
                style: TextStyle(fontSize: 12, color: _kMuted),
              ),
              const SizedBox(height: 12),
              _topicRow(
                context,
                Icons.account_balance_wallet_rounded,
                'Recharge or withdrawal issues',
              ),
              _topicRow(
                context,
                Icons.inventory_2_rounded,
                'Product purchase questions',
              ),
              _topicRow(
                context,
                Icons.smart_display_rounded,
                'Ad task not working',
              ),
              _topicRow(
                context,
                Icons.people_alt_rounded,
                'Referral & team earnings',
              ),
              _topicRow(
                context,
                Icons.account_balance_rounded,
                'Bank account & payment details',
              ),
            ],
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

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.of(context).pop(),
        ),
        const Text(
          'Customer Care',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
        const SizedBox(width: 44, height: 44),
      ],
    );
  }

  // ───────────────────────── HERO CARD ─────────────────────────

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A3D), _kOrange],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _circle(140, Colors.white.withOpacity(0.10)),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: _circle(150, Colors.white.withOpacity(0.07)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: _kOrange,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WhatsApp Support',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Fast response, usually within minutes',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xDDFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // number box
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp number',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppConstants.whatsappNumber,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: AppConstants.whatsappNumber),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Number copied'),
                                backgroundColor: _kInk,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          },
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: _kOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // black pill with orange arrow circle
                Material(
                  color: _kBtnDark,
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => _launchWhatsApp(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 7, 7, 7),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Chat on WhatsApp',
                              style: TextStyle(
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
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  // ───────────────────────── FEATURES ─────────────────────────

  Widget _buildFeatureRow() {
    return Row(
      children: [
        Expanded(child: _featureCard(Icons.bolt_rounded, 'Fast\nresponse')),
        const SizedBox(width: 8),
        Expanded(child: _featureCard(Icons.schedule_rounded, '24/7\nsupport')),
        const SizedBox(width: 8),
        Expanded(child: _featureCard(Icons.lock_rounded, 'Secure &\nprivate')),
        const SizedBox(width: 8),
        Expanded(child: _featureCard(Icons.flag_rounded, 'Nigeria\nbased')),
      ],
    );
  }

  Widget _featureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kOrangeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: _kOrange),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── CHANNEL BUTTON ─────────────────────────

  Widget _buildChannelButton(BuildContext context) {
    return Material(
      color: _kOrangeSoft,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _launchWhatsAppChannel(),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign_rounded, size: 20, color: _kOrange),
              SizedBox(width: 8),
              Text(
                'Join Our WhatsApp Channel',
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
    );
  }

  // ───────────────────────── TOPICS ─────────────────────────

  Widget _topicRow(BuildContext context, IconData icon, String topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _launchWhatsApp(message: 'Hello, I need help with: $topic'),
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
                  child: Text(
                    topic,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                    ),
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

  // ───────────────────────── LAUNCHERS ─────────────────────────
  // launchUrl is used directly (no canLaunchUrl): on Android 11+ canLaunchUrl
  // can return false for wa.me links unless <queries> is set in the manifest,
  // which silently blocked WhatsApp from opening.

  Future<void> _launchWhatsApp({String? message}) async {
    final number = AppConstants.whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
    final query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    final uri = Uri.parse('https://wa.me/$number$query');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _launchWhatsAppChannel() async {
    final uri = Uri.parse(AppConstants.whatsappChannel);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}