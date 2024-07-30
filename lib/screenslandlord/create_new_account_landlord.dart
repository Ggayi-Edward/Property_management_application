import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:propertysmart2/widgets/widgets.dart';

class CreateNewAccountLandlord extends StatefulWidget {
  const CreateNewAccountLandlord({super.key});

  @override
  _CreateNewAccountLandlordState createState() => _CreateNewAccountLandlordState();
}

class _CreateNewAccountLandlordState extends State<CreateNewAccountLandlord> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _landlordEmailController = TextEditingController();
  final TextEditingController _landlordPhoneController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _message = '';
  bool _isLoading = false;

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Passwords do not match.';
        _isLoading = false;
      });

      // Show Snackbar for password mismatch
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Optionally, update the user's profile here
      await userCredential.user?.updateProfile(displayName: _userController.text);

      // Create subaccount for landlord
      String landlordEmail = _landlordEmailController.text;
      String landlordPhone = _landlordPhoneController.text;
      String businessName = _businessNameController.text;

      var response = await createSubaccount(
        email: landlordEmail,
        phone: landlordPhone,
        businessName: businessName,
      );

      if (response != null && response['status'] == 'success') {
        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account and subaccount created successfully!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to IntroPageView after the Snackbar message disappears
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, 'LandlordDashboard');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create subaccount'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Account creation error: $e'); // Print error for debugging

      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account. Please try again.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> createSubaccount({
    required String email,
    required String phone,
    required String businessName,
  }) async {
    // Your API request logic here
    // ...

    // Example response format
    return {
      'status': 'success',
      'data': {
        'subaccount_id': 'RS_1234567890ABCDEFGHIJKL',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        BackgroundImage(image: 'assets/images/background6.jfif'),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.width * 0.1),
                Center(
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 6,
                        sigmaY: 6,
                      ),
                      child: CircleAvatar(
                        radius: size.width * 0.14,
                        backgroundColor: Colors.grey[500]?.withOpacity(0.5),
                        child: Icon(
                          FontAwesomeIcons.userPlus,
                          color: Colors.white,
                          size: size.width * 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.1),
                Column(
                  children: [
                    TextInputField(
                      controller: _userController,
                      icon: Icons.person,
                      hint: 'User',
                      inputType: TextInputType.name,
                      inputAction: TextInputAction.next,
                    ),
                    TextInputField(
                      controller: _emailController,
                      icon: Icons.mail,
                      hint: 'Email',
                      inputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.next,
                    ),
                    PasswordInput(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hint: 'Password',
                      inputAction: TextInputAction.next,
                    ),
                    PasswordInput(
                      controller: _confirmPasswordController,
                      icon: Icons.lock,
                      hint: 'Confirm Password',
                      inputAction: TextInputAction.done,
                    ),
                    TextInputField(
                      controller: _landlordEmailController,
                      icon: Icons.mail_outline,
                      hint: 'Landlord Email',
                      inputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.next,
                    ),
                    TextInputField(
                      controller: _landlordPhoneController,
                      icon: Icons.phone,
                      hint: 'Landlord Phone',
                      inputType: TextInputType.phone,
                      inputAction: TextInputAction.next,
                    ),
                    TextInputField(
                      controller: _businessNameController,
                      icon: Icons.business,
                      hint: 'Business Name',
                      inputType: TextInputType.text,
                      inputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 25),
                    if (_isLoading) CircularProgressIndicator(),
                    SizedBox(height: 30),
                    RoundedButton(
                      buttonName: 'Sign Up',
                      onPressed: _createAccount,
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'LoginScreenLandlord');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
