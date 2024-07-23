import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:propertysmart2/widgets/widgets.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _userController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        // Fetch bio from a database if required
        // _bioController.text = fetchUserBio();
      });
    }
  }

  Future<void> _pickImage() async {
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

        // Update phone number if needed
        // await user.updatePhoneNumber(newPhoneNumber);

        // The bio may need to be stored in a separate database, such as Firestore
        // await _updateUserBio(_bioController.text);

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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(image: 'assets/images/background1.jpeg'),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.width * 0.1,
                ),
                Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: ClipOval(
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
                                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
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
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.08,
                      left: size.width * 0.56,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: size.width * 0.12,
                          width: size.width * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.width * 0.1,
                ),
                Column(
                  children: [
                    TextInputField(
                      controller: _userController,
                      icon: Icons.person,
                      hint: 'Name',
                      inputType: TextInputType.name,
                      inputAction: TextInputAction.next,
                    ),
                    TextInputField(
                      controller: _emailController,
                      icon: Icons.mail,
                      hint: 'Email',
                      inputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.next,
                    ),
                    TextInputField(
                      controller: _bioController,
                      icon: Icons.person,
                      hint: 'Short bio',
                      inputType: TextInputType.multiline,
                      inputAction: TextInputAction.newline,
                      maxLines: 5,
                    ),
                    TextInputField(
                      controller: _phoneController,
                      icon: Icons.phone,
                      hint: 'Phone number',
                      inputType: TextInputType.phone,
                      inputAction: TextInputAction.done,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(height: 30),
                    RoundedButton(
                      buttonName: 'Save Profile',
                      onPressed: _handleSave,
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
