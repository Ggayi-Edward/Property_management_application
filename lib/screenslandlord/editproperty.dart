import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditPropertyPage extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic>? propertyData;

  EditPropertyPage({required this.propertyId, this.propertyData});

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String location = '';
  double price = 0.0;
  String mainImageUrl = '';
  List<PlatformFile> pickedRoomFiles = [];
  List<String> roomImageUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      title = widget.propertyData!['title'] ?? '';
      location = widget.propertyData!['location'] ?? '';
      price = widget.propertyData!['price']?.toDouble() ?? 0.0;
      mainImageUrl = widget.propertyData!['mainImage'] ?? '';
      roomImageUrls = List<String>.from(widget.propertyData!['roomImages'] ?? []);
    }
  }

  Future<void> _pickMainImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        mainImageUrl = '';
        pickedRoomFiles = [result.files.first];
      });
    }
  }

  Future<void> _pickRoomImages() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        pickedRoomFiles.addAll(result.files);
      });
    }
  }

  Future<String> _uploadFile(String userId, PlatformFile file) async {
    Uint8List? fileBytes;
    String fileName;

    if (kIsWeb) {
      fileBytes = file.bytes;
      fileName = file.name;
    } else {
      fileBytes = await File(file.path!).readAsBytes();
      fileName = path.basename(file.path!);
    }

    final storageRef = FirebaseStorage.instance.ref().child('uploads/$userId/$fileName');
    final uploadTask = storageRef.putData(
      fileBytes!,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'ownerId': userId},
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      String newMainImageUrl = mainImageUrl;
      List<String> newRoomImageUrls = [];

      if (pickedRoomFiles.isNotEmpty) {
        for (var file in pickedRoomFiles) {
          final imageUrl = await _uploadFile(userId, file);
          if (file == pickedRoomFiles.first) {
            newMainImageUrl = imageUrl;
          } else {
            newRoomImageUrls.add(imageUrl);
          }
        }
      }

      final updatedProperty = {
        'title': title,
        'location': location,
        'price': price,
        'mainImage': newMainImageUrl,
        'roomImages': newRoomImageUrls,
        'userId': userId,
      };

      await FirebaseFirestore.instance.collection('properties').doc(widget.propertyId).update(updatedProperty);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Property',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a title';
                  return null;
                },
              ),
              TextFormField(
                initialValue: location,
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) => setState(() => location = value),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a location';
                  return null;
                },
              ),
              TextFormField(
                initialValue: price.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
                onChanged: (value) => setState(() => price = double.tryParse(value) ?? 0.0),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
         
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickMainImage,
                child: Text('Pick Main Image'),
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Control padding
                ),
              ),
              SizedBox(height: 10),
              if (mainImageUrl.isNotEmpty && pickedRoomFiles.isEmpty)
                Image.network(mainImageUrl, height: 150),
              if (pickedRoomFiles.isNotEmpty)
                Image.memory(pickedRoomFiles.first.bytes!, height: 150),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickRoomImages,
                child: Text('Pick Room Images'),
                              style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Control padding
                ),
              ),
              SizedBox(height: 10),
              if (roomImageUrls.isNotEmpty && pickedRoomFiles.length == 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: roomImageUrls.map((url) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(url, height: 100, width: 100),
                      );
                    }).toList(),
                  ),
                ),
              if (pickedRoomFiles.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: pickedRoomFiles.skip(1).map((file) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.memory(file.bytes!, height: 100, width: 100),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProperty,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Control padding
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
