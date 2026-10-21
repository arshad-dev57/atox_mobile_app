import 'package:flutter/material.dart';

import '../../../widgets/ads/native_ad_widget.dart';
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
              _buildHero(),
              const SizedBox(height: 16),
              _buildFeatureRow(),
              const SizedBox(height: 16),
              _buildMissionCard(),
              // Native ad — below content, clearly labeled, not near CTAs.
              const SizedBox(height: 24),
              const NativeAdWidget(),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _kInk,
              ),
            ),
          ),
        ),
        const Text(
          'About Us',
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

  Widget _buildHero() {
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
            child: _circle(150, Colors.white.withOpacity(0.10)),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: _circle(170, Colors.white.withOpacity(0.07)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Atox',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _kOrange,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Welcome to ATOX',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ATOX is a revolutionary digital platform designed to help users earn daily income through simple tasks like watching ads, while also providing seamless VTU services for airtime and data top-ups.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Colors.white.withOpacity(0.92),
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


  Widget _buildFeatureRow() {
    return Row(
      children: [
        Expanded(
          child: _featureCard(Icons.play_circle_rounded, 'Watch ads\n& earn'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _featureCard(Icons.phone_android_rounded, 'Airtime\n& data'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _featureCard(Icons.payments_rounded, 'Daily\nincome'),
        ),
      ],
    );
  }

  Widget _featureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kOrangeSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: _kOrange),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kOrangeSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: _kOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'To empower individuals across Nigeria by providing a reliable and sustainable stream of passive income, right from their smartphones.',
            style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF55555F)),
          ),
        ],
      ),
    );
  }
}