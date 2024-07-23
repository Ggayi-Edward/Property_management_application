class EstateModel {
  String image;          // Main image of the estate
  String title;
  String location;
  double price;
  final Map<String, dynamic> availability;
  List<String> roomImages;  // List to store URLs of room images

  EstateModel({
    required this.image,
    required this.availability,
    required this.location,
    required this.price,
    required this.title,
    this.roomImages = const [], // Initialize with an empty list by default
  });
}
