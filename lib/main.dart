import 'package:firebase_core/firebase_core.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/pages/intro/splash_screen.dart';
import 'package:propertysmart2/screens/forgot_password.dart';
import 'package:propertysmart2/screens/profile_page.dart';
// Import your existing confirmation page
import 'package:propertysmart2/screens/login_screen.dart';
import 'package:propertysmart2/screenslandlord/landlord_dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme_data.dart';
import 'constants/theme_notifier.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCXQ4B81sO45QqDW0GAMAyNclVu9UqDNzw",
      authDomain: "propertysmart-95070.firebaseapp.com",
      appId: "1:508998199848:web:6903991d1471ab8bbfe31d",
      storageBucket: "propertysmart-95070.appspot.com",
      messagingSenderId: "508998199848",
      projectId: "propertysmart-95070",
    ),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme, // Use light theme
            darkTheme: darkTheme, // Use dark theme
            themeMode: themeNotifier.themeMode, // Control theme mode dynamically
            home: const SplashScreen(),
            routes: {
              'LoginScreen': (context) => const LoginScreen(),
              'CreateAccount': (context) => const CreateNewAccount(),
              'ForgotPassword': (context) => const ForgotPassword(),
              'IntroPageView': (context) => const IntroPageView(),
              'EstateListingView': (context) => const EstateListingView(),
              'ProfileScreen': (context) => const ProfileScreen(),
              'CreateNewAccountLandlord': (context) => const CreateNewAccountLandlord(),
              'ForgotPasswordLandlord': (context) => const ForgotPasswordLandlord(),
              'LoginScreenLandlord': (context) => const LoginScreenLandlord(),
              'ProfileScreenLandlord': (context) => const ProfileScreenLandlord(userId: '',),
              'PaymentPage': (context) => PaymentPage(
                landlordEmail: '',
                landlordMobileMoneyNumber: '',
              ),
              'AccountPage': (context) => AccountPage(),
              'LeaseAgreementsPage': (context) => LeaseAgreementsPage(),
              'MessagingPage': (context) => MessagingPage(chatId: '', senderId: '',),
              'MaintenanceRequestsPage': (context) => MaintenanceRequestsPage(),
              'LandlordDashboard': (context) => LandlordDashboard(userId: '',),
              'AddPropertyPage': (context) => AddPropertyPage(),
            },
          );
        },
      ),
    );
  }
}
