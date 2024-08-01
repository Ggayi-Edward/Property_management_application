import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/messages/messagingPage.dart';
import 'package:propertysmart2/messages/PropertyService.dart';
import 'package:propertysmart2/messages/chat_service.dart';

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
  User? _user;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ChatService _chatService = ChatService();
  final PropertyService _propertyService = PropertyService();

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

  Future<void> _navigateToMessagingPage(BuildContext context) async {
    if (_user != null) {
      // Replace 'propertyId' with the actual ID of the property being viewed
      String propertyId = 'propertyId';
      String? landlordId = await _propertyService.getLandlordId(propertyId);
      if (landlordId != null) {
        String chatId = await _chatService.createOrJoinChat(_user!.uid, landlordId);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagingPage(
              chatId: chatId,
              senderId: _user!.uid,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to find landlord information'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not logged in'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0D47A1),
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
          _buildDrawerItem(Icons.home, 'Home', () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'IntroPageView');
          }),
          _buildDrawerItem(Icons.person, 'Profile', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'ProfileScreen');
          }),
          _buildDrawerItem(Icons.email, 'Messages', () {
            _navigateToMessagingPage(context);
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
                  checkColor: Colors.white,
                  activeColor: Color(0xFF0D47A1),
                  tileColor: Color(0xFFE3F2FD),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        'Reset Filters',
                        Colors.white,
                        Color(0xFF0D47A1),
                            () {
                          setState(() {
                            selectedPriceRange = null;
                            selectedBedrooms = null;
                            selectedBathrooms = null;
                            swimmingPool = null;
                          });
                          _applyFilters();
                        },
                      ),
                      _buildActionButton(
                        'Apply Filters',
                        Color(0xFF0D47A1),
                        Colors.white,
                        _applyFilters,
                      ),
                    ],
                  ),
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
        dropdownColor: Color(0xFFE3F2FD),
        style: TextStyle(color: Color(0xFF0D47A1)),
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

  Widget _buildActionButton(
      String text,
      Color backgroundColor,
      Color textColor,
      VoidCallback onPressed,
      ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
