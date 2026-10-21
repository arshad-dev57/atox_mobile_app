import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/constants.dart';
import '../../../../services/api_service.dart';
import '../../../../providers/user_provider.dart';

// Design tokens (same as the rest of the app)
const Color _kOrange = Color(0xFFF26A2E);
const Color _kOrangeSoft = Color(0xFFFFEDE3);
const Color _kBg = Color(0xFFF4F4F6);
const Color _kInk = Color(0xFF16161A);
const Color _kMuted = Color(0xFF9A9AA5);
const Color _kBtnDark = Color(0xFF1B1B1F);
const Color _kRed = Color(0xFFE5484D);

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

  // Brand colors for the network badges
  static const Map<int, Color> _brandColors = {
    1: Color(0xFFFFC400),
    2: Color(0xFF2BB673),
    3: Color(0xFFE5484D),
    4: Color(0xFF0B7A4B),
  };

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

  Future<void> _handlePurchase() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userData;

    if (user == null || user.uid == null) return;

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _snack('Please enter phone number', error: true);
      return;
    }

    setState(() {
      _loading = true;
    });

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
        final plans = _allDataPlans
            .where((p) => p['providerId'] == _selectedProvider)
            .toList();
        final selectedPlan = plans.firstWhere(
          (p) => p['id'] == _selectedBundleId,
          orElse: () => plans.first,
        );

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
        _snack(response['message'] ?? 'Purchase successful!');
        _phoneController.clear();
        _amountController.clear();
      }
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceAll("Exception: ", ""), error: true);
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
    final availableDataPlans = _allDataPlans
        .where((p) => p['providerId'] == _selectedProvider)
        .toList();

    // Ensure selected bundle is valid for provider
    if (!availableDataPlans.any((p) => p['id'] == _selectedBundleId) &&
        availableDataPlans.isNotEmpty) {
      _selectedBundleId = availableDataPlans.first['id'] as int;
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 18),
              _buildTypeToggle(),
              const SizedBox(height: 16),
              _buildMainCard(availableDataPlans),
              const SizedBox(height: 18),
              _buildSummaryAndButton(availableDataPlans),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
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
          child: Icon(icon, size: 20, color: _kInk),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.of(context).pop(),
        ),
        const Text(
          'Data & Airtime',
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

  // ───────────────────────── TYPE TOGGLE ─────────────────────────

  Widget _buildTypeToggle() {
    Widget pill(String label, String value, IconData icon) {
      final active = _purchaseType == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _purchaseType = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? _kOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: active ? Colors.white : _kMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _kMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          pill('Airtime', 'airtime', Icons.phone_in_talk_rounded),
          pill('Data', 'data', Icons.wifi_rounded),
        ],
      ),
    );
  }

  // ───────────────────────── MAIN CARD ─────────────────────────

  Widget _buildMainCard(List<Map<String, dynamic>> plans) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          _label('Select network'),
          const SizedBox(height: 10),
          Row(
            children: _providers.map((provider) {
              final id = provider['id'] as int;
              final selected = _selectedProvider == id;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: provider != _providers.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedProvider = id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? _kOrangeSoft : _kBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? _kOrange : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _brandColors[id] ?? _kOrange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              (provider['name'] as String).substring(0, 1),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: id == 1 ? _kInk : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider['name'] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? _kOrange : _kInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _label('Phone number'),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _decoration(
              'e.g. 08012345678',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 20),
          if (_purchaseType == 'airtime') _buildAirtimeSection() else _buildDataSection(plans),
        ],
      ),
    );
  }

  Widget _buildAirtimeSection() {
    const quick = [100, 200, 500, 1000];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Amount (NGN)'),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: _decoration(
            'Enter amount',
            icon: Icons.payments_outlined,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: quick.map((v) {
            final selected = _amountController.text.trim() == v.toString();
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: v != quick.last ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _amountController.text = v.toString();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _kOrange : _kOrangeSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '₦$v',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : _kOrange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDataSection(List<Map<String, dynamic>> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('Select data plan'),
            Text(
              '${plans.length} plans',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final p = plans[i];
                final selected = p['id'] == _selectedBundleId;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedBundleId = p['id'] as int),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _kOrangeSoft : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? _kOrange : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: selected ? _kOrange : const Color(0xFFCFCFD6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₦${p['price']}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: selected ? _kOrange : _kInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── SUMMARY + BUTTON ─────────────────────────

  Widget _buildSummaryAndButton(List<Map<String, dynamic>> plans) {
    String total;
    if (_purchaseType == 'airtime') {
      final amt = int.tryParse(_amountController.text.trim());
      total = amt != null && amt > 0 ? '₦$amt' : '₦0';
    } else {
      final selected = plans.firstWhere(
        (p) => p['id'] == _selectedBundleId,
        orElse: () => plans.first,
      );
      total = '₦${selected['price']}';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _kOrangeSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You pay',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _kOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: _loading ? _kBtnDark.withOpacity(0.6) : _kBtnDark,
          borderRadius: BorderRadius.circular(40),
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: _loading ? null : _handlePurchase,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Purchase Now',
                      style: TextStyle(
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
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
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
      ],
    );
  }

  // ───────────────────────── HELPERS ─────────────────────────

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _kInk,
        ),
      );

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