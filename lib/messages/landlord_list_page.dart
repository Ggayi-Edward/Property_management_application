// landlord_list_page.dart
import 'package:flutter/material.dart';
import 'package:propertysmart2/messages/chat_service.dart';
import 'package:propertysmart2/model/landlord.dart'; // Import model for landlord
import 'package:propertysmart2/messages/messagingPage.dart'; // Import MessagingPage

class LandlordListPage extends StatelessWidget {
  final String tenantId;
  final ChatService _chatService = ChatService();

  LandlordListPage({required this.tenantId, required String userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Messages',
        style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: FutureBuilder<List<Landlord>>(
        future: _chatService.getLandlordsWhoSentMessages(tenantId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final landlords = snapshot.data!;

          if (landlords.isEmpty) {
            return Center(child: Text('No messages yet'));
          }

          return ListView.builder(
            itemCount: landlords.length,
            itemBuilder: (context, index) {
              final landlord = landlords[index];

              return ListTile(
                title: Text(landlord.name),
                subtitle: Text(landlord.email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingPage(
                        chatId: landlord.chatId,
                        senderId: tenantId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
