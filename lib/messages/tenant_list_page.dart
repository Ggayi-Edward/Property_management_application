import 'package:flutter/material.dart';
import 'package:propertysmart2/messages/chat_service.dart';
import 'package:propertysmart2/messages/messagingPage.dart';
import 'package:propertysmart2/model/tenant.dart';

class TenantListPage extends StatelessWidget {
  final String landlordId;
  final ChatService _chatService = ChatService();

  TenantListPage({required this.landlordId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tenant Messages',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: FutureBuilder<List<Tenant>>(
        future: _chatService.getTenantsWhoSentMessages(landlordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading tenants'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages from tenants'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final tenant = snapshot.data![index];
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _chatService.getUserDetails(tenant.name), // Assuming tenant.name is userId
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
                      subtitle: Text(tenant.email),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagingPage(
                              chatId: tenant.chatId,
                              senderId: landlordId,
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
