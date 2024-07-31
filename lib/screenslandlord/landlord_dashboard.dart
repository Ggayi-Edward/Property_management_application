import 'package:flutter/material.dart';
import 'package:propertysmart2/export/file_exports.dart';

class LandlordDashboard extends StatelessWidget {
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
                _buildDashboardItem(
                    context, Icons.message, 'Messages', MessagingPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
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
              color: Colors.blueAccent,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
