import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('lease_agreements')
          .where('userId', isEqualTo: user.uid)
          .get();
      
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
      print('Error fetching agreements: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _deleteLeaseAgreement(String leaseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this lease agreement? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('lease_agreements').doc(leaseId).delete();
      setState(() {
        leaseAgreements.removeWhere((lease) => lease['id'] == leaseId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting lease agreement: $e')),
      );
    }
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
                          'Agreements',
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
                        margin: EdgeInsets.all(10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lease['propertyAddress'] ?? 'Unknown Address',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Monthly Rent: \$${lease['monthlyRent'].toStringAsFixed(2)}'),
                              SizedBox(height: 10),
                              if (lease['documents'].isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: lease['documents'].map<Widget>((url) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Tenant Agreement: $url',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.download),
                                            onPressed: () {
                                              _launchURL(url);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _deleteLeaseAgreement(lease['id']),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: leaseAgreements.length,
                  ),
                ),
        ],
      ),
    );
  }
}
