import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/action_button.dart';
import 'tasks/tasks_screen.dart';
import 'products/products_screen.dart';
import 'profile/profile_screen.dart';
import 'team/team_screen.dart';
import 'notifications/notifications_screen.dart';
import 'support/support_screen.dart';
import 'vtu/vtu_screen.dart';
import 'freemode/free_mode_screen.dart';
import '../../widgets/modals/recharge_modal.dart';
import '../../widgets/modals/withdraw_modal.dart';
import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _hasActivePlan = false;
  double _todayEarnings = 0;
  int _activePlansCount = 0;

  @override
  void initState() {
    super.initState();
    _checkActivePlan();
  }

  Future<void> _checkActivePlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final dbService = DatabaseService();
    final purchases = await dbService.getUserPurchases(user.uid);
    
    // An active plan is one whose expireAt is in the future
    final activePurchases = purchases.where((p) => 
      p.expireAt == null || p.expireAt!.isAfter(DateTime.now())
    ).toList();
    
    double todayTotal = 0;
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    
    for (var plan in activePurchases) {
      final progress = await dbService.getAdProgress(user.uid, plan.productId, todayKey);
      todayTotal += (progress['earned'] as num).toDouble();
    }
    
    if (mounted) {
      setState(() {
        _hasActivePlan = activePurchases.isNotEmpty;
        _activePlansCount = activePurchases.length;
        _todayEarnings = todayTotal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _hasActivePlan ? const TasksScreen() : const FreeModeScreen(),
          const ProductsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.play_circle_outline,
                  activeIcon: Icons.play_circle,
                  label: _hasActivePlan ? 'Tasks' : 'Free',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag,
                  label: 'Products',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, _) {
        final user = userProvider.userData;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Welcome Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, 👋',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Here's what's happening with your earnings",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'NIGERIA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    title: 'Balance',
                    value: CurrencyFormatter.format(user?.balance ?? 0),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                  StatCard(
                    title: 'Referral Balance',
                    value: CurrencyFormatter.format(user?.referralBalance ?? 0),
                    icon: Icons.trending_up_outlined,
                    iconColor: AppColors.secondary,
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                  ),
                  StatCard(
                    title: 'Active Plans',
                    value: _activePlansCount.toString(),
                    icon: Icons.shopping_bag_outlined,
                    iconColor: Colors.purple,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                  ),
                  StatCard(
                    title: "Today's Earnings",
                    value: CurrencyFormatter.format(_todayEarnings),
                    icon: Icons.today_outlined,
                    iconColor: AppColors.accent,
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Recharge',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const RechargeModal(),
                        );
                      },
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      icon: Icons.payments_outlined,
                      label: 'Withdraw',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const WithdrawModal(),
                        );
                      },
                      gradient: LinearGradient(
                        colors: [AppColors.accent, Colors.orange],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Withdrawal Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.schedule_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📌 Withdrawal Schedule',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Every Friday from 8 AM to 8 PM (Minimum ₦5,000)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Quick Access Section
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickAccessItem(
                icon: Icons.people_outline,
                title: 'Team & Referrals',
                subtitle: 'Invite friends and earn commissions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeamScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickAccessItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Updates on your requests and account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickAccessItem(
                icon: Icons.support_agent_outlined,
                title: 'Customer Care',
                subtitle: 'We\'re here to help — reach us anytime',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickAccessItem(
                icon: Icons.phone_android_outlined,
                title: 'Data & Airtime',
                subtitle: 'Purchase airtime and data bundles instantly',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VTUScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
