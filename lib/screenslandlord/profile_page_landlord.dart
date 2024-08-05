import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:propertysmart2/widgets/widgets.dart';
import 'package:propertysmart2/export/file_exports.dart';

class ProfileScreenLandlord extends StatefulWidget {
  const ProfileScreenLandlord({super.key, required this.userId});

  final String userId;

  @override
  _ProfileScreenLandlordState createState() => _ProfileScreenLandlordState();
}

class _ProfileScreenLandlordState extends State<ProfileScreenLandlord> {
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
      // Use ImagePicker for web platforms
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final webImage = await pickedFile.readAsBytes();
        setState(() {
          _webProfileImage = webImage;
        });
      }
    } else {
      // Use ImagePicker for mobile platforms
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
        String fileName = 'profile_pics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);

        if (kIsWeb) {
          // For web
          await storageRef.putData(_webProfileImage!);
        } else {
          // For mobile
          await storageRef.putFile(_profileImage!);
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
      print('Error uploading image: $e'); // Log error
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
                              backgroundImage: kIsWeb
                                  ? (_webProfileImage != null
                                      ? MemoryImage(_webProfileImage!)
                                      : const AssetImage('assets/images/default_avatar.jfif')
                                          as ImageProvider)
                                  : _profileImage != null
                                      ? FileImage(_profileImage!) as ImageProvider
                                      : (_user?.photoURL != null
                                          ? NetworkImage(_user!.photoURL!)
                                          : const AssetImage('assets/images/default_avatar.jfif')
                                              as ImageProvider),
                              onBackgroundImageError: (_, __) {
                                // Handle image loading error
                                setState(() {
                                  // Fallback to a default image or any other error handling
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            height: size.width * 0.12,
                            width: size.width * 0.12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userController.text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _emailController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextInputField(
                    controller: _userController,
                    icon: Icons.person,
                    hint: 'Name',
                    inputType: TextInputType.name,
                    inputAction: TextInputAction.next,
                    color: theme.colorScheme.primary,
                  ),
                  TextInputField(
                    controller: _emailController,
                    icon: Icons.mail,
                    hint: 'Email',
                    inputType: TextInputType.emailAddress,
                    inputAction: TextInputAction.next,
                    color: theme.colorScheme.primary,
                  ),
                  TextInputField(
                    controller: _bioController,
                    icon: Icons.info_outline,
                    hint: 'Bio',
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                    color: theme.colorScheme.primary,
                  ),
                  TextInputField(
                    controller: _phoneController,
                    icon: Icons.phone,
                    hint: 'Phone',
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.next,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    buttonName: 'Save',
                    onPressed: _handleSave,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
