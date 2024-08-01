import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPropertyPage extends StatefulWidget {
  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _wifi = false;
  int _bedrooms = 1;
  int _bathrooms = 1;
  bool _swimmingPool = false;

  String? _mainImageBase64;
  List<String> _roomImagesBase64 = [];

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _feedbackMessage;

  Future<void> _pickImage(bool isMainImage) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.length == 1) {
        final reader = html.FileReader();
        reader.readAsDataUrl(files[0]);
        reader.onLoadEnd.listen((e) {
          final base64String = reader.result as String;
          setState(() {
            if (isMainImage) {
              _mainImageBase64 = base64String;
            } else {
              _roomImagesBase64.add(base64String);
            }
          });
        });
      }
    });
  }

  Future<String> _uploadImage(String base64Image) async {
    final ref = FirebaseStorage.instance.ref().child('property_images/${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = ref.putString(base64Image, format: PutStringFormat.dataUrl);
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
        String? mainImageUrl;
        List<String> roomImageUrls = [];

        if (_mainImageBase64 != null) {
          mainImageUrl = await _uploadImage(_mainImageBase64!);
        }

        for (var imageBase64 in _roomImagesBase64) {
          final imageUrl = await _uploadImage(imageBase64);
          roomImageUrls.add(imageUrl);
        }

        await FirebaseFirestore.instance.collection('properties').add({
          'title': _titleController.text,
          'location': _locationController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'mainImage': mainImageUrl,
          'roomImages': roomImageUrls,
          'wifi': _wifi,
          'bedrooms': _bedrooms,
          'bathrooms': _bathrooms,
          'swimmingPool': _swimmingPool,
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
      appBar: AppBar(
        title: Text('Add Property'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('WiFi'),
                    Switch(
                      value: _wifi,
                      onChanged: (value) {
                        setState(() {
                          _wifi = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Swimming Pool'),
                    Switch(
                      value: _swimmingPool,
                      onChanged: (value) {
                        setState(() {
                          _swimmingPool = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Bedrooms'),
                    Expanded(
                      child: Slider(
                        value: _bedrooms.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_bedrooms',
                        onChanged: (value) {
                          setState(() {
                            _bedrooms = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text('$_bedrooms'),
                  ],
                ),
                Row(
                  children: [
                    Text('Bathrooms'),
                    Expanded(
                      child: Slider(
                        value: _bathrooms.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_bathrooms',
                        onChanged: (value) {
                          setState(() {
                            _bathrooms = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text('$_bathrooms'),
                  ],
                ),
                SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _pickImage(true),
                  icon: Icon(Icons.image),
                  label: Text('Pick Main Image'),
                ),
                if (_mainImageBase64 != null)
                  Image.memory(
                    base64Decode(_mainImageBase64!.split(',').last),
                    height: 150,
                  ),
                SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _pickImage(false),
                  icon: Icon(Icons.image),
                  label: Text('Pick Room Images'),
                ),
                Wrap(
                  spacing: 10,
                  children: _roomImagesBase64.map((imgBase64) {
                    return Image.memory(
                      base64Decode(imgBase64.split(',').last),
                      height: 100,
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                if (_isSaving)
                  Center(child: CircularProgressIndicator())
                else
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProperty,
                      child: Text('Save Property'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
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
        ),
      ),
    );
  }
}