// messaging_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'message_service.dart';
import 'message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingPage extends StatefulWidget {
  final String chatId;
  final String senderId;

  MessagingPage({required this.chatId, required this.senderId});

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  String senderName = '';

  @override
  void initState() {
    super.initState();
    _fetchSenderName();
  }

  Future<void> _fetchSenderName() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.senderId).get();
    setState(() {
      senderName = userDoc.data()?['name'] ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(message.senderName), // Display the sender's name
                      ),
                      subtitle: Text(message.messageText),
                      trailing: Text(DateFormat('HH:mm').format(message.timestamp.toDate())),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await _messageService.sendMessage(
                        widget.chatId,
                        widget.senderId,
                        senderName, // Pass the sender's name
                        _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                  child: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
