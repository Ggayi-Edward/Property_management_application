// ignore: file_names
import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  final String templateId = 'your_template_id_here';
  Map<String, String> tabValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt'),
        backgroundColor: Colors.blue, // Adjust background color of app bar
      ),
      backgroundColor: Colors.grey[200], // Adjust background color of the body
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 20.0),
            Text(
              'Receipt Details',
              style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 20.0),
            Divider(
                thickness: 2,
                color: Colors.blue), // Add a divider for visual separation
            SizedBox(height: 20.0),
            Text(
              'Transaction ID: 1234567890',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            SizedBox(height: 10.0),
            Text(
              'Amount Paid: \$50.00',
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Adjust button background color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Back Button',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
