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
                _buildTextFormField('Title', _titleController),
                _buildTextFormField('Location', _locationController),
                _buildTextFormField('Price', _priceController, TextInputType.number),
                _buildTextFormField('Description', _descriptionController),
                _buildSwitchRow('WiFi', _wifi, (value) => setState(() => _wifi = value)),
                _buildSwitchRow('Swimming Pool', _swimmingPool, (value) => setState(() => _swimmingPool = value)),
                _buildSliderRow('Bedrooms', _bedrooms, (value) => setState(() => _bedrooms = value.toInt()), 1, 10),
                _buildSliderRow('Bathrooms', _bathrooms, (value) => setState(() => _bathrooms = value.toInt()), 1, 10),
                _buildImagePicker('Pick Main Image', () => _pickImage(true), _mainImageBase64),
                _buildImagePicker('Pick Room Images', () => _pickImage(false), null, _roomImagesBase64),
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
        ),
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
          labelStyle: TextStyle(color: Colors.blue),
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label.toLowerCase()';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.blue)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildSliderRow(String label, int value, ValueChanged<double> onChanged, int min, int max) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.blue)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: onChanged,
          ),
        ),
        Text('$value', style: TextStyle(color: Colors.blue)),
      ],
    );
  }

  Widget _buildImagePicker(String label, VoidCallback onPressed, String? imageBase64, [List<String>? imagesBase64]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.image, color: Colors.blue),
          label: Text(label, style: TextStyle(color: Colors.blue)),
        ),
        if (imageBase64 != null)
          Image.memory(
            base64Decode(imageBase64.split(',').last),
            height: 150,
          ),
        if (imagesBase64 != null)
          Wrap(
            spacing: 10,
            children: imagesBase64.map((imgBase64) {
              return Image.memory(
                base64Decode(imgBase64.split(',').last),
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
              backgroundColor: Colors.blueAccent,
            ),
          ),
    );
  }
}