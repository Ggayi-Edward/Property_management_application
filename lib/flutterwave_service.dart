import 'dart:convert';
import 'package:http/http.dart' as http;

class FlutterwaveService {
  final String baseUrl = 'https://api.flutterwave.com/v3';
  final String secretKey = ''; // Replace with your actual Flutterwave secret key

  Future<http.Response> makePayment(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/payments');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );

    return response;
  }
}
