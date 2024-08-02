import 'package:flutter/material.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:propertysmart2/messages/messagingPage.dart';
import 'package:propertysmart2/messages/chat_service.dart'; // Import the chat service

class LandlordDashboard extends StatelessWidget {
  final String userId;

  LandlordDashboard({required this.userId}); // Add userId to the constructor

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;
                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'PropertySmart',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isCollapsed)
                        Text(
                          'Landlord Dashboard',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildDashboardItem(
                    context, Icons.home, 'Properties', PropertyListingsPage()),
                _buildDashboardItem(
                    context, Icons.people, 'Tenants', TenantManagementPage()),
                _buildDashboardItem(
                    context, Icons.assignment, 'Leases', LeaseAgreementsPage()),
                _buildDashboardItem(context, Icons.build, 'Maintenance',
                    MaintenanceRequestsPage()),
                _buildDashboardItem(context, Icons.message, 'Messages', null), // Change to null for messages
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, IconData icon, String title, Widget? page) {
    return GestureDetector(
      onTap: () async {
        if (title == 'Messages') {
          // Assuming 'tenantId' is the ID of the tenant you want to chat with
          String tenantId = 'tenantId'; // This should be dynamic based on your logic
          String chatId = await _chatService.createOrJoinChat(userId, tenantId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagingPage(
                chatId: chatId,
                senderId: userId,
              ),
            ),
          );
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Color(0xFF0D47A1),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
