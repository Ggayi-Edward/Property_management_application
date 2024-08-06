import 'package:flutter_animate/flutter_animate.dart';
import 'package:propertysmart2/export/file_exports.dart'; // Ensure the import path is correct
import 'package:propertysmart2/widgets/widgets.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Top half with background image and welcome text
          BackgroundImage(
            image: 'assets/images/background1.jpeg',
          ),
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 2,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // Dark Blue for top section
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'Property Smart',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          'Welcome to Property Smart',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: theme.textTheme.titleMedium,
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom half with color scheme background and login buttons
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme
                    .secondary, // Very Light Blue for bottom section
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login as...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                      SizedBox(height: 20),
                      _buildLoginButton(
                        context,
                        'Tenant',
                        theme.colorScheme.primary,
                        Icons.person,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                      ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                      SizedBox(height: 20),
                      _buildLoginButton(
                        context,
                        'Landlord',
                        theme.colorScheme.primary,
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

  Widget _buildLoginButton(BuildContext context, String text, Color color,
      IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.8, // 80% of the screen width
      height: 50, // Increased height for better readability
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: TextStyle(fontSize: 18), // Adjusted font size
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          // Adjusted padding
          backgroundColor: color,
          foregroundColor: Colors.white,
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
