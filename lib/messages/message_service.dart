import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String chatId, String senderId, String senderName, String messageText) async {
    final messageData = {
      'messageText': messageText,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.now(),
    };

    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.collection('messages').add(messageData);
    await chatRef.update({
      'lastMessage': messageText,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
