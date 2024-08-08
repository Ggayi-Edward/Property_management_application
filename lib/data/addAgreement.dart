import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateLeaseAgreementPage extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic>? leaseAgreement;

  CreateLeaseAgreementPage({required this.propertyId, this.leaseAgreement});

  @override
  _CreateLeaseAgreementPageState createState() => _CreateLeaseAgreementPageState();
}

class _CreateLeaseAgreementPageState extends State<CreateLeaseAgreementPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String propertyAddress = '';
  double monthlyRent = 0.0;
  List<PlatformFile> uploadedDocuments = [];

  @override
  void initState() {
    super.initState();
    if (widget.leaseAgreement != null) {
      final lease = widget.leaseAgreement!;
      title = lease['title'] ?? '';
      propertyAddress = lease['propertyAddress'] ?? '';
      monthlyRent = lease['monthlyRent']?.toDouble() ?? 0.0;
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        setState(() {
          uploadedDocuments = result.files;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
      print('Error picking files: $e');
    }
  }

  Future<List<String>> _uploadDocuments(List<PlatformFile> documents) async {
    final storage = FirebaseStorage.instance;
    final List<String> documentUrls = [];
    final user = FirebaseAuth.instance.currentUser;

    for (var file in documents) {
      try {
        final ref = storage.ref().child('lease_documents/${user?.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.name}');

        UploadTask uploadTask;
        if (kIsWeb) {
          // Web platform - use file.bytes
          uploadTask = ref.putData(file.bytes!, SettableMetadata(contentType: file.extension));
        } else {
          // Mobile/Desktop platforms - use file.path
          final localFile = File(file.path!);
          uploadTask = ref.putFile(localFile);
        }

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        documentUrls.add(downloadUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
        print('Error uploading file: $e');
      }
    }
    return documentUrls;
  }

  Future<void> _saveLeaseAgreement() async {
    if (_formKey.currentState?.validate() ?? false) {
      final documentUrls = await _uploadDocuments(uploadedDocuments);

      final newLease = {
        'title': title,
        'propertyAddress': propertyAddress,
        'monthlyRent': monthlyRent,
        'documents': documentUrls,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'propertyId': widget.propertyId,
      };

      try {
        if (widget.leaseAgreement == null) {
          await FirebaseFirestore.instance.collection('lease_agreements').add(newLease);
        } else {
          await FirebaseFirestore.instance.collection('lease_agreements').doc(widget.leaseAgreement!['id']).update(newLease);
        }

        Navigator.pop(context, newLease);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving lease agreement: $e')),
        );
        print('Error saving lease agreement: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Lease Agreement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Property Address'),
                  onChanged: (value) {
                    setState(() {
                      propertyAddress = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter property address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Monthly Rent'),
                  onChanged: (value) {
                    setState(() {
                      monthlyRent = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter monthly rent';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFiles,
                  child: Text('Upload Documents'),
                ),
                SizedBox(height: 10),
                if (uploadedDocuments.isNotEmpty)
                  ...uploadedDocuments.map((file) => Text('Uploaded: ${file.name}')),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveLeaseAgreement,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
