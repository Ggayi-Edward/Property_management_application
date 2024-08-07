import 'package:cloud_firestore/cloud_firestore.dart';

class EstateModel {
  String id; // Add this line
  String image; // Main image of the estate
  String title;
  String location;
  double price;
  final Map<String, dynamic> availability;
  List<String> roomImages; // List to store URLs of room images

  EstateModel({
    required this.id, // Add this line
    required this.image,
    required this.availability,
    required this.location,
    required this.price,
    required this.title,
    this.roomImages = const [], // Initialize with an empty list by default
  });

  factory EstateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EstateModel(
      id: doc.id, // Add this line
      image: data['image'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      availability: data['availability'] ?? {},
      roomImages: List<String>.from(data['roomImages'] ?? []),
    );
  }
}
