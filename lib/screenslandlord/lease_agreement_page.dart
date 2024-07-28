import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:propertysmart2/export/file_exports.dart';// Ensure the import path is correct

class LeaseAgreementsPage extends StatelessWidget {
  final List<LeaseAgreement> leaseAgreements = [
    LeaseAgreement(
      id: '1',
      tenantName: 'John Doe',
      propertyAddress: '123 Main St, Cityville',
      startDate: DateTime(2023, 1, 1),
      endDate: DateTime(2024, 1, 1),
      monthlyRent: 1200.00,
    ),
    LeaseAgreement(
      id: '2',
      tenantName: 'Jane Smith',
      propertyAddress: '456 Elm St, Townsville',
      startDate: DateTime(2023, 5, 1),
      endDate: DateTime(2024, 5, 1),
      monthlyRent: 1500.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lease Agreements'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: leaseAgreements.length,
        itemBuilder: (context, index) {
          final lease = leaseAgreements[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(lease.tenantName),
              subtitle: Text(lease.propertyAddress),
              trailing: Text(DateFormat('yyyy-MM-dd').format(lease.endDate)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaseAgreementDetailsPage(leaseAgreement: lease),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a page to create a new lease agreement
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class LeaseAgreementDetailsPage extends StatelessWidget {
  final LeaseAgreement leaseAgreement;

  LeaseAgreementDetailsPage({required this.leaseAgreement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lease Agreement Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tenant: ${leaseAgreement.tenantName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Property Address: ${leaseAgreement.propertyAddress}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Start Date: ${DateFormat('yyyy-MM-dd').format(leaseAgreement.startDate)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('End Date: ${DateFormat('yyyy-MM-dd').format(leaseAgreement.endDate)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Monthly Rent: \$${leaseAgreement.monthlyRent.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Edit lease agreement
                  },
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Delete lease agreement
                  },
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
