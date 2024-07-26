import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:propertysmart2/export/file_exports.dart'; // Ensure the import path is correct
import 'package:propertysmart2/widgets/widgets.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top half with blue background and welcome text
          BackgroundImage(
            image: 'assets/images/background1.jpeg',
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
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
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'Property Smart',
                          style: TextStyle(
                            color: Color(0xFF304FFE),
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Welcome to Property Smart',
                          textAlign: TextAlign.left,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueAccent,
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      ],
                    ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                      ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                      SizedBox(height: 20),
                      _buildLoginButton(
                        context,
                        'Landlord',
                        Colors.greenAccent,
                        Icons.house,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreenLandlord(),
                            ),
                          );
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
