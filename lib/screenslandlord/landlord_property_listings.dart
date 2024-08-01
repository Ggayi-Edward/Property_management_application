import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_storage/firebase_storage.dart';
import 'package:propertysmart2/data/addProperty.dart';
// ignore: unused_import
import 'add_property_page.dart';

class PropertyListingsPage extends StatelessWidget {
  Future<void> _deleteProperty(String propertyId, String mainImageUrl, List<String> roomImageUrls) async {
    try {
      if (mainImageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(mainImageUrl).delete();
      }
      for (String imgUrl in roomImageUrls) {
        if (imgUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(imgUrl).delete();
        }
      }
      await FirebaseFirestore.instance.collection('properties').doc(propertyId).delete();
    } catch (e) {
      print('Error deleting property: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Listings'),
        backgroundColor: Colors.blueAccent,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('properties').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No properties available.'));
          }

          final properties = snapshot.data!.docs;

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
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
                                  : Container(), // Handle empty URL case
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
          );
        },
      ),
    );
  }
}