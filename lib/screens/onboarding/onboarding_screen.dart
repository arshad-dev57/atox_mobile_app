import 'package:atox_mobile_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

// Design tokens (same as the rest of the app)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF8A8A95);
const Color _kBtnDark = Color(0xFF1B1B1F);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _slides = <_Slide>[
    _Slide(
      title: 'Watch ads,\nearn real money',
      body:
          'Watch short video ads and get paid for every one you finish. No limits, no experience needed.',
    ),
    _Slide(
      title: 'Invite friends,\ngrow your income',
      body:
          'Share your referral code and earn commission when your friends join and buy a plan.',
    ),
    _Slide(
      title: 'Withdraw your\nearnings daily',
      body:
          'Cash out to your bank account every day. Fast, simple and secure payments.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _goToLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF26A2E),
              Color(0xFFFF9A55),
              Color(0xFFFFE3CF),
              Colors.white,
            ],
            stops: [0.0, 0.32, 0.55, 0.68],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: brand + skip
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: _kOrange,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'ATOX',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLast ? 0 : 1,
                      child: GestureDetector(
                        onTap: isLast ? null : _goToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => _SlideView(
                    index: i,
                    slide: _slides[i],
                  ),
                ),
              ),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 26 : 8,
                    decoration: BoxDecoration(
                      color: active ? _kOrange : const Color(0xFFE2E2E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Black pill button with orange arrow circle
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Material(
                  color: _kBtnDark,
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: _next,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isLast ? 'Get started' : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: _kOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final String title;
  final String body;
  const _Slide({required this.title, required this.body});
}

// ───────────────────────── SLIDE VIEW ─────────────────────────

class _SlideView extends StatelessWidget {
  final int index;
  final _Slide slide;
  const _SlideView({required this.index, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
            child: _Illustration(index: index),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.body,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── ILLUSTRATION (2x2 tiles) ─────────────────────────
// Drawn with widgets only, so no image assets are needed. To use real images,
// replace a tile's child with Image.asset(...) inside a ClipRRect.

class _Illustration extends StatelessWidget {
  final int index;
  const _Illustration({required this.index});

  static const _shades = [
    Color(0xFFEE5A1F),
    Color(0xFFFF8A3D),
    Color(0xFFF9A04F),
    Color(0xFFFFB877),
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = _tilesFor(index);
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _tile(_shades[0], tiles[0])),
              const SizedBox(width: 12),
              Expanded(child: _tile(_shades[1], tiles[1])),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _tile(_shades[2], tiles[2])),
              const SizedBox(width: 12),
              Expanded(child: _tile(_shades[3], tiles[3])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(Color color, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  List<Widget> _tilesFor(int i) {
    switch (i) {
      case 0: // Watch & Earn
        return [
          _iconBadge(Icons.play_arrow_rounded),
          _textBadge('+₦10'),
          _ringBadge(),
          _iconBadge(Icons.ondemand_video_rounded, solid: false),
        ];
      case 1: // Invite
        return [
          _iconBadge(Icons.people_alt_rounded),
          _ringBadge(),
          _textBadge('10%'),
          _iconBadge(Icons.card_giftcard_rounded, solid: false),
        ];
      default: // Withdraw
        return [
          _textBadge('₦'),
          _iconBadge(Icons.account_balance_wallet_rounded, solid: false),
          _iconBadge(Icons.bolt_rounded),
          _ringBadge(),
        ];
    }
  }

  // White circle with orange icon
  Widget _iconBadge(IconData icon, {bool solid = true}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: solid ? Colors.white : Colors.white.withOpacity(0.25),
      ),
      child: Icon(
        icon,
        size: 38,
        color: solid ? _kOrange : Colors.white,
      ),
    );
  }

  // White rounded chip with orange text
  Widget _textBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: _kOrange,
        ),
      ),
    );
  }

  // White ring with orange dot (like the reference design)
  Widget _ringBadge() {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kOrange,
          ),
        ),
      ),
    );
  }
}