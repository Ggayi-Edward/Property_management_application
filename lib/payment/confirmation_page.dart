// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

import 'package:propertysmart2/payment/Receipt_page.dart';   // Adjusted import path

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key}); // Corrected constructor syntax

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Background color for the entire screen
      appBar: AppBar(
        title: Text('Confirmation'),
        backgroundColor: Colors.blue, // Adjusted app bar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding around the body content
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120.0, // Increased size of the check circle icon
              ),
              SizedBox(height: 20.0),
              Text(
                'Welcome to the Confirmation Page',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center, // Center-align the text
              ),
              SizedBox(height: 20.0),
              Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 20.0),
              Text(
                'Transaction ID: 1234567890',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
              Text(
                'Amount Paid: \$50.00',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Adjusted button background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Back to Payment Page',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReceiptPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Adjusted button background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'View Receipt',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}