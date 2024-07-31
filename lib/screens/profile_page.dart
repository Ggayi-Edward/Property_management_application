import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:propertysmart2/widgets/widgets.dart';
import 'package:propertysmart2/export/file_exports.dart';

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
      }
    }
  }

  Future<void> _configureFirebaseMessaging() async {
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
                title: Text(notification.title ?? ''),
                content: Text(notification.body ?? ''),
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

      if (_user != null && token != null) {
        await _firestore.collection('users').doc(_user!.uid).update({'fcmToken': token});
      }
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  Future<void> _pickImage() async {
    await _checkAndRequestPermissions();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fileName = 'profile_pics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putFile(_profileImage!);
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
    }
  }

  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: _userController.text);

        if (_emailController.text.isNotEmpty && _emailController.text != user.email) {
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
    final theme = Theme.of(context); // Access the theme

    return Scaffold(
      backgroundColor: Colors.blue[100], // Use a thin blue background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.width * 0.1,
            ),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 6,
                              sigmaY: 6,
                            ),
                            child: CircleAvatar(
                              radius: size.width * 0.14,
                              backgroundColor: Colors.grey[500]?.withOpacity(0.5),
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!) as ImageProvider
                                  : (_user?.photoURL != null
                                  ? NetworkImage(_user!.photoURL!)
                                  : const AssetImage('assets/images/default_avatar.jfif')
                              as ImageProvider),
                              child: _profileImage == null && (_user?.photoURL == null)
                                  ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: size.width * 0.1,
                              )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            height: size.width * 0.12,
                            width: size.width * 0.12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary, // Use theme color
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: size.width * 0.08,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.width * 0.1,
            ),
            Column(
              children: [
                Text(
                  _userController.text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary, // Use theme color
                  ),
                ),
                Text(
                  _emailController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onBackground, // Use theme color
                  ),
                ),
                const SizedBox(height: 30),
                TextInputField(
                  controller: _userController,
                  icon: Icons.person,
                  hint: 'Name',
                  inputType: TextInputType.name,
                  inputAction: TextInputAction.next,
                  color: theme.colorScheme.primary, // Use theme color
                ),
                TextInputField(
                  controller: _emailController,
                  icon: Icons.mail,
                  hint: 'Email',
                  inputType: TextInputType.emailAddress,
                  inputAction: TextInputAction.next,
                  color: theme.colorScheme.primary, // Use theme color
                ),
                TextInputField(
                  controller: _bioController,
                  icon: Icons.person,
                  hint: 'Short bio',
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.newline,
                  maxLines: 5,
                  color: theme.colorScheme.primary, // Use theme color
                ),
                TextInputField(
                  controller: _phoneController,
                  icon: Icons.phone,
                  hint: 'Phone number',
                  inputType: TextInputType.phone,
                  inputAction: TextInputAction.done,
                  color: theme.colorScheme.primary, // Use theme color
                ),
                const SizedBox(height: 25),
                RoundedButton(
                  buttonName: 'Save Profile',
                  onPressed: _handleSave,
                  color: theme.colorScheme.primary, // Use theme color
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
