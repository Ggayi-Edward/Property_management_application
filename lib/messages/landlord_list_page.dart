import 'package:flutter/material.dart';
import 'package:propertysmart2/messages/chat_service.dart';
import 'package:propertysmart2/messages/messagingPage.dart';
import 'package:propertysmart2/model/landlord.dart';

class LandlordListPage extends StatelessWidget {
  final String tenantId;
  final ChatService _chatService = ChatService();

  LandlordListPage({required this.tenantId, required String userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Landlord Messages',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: FutureBuilder<List<Landlord>>(
        future: _chatService.getLandlordsWhoSentMessages(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading landlords'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages from landlords'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final landlord = snapshot.data![index];
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _chatService.getUserDetails(landlord.name), // Assuming landlord.name is userId
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final userData = userSnapshot.data!;
                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(userData['name']),
                      ),
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
            );
          }
        },
      ),
    );
  }
}
