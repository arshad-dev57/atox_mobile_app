import 'package:atox_mobile_app/models/plan_model.dart';
import 'package:atox_mobile_app/utils/constants.dart';
import 'package:atox_mobile_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import '../../../widgets/modals/payment_modal.dart';
import 'package:provider/provider.dart';
import 'package:atox_mobile_app/providers/user_provider.dart';
import 'package:atox_mobile_app/services/database_service.dart';
import 'package:atox_mobile_app/models/payment_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<PaymentModel> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userData;
    if (user != null && user.uid != null) {
      final payments = await DatabaseService().getUserPayments(user.uid!);
      if (mounted) {
        setState(() {
          _payments = payments;
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Plans'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a plan that fits your goals',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ...Plans.allPlans.map((plan) => _buildPlanCard(context, plan)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PlanModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorFromString(plan.color),
                  _getColorFromString(plan.color).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.badge} Plan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${plan.ads} ads',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(plan.price.toDouble()),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'one-time',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Daily Ads', '${plan.ads} ads'),
                _buildDetailRow('Duration', plan.term),
                _buildDetailRow(
                  'Daily Income',
                  CurrencyFormatter.format(plan.dailyIncome.toDouble()),
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Total Return',
                  CurrencyFormatter.format(plan.totalIncome.toDouble()),
                  isBold: true,
                ),
                _buildDetailRow(
                  'ROI',
                  '+${((plan.totalIncome / plan.price) * 100).round()}%',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final hasPending = _payments.any(
                        (p) => p.status == 'pending',
                      );
                      if (hasPending) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "You already have a pending payment request. Please wait for approval.",
                            ),
                          ),
                        );
                        return;
                      }

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => PaymentModal(plan: plan),
                      ).then(
                        (_) => _fetchPayments(),
                      ); // Refresh payments after closing
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getColorFromString(plan.color),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    // Simple color mapping from the web app's gradient strings
    if (colorString.contains('blue')) return Colors.blue;
    if (colorString.contains('green') || colorString.contains('emerald'))
      return AppColors.primary;
    if (colorString.contains('orange') || colorString.contains('yellow'))
      return AppColors.accent;
    if (colorString.contains('purple')) return Colors.purple;
    if (colorString.contains('gray') || colorString.contains('silver'))
      return Colors.grey;
    if (colorString.contains('cyan')) return Colors.cyan;
    return AppColors.primary;
  }
}
