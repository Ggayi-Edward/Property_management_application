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
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: FutureBuilder<List<Tenant>>(
        future: _chatService.getTenantsWhoSentMessages(landlordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tenants'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No messages from tenants'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final tenant = snapshot.data![index];
                return ListTile(
                  title: Text(tenant.name),
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
          }
        },
      ),
    );
  }
}
