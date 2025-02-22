import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:propertysmart2/pages/estate_details/estate_detail_view.dart';
import 'package:propertysmart2/widgets/drawer.dart';

class EstateListingView extends StatefulWidget {
  const EstateListingView({super.key});

  @override
  _EstateListingViewState createState() => _EstateListingViewState();
}

class _EstateListingViewState extends State<EstateListingView> {
  Map<String, dynamic> filters = {};
  String searchQuery = "";

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

  Future<void> pickAndUploadFile(String userId) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      await uploadFile(file, userId);
    } else {
      print('No file selected.');
    }
  }

  Query<Map<String, dynamic>> _buildQuery() {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('properties');

  if (filters.isNotEmpty) {
    if (filters['priceRange'] != null) {
      final priceRange = filters['priceRange'].toString().split(' - ');
      final minPrice = int.tryParse(priceRange[0].replaceAll('\$', '').replaceAll(',', '')) ?? 0;
      final maxPrice = priceRange.length > 1
          ? int.tryParse(priceRange[1].replaceAll('\$', '').replaceAll(',', '')) ?? double.infinity
          : double.infinity;
      query = query.where('price', isGreaterThanOrEqualTo: minPrice, isLessThanOrEqualTo: maxPrice);
    }
    if (filters['bedrooms'] != null) {
      query = query.where('bedrooms', isEqualTo: filters['bedrooms']);
    }
    if (filters['bathrooms'] != null) {
      query = query.where('bathrooms', isEqualTo: filters['bathrooms']);
    }
    if (filters['swimmingPool'] != null) {
      query = query.where('swimmingPool', isEqualTo: filters['swimmingPool']);
    }
    if (filters['wifi'] != null) {
      query = query.where('wifi', isEqualTo: filters['wifi']);
    }
  }

  if (searchQuery.isNotEmpty) {
    query = query
        .where('title', isGreaterThanOrEqualTo: searchQuery)
        .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff');
  }

  return query;
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to view your properties.')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      drawer: CustomDrawer(
        onFilterApplied: (newFilters) {
          setState(() {
            filters = newFilters;
          });
        },
        showFilters: true, // Enable filter display in the drawer
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
  expandedHeight: 200.0, 
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
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            if (!isCollapsed)
              Text(
                'Property Listing',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 8.0), // Adjusted spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 35, // Reduced height
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 14), // Reduced font size
                  decoration: InputDecoration(
                    hintText: 'Search by title or location',
                    hintStyle: const TextStyle(color: Colors.white70, fontSize: 14), // Reduced hint text size
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20), // Reduced icon size
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjusted border radius
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        background: Container(
          color: const Color(0xFF0D47A1),
        ),
      );
    },
  ),
),

          StreamBuilder<QuerySnapshot>(
            stream: _buildQuery().snapshots(),
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

              return SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = properties[index];
                      final data = property.data() as Map<String, dynamic>?;

                      final mainImage = data?['mainImage'] as String? ?? '';
                      final propertyId = property.id;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EstateDetailsPage(
                                estateId: propertyId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 300,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Card(
                              elevation: 4.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (mainImage.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl: mainImage,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error, color: Colors.red)),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: OverflowBox(
                                        maxHeight: double.infinity,
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              data?['title'] ?? 'No title',
                                              style: const TextStyle(
                                                fontSize: 22.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              data?['location'] ?? 'No location',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '\UGX${data?['price'] ?? '0'}',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Bedrooms: ${data?['bedrooms'] ?? '0'}',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: properties.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
