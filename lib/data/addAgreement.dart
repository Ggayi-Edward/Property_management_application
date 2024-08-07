import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../model/lease_agreement.dart';

class CreateLeaseAgreementPage extends StatefulWidget {
  final LeaseAgreement? leaseAgreement;

  CreateLeaseAgreementPage({this.leaseAgreement});

  @override
  _CreateLeaseAgreementPageState createState() => _CreateLeaseAgreementPageState();
}

class _CreateLeaseAgreementPageState extends State<CreateLeaseAgreementPage> {
  final _formKey = GlobalKey<FormState>();
  String tenantName = '';
  String propertyAddress = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 365));
  double monthlyRent = 0.0;
  List<PlatformFile> uploadedDocuments = [];

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

  Future<void> _selectDate(BuildContext context, DateTime initialDate, bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != initialDate) {
      setState(() {
        if (isStartDate) {
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      });
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
          uploadTask = ref.putData(file.bytes!, SettableMetadata(contentType: file.extension));
        } else {
          uploadTask = ref.putFile(File(file.path!));
        }

        final snapshot = await uploadTask.whenComplete(() => null);
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

      final newLease = LeaseAgreement(
        id: DateTime.now().toString(),
        tenantName: tenantName,
        propertyAddress: propertyAddress,
        startDate: startDate,
        endDate: endDate,
        monthlyRent: monthlyRent,
        documents: documentUrls,
      );

      try {
        await FirebaseFirestore.instance.collection('lease_agreements').add({
          'tenantName': tenantName,
          'propertyAddress': propertyAddress,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'monthlyRent': monthlyRent,
          'documents': documentUrls,
          'userId': FirebaseAuth.instance.currentUser!.uid,
        });

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
        title: Text('Create Lease Agreement'),
        backgroundColor: Colors.blueAccent,
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
                  decoration: InputDecoration(labelText: 'Tenant Name'),
                  onChanged: (value) {
                    setState(() {
                      tenantName = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tenant name';
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
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, startDate, true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('End Date: ${DateFormat('yyyy-MM-dd').format(endDate)}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, endDate, false),
                      ),
                    ),
                  ],
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
