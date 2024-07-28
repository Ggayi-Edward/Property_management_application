import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/pages/intro/splash_screen.dart';
import 'package:propertysmart2/payment/payment_page.dart';
import 'package:propertysmart2/screens/forgot_password.dart';
import 'package:propertysmart2/screens/profile_page.dart';
import 'package:propertysmart2/payment/confirmation_page.dart'; // Import your existing confirmation page
import 'package:uni_links/uni_links.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCXQ4B81sO45QqDW0GAMAyNclVu9UqDNzw",
      appId: "1:508998199848:web:6903991d1471ab8bbfe31d",
      messagingSenderId: "508998199848",
      projectId: "propertysmart-95070",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'propertysmart' && uri.host == 'payment-confirmation') {
        Navigator.pushNamed(context, '/payment-confirmation', arguments: uri.queryParameters);
      }
    }, onError: (err) {
      // Handle error
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PropertySmart',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        'LoginScreen': (context) => const LoginScreen(),
        'CreateAccount': (context) => const CreateNewAccount(),
        'ForgotPassword': (context) => const ForgotPassword(),
        'IntroPageView': (context) => const IntroPageView(),
        'EstateListingView': (context) => const EstateListingView(),
        'ProfileScreen': (context) => const ProfileScreen(),
        'PaymentPage': (context) => PaymentPage(landlordMobileMoneyNumber: ''),
        '/payment-confirmation': (context) => ConfirmationPage(), // Updated to use existing ConfirmationPage
        // Other routes can be added here
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(child: Text('Home Page')),
    );
  }
}
