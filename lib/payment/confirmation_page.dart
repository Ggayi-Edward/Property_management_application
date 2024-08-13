import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmationPage extends StatelessWidget {
  final String transactionId;
  final String amount;
  final String landlordPhoneNumber;

  const ConfirmationPage({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.landlordPhoneNumber,
  });

  Future<void> _sendNotification() async {
    final url = 'https://your-fcm-endpoint.com/send'; // Replace with your notification endpoint
    final payload = {
      'to': landlordPhoneNumber, // Phone number or FCM token
      'message': {
        'title': 'Payment Received',
        'body': 'A payment of $amount has been made. Transaction ID: $transactionId.',
      },
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY', // Replace with your server key
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Send notification when page is built
    _sendNotification();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blueGrey[50], // Dark mode background color
      appBar: AppBar(
        title: const Text(
          'Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.blueGrey[800] : Color(0xFF0D47A1), // Dark mode app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120.0,
              ),
              SizedBox(height: 20.0),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Color(0xFF0D47A1), // Text color based on theme
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              Text(
                'Transaction ID: $transactionId',
                style: TextStyle(
                  fontSize: 18.0,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              Text(
                'Amount Paid: UGX $amount',
                style: TextStyle(
                  fontSize: 18.0,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
