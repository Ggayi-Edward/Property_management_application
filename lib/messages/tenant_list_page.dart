import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landlord_messaging_page.dart';

class TenantListPage extends StatelessWidget {
  final String landlordId;

  const TenantListPage({Key? key, required this.landlordId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenants List"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: landlordId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final participants = List<String>.from(chatData['participants']);
              final tenantId = participants.firstWhere((id) => id != landlordId, orElse: () => 'Unknown');
              final lastMessage = chatData['lastMessage'] ?? 'No message';
              final tenantUsername = chatData['tenantUsername'] ?? 'Unknown Tenant';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandlordMessagingPage(
                        landlordId: landlordId,
                        tenantId: tenantId,
                        chatId: chats[index].id, senderId: '', estateId: '',
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenantUsername,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lastMessage,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
