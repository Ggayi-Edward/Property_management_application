import 'dart:io';
import 'package:path/path.dart' as path; // Import the path package with alias
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:propertysmart2/data/addProperty.dart';


class PropertyListingsPage extends StatelessWidget {
  Future<void> _uploadFile(String filePath, String userId) async {
    final file = File(filePath);
    final fileName = path.basename(filePath); // Get the file name using basename
    final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(
        customMetadata: {'ownerId': userId},
      ),
    );

    await uploadTask.whenComplete(() => print('File uploaded successfully.'));
  }

  Future<void> _deleteProperty(String propertyId, String mainImageUrl, List<String> roomImageUrls) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return;
      }

      // Delete the main image if owned by the user
      if (mainImageUrl.isNotEmpty) {
        final mainImageRef = FirebaseStorage.instance.refFromURL(mainImageUrl);
        try {
          final metadata = await mainImageRef.getMetadata();
          if (metadata.customMetadata?['ownerId'] == user.uid) {
            await mainImageRef.delete();
          } else {
            print('User does not own this image');
          }
        } catch (e) {
          print('Error retrieving metadata or deleting main image: $e');
        }
      }

      // Delete room images if owned by the user
      for (String imgUrl in roomImageUrls) {
        if (imgUrl.isNotEmpty) {
          final imgRef = FirebaseStorage.instance.refFromURL(imgUrl);
          try {
            final metadata = await imgRef.getMetadata();
            if (metadata.customMetadata?['ownerId'] == user.uid) {
              await imgRef.delete();
            } else {
              print('User does not own this image');
            }
          } catch (e) {
            print('Error retrieving metadata or deleting room image: $e');
          }
        }
      }

      // Delete the property document
      await FirebaseFirestore.instance.collection('properties').doc(propertyId).delete();
      print('Property deleted successfully.');
    } catch (e) {
      print('Error deleting property: $e');
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
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPropertyPage()),
                  );
                },
              ),
            ],
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
                    final roomImages = data?['roomImages'] is List
                        ? List<String>.from(data!['roomImages'])
                        : <String>[];

                    return Card(
                      margin: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mainImage.isNotEmpty)
                            Image.network(
                              mainImage,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Icon(Icons.error, color: Colors.red));
                              },
                            ),
                          Padding(
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
                                SizedBox(height: 10),
                                Text(data?['description'] ?? 'No description'),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  children: roomImages.map(
                                        (imgUrl) => imgUrl.isNotEmpty
                                        ? Image.network(
                                      imgUrl,
                                      height: 100,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) {
                                          return child;
                                        } else {
                                          return Center(child: CircularProgressIndicator());
                                        }
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(child: Icon(Icons.error, color: Colors.red));
                                      },
                                    )
                                        : Container(),
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                          ButtonBar(
                            children: [
                              TextButton(
                                onPressed: () {
                                  _deleteProperty(
                                    property.id,
                                    mainImage,
                                    roomImages,
                                  );
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
    );
  }
}
