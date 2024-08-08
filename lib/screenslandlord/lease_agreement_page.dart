import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:propertysmart2/data/addAgreement.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaseAgreementsPage extends StatefulWidget {
  @override
  _LeaseAgreementsPageState createState() => _LeaseAgreementsPageState();
}

class _LeaseAgreementsPageState extends State<LeaseAgreementsPage> {
  List<Map<String, dynamic>> leaseAgreements = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaseAgreements();
  }

  Future<void> _fetchLeaseAgreements() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('lease_agreements').get();
      final agreements = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'propertyAddress': data['propertyAddress'] ?? 'Unknown Address',
          'monthlyRent': data['monthlyRent'] ?? 0.0,
          'documents': data['documents'] != null ? List<String>.from(data['documents']) : [],
        };
      }).toList();

      setState(() {
        leaseAgreements = agreements;
      });
    } catch (e) {
      print('Error fetching lease agreements: $e');
    }
  }

  void _addNewLeaseAgreement(Map<String, dynamic> lease) {
    setState(() {
      leaseAgreements.add(lease);
    });
  }

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
                          'Lease Agreements',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  final newLease = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateLeaseAgreementPage()),
                  );
                  if (newLease != null) {
                    _addNewLeaseAgreement(newLease);
                  }
                },
              ),
            ],
          ),
          leaseAgreements.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No agreements here',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lease = leaseAgreements[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(lease['propertyAddress']),
                        
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaseAgreementDetailsPage(lease: lease),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: leaseAgreements.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newLease = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateLeaseAgreementPage()),
          );
          if (newLease != null) {
            _addNewLeaseAgreement(newLease);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF0D47A1),
      ),
    );
  }
}

class LeaseAgreementDetailsPage extends StatelessWidget {
  final Map<String, dynamic> lease;

  LeaseAgreementDetailsPage({required this.lease});

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _editLeaseAgreement(BuildContext context) async {
    final editedLease = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLeaseAgreementPage(leaseAgreement: lease),
      ),
    );
    if (editedLease != null) {
      // Handle updated lease agreement data here
    }
  }

  void _deleteLeaseAgreement(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this lease agreement?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('lease_agreements').doc(lease['id']).delete();
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context, 'deleted'); // Return a result indicating deletion
                } catch (e) {
                  print('Error deleting lease agreement: $e');
                }
              },
              child: Text('Delete'),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    ).then((result) {
      if (result == 'deleted') {
        // Handle the deletion logic here, e.g., remove from the list
      }
    });
  }

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
            Text('Property Address: ${lease['propertyAddress']}', style: TextStyle(fontSize: 18)),
          
            Text('Monthly Rent: \$${lease['monthlyRent'].toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (lease['documents'].isNotEmpty)
              ...lease['documents'].map((url) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text('Document: $url', overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        _launchURL(url);
                      },
                    ),
                  ],
                ),
              )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _editLeaseAgreement(context),
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () => _deleteLeaseAgreement(context),
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
