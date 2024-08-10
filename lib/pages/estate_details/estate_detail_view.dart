import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:propertysmart2/payment/payment_page.dart';

class EstateDetailsPage extends StatelessWidget {
  final String estateId;

  const EstateDetailsPage({Key? key, required this.estateId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estate Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('properties').doc(estateId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No estate data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final roomImages = List<String>.from(data['roomImages'] ?? []);
          final mainImage = data['mainImage'] as String? ?? '';
          final landlordEmail = data['ownerEmail'] ?? 'default@example.com';
          final landlordPhone = data['ownerPhone'] ?? 'N/A';
          final price = data['price']?.toString() ?? '0';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mainImage.isNotEmpty)
                  ClipPath(
                    clipper: SingleArcClipper(),
                    child: CachedNetworkImage(
                      imageUrl: mainImage,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.red)),
                    ),
                  ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No title',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Location: ${data['location'] ?? 'No location'}',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Price: \$${data['price'] ?? '0'}',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.king_bed, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Bedrooms: ${data['bedrooms'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.bathtub, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Bathrooms: ${data['bathrooms'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.wifi, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'WiFi: ${data['wifi'] ?? false ? 'Yes' : 'No'}',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.pool, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Swimming Pool: ${data['swimmingPool'] ?? false ? 'Yes' : 'No'}',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          Text(
                            'Owner Phone: $landlordPhone',
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (roomImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rooms',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: roomImages.length,
                                itemBuilder: (context, index) {
                                  final imageUrl = roomImages[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.red)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  landlordEmail: landlordEmail,
                                  landlordMobileMoneyNumber: landlordPhone,
                                  price: price,
                                  estateId: estateId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1), // Button color
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom clipper class for creating a single outward arc
class SingleArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);

    final controlPoint = Offset(size.width / 2, size.height + 50);
    final endPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
