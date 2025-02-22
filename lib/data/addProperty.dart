import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:propertysmart2/data/addAgreement.dart'; // Import the file with CreateLeaseAgreementPage

class AddPropertyPage extends StatefulWidget {
  final String? propertyId;
  final Map<String, dynamic>? propertyData;

  const AddPropertyPage({Key? key, this.propertyId, this.propertyData}) : super(key: key);

  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      _loadPropertyDetails(widget.propertyData!);
    }
  }

  Future<void> _loadPropertyDetails(Map<String, dynamic> data) async {
    setState(() {
      _titleController.text = data['title'];
      _locationController.text = data['location'];
      _priceController.text = data['price'].toString();
      _ownerPhoneController.text = data['ownerPhone'];
      _wifi = data['wifi'];
      _bedrooms = data['bedrooms'];
      _bathrooms = data['bathrooms'];
      _swimmingPool = data['swimmingPool'];
      _mainImage = data['mainImage'];
      _roomImages = data['roomImages'] ?? [];
    });
  }

  Future<void> _pickImage(bool isMainImage) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageBytes = kIsWeb ? await pickedFile.readAsBytes() : io.File(pickedFile.path);
        setState(() {
          if (isMainImage) {
            _mainImage = imageBytes;
          } else {
            _roomImages.add(imageBytes);
          }
        });
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
      final ref = FirebaseStorage.instance.ref().child('property_images/${DateTime.now().toIso8601String()}.jpg');
      final mimeType = 'image/jpeg';
      final uploadTask = kIsWeb
          ? ref.putData(imageFile, SettableMetadata(contentType: mimeType, customMetadata: {'ownerId': user.uid}))
          : ref.putFile(imageFile as io.File, SettableMetadata(contentType: mimeType, customMetadata: {'ownerId': user.uid}));
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

  Future<void> _saveProperty() async {
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

        final propertyData = {
          'title': _titleController.text,
          'location': _locationController.text,
          'price': double.tryParse(_priceController.text) ?? 0,
          'ownerPhone': _ownerPhoneController.text,
          'mainImage': mainImageUrl,
          'roomImages': roomImageUrls,
          'wifi': _wifi,
          'bedrooms': _bedrooms,
          'bathrooms': _bathrooms,
          'swimmingPool': _swimmingPool,
          'userId': user.uid,
        };

        String? propertyId;
        if (widget.propertyId == null) {
          final docRef = await FirebaseFirestore.instance.collection('properties').add(propertyData);
          propertyId = docRef.id;
          // Navigate to create lease agreement page
          _navigateToCreateLeaseAgreementPage(propertyId);
        } else {
          propertyId = widget.propertyId;
          await FirebaseFirestore.instance.collection('properties').doc(propertyId).update(propertyData);
          Navigator.pop(context, propertyId); // Return the document ID
        }

        setState(() {
          _feedbackMessage = 'Property saved successfully!';
          _isSaving = false;
        });
      } catch (e) {
        setState(() {
          _feedbackMessage = 'Error saving property: $e';
          _isSaving = false;
        });
      }
    }
  }

  void _navigateToCreateLeaseAgreementPage(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLeaseAgreementPage(propertyId: propertyId),
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
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
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

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, int value, ValueChanged<int?> onChanged, int min, int max) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        SizedBox(width: 20),
        DropdownButton<int>(
          value: value,
          items: List.generate(max - min + 1, (index) => index + min)
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      '$e',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
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
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Image(
        image: kIsWeb ? MemoryImage(image) : FileImage(image as io.File),
        fit: BoxFit.cover,
      ),
    );
  }

  @override


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propertyId == null ? 'Add Property' : 'Edit Property',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField('Title', _titleController),
                _buildTextFormField('Location', _locationController),
                _buildTextFormField('Price', _priceController, TextInputType.number),
                _buildTextFormField('Owner Phone', _ownerPhoneController),
                _buildCheckboxRow('WiFi', _wifi, (value) => setState(() => _wifi = value!)),
                _buildCheckboxRow('Swimming Pool', _swimmingPool, (value) => setState(() => _swimmingPool = value!)),
                _buildDropdownRow('Bedrooms', _bedrooms, (value) => setState(() => _bedrooms = value!), 1, 10),
                _buildDropdownRow('Bathrooms', _bathrooms, (value) => setState(() => _bathrooms = value!), 1, 10),
                SizedBox(height: 20),
                _buildImagePicker('Upload Main Image', () => _pickImage(true), _mainImage),
                SizedBox(height: 20),
                _buildImagePicker('Upload Room Images', () => _pickImage(false), null, _roomImages),
                SizedBox(height: 20),
                _isSaving
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton(
                          onPressed: _saveProperty,
                          child: Text(widget.propertyId == null ? 'Save Property' : 'Update Property'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                if (_feedbackMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
