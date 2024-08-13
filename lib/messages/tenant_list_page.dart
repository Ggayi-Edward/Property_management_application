import 'package:flutter/material.dart';
import 'landlord_messaging_page.dart';

class TenantListPage extends StatelessWidget {
  final String landlordId;

  const TenantListPage({Key? key, required this.landlordId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hardcoded demo tenant data
    final List<Map<String, dynamic>> tenants = [
      {
        'tenantId': 'tenant1',
        'tenantUsername': 'Tenant 1',
        'lastMessage': 'What time is the earliest I can move in?',
      },
      {
        'tenantId': 'tenant2',
        'tenantUsername': 'Tenant 2',
        'lastMessage': 'I’m interested in the property.',
      },
    ];

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: tenants.length,
        itemBuilder: (context, index) {
          final tenant = tenants[index];
          final tenantId = tenant['tenantId'];
          final lastMessage = tenant['lastMessage'];
          final tenantUsername = tenant['tenantUsername'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LandlordMessagingPage(
                    landlordId: landlordId,
                    tenantId: tenantId,
                    chatId: 'demoChatId_$tenantId', // Hardcoded chat ID
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenantUsername,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
