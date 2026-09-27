import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/constants.dart';
import '../../../../services/api_service.dart';
import '../../../../providers/user_provider.dart';

class VTUScreen extends StatefulWidget {
  const VTUScreen({super.key});

  @override
  State<VTUScreen> createState() => _VTUScreenState();
}

class _VTUScreenState extends State<VTUScreen> {
  String _purchaseType = 'airtime';
  int _selectedProvider = 1;
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  int _selectedBundleId = 43; // default
  bool _loading = false;

  final List<Map<String, dynamic>> _providers = [
    {'id': 1, 'name': 'MTN'},
    {'id': 2, 'name': 'Glo'},
    {'id': 3, 'name': 'Airtel'},
    {'id': 4, 'name': '9mobile'},
  ];

  final List<Map<String, dynamic>> _allDataPlans = [
    // MTN
    {"id": 43, "providerId": 1, "name": "110MB Gifting", "price": 100, "apiPrice": 100},
    {"id": 74, "providerId": 1, "name": "230MB Gifting", "price": 300, "apiPrice": 250},
    {"id": 76, "providerId": 1, "name": "500MB SME", "price": 500, "apiPrice": 270},
    {"id": 78, "providerId": 1, "name": "1GB SME", "price": 400, "apiPrice": 300},
    {"id": 44, "providerId": 1, "name": "500MB SME", "price": 400, "apiPrice": 400},
    {"id": 77, "providerId": 1, "name": "1GB SME", "price": 500, "apiPrice": 450},
    {"id": 45, "providerId": 1, "name": "1GB SME", "price": 650, "apiPrice": 499},
    {"id": 46, "providerId": 1, "name": "1GB SME", "price": 770, "apiPrice": 600},
    {"id": 79, "providerId": 1, "name": "2.5GB SME", "price": 700, "apiPrice": 650},
    {"id": 47, "providerId": 1, "name": "2GB Gifting", "price": 1200, "apiPrice": 950},
    {"id": 27, "providerId": 1, "name": "2.5GB Gifting", "price": 1200, "apiPrice": 1000},
    {"id": 71, "providerId": 1, "name": "2GB SME", "price": 1200, "apiPrice": 1000},
    {"id": 60, "providerId": 1, "name": "3.5GB Gifting", "price": 1200, "apiPrice": 1000},
    {"id": 48, "providerId": 1, "name": "2GB SME", "price": 1250, "apiPrice": 1250},
    {"id": 61, "providerId": 1, "name": "4GB Gifting", "price": 1275, "apiPrice": 1300},
    {"id": 80, "providerId": 1, "name": "5GB corporate gifting", "price": 1399, "apiPrice": 1500},
    {"id": 49, "providerId": 1, "name": "3GB SME", "price": 1570, "apiPrice": 1500},
    {"id": 50, "providerId": 1, "name": "5GB SME", "price": 2150, "apiPrice": 2300},
    {"id": 53, "providerId": 1, "name": "6GB Gifting", "price": 2595, "apiPrice": 2600},
    {"id": 55, "providerId": 1, "name": "11GB Gifting", "price": 3530, "apiPrice": 3450},
    {"id": 33, "providerId": 1, "name": "7GB Gifting", "price": 3599, "apiPrice": 3599},
    {"id": 67, "providerId": 1, "name": "10GB Gifting", "price": 4570, "apiPrice": 5000},
    {"id": 57, "providerId": 1, "name": "36GB Gifting", "price": 11800, "apiPrice": 11000},
    {"id": 51, "providerId": 1, "name": "75GB SME", "price": 18990, "apiPrice": 18500},
    // Glo
    {"id": 42, "providerId": 2, "name": "Glo 200 MB - 1 Day", "price": 100, "apiPrice": 100},
    {"id": 35, "providerId": 2, "name": "Glo 500MB - 30 Days", "price": 250, "apiPrice": 250},
    {"id": 68, "providerId": 2, "name": "Glo 1GB - 3 Days", "price": 350, "apiPrice": 350},
    {"id": 36, "providerId": 2, "name": "Glo 1GB - 30 Days", "price": 450, "apiPrice": 450},
    {"id": 41, "providerId": 2, "name": "Glo 1GB - 14 Days", "price": 500, "apiPrice": 500},
    {"id": 40, "providerId": 2, "name": "Glo 2GB - 30 Days", "price": 900, "apiPrice": 900},
    {"id": 37, "providerId": 2, "name": "Glo 3GB - 30 Days", "price": 1500, "apiPrice": 1500},
    {"id": 54, "providerId": 2, "name": "Glo 5GB - 7 Days", "price": 1800, "apiPrice": 1800},
    {"id": 38, "providerId": 2, "name": "Glo 5GB - 30 Days", "price": 2400, "apiPrice": 2400},
    {"id": 39, "providerId": 2, "name": "Glo 10GB - 30 Days", "price": 4500, "apiPrice": 4500},
    {"id": 59, "providerId": 2, "name": "Glo 20.5GB - 30 Days", "price": 6000, "apiPrice": 6000},
    {"id": 58, "providerId": 2, "name": "Glo 107GB - 30 Days", "price": 20000, "apiPrice": 20000},
    // Airtel
    {"id": 70, "providerId": 3, "name": "Airtel 1GB (Social) - 3 Days", "price": 350, "apiPrice": 350},
    {"id": 13, "providerId": 3, "name": "Airtel 500MB - 7 days", "price": 500, "apiPrice": 500},
    {"id": 69, "providerId": 3, "name": "Airtel 1.5GB - 1 Day", "price": 530, "apiPrice": 530},
    {"id": 66, "providerId": 3, "name": "Airtel 1.5GB - 2 Days", "price": 650, "apiPrice": 650},
    {"id": 15, "providerId": 3, "name": "Airtel 1GB - 7 Days", "price": 800, "apiPrice": 800},
    {"id": 17, "providerId": 3, "name": "Airtel 2GB - 30 Days", "price": 1500, "apiPrice": 1500},
    {"id": 52, "providerId": 3, "name": "Airtel 5GB - 7 Days", "price": 1599, "apiPrice": 1599},
    {"id": 18, "providerId": 3, "name": "Airtel 3GB - 30 Days", "price": 2100, "apiPrice": 2100},
    {"id": 22, "providerId": 3, "name": "Airtel 6GB - 7 Days", "price": 2599, "apiPrice": 2599},
    {"id": 19, "providerId": 3, "name": "Airtel 4GB - 30 Days", "price": 2650, "apiPrice": 2650},
    {"id": 20, "providerId": 3, "name": "Airtel 8GB - 30 Days", "price": 3200, "apiPrice": 3200},
    {"id": 21, "providerId": 3, "name": "Airtel 10GB - 30 Days", "price": 4200, "apiPrice": 4200},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userData;
    
    if (user == null || user.uid == null) return;
    
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter phone number')));
      return;
    }

    setState(() { _loading = true; });

    try {
      final apiService = ApiService();
      Map<String, dynamic> response;

      if (_purchaseType == 'airtime') {
        final amt = int.tryParse(_amountController.text.trim());
        if (amt == null || amt <= 0) {
          throw Exception("Invalid amount");
        }
        response = await apiService.purchaseAirtime(
          userId: user.uid!,
          providerId: _selectedProvider,
          phoneNumber: phone,
          amount: amt,
        );
      } else {
        final plans = _allDataPlans.where((p) => p['providerId'] == _selectedProvider).toList();
        final selectedPlan = plans.firstWhere((p) => p['id'] == _selectedBundleId, orElse: () => plans.first);
        
        response = await apiService.purchaseData(
          userId: user.uid!,
          bundleId: _selectedBundleId,
          phoneNumber: phone,
          providerId: _selectedProvider,
          amount: selectedPlan['apiPrice'] as int,
        );
      }

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Purchase successful!')));
        _phoneController.clear();
        _amountController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableDataPlans = _allDataPlans.where((p) => p['providerId'] == _selectedProvider).toList();

    // Ensure selected bundle is valid for provider
    if (!availableDataPlans.any((p) => p['id'] == _selectedBundleId) && availableDataPlans.isNotEmpty) {
      _selectedBundleId = availableDataPlans.first['id'] as int;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Airtime'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Purchase airtime and data bundles instantly', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _purchaseType = 'airtime'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _purchaseType == 'airtime' ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _purchaseType == 'airtime' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                              ),
                              child: Text('Airtime', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: _purchaseType == 'airtime' ? AppColors.primary : AppColors.textSecondary)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _purchaseType = 'data'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _purchaseType == 'data' ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _purchaseType == 'data' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                              ),
                              child: Text('Data', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: _purchaseType == 'data' ? AppColors.primary : AppColors.textSecondary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Network Selection
                  const Text('Select Network', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: _providers.map((provider) {
                      final isSelected = _selectedProvider == provider['id'];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: provider != _providers.last ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProvider = provider['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 2 : 1),
                              ),
                              child: Text(
                                provider['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Phone Number
                  const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'e.g. 08012345678',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Amount or Data Plan
                  if (_purchaseType == 'airtime')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount (NGN)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Data Plan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedBundleId,
                              items: availableDataPlans.map((p) {
                                return DropdownMenuItem<int>(
                                  value: p['id'] as int,
                                  child: Text("${p['name']} — ₦${p['price']}"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _selectedBundleId = value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  
                  // Purchase Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Purchase Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
