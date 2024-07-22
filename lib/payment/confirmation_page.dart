// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// confirmation_page.dart


// ignore: use_key_in_widget_constructors
class ConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 20.0),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen, or any desired action
                Navigator.pop(context);
              },
              child: Text('Back to Payment Page'),
            ),
          ],
        ),
      ),
    );
  }
}