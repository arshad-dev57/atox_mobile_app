import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import '../../models/withdrawal_model.dart';
import '../../providers/user_provider.dart';

class WithdrawModal extends StatefulWidget {
  const WithdrawModal({Key? key}) : super(key: key);

  @override
  _WithdrawModalState createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  
  String _balanceType = 'referral';
  bool _loading = false;

  bool get _isTaskAllowed {
    final now = DateTime.now();
    // UTC+1 for Nigerian Time roughly
    final nigeriaTime = now.toUtc().add(const Duration(hours: 1));
    final isFriday = nigeriaTime.weekday == DateTime.friday;
    final hour = nigeriaTime.hour;
    return isFriday && hour >= 8 && hour < 20;
  }

  Future<void> _handleSubmit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userData;

    if (user == null || user.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not authenticated")));
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter amount")));
      return;
    }

    final withdrawAmount = double.tryParse(amountText);
    if (withdrawAmount == null || withdrawAmount < AppConstants.minimumWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Minimum withdrawal is ₦${AppConstants.minimumWithdrawal}")),
      );
      return;
    }

    final bankName = _bankNameController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final accountName = _accountNameController.text.trim();

    if (bankName.isEmpty || accountNumber.isEmpty || accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all bank details")));
      return;
    }

    final isTask = _balanceType == 'task';
    final availableBalance = isTask ? user.balance : user.referralBalance;

    if (withdrawAmount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insufficient ${isTask ? 'Task' : 'Referral'} balance")),
      );
      return;
    }

    if (isTask && !_isTaskAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task Balance can only be withdrawn on Fridays between 8:00 AM and 8:00 PM (Nigerian Time).")),
      );
      return;
    }

    setState(() { _loading = true; });

    final fee = (withdrawAmount * AppConstants.withdrawalFee).roundToDouble();
    final finalAmount = withdrawAmount - fee;

    try {
      final withdrawal = WithdrawalModel(
        userId: user.uid!,
        amount: withdrawAmount,
        fee: fee,
        finalAmount: finalAmount,
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        status: 'pending',
        balanceType: _balanceType,
        createdAt: DateTime.now(),
      );

      await DatabaseService().createWithdrawal(withdrawal);

      // Deduct from balance
      if (isTask) {
        await userProvider.updateBalance(user.uid!, user.balance - withdrawAmount);
      } else {
        await userProvider.updateReferralBalance(user.uid!, user.referralBalance - withdrawAmount);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Withdrawal of ₦${withdrawAmount.toInt()} submitted successfully! After 10% fee (₦${fee.toInt()}), you will receive ₦${finalAmount.toInt()}.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process withdrawal. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userData;
    final availableBal = _balanceType == 'task' ? (user?.balance ?? 0) : (user?.referralBalance ?? 0);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text("Withdraw Funds", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text("Withdraw your earnings", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 24),

            // Schedule info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Withdrawal Schedule", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 13)),
                        Text("Every Friday (8 AM - 8 PM) • Minimum ₦5,000", style: TextStyle(color: Colors.amber.shade800, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Fee info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text("⚠️", style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Withdrawal Fee", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 13)),
                        Text("A 10% charge will be applied to all withdrawals.", style: TextStyle(color: Colors.red.shade800, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Select Balance to Withdraw", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _balanceType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'referral',
                      child: Text('Referral Balance — ₦${(user?.referralBalance ?? 0).toInt()}'),
                    ),
                    DropdownMenuItem(
                      value: 'task',
                      child: Text('Task Balance — ₦${(user?.balance ?? 0).toInt()}${!_isTaskAllowed ? " 🔒" : ""}'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() { _balanceType = val; });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_balanceType == 'task' && !_isTaskAllowed)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text("🔒", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Task Balance Locked", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 13)),
                          Text("Task withdrawals are only available every Friday from 8:00 AM to 8:00 PM.", style: TextStyle(color: Colors.red.shade800, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Text("Amount (₦)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount (min ₦${AppConstants.minimumWithdrawal})",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text("Available: ₦${availableBal.toInt()}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),

            const Text("Bank Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _buildTextField(_bankNameController, "Bank Name"),
            const SizedBox(height: 12),
            _buildTextField(_accountNumberController, "Account Number", isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(_accountNameController, "Account Name"),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.divider, width: 2),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Withdraw", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
