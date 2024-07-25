import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top half with blue background and welcome text
          Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/splashscreen.png', // Make sure to reference your image correctly
                    height: 220,
                  ).animate().fadeIn(duration: 800.ms, delay: 100.ms),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Welcome to Property Smart',
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                  ),
                ],
              ),
            ),
          ),
          // Bottom half with blue background and login buttons
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login as',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                      SizedBox(height: 20),
                      _buildLoginButton(
                        context,
                        'Tenant',
                        Colors.white,
                        Icons.person,
                            () {
                          // Add your onPressed logic here
                        },
                      ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                      SizedBox(height: 20),
                      _buildLoginButton(
                        context,
                        'Landlord',
                        Colors.greenAccent,
                        Icons.house,
                            () {
                          // Add your onPressed logic here
                        },
                      ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, String text, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 190, // Fixed width for both buttons
      height: 40, // Fixed height for both buttons
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(text, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
