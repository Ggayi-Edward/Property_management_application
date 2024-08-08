import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String chatId, String senderId, String senderName, String messageText) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName, // Include senderName
      'messageText': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the last message in the chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': messageText,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc.data() as Map<String, dynamic>)).toList());
  }
}
