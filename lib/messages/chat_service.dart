// chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrJoinChat(String userId1, String userId2) async {
    final chatCollection = _firestore.collection('chats');

    // Check if chat already exists
    final existingChats = await chatCollection
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in existingChats.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    // If chat doesn't exist, create a new one
    final chatDoc = await chatCollection.add({
      'participants': [userId1, userId2],
      'lastMessage': '',
      'lastTimestamp': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }
}
