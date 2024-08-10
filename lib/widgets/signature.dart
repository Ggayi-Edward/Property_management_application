import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Here'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Signature(
            controller: _controller,
            height: 300,
            backgroundColor: Colors.grey[200]!,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _controller.clear();
                },
                child: Text('Clear'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    Uint8List? data = await _controller.toPngBytes();
                    if (data != null) {
                      await _saveSignature(data);
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveSignature(Uint8List signature) async {
    try {
      // Get the current user's UID
      final User? user = FirebaseAuth.instance.currentUser;
      final String userId = user!.uid;

      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('signatures')
          .child('$userId.png');

      // Upload the signature image
      await storageRef.putData(signature);

      // Get the download URL of the uploaded image
      final downloadURL = await storageRef.getDownloadURL();

      // Save the download URL to Firestore under the user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'signatureURL': downloadURL});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signature saved successfully!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving signature: $e'),
      ));
    }
  }
}
