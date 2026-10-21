import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import '../../models/withdrawal_model.dart';
import '../../providers/user_provider.dart';

// Design tokens (same as the rest of the app)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kBtnDark = Color(0xFF1B1B1F);
const Color _kRed = Color(0xFFE5484D);
const Color _kRedSoft = Color(0xFFFDECEC);

class WithdrawModal extends StatefulWidget {
  const WithdrawModal({Key? key}) : super(key: key);

  @override
  _WithdrawModalState createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  String _balanceType = 'referral';
  bool _loading = false;

  // Whether the user already submitted a withdrawal today (loaded on open).
  bool _withdrawnToday = false;

  @override
  void initState() {
    super.initState();
    _checkWithdrawnToday();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _checkWithdrawnToday() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.userData?.uid;
    if (uid == null) return;
    final already = await DatabaseService().hasWithdrawnToday(uid);
    if (mounted) setState(() => _withdrawnToday = already);
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? _kRed : _kInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userData;

    if (user == null || user.uid == null) {
      _snack("User not authenticated", error: true);
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _snack("Please enter amount", error: true);
      return;
    }

    final withdrawAmount = double.tryParse(amountText);
    if (withdrawAmount == null ||
        withdrawAmount < AppConstants.minimumWithdrawal) {
      _snack(
        "Minimum withdrawal is ₦${AppConstants.minimumWithdrawal}",
        error: true,
      );
      return;
    }

    final bankName = _bankNameController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final accountName = _accountNameController.text.trim();

    if (bankName.isEmpty || accountNumber.isEmpty || accountName.isEmpty) {
      _snack("Please fill all bank details", error: true);
      return;
    }

    final isTask = _balanceType == 'task';
    final availableBalance = isTask ? user.balance : user.referralBalance;

    if (withdrawAmount > availableBalance) {
      _snack("Insufficient ${isTask ? 'Task' : 'Referral'} balance", error: true);
      return;
    }

    // One withdrawal per day rule.
    if (_withdrawnToday) {
      _snack(
        "You can only withdraw once per day. Please try again tomorrow.",
        error: true,
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final fee = (withdrawAmount * AppConstants.withdrawalFee).round();
    final finalAmount = withdrawAmount - fee;

    try {
      final withdrawal = WithdrawalModel(
        id: '',
        userId: user.uid!,
        amount: withdrawAmount.toInt(),
        fee: fee,
        finalAmount: finalAmount.toInt(),
        bankDetails: {
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountName': accountName,
        },
        status: 'pending',
        balanceType: _balanceType,
        createdAt: DateTime.now(),
      );

      await DatabaseService().createWithdrawal(withdrawal);

      // Deduct from balance atomically (delta) so the real-time user stream
      // and every screen stay consistent.
      if (isTask) {
        await DatabaseService().incrementUserData(
          user.uid!,
          balanceDelta: -withdrawAmount,
        );
      } else {
        await DatabaseService().incrementUserData(
          user.uid!,
          referralBalanceDelta: -withdrawAmount,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        _snack(
          "Withdrawal of ₦${withdrawAmount.toInt()} submitted successfully! After 10% fee (₦${fee.toInt()}), you will receive ₦${finalAmount.toInt()}.",
        );
      }
    } catch (e) {
      if (mounted) {
        _snack("Failed to process withdrawal. Please try again.", error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userData;
    final availableBal = _balanceType == 'task'
        ? (user?.balance ?? 0)
        : (user?.referralBalance ?? 0);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final fee = (amount * AppConstants.withdrawalFee).round();
    final receive = amount > 0 ? amount - fee : 0;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
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
            // drag handle
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E7),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // header
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _kOrange,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _kOrange.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Withdraw Funds",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Withdraw your earnings",
                        style: TextStyle(fontSize: 13, color: _kMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _infoBanner(
              icon: Icons.schedule_rounded,
              title: "Withdrawal Schedule",
              body: "Available daily • Minimum ₦2,000 • 1 withdrawal per day",
              color: _kOrange,
              soft: _kOrangeSoft,
            ),
            const SizedBox(height: 10),
            _infoBanner(
              icon: Icons.percent_rounded,
              title: "Withdrawal Fee",
              body: "A 10% charge will be applied to all withdrawals.",
              color: _kRed,
              soft: _kRedSoft,
            ),
            if (_withdrawnToday) ...[
              const SizedBox(height: 10),
              _infoBanner(
                icon: Icons.hourglass_bottom_rounded,
                title: "Daily Limit Reached",
                body:
                    "You've already made a withdrawal today. You can withdraw again tomorrow.",
                color: _kRed,
                soft: _kRedSoft,
              ),
            ],
            const SizedBox(height: 20),

            _label("Select balance to withdraw"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _balanceOption(
                    value: 'referral',
                    title: 'Referral',
                    amount: (user?.referralBalance ?? 0).toInt(),
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _balanceOption(
                    value: 'task',
                    title: 'Task',
                    amount: (user?.balance ?? 0).toInt(),
                    icon: Icons.task_alt_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _label("Amount (₦)"),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: _decoration(
                "Enter amount (min ₦${AppConstants.minimumWithdrawal})",
                icon: Icons.payments_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                "Available: ₦${availableBal.toInt()}",
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
            ),
            if (amount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _summaryRow("Amount", "₦${amount.toInt()}"),
                    const SizedBox(height: 8),
                    _summaryRow("Fee (10%)", "-₦$fee", valueColor: _kRed),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFE2E2E7)),
                    ),
                    _summaryRow(
                      "You receive",
                      "₦${receive.toInt()}",
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            _label("Bank details"),
            const SizedBox(height: 8),
            TextField(
              controller: _bankNameController,
              decoration: _decoration("Bank Name", icon: Icons.account_balance_rounded),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: _decoration("Account Number", icon: Icons.pin_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _accountNameController,
              decoration: _decoration("Account Name", icon: Icons.person_outline_rounded),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Material(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(40),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        height: 62,
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(flex: 3, child: _submitButton()),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── PIECES ─────────────────────────

  Widget _submitButton() {
    final disabled = _loading || _withdrawnToday;
    return Material(
      color: disabled ? _kBtnDark.withOpacity(0.55) : _kBtnDark,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: disabled ? null : _handleSubmit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 7, 7, 7),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Withdraw",
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
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_forward_rounded,
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _kInk,
        ),
      );

  Widget _infoBanner({
    required IconData icon,
    required String title,
    required String body,
    required Color color,
    required Color soft,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Color(0xFF55555F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceOption({
    required String value,
    required String title,
    required int amount,
    required IconData icon,
  }) {
    final selected = _balanceType == value;
    return GestureDetector(
      onTap: () => setState(() => _balanceType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _kOrangeSoft : _kBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kOrange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: selected ? _kOrange : _kMuted),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: selected ? _kOrange : const Color(0xFFCFCFD6),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "₦$amount",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold ? _kInk : _kMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? (bold ? _kOrange : _kInk),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint, {required IconData icon}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: _kMuted, size: 20),
      filled: true,
      fillColor: _kBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(_kOrange, 1.5),
    );
  }
}