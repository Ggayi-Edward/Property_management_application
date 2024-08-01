// message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sender;
  final String text;
  final DateTime timestamp;

  Message({required this.sender, required this.text, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderId': sender,
      'messageText': text,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['senderId'] ?? '',
      text: map['messageText'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
