import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TenantMessagingPage extends StatefulWidget {
  final String landlordId;
  final String tenantId;
  final String chatId;
  final String estateId;

  const TenantMessagingPage({
    Key? key,
    required this.landlordId,
    required this.tenantId,
    required this.chatId,
    required this.estateId,
  }) : super(key: key);

  @override
  _TenantMessagingPageState createState() => _TenantMessagingPageState();
}

class _TenantMessagingPageState extends State<TenantMessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  String senderName = 'Tenant'; // Hardcoded sender name for the demo

  // Hardcoded demo messages
  final List<Map<String, dynamic>> _demoMessages = [
    {
      'messageText': 'Hello, I have a question about the property.',
      'senderId': 'tenant1',
      'senderName': 'Tenant',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
    },
    {
      'messageText': 'Sure, I’m happy to help!',
      'senderId': 'landlord1',
      'senderName': 'Landlord',
      'timestamp': DateTime.now().subtract(Duration(minutes: 4)),
    },
    {
      'messageText': 'What time is the earliest I can move in?',
      'senderId': 'tenant1',
      'senderName': 'Tenant',
      'timestamp': DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      'messageText': 'You can move in as early as 9 AM.',
      'senderId': 'landlord1',
      'senderName': 'Landlord',
      'timestamp': DateTime.now().subtract(Duration(minutes: 2)),
    },
  ];

  Future<void> onSendMessage(String message) async {
    if (message.trim().isNotEmpty) {
      setState(() {
        // Adding the new message to the list
        _demoMessages.add({
          'messageText': message,
          'senderId': widget.tenantId,
          'senderName': senderName,
          'timestamp': DateTime.now(),
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenant Messaging"),
        backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blueAccent,
      ),
      backgroundColor: isDarkMode ? Colors.blueGrey[800] : Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _demoMessages.length,
              itemBuilder: (context, index) {
                // Reversing the index to show the latest message at the bottom
                var message = _demoMessages[_demoMessages.length - 1 - index];
                return ListTile(
                  title: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: message['senderId'] == widget.tenantId
                          ? (isDarkMode ? Colors.blueGrey[700] : Colors.blue[100]) // Tenant message color
                          : (isDarkMode ? Colors.grey[700] : Colors.grey[300]), // Landlord message color
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      message['messageText'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    message['senderName'] ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  trailing: Text(
                    DateFormat('HH:mm').format(message['timestamp']),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
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
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      fillColor: isDarkMode ? Colors.blueGrey[700] : Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onSendMessage(_messageController.text);
                  },
                  child: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: isDarkMode ? Colors.blueGrey[700] : Colors.blueAccent,
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
