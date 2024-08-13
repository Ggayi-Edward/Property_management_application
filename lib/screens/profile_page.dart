import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> _checkAndRequestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  Future<void> _pickImage() async {
    await _checkAndRequestPermissions();

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blueAccent,
      ),
      backgroundColor: isDarkMode ? Colors.blueGrey[800] : Colors.blue[100],
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
                              backgroundColor: isDarkMode
                                  ? Colors.grey[700]?.withOpacity(0.5)
                                  : Colors.grey[500]?.withOpacity(0.5),
                              backgroundImage: _profileImage != null
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
                              color: isDarkMode ? Colors.blueGrey[600] : theme.colorScheme.primary,
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
                      color: isDarkMode ? Colors.white : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _emailController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextInputField(
                    controller: _userController,
                    icon: Icons.person,
                    hint: 'Name',
                    inputType: TextInputType.name,
                    inputAction: TextInputAction.next,
                    color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.primary,
                  ),
                  TextInputField(
                    controller: _emailController,
                    icon: Icons.mail,
                    hint: 'Email',
                    inputType: TextInputType.emailAddress,
                    inputAction: TextInputAction.next,
                    color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.primary,
                  ),
                  TextInputField(
                    controller: _bioController,
                    icon: Icons.info_outline,
                    hint: 'Bio',
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                    color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.primary,
                  ),
                  TextInputField(
                    controller: _phoneController,
                    icon: Icons.phone,
                    hint: 'Phone',
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.next,
                    color: isDarkMode ? theme.colorScheme.primary : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    buttonName: 'Save',
                    onPressed: _handleSave,
                    color: isDarkMode ? theme.colorScheme.secondary : theme.colorScheme.secondary,
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
                        color: isDarkMode ? theme.colorScheme.error : theme.colorScheme.error,
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
