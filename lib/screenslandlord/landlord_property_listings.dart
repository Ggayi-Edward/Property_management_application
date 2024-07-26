import 'package:flutter/material.dart';
import 'package:propertysmart2/export/file_exports.dart';

class PropertyListingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Listings'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPropertyPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('List of properties will be displayed here.'),
      ),
    );
  }
}
