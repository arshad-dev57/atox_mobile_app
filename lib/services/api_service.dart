import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL - update this to your actual API base URL
  static const String baseUrl = 'https://your-api-domain.com';

  // VTU API endpoints
  Future<Map<String, dynamic>> purchaseAirtime({
    required String userId,
    required int providerId,
    required String phoneNumber,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/vtu/airtime'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'provider_id': providerId,
          'phone_number': phoneNumber,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {'error': 'Failed to purchase airtime'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> purchaseData({
    required String userId,
    required int bundleId,
    required String phoneNumber,
    required int providerId,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/vtu/data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'bundle_id': bundleId,
          'phone_number': phoneNumber,
          'provider_id': providerId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {'error': 'Failed to purchase data'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Referral lookup
  Future<Map<String, dynamic>> lookupReferralCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/referral/lookup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {'error': 'Invalid referral code'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
