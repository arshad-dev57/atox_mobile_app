import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/recharge_model.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// Design tokens (same as the rest of the app)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kBtnDark = Color(0xFF1B1B1F);
const Color _kRed = Color(0xFFE5484D);
const Color _kGreen = Color(0xFF2BB673);

class RechargeModal extends StatefulWidget {
  const RechargeModal({Key? key}) : super(key: key);

  @override
  _RechargeModalState createState() => _RechargeModalState();
}

class _RechargeModalState extends State<RechargeModal> {
  final TextEditingController _amountController = TextEditingController();
  File? _paymentScreenshot;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  void _copy(String text, String what) {
    Clipboard.setData(ClipboardData(text: text));
    _snack("$what copied");
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentScreenshot = File(image.path);
      });
    }
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

    final amount = double.tryParse(amountText);
    if (amount == null || amount < AppConstants.minimumRecharge) {
      _snack(
        "Minimum recharge amount is ₦${AppConstants.minimumRecharge}",
        error: true,
      );
      return;
    }

    if (_paymentScreenshot == null) {
      _snack("Please upload a payment screenshot", error: true);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      String? screenshotUrl = await CloudinaryService.uploadImage(
        _paymentScreenshot!,
        folder: 'recharge-screenshots',
      );

      // Fallback if cloudinary upload fails
      screenshotUrl ??= "https://via.placeholder.com/150?text=Upload+Failed";

      final recharge = RechargeModel(
        id: '',
        userId: user.uid!,
        amount: amount.toInt(),
        screenshotUrl: screenshotUrl,
        bankDetails: {
          'bankName': AppConstants.bankName,
          'accountNumber': AppConstants.accountNumber,
          'accountName': AppConstants.accountName,
        },
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await DatabaseService().createRecharge(recharge);

      if (mounted) {
        Navigator.pop(context);
        _snack(
          "Recharge request of ₦${amount.toInt()} submitted! It will reflect in your balance upon approval.",
        );
      }
    } catch (e) {
      if (mounted) {
        _snack("Failed to process recharge. Please try again.", error: true);
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
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recharge Wallet",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Add funds to your account",
                        style: TextStyle(fontSize: 13, color: _kMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Amount
            _label("Amount (₦)"),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                "Enter amount (min ₦${AppConstants.minimumRecharge})",
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(height: 18),

            // Bank details
            _label("Send payment to"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kOrangeSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _bankRow(
                    Icons.account_balance_rounded,
                    "Bank Name",
                    AppConstants.bankName,
                  ),
                  const SizedBox(height: 12),
                  _bankRow(
                    Icons.pin_outlined,
                    "Account Number",
                    AppConstants.accountNumber,
                    copyable: true,
                  ),
                  const SizedBox(height: 12),
                  _bankRow(
                    Icons.person_outline_rounded,
                    "Account Name",
                    AppConstants.accountName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Screenshot upload
            _label("Payment screenshot"),
            const SizedBox(height: 8),
            _buildUploadBox(),
            const SizedBox(height: 24),

            // Actions
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
    return Material(
      color: _loading ? _kBtnDark.withOpacity(0.55) : _kBtnDark,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: _loading ? null : _handleSubmit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 7, 7, 7),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Recharge",
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

  Widget _bankRow(
    IconData icon,
    String label,
    String value, {
    bool copyable = false,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: _kOrange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _kMuted)),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _kInk,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          GestureDetector(
            onTap: () => _copy(value, label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    "Copy",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadBox() {
    final picked = _paymentScreenshot != null;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding:  EdgeInsets.all(picked ? 10 : 22),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: picked ? _kGreen : const Color(0xFFD9D9DF),
            width: 1.5,
          ),
        ),
        child: picked
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _paymentScreenshot!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: _kGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Screenshot selected",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kInk,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Tap to change",
                          style: TextStyle(fontSize: 11, color: _kMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: _kOrangeSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: _kOrange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Upload Screenshot",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _kInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Tap to choose from your gallery",
                    style: TextStyle(fontSize: 11.5, color: _kMuted),
                  ),
                ],
              ),
      ),
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