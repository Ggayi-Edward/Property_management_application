import 'package:propertysmart2/widgets/widgets.dart';
import 'package:propertysmart2/export/file_exports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged in!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, 'IntroPageView');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in. Please check your credentials.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, 'AccountPage');
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.secondary, // Very Light Blue
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    onTap: () => Navigator.pushNamed(context, 'ForgotPassword'),
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
                    onTap: () => Navigator.pushNamed(context, 'CreateAccount'),
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
      ),
    );
  }
}
