// messaging_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'message_service.dart';
import 'message.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message.sender),
                      subtitle: Text(message.text),
                      trailing: Text(DateFormat('HH:mm').format(message.timestamp)),
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
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await _messageService.sendMessage(
                        widget.chatId,
                        widget.senderId,
                        _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                  child: Text('Send'),
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
