import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../services/database_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/payment_model.dart';
import '../../models/plan_model.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class PaymentModal extends StatefulWidget {
  final PlanModel plan;
  const PaymentModal({Key? key, required this.plan}) : super(key: key);

  @override
  _PaymentModalState createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  File? _paymentScreenshot;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    if (_paymentScreenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a payment screenshot")),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      String? screenshotUrl = await CloudinaryService.uploadImage(
        _paymentScreenshot!, 
        folder: 'plan-payments'
      );
      
      // Fallback
      screenshotUrl ??= "https://via.placeholder.com/150?text=Upload+Failed";

      final payment = PaymentModel(
        userId: user.uid!,
        productId: widget.plan.id,
        amount: widget.plan.price.toDouble(),
        screenshotUrl: screenshotUrl,
        status: 'pending',
        submittedAt: DateTime.now(),
      );

      await DatabaseService().createPayment(payment);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment for ${widget.plan.name} submitted! Please wait for approval.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process payment. Please try again.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text("Purchase Plan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 8),
            
            // Plan Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(widget.plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text("Total Amount Due: ${CurrencyFormatter.format(widget.plan.price.toDouble())}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bank Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("💳 Transfer exactly the amount due to:", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _buildBankDetailRow("Bank Name:", AppConstants.bankName),
                  const SizedBox(height: 8),
                  _buildBankDetailRow("Account Number:", AppConstants.accountNumber),
                  const SizedBox(height: 8),
                  _buildBankDetailRow("Account Name:", AppConstants.accountName),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Screenshot Upload
            const Text("Payment Screenshot", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      _paymentScreenshot != null ? Icons.check_circle : Icons.upload_file,
                      color: _paymentScreenshot != null ? AppColors.primary : AppColors.textTertiary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _paymentScreenshot != null ? "Screenshot Selected" : "Upload Receipt/Screenshot",
                      style: TextStyle(
                        color: _paymentScreenshot != null ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildBankDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
      ],
    );
  }
}
