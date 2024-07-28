import 'package:flutter/material.dart';

class TenantManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tenant Management'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text('List of tenants will be displayed here.'),
      ),
    );
  }
}
