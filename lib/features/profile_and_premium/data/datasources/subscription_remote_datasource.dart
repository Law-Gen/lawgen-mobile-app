// lib/features/profile_and_premium/data/datasources/subscription_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

abstract class SubscriptionRemoteDataSource {
  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String returnUrl,
  });
  Future<Map<String, dynamic>> verifyTransaction(String txRef);
  // --- FIX: Added the missing userId parameter ---
  Future<void> notifyBackend(
      String status, String txRef, String planName, String userId);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final String _baseUrl = "https://api.chapa.co/v1";
  final String _secretKey = "CHASECK_TEST-nWj0TY3iiIVJhnVvLHKxh0tEF3viojXz";

  @override
  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String returnUrl,
  }) async {
    final String txRef = const Uuid().v4();
    final String url = '$_baseUrl/transaction/initialize';
    final Map<String, dynamic> payload = {
      "amount": amount.toString(),
      "currency": "ETB",
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "tx_ref": txRef,
      "callback_url": "https://chapa.co",
      "return_url": returnUrl,
      "customization": {
        "title": "App Subscription",
        "description": "Payment for app features"
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        responseData['data']['tx_ref'] = txRef;
        return responseData;
      } else {
        throw Exception('Failed to initialize payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error initializing payment: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyTransaction(String txRef) async {
    final String url = '$_baseUrl/transaction/verify/$txRef';
    try {
      final response = await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $_secretKey'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify transaction');
      }
    } catch (e) {
      throw Exception('Error verifying transaction: $e');
    }
  }

  @override
  Future<void> notifyBackend(
      String status, String txRef, String planName, String userId) async {
    final url = Uri.parse('https://your-backend.com/api/update-subscription');
    final body = jsonEncode({
      'userId': userId,
      'transactionRef': txRef,
      'planName': planName,
      'paymentStatus': status,
    });
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);
      if (response.statusCode == 200) {
        print('Backend notified successfully.');
      } else {
        print('Failed to notify backend. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error notifying backend: $e');
    }
  }
}
