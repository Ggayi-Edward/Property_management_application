// lib/data/addProperty.dart
import 'dart:io'; // For File type
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _mainImage;
  List<File> _roomImages = [];

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _feedbackMessage;

  Future<void> _pickImage(bool isMainImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isMainImage) {
          _mainImage = File(pickedFile.path);
        } else {
          _roomImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('property_images/${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(customMetadata: {'ownerId': user.uid}),
    );
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
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
          mainImageUrl = await _uploadImage(_mainImage!);
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
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        _buildTextFormField(
                            'Price', _priceController, TextInputType.number),
                        _buildSwitchRow('WiFi', _wifi,
                                (value) => setState(() => _wifi = value)),
                        _buildSwitchRow('Swimming Pool', _swimmingPool,
                                (value) => setState(() => _swimmingPool = value)),
                        _buildDropdownRow(
                            'Bedrooms',
                            _bedrooms,
                                (value) => setState(() => _bedrooms = value!),
                            1,
                            10),
                        _buildDropdownRow(
                            'Bathrooms',
                            _bathrooms,
                                (value) => setState(() => _bathrooms = value!),
                            1,
                            10),
                        _buildImagePicker('Pick Main Image',
                                () => _pickImage(true), _mainImage),
                        _buildImagePicker('Pick Room Images',
                                () => _pickImage(false), null, _roomImages),
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

  Widget _buildTextFormField(String label, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
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

  Widget _buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Color(0xFF0D47A1))),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDropdownRow(
      String label, int value, ValueChanged<int?> onChanged, int min, int max) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Color(0xFF0D47A1))),
        SizedBox(width: 20),
        DropdownButton<int>(
          value: value,
          items: List.generate(max - min + 1, (index) => index + min)
              .map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                value.toString(),
                style: TextStyle(color: Color(0xFF0D47A1), fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildImagePicker(
      String label, VoidCallback onPressed, File? imageFile,
      [List<File>? imagesFiles]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.image, color: Color(0xFF0D47A1)),
          label: Text(label, style: TextStyle(color: Color(0xFF0D47A1))),
        ),
        if (imageFile != null)
          Image.file(
            imageFile,
            height: 150,
          ),
        if (imagesFiles != null)
          Wrap(
            spacing: 10,
            children: imagesFiles.map((file) {
              return Image.file(
                file,
                height: 100,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: _isSaving
          ? CircularProgressIndicator()
          : ElevatedButton(
        onPressed: _saveProperty,
        child: Text('Save Property'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0D47A1),
        ),
      ),
    );
  }
}
