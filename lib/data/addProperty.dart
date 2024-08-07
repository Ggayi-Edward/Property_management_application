import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
class AddPropertyPage extends StatefulWidget {
  final String? propertyId;
  final Map<String, dynamic>? propertyData;

  AddPropertyPage({this.propertyId, this.propertyData});

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

  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      _titleController.text = widget.propertyData!['title'] ?? '';
      _locationController.text = widget.propertyData!['location'] ?? '';
      _priceController.text = widget.propertyData!['price']?.toString() ?? '';
      _wifi = widget.propertyData!['wifi'] ?? false;
      _bedrooms = widget.propertyData!['bedrooms'] ?? 1;
      _bathrooms = widget.propertyData!['bathrooms'] ?? 1;
      _swimmingPool = widget.propertyData!['swimmingPool'] ?? false;
      _mainImage = widget.propertyData!['mainImage'];
      _roomImages = List<dynamic>.from(widget.propertyData!['roomImages'] ?? []);
    }
  }

  Future<void> _uploadImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _feedbackMessage = 'User not authenticated';
      });
      return;
    }

    try {
      if (_mainImage is XFile || _mainImage is io.File) {
        _mainImage = await _uploadImage(_mainImage, user.uid);
      }

      for (int i = 0; i < _roomImages.length; i++) {
        if (_roomImages[i] is XFile || _roomImages[i] is io.File) {
          _roomImages[i] = await _uploadImage(_roomImages[i], user.uid);
        }
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Image upload failed: $e';
      });
    }
  }

  Future<String> _uploadImage(dynamic image, String userId) async {
    Uint8List? fileBytes;
    String fileName;

    if (image is XFile) {
      fileBytes = await image.readAsBytes();
      fileName = image.name;
    } else if (image is io.File) {
      fileBytes = await image.readAsBytes();
      fileName = path.basename(image.path);
    } else {
      throw 'Unsupported image type';
    }

    final storageRef = FirebaseStorage.instance.ref().child('uploads/$userId/$fileName');
    final uploadTask = storageRef.putData(
      fileBytes!,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'ownerId': userId},
      ),
    );

    await uploadTask;
    return await storageRef.getDownloadURL();
  }

  Future<void> _pickImage(bool isMainImage) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isMainImage) {
          _mainImage = pickedFile;
        } else {
          _roomImages.add(pickedFile);
        }
      });
    }
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _feedbackMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _feedbackMessage = 'User not authenticated';
          _isSaving = false;
        });
        return;
      }

      await _uploadImages();

      final propertyData = {
        'title': _titleController.text,
        'location': _locationController.text,
        'price': double.parse(_priceController.text),
        'wifi': _wifi,
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'swimmingPool': _swimmingPool,
        'mainImage': _mainImage,
        'roomImages': _roomImages,
        'userId': user.uid,
      };

      if (widget.propertyId != null) {
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(widget.propertyId)
            .update(propertyData);
      } else {
        await FirebaseFirestore.instance.collection('properties').add(propertyData);
      }

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Error saving property: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propertyId != null ? 'Edit Property' : 'Add Property',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text('WiFi'),
                value: _wifi,
                onChanged: (value) {
                  setState(() {
                    _wifi = value;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _bedrooms,
                decoration: InputDecoration(labelText: 'Bedrooms'),
                items: List.generate(10, (index) => index + 1)
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(), style: TextStyle(color: Colors.blue[900], fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _bedrooms = value!;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _bathrooms,
                decoration: InputDecoration(labelText: 'Bathrooms'),
                items: List.generate(10, (index) => index + 1)
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString(), style: TextStyle(color: Colors.blue[900], fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _bathrooms = value!;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Swimming Pool'),
                value: _swimmingPool,
                onChanged: (value) {
                  setState(() {
                    _swimmingPool = value;
                  });
                },
              ),
              if (_mainImage != null)
                kIsWeb
                    ? Image.network(_mainImage, height: 150)
                    : Image.file(io.File(_mainImage.path), height: 150),
              TextButton(
                onPressed: () => _pickImage(true),
                child: Text('Pick Main Image'),
              ),
              Text('Room Images:'),
              Wrap(
                children: _roomImages
                    .map<Widget>((image) => kIsWeb
                        ? Image.network(image, height: 100)
                        : Image.file(io.File(image.path), height: 100))
                    .toList(),
              ),
              TextButton(
                onPressed: () => _pickImage(false),
                child: Text('Pick Room Images'),
              ),
              SizedBox(height: 20),
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProperty,
                      child: Text('Save Property'),
                    ),
              if (_feedbackMessage != null)
                Text(
                  _feedbackMessage!,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
