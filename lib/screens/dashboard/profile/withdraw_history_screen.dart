import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/constants.dart';
import '../../../../services/database_service.dart';
import '../../../../models/withdrawal_model.dart';
import '../../../../providers/user_provider.dart';

class WithdrawHistoryScreen extends StatefulWidget {
  const WithdrawHistoryScreen({super.key});

  @override
  State<WithdrawHistoryScreen> createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {
  List<WithdrawalModel> _withdrawals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Load once immediately; the StreamBuilder keeps it live afterwards.
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    if (user?.uid != null) {
      final list =
          await DatabaseService().getUserWithdrawals(user!.uid!);
      if (mounted) setState(() => _withdrawals = list);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<UserProvider>(context).userData?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw History'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: uid == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : StreamBuilder<List<WithdrawalModel>>(
              stream: DatabaseService().getUserWithdrawalsStream(uid),
              initialData: _withdrawals,
              builder: (context, snapshot) {
                final list = snapshot.data ?? _withdrawals;
                if (_loading && list.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      "No withdrawals yet.",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _loadInitial,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) =>
                        _buildWithdrawalCard(list[index]),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWithdrawalCard(WithdrawalModel w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "₦${w.amount.toInt()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${w.bankDetails['bankName']} - ${w.bankDetails['accountNumber']}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                w.createdAt.toString().substring(0, 16),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: w.status == 'approved'
                  ? Colors.green.shade50
                  : (w.status == 'rejected'
                        ? Colors.red.shade50
                        : Colors.orange.shade50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              w.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: w.status == 'approved'
                    ? Colors.green
                    : (w.status == 'rejected'
                          ? Colors.red
                          : Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
