import 'package:cloud_firestore/cloud_firestore.dart';

class EstateModel {
  String id; // Property ID
  String image; // Main image of the estate
  String title;
  String location;
  double price;
  Map<String, dynamic>? availability;
  List<String>? roomImages; // List to store URLs of room images
  String phoneNumber; // New field for owner's phone number

  EstateModel({
    required this.id,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.availability,
    this.roomImages = const [],
    required this.phoneNumber, // Initialize new field
  });

  factory EstateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper function to convert price to double
    double parsePrice(dynamic price) {
      if (price is String) {
        return double.tryParse(price.replaceAll(',', '')) ?? 0.0;
      }
      return (price as num).toDouble();
    }

    return EstateModel(
      id: doc.id,
      image: data['mainImage'] ?? '', // Updated field name
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      price: parsePrice(data['price']),
      availability: data['availability'] ?? {},
      roomImages: List<String>.from(data['roomImages'] ?? []),
      phoneNumber: data['phoneNumber'] ?? '', // Extract new field
    );
  }
}
