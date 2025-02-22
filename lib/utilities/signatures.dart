import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class SignaturePad extends StatefulWidget {
  @override
  _SignaturePadState createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Signature Pad',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Please sign in the box below. Use your finger or a stylus to create your signature.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Signature(
              controller: _controller,
              height: 300,
              backgroundColor: Colors.grey[200]!,
            ),
            const SizedBox(height: 20),
            if (_isUploading)
              const CircularProgressIndicator(),
            if (!_isUploading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _controller.clear(),
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: _saveSignature,
                    child: const Text('Save'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      try {
        setState(() {
          _isUploading = true;
        });

        Uint8List? data = await _controller.toPngBytes();
        if (data != null) {
          await _saveImageToFirebase(data);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signature saved and attached to your account!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving signature: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign before saving.')),
      );
    }
  }

  Future<void> _saveImageToFirebase(Uint8List data) async {
    // Request storage permissions
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to save the signature.')),
      );
      return;
    }

    // Get the current user
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Create a unique filename for the signature
      String fileName = '${Uuid().v4()}.png';
      String filePath = 'signatures/${user.uid}/$fileName';
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putData(data);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the download URL to Firestore under the user's document
      await _firestore.collection('users').doc(user.uid).set({
        'signatureUrl': downloadUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error uploading and saving signature: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving signature to Firestore: $e')),
      );
    }
  }
}
