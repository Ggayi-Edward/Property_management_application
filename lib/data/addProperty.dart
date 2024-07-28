import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  File? _mainImage;
  List<File> _roomImages = [];
  final _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(bool isMainImage) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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

  void _saveProperty() {
    if (_formKey.currentState?.validate() ?? false) {
      // Here you can add logic to save the property details and images to your database
      print('Title: ${_titleController.text}');
      print('Location: ${_locationController.text}');
      print('Price: ${_priceController.text}');
      print('Description: ${_descriptionController.text}');
      print('Main Image: ${_mainImage?.path}');
      print('Room Images: ${_roomImages.map((img) => img.path).toList()}');
      print('WiFi: $_wifi');
      print('Bedrooms: $_bedrooms');
      print('Bathrooms: $_bathrooms');
      print('Swimming Pool: $_swimmingPool');
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
                if (_mainImage != null)
                  Image.file(
                    _mainImage!,
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
                  children: _roomImages.map((img) => Image.file(img, height: 100)).toList(),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProperty,
                    child: Text('Save Property'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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
