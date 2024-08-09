import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_notifier.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/screenslandlord/landlord_dashboard.dart';

class CustomDrawer extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFilterApplied;
  final bool showFilters;

  const CustomDrawer({
    super.key,
    this.onFilterApplied,
    this.showFilters = false,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? selectedPriceRange;
  int? selectedBedrooms;
  int? selectedBathrooms;
  bool? swimmingPool;
  bool? wifi;
  User? _user;
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool showFilters = false; // Control to show/hide filters

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(

                color: Color(0xFF0D47A1)

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PropertySmart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: _user?.photoURL != null
                          ? NetworkImage(_user!.photoURL!)
                          : const AssetImage('assets/images/default_avatar.jfif') as ImageProvider,
                      radius: 30,
                    ),
                    const SizedBox(width: 10),
                    if (_user?.displayName != null && _user?.email != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user!.displayName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 150, // Adjust width as needed
                            child: Text(
                              _user!.email!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', () {
            Navigator.pop(context);
            _navigateToHome(context);
          }),
          _buildDrawerItem(Icons.person, 'Profile', () {
            Navigator.pop(context);
            _navigateToProfile(context);
          }),
          _buildDrawerItem(
            themeNotifier.themeMode == ThemeMode.dark ? Icons.brightness_7 : Icons.brightness_4,
            themeNotifier.themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                () {
              themeNotifier.toggleTheme(themeNotifier.themeMode != ThemeMode.dark);
            },
          ),
          _buildDrawerItem(Icons.logout, 'Logout', () async {
                try {
                  await _authService.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pushReplacementNamed(context, 'AccountPage');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }),
          ListTile(
              leading: const Icon(
            Icons.filter_list,
            color: Color(0xFF0D47A1), // Thick blue color for the icon
          ),
            title: const Text(
                'Filters',
                style: TextStyle(
                  color: Color(0xFF0D47A1), // Thick blue color for the text
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            onTap: () {
              setState(() {
                showFilters = !showFilters; // Toggle filter visibility
              });
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showFilters ? null : 0, // Adjust height to show/hide filters
            child: showFilters ? _buildFilters() : null,
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    // Navigate to landlord or tenant home based on user role
    if (_user != null) {
      // Check for landlord or tenant role and navigate accordingly
      // Assuming you have a way to determine user role (e.g., user metadata, custom claims, etc.)
      bool isLandlord = _user!.uid == 'landlordUid'; // Replace with actual logic
      if (isLandlord) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandlordDashboard(userId: _user!.uid)),
        );
      } else {
        Navigator.pushReplacementNamed(context, 'IntroPageView');
      }
    }
  }

  void _navigateToProfile(BuildContext context) {
    // Navigate to landlord or tenant profile based on user role
    if (_user != null) {
      // Check for landlord or tenant role and navigate accordingly
      bool isLandlord = _user!.uid == 'landlordUid'; // Replace with actual logic
      if (isLandlord) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreenLandlord(userId: _user!.uid)),
        );
      } else {
        Navigator.pushNamed(context, 'ProfileScreen');
      }
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(
      icon,
      color: const Color(0xFF0D47A1), // Thick blue color for the icon
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0D47A1), // Thick blue color for the text
        fontWeight: FontWeight.bold, // Bold text
      ),
    ),
    onTap: onTap,
  );
}
  Widget _buildFilters() {
    return Column(
      children: [
        ListTile(
          title: const Text('Price Range'),
          trailing: DropdownButton<String>(
            value: selectedPriceRange,
            items: <String>[
              '\$0 - \$100,000',
              '\$100,000 - \$200,000',
              '\$200,000 - \$300,000',
              '\$300,000 - \$400,000',
              '\$400,000+',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0D47A1), // Thick blue text
                    fontSize: 14, // Reduced font size
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPriceRange = newValue;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Bedrooms'),
          trailing: DropdownButton<int>(
            value: selectedBedrooms,
            items: List.generate(6, (index) => index).map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1), // Thick blue text
                    fontSize: 14, // Reduced font size
                  ),
                ),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                selectedBedrooms = newValue;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Bathrooms'),
          trailing: DropdownButton<int>(
            value: selectedBathrooms,
            items: List.generate(6, (index) => index).map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1), // Thick blue text
                    fontSize: 14, // Reduced font size
                  ),
                ),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                selectedBathrooms = newValue;
              });
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Swimming Pool'),
          value: swimmingPool ?? false,
          onChanged: (bool value) {
            setState(() {
              swimmingPool = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('WiFi'),
          value: wifi ?? false,
          onChanged: (bool value) {
            setState(() {
              wifi = value;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              // Apply filters
              if (widget.onFilterApplied != null) {
                widget.onFilterApplied!({
                  'priceRange': selectedPriceRange,
                  'bedrooms': selectedBedrooms,
                  'bathrooms': selectedBathrooms,
                  'swimmingPool': swimmingPool,
                  'wifi': wifi,
                });
              }
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}
