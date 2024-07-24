import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:propertysmart2/export/file_exports.dart';

class CustomDrawer extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFilterApplied;
  final bool showFilters;

  const CustomDrawer({
    Key? key,
    this.onFilterApplied,
    this.showFilters = false,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? selectedPriceRange;
  int? selectedBedrooms;
  int? selectedBathrooms;
  bool? swimmingPool;
  User? _user; // User information
  final FirebaseAuthService _authService = FirebaseAuthService();

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF304FFE), Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PropertySmart text
                const Text(
                  'PropertySmart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Avatar, Username, and Email in a Row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: _user?.photoURL != null
                          ? NetworkImage(_user!.photoURL!)
                          : AssetImage('assets/images/default_avatar.jfif') as ImageProvider,
                      radius: 30,
                    ),
                    const SizedBox(width: 10),
                    if (_user?.displayName != null && _user?.email != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user!.displayName!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _user!.email!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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
          // Existing Drawer Items
          _buildDrawerItem(Icons.home, 'Home', () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'IntroPageView');
          }),
          _buildDrawerItem(Icons.person, 'Profile', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'ProfileScreen');
          }),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.logout, 'Logout', () async {
            try {
              await _authService.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pushReplacementNamed(context, 'LoginScreen');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: $e'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }),
          // New Filter Section (Conditional)
          if (widget.showFilters) ...[
            ExpansionTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Filters'),
              children: <Widget>[
                _buildFilterDropdown<String>(
                  'Price Range',
                  selectedPriceRange,
                  <String>['All', 'Below \$100k', '\$100k - \$500k', 'Above \$500k'],
                      (value) {
                    setState(() {
                      selectedPriceRange = value;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterDropdown<int>(
                  'Bedrooms',
                  selectedBedrooms,
                  <int>[1, 2, 3, 4, 5],
                      (value) {
                    setState(() {
                      selectedBedrooms = value;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterDropdown<int>(
                  'Bathrooms',
                  selectedBathrooms,
                  <int>[1, 2, 3, 4, 5],
                      (value) {
                    setState(() {
                      selectedBathrooms = value;
                    });
                    _applyFilters();
                  },
                ),
                CheckboxListTile(
                  title: const Text('Swimming Pool'),
                  value: swimmingPool ?? false,
                  onChanged: (value) {
                    setState(() {
                      swimmingPool = value;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildFilterDropdown<T>(
      String title,
      T? selectedValue,
      List<T> values,
      ValueChanged<T?> onChanged,
      ) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<T>(
        value: selectedValue,
        onChanged: onChanged,
        items: values.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
      ),
    );
  }

  void _applyFilters() {
    if (widget.onFilterApplied != null) {
      widget.onFilterApplied!({
        'priceRange': selectedPriceRange,
        'bedrooms': selectedBedrooms,
        'bathrooms': selectedBathrooms,
        'swimmingPool': swimmingPool,
      });
    }
  }
}
