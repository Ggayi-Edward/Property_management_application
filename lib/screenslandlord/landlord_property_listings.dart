import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:propertysmart2/data/addAgreement.dart';
import 'package:propertysmart2/data/addProperty.dart';
import 'package:propertysmart2/screenslandlord/editproperty.dart'; // Import the Edit Property Page

class PropertyListingsPage extends StatelessWidget {
  Future<void> uploadFile(PlatformFile file, String userId) async {
    try {
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

      await uploadTask;
      print('File uploaded successfully.');
    } catch (e) {
      print('File upload failed: $e');
    }
  }

  Future<void> deleteProperty(BuildContext context, String propertyId, String mainImageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this property? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      Future<void> deleteImage(String imageUrl) async {
        if (imageUrl.isEmpty) return;
        final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        try {
          final metadata = await imageRef.getMetadata();
          if (metadata.customMetadata?['ownerId'] == user.uid) {
            await imageRef.delete();
            print('Image deleted: $imageUrl');
          } else {
            print('User does not own this image: $imageUrl');
          }
        } catch (e) {
          if (e.toString().contains('object-not-found')) {
            print('Image not found, might already be deleted: $imageUrl');
          } else {
            print('Error retrieving metadata or deleting image: $e');
          }
        }
      }

      await deleteImage(mainImageUrl);
      await FirebaseFirestore.instance.collection('properties').doc(propertyId).delete();
      print('Property deleted successfully.');
    } catch (e) {
      print('Error deleting property: $e');
    }
  }

  Future<void> pickAndUploadFile(String userId) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      await uploadFile(file, userId);
    } else {
      print('No file selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to view your properties.')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;
                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'PropertySmart',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isCollapsed)
                        Text(
                          'Property Listing',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('properties')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text('No properties available.')),
                );
              }

              final properties = snapshot.data!.docs;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final property = properties[index];
                    final data = property.data() as Map<String, dynamic>?;

                    final mainImage = data?['mainImage'] as String? ?? '';

                    return Card(
                      margin: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          if (mainImage.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: mainImage,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Center(child: Icon(Icons.error, color: Colors.red)),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data?['title'] ?? 'No title',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(data?['location'] ?? 'No location'),
                                  SizedBox(height: 10),
                                  Text('\$${data?['price'] ?? '0'}'),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              // Edit button
                              TextButton(
                                onPressed: () {
                                  // Navigate to Edit Property Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPropertyPage(propertyId: property.id, propertyData: data),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Edit',
                                  style: TextStyle(color: Color(0xFF0D47A1)),
                                ),
                              ),
                              // Delete button with confirmation dialog
                              TextButton(
                                onPressed: () {
                                  deleteProperty(context, property.id, mainImage);
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: properties.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPropertyPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF0D47A1),
      ),
    );
  }
}
