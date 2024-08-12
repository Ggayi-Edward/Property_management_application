import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:propertysmart2/payment/payment_page.dart';
import 'package:propertysmart2/screenslandlord/landlord_dashboard.dart';
import 'package:propertysmart2/screenslandlord/landlord_property_listings.dart';
import 'package:propertysmart2/screenslandlord/lease_agreement_page.dart';
import 'package:propertysmart2/screenslandlord/profile_page_landlord.dart';
import 'package:provider/provider.dart';
import 'package:propertysmart2/constants/theme_data.dart';
import 'package:propertysmart2/constants/theme_notifier.dart';
import 'package:propertysmart2/pages/intro/splash_screen.dart';
import 'package:propertysmart2/screens/account_page.dart';
import 'package:propertysmart2/screens/create_new_account.dart';
import 'package:propertysmart2/screenslandlord/create_new_account_landlord.dart';
import 'package:propertysmart2/pages/estate_listing/estate_listing_view.dart';
import 'package:propertysmart2/screens/forgot_password.dart';
import 'package:propertysmart2/screenslandlord/forgot_password_landlord.dart';
import 'package:propertysmart2/screens/login_screen.dart';
import 'package:propertysmart2/screenslandlord/login_screen_landlord.dart';
import 'package:propertysmart2/pages/intro/intropage_view.dart';
import 'package:propertysmart2/screens/profile_page.dart';

import 'data/addAgreement.dart';
import 'data/addProperty.dart';
import 'messages/tenant_messaging_page.dart';
import 'messages/landlord_messaging_page.dart';



// Background message handler for Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: No need to initialize Firebase here again
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Firebase is only initialized once
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
            home: const SplashScreen(), // Set the initial screen
            routes: {
              'LoginScreen': (context) => const LoginScreen(),
              'CreateAccount': (context) => const CreateNewAccount(),
              'ForgotPassword': (context) => const ForgotPassword(),
              'IntroPageView': (context) => const IntroPageView(),
              'EstateListingView': (context) =>  EstateListingView(),
              'ProfileScreen': (context) => const ProfileScreen(),
              'CreateNewAccountLandlord': (context) => const CreateNewAccountLandlord(),
              'ForgotPasswordLandlord': (context) => const ForgotPasswordLandlord(),
              'LoginScreenLandlord': (context) => const LoginScreenLandlord(),
              'ProfileScreenLandlord': (context) => const ProfileScreenLandlord(userId: ''),
              'PaymentPage': (context) => PaymentPage(
                landlordEmail: '',
                landlordMobileMoneyNumber: '', price: '', estateId: '', amount: '',
              ),
              'AccountPage': (context) => AccountPage(),
              'LeaseAgreementsPage': (context) => LeaseAgreementsPage(),
              'TenantMessagingPage': (context) => TenantMessagingPage(chatId: '', senderId: '', landlordId: '', tenantId: '', estateId: '',),
              'LandlordMessagingPage': (context) => LandlordMessagingPage(chatId: '', senderId: '', landlordId: '', tenantId: '', estateId: '',),
              'LandlordDashboard': (context) => LandlordDashboard(userId: ''),
              'AddPropertyPage': (context) => AddPropertyPage(),
              'CreateLeaseAgreementPage': (context) => CreateLeaseAgreementPage(propertyId: '',),
              'PropertyListingsPage': (context) => PropertyListingsPage(),
              '/propertyListings': (context) => PropertyListingsPage(),
            },
          );
        },
      ),
    );
  }
}
