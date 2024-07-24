// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';

import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/pages/intro/splash_screen.dart';
import 'package:propertysmart2/screens/forgot_password.dart';

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
  // ignore: prefer_const_constructors
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        'LoginScreen': (context) => const LoginScreen(),
        'CreateAccount': (context) => const CreateNewAccount(),
        'ForgotPassword': (context) => const ForgotPassword(),
        'IntroPageView': (context) => const IntroPageView(),
        'EstateListingView': (context) => const EstateListingView(),
        'ProfileScreen': (context) => const ProfileScreen(),
        'PaymentPage': (context) =>  PaymentPage(),
        // Other routes can be added here
      },
    );
  }
}
