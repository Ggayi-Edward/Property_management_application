import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getLandlordId(String propertyId) async {
    DocumentSnapshot propertyDoc = await _firestore.collection('properties').doc(propertyId).get();
    if (propertyDoc.exists) {
      return propertyDoc['landlordId'];
    }
    return null;
  }
}
