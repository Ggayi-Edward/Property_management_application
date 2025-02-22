import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:propertysmart2/export/file_exports.dart';

class FirstIntro extends StatefulWidget {
  final VoidCallback onConfirmTap;

  const FirstIntro({super.key, required this.onConfirmTap});

  @override
  _FirstIntroState createState() => _FirstIntroState();
}

class _FirstIntroState extends State<FirstIntro> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _configureFirebaseMessaging();
  }

  Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title ?? 'No Title'),
              content: Text(notification.body ?? 'No Body'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });

    final String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: CustomDrawer(showFilters: false),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/houses/rooms/swimmingpool3.jfif'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.5), // Adjust opacity based on theme
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    var isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;
                    return FlexibleSpaceBar(
                      centerTitle: true,
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'PropertySmart',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              color: isDarkMode ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isCollapsed)
                            Text(
                              'Your Real Estate Partner',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white70 : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blueGrey[800] : Color(0xFF0D47A1),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverFillRemaining(
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: isDarkMode ? Colors.blueGrey[700] : Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Discover Your Favourite Property with PropertySmart',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: widget.onConfirmTap,
                            child: Container(
                              width: 150,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'View Properties',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
