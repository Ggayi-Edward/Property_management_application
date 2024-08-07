import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddPropertyPage extends StatefulWidget {
  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _wifi = false;
  int _bedrooms = 1;
  int _bathrooms = 1;
  bool _swimmingPool = false;

  dynamic _mainImage;
  List<dynamic> _roomImages = [];

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isUploading = false;
  String? _feedbackMessage;

  Future<void> _pickImage(bool isMainImage) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (isMainImage) {
          _mainImage = kIsWeb ? await pickedFile.readAsBytes() : io.File(pickedFile.path);
        } else {
          _roomImages.add(kIsWeb ? await pickedFile.readAsBytes() : io.File(pickedFile.path));
        }
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Error picking image: $e';
      });
    }
  }

  Future<String> _uploadImage(dynamic imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('property_images/${DateTime.now().toIso8601String()}.jpg');
      
      String mimeType = 'image/jpeg'; // Default MIME type
      if (imageFile is io.File) {
        final extension = imageFile.path.split('.').last;
        if (extension == 'png') {
          mimeType = 'image/png';
        }
      }

      final uploadTask = kIsWeb
          ? ref.putData(imageFile, SettableMetadata(contentType: mimeType, customMetadata: {'ownerId': user.uid}))
          : ref.putFile(
              imageFile,
              SettableMetadata(contentType: mimeType, customMetadata: {'ownerId': user.uid}),
            );

      setState(() {
        _isUploading = true;
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _saveProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
        _feedbackMessage = null;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _feedbackMessage = 'User not authenticated. Please log in.';
            _isSaving = false;
          });
          return;
        }

        String? mainImageUrl;
        List<String> roomImageUrls = [];

        if (_mainImage != null) {
          mainImageUrl = await _uploadImage(_mainImage);
        }

        for (var imageFile in _roomImages) {
          final imageUrl = await _uploadImage(imageFile);
          roomImageUrls.add(imageUrl);
        }

        await FirebaseFirestore.instance.collection('properties').add({
          'title': _titleController.text,
          'location': _locationController.text,
          'price': _priceController.text,
          'mainImage': mainImageUrl,
          'roomImages': roomImageUrls,
          'wifi': _wifi,
          'bedrooms': _bedrooms,
          'bathrooms': _bathrooms,
          'swimmingPool': _swimmingPool,
          'userId': user.uid,
        });

        setState(() {
          _feedbackMessage = 'Property saved successfully!';
          _isSaving = false;
        });

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _feedbackMessage = 'Error saving property: $e';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isCollapsed)
                        Text(
                          'Add Property',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFormField('Title', _titleController),
                        _buildTextFormField('Location', _locationController),
                        _buildTextFormField('Price', _priceController, TextInputType.number),
                        _buildSwitchRow('WiFi', _wifi, (value) => setState(() => _wifi = value)),
                        _buildSwitchRow('Swimming Pool', _swimmingPool, (value) => setState(() => _swimmingPool = value)),
                        _buildDropdownRow('Bedrooms', _bedrooms, (value) => setState(() => _bedrooms = value!), 1, 10),
                        _buildDropdownRow('Bathrooms', _bathrooms, (value) => setState(() => _bathrooms = value!), 1, 10),
                        _buildImagePicker('Pick Main Image', () => _pickImage(true), _mainImage),
                        _buildImagePicker('Pick Room Images', () => _pickImage(false), null, _roomImages),
                        SizedBox(height: 20),
                        _buildSaveButton(),
                        if (_feedbackMessage != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _feedbackMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF0D47A1)),
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Color(0xFF0D47A1))),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDropdownRow(String label, int value, ValueChanged<int?> onChanged, int min, int max) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Color(0xFF0D47A1))),
        SizedBox(width: 20),
        DropdownButton<int>(
          value: value,
          items: List.generate(max - min + 1, (index) => index + min)
              .map((e) => DropdownMenuItem(
            child: Text('$e'),
            value: e,
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildImagePicker(String buttonText, VoidCallback onPressed, dynamic image, [List<dynamic>? images]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0D47A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(buttonText),
        ),
        SizedBox(height: 10),
        if (image != null) _displayImage(image),
        if (images != null) Wrap(children: images.map((img) => _displayImage(img)).toList()),
      ],
    );
  }

  Widget _displayImage(dynamic image) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: kIsWeb
          ? Image.memory(image, width: 100, height: 100)
          : Image.file(image as io.File, width: 100, height: 100),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isSaving || _isUploading ? null : _saveProperty,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0D47A1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: _isSaving || _isUploading
            ? SizedBox(
          height: 24.0,
          width: 24.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
            strokeWidth: 4.0,
          ),
        )
            : Text('Save Property'),
      ),
    );
  }
}
