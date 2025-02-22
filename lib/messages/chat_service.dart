import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:propertysmart2/model/landlord.dart';
import 'package:propertysmart2/model/tenant.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or join a chat between two users
  Future<String> createOrJoinChat(String userId1, String userId2, {String? estateId}) async {
    final chatCollection = _firestore.collection('chats');

    // Check if chat already exists
    final existingChats = await chatCollection
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in existingChats.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(userId2)) {
        // Return existing chatId if both participants are found
        return doc.id;
      }
    }

    // If chat doesn't exist, create a new one
    final chatDoc = await chatCollection.add({
      'participants': [userId1, userId2],
      if (estateId != null) 'estateId': estateId,
      'lastMessage': '',
      'lastTimestamp': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }

  // Get or create a chat ID between a landlord and a tenant for a specific estate
  Future<String> getOrCreateChatId(String landlordId, String tenantId, String estateId) async {
    final chatRef = _firestore.collection('chats');

    // Check if a chat already exists for the specific landlord, tenant, and estate
    final existingChat = await chatRef
        .where('landlordId', isEqualTo: landlordId)
        .where('tenantId', isEqualTo: tenantId)
        .where('estateId', isEqualTo: estateId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      // Return existing chatId
      return existingChat.docs.first.id;
    } else {
      // Create a new chat document and return its ID
      final newChatDoc = chatRef.doc();
      await newChatDoc.set({
        'landlordId': landlordId,
        'tenantId': tenantId,
        'estateId': estateId,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [landlordId, tenantId],
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
      return newChatDoc.id;
    }
  }

  // Get a list of tenants who have sent messages to a landlord
  Future<List<Tenant>> getTenantsWhoSentMessages(String landlordId) async {
    final chatCollection = _firestore.collection('chats');
    final tenantList = <Tenant>[];

    final chats = await chatCollection
        .where('participants', arrayContains: landlordId)
        .get();

    for (var chat in chats.docs) {
      final participants = List<String>.from(chat['participants']);
      for (var participant in participants) {
        if (participant != landlordId) {
          final userDoc = await _firestore.collection('users').doc(participant).get();
          if (userDoc.exists) {
            final tenant = Tenant(
              name: userDoc['name'],
              email: userDoc['email'],
              chatId: chat.id,
            );
            tenantList.add(tenant);
          }
        }
      }
    }

    return tenantList;
  }

  // Get a list of landlords who have sent messages to a tenant
  Future<List<Landlord>> getLandlordsWhoSentMessages(String tenantId) async {
    final chatCollection = _firestore.collection('chats');
    final landlordList = <Landlord>[];

    final chats = await chatCollection
        .where('participants', arrayContains: tenantId)
        .get();

    for (var chat in chats.docs) {
      final participants = List<String>.from(chat['participants']);
      for (var participant in participants) {
        if (participant != tenantId) {
          final userDoc = await _firestore.collection('users').doc(participant).get();
          if (userDoc.exists) {
            final landlord = Landlord(
              name: userDoc['name'],
              email: userDoc['email'],
              chatId: chat.id,
            );
            landlordList.add(landlord);
          }
        }
      }
    }

    return landlordList;
  }

  // Stream of messages for a given chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc.data()))
            .toList());
  }

  // Send a message in a given chat
  Future<void> sendMessage(String chatId, String userId, String message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }
}

// Message class
class Message {
  final String senderId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      message: data['message'],
      timestamp: data['timestamp'],
    );
  }
}
