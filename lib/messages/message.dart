import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName; // Add senderName to the Message model
  final String messageText;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.timestamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      senderName: data['senderName'], // Add this line
      messageText: data['messageText'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName, // Add this line
      'messageText': messageText,
      'timestamp': timestamp,
    };
  }
}
