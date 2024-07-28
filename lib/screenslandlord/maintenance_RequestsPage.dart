import 'package:flutter/material.dart';
import 'package:propertysmart2/export/file_exports.dart';
import 'package:intl/intl.dart';

class MaintenanceRequestsPage extends StatefulWidget {
  @override
  _MaintenanceRequestsPageState createState() => _MaintenanceRequestsPageState();
}

class _MaintenanceRequestsPageState extends State<MaintenanceRequestsPage> {
  final List<MaintenanceRequest> requests = [
    MaintenanceRequest(title: 'Leaky Faucet', description: 'The faucet in the kitchen is leaking.', date: DateTime.now().subtract(Duration(days: 1)), status: 'Pending'),
    MaintenanceRequest(title: 'Broken Window', description: 'The window in the living room is broken.', date: DateTime.now().subtract(Duration(days: 2)), status: 'In Progress'),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _addRequest() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      setState(() {
        requests.add(MaintenanceRequest(
          title: _titleController.text,
          description: _descriptionController.text,
          date: DateTime.now(),
          status: 'Pending',
        ));
        _titleController.clear();
        _descriptionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance Requests'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return ListTile(
                  title: Text(request.title),
                  subtitle: Text(request.description),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(request.status, style: TextStyle(color: request.status == 'Pending' ? Colors.red : Colors.green)),
                      Text(DateFormat('MM/dd/yyyy').format(request.date)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addRequest,
                  child: Text('Submit Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
