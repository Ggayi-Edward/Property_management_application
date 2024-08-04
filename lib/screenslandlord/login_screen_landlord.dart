import 'package:flutter/material.dart';
import 'package:propertysmart2/widgets/widgets.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreenLandlord extends StatefulWidget {
  const LoginScreenLandlord({super.key});

  @override
  _LoginScreenLandlordState createState() => _LoginScreenLandlordState();
}

class _LoginScreenLandlordState extends State<LoginScreenLandlord> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      User? user = await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged in!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to IntroPageView after the Snackbar message disappears
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, 'LandlordDashboard');
        });
      } else {
        // Show error Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in. Please check your credentials.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error Snackbar for unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary, // Very Light Blue
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Center(
              child: Text(
                'Property Smart',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary, // Dark Blue
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            // Form Fields and Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextInputField(
                  controller: _emailController,
                  icon: Icons.mail,
                  hint: 'Email',
                  inputType: TextInputType.emailAddress,
                  inputAction: TextInputAction.next,
                ),
                SizedBox(height: 16),
                PasswordInput(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hint: 'Password',
                  inputType: TextInputType.text,
                  inputAction: TextInputAction.done,
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'ForgotPasswordLandlord'),
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: theme.colorScheme.primary, // Dark Blue
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RoundedButton(
                  buttonName: 'Login',
                  onPressed: _login,
                ),
                SizedBox(height: 25),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'CreateNewAccountLandlord'),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Create New Account',
                      style: TextStyle(
                        color: theme.colorScheme.primary, // Dark Blue
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
