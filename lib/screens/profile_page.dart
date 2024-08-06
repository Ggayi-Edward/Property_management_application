import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:propertysmart2/export/file_exports.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  User? _user;
  File? _profileImage;
  Uint8List? _webProfileImage; // For web image storage
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _configureFirebaseMessaging();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _user = user;
          _userController.text = user.displayName ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phoneNumber ?? '';
        });

        // Fetch bio from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _bioController.text = userDoc['bio'] ?? '';
          });
        } else {
          // Handle case where document does not exist
          setState(() {
            _bioController.text = ''; // or any default value
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch user data: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    try {
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final RemoteNotification? notification = message.notification;
          final AndroidNotification? android = message.notification?.android;

          if (notification != null && android != null) {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text('Property Smart - ${notification.title ?? 'Notification'}'),
                  content: Text(notification.body ?? ''),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                  backgroundColor: Theme.of(context).dialogBackgroundColor,
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  contentTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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

        if (_user != null && token != null) {
          await _firestore
              .collection('users')
              .doc(_user!.uid)
              .update({'fcmToken': token});
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('User denied permission');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permissions are required for full functionality. Please enable them in your device settings.'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                final Uri uri = Uri.parse(Platform.isAndroid
                    ? 'package:your.package.name'
                    : 'App-Prefs:root=NOTIFICATIONS_ID');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $uri';
                }
              },
            ),
          ),
        );
      } else {
        print('User has not yet granted permission');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permissions are required for full functionality. Please grant permission in your device settings.'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                final Uri uri = Uri.parse(Platform.isAndroid
                    ? 'package:your.package.name'
                    : 'App-Prefs:root=NOTIFICATIONS_ID');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $uri';
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error configuring Firebase Messaging: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to configure notifications: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    if (kIsWeb) {
      // Skip requesting permissions on web
      return;
    }
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  Future<void> _pickImage() async {
    await _checkAndRequestPermissions();
    if (kIsWeb) {
      // Web image picking can be implemented here if needed
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null && _webProfileImage == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String fileName =
            'profile_pics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);

        final metadata = SettableMetadata(customMetadata: {
          'ownerId': user.uid,
        });

        if (kIsWeb) {
          // For web
          await storageRef.putData(_webProfileImage!, metadata);
        } else {
          // For mobile
          await storageRef.putFile(_profileImage!, metadata);
        }

        final downloadURL = await storageRef.getDownloadURL();

        await user.updatePhotoURL(downloadURL);
        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        setState(() {
          _user = updatedUser;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload photo: $e'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error uploading image: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: _userController.text);

        if (_emailController.text.isNotEmpty &&
            _emailController.text != user.email) {
          await user.verifyBeforeUpdateEmail(_emailController.text);
        }

        // Save bio to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'bio': _bioController.text,
        }, SetOptions(merge: true));

        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        setState(() {
          _user = updatedUser;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    await _saveProfile();
    await _uploadImage(); // Upload image after saving profile
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: size.width * 0.2,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_user?.photoURL != null
                        ? NetworkImage(_user!.photoURL!)
                        : AssetImage('assets/default_profile.png')
                    as ImageProvider),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
