import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:propertysmart2/payment/payment_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementsPage extends StatefulWidget {
  final String propertyId;

  AgreementsPage({required this.propertyId});

  @override
  _AgreementsPageState createState() => _AgreementsPageState();
}

class _AgreementsPageState extends State<AgreementsPage> {
  String? documentUrl;
  String? leaseAgreementId;
  String? userSignatureUrl;
  bool hasReadAndVerified = false; // Checkbox state

  @override
  void initState() {
    super.initState();
    fetchLeaseAgreementDetails(widget.propertyId);
  }

  Future<String?> getLeaseAgreementId(String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();

      leaseAgreementId = propertyDoc.data()?['leaseAgreementId'];
      return leaseAgreementId;
    } catch (e) {
      print("Failed to get leaseAgreementId for property ID $propertyId: $e");
      return null;
    }
  }

  Future<String?> getLeaseAgreementUrl(String leaseAgreementId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> leaseAgreementDoc = await FirebaseFirestore.instance
          .collection('lease_agreements')
          .doc(leaseAgreementId)
          .get();

      String? documentUrl = leaseAgreementDoc.data()?['documents']?.first;
      return documentUrl;
    } catch (e) {
      print("Failed to get document URL for leaseAgreementId $leaseAgreementId: $e");
      return null;
    }
  }

  Future<void> fetchLeaseAgreementDetails(String propertyId) async {
    try {
      String? leaseAgreementId = await getLeaseAgreementId(propertyId);
      if (leaseAgreementId != null) {
        String? documentUrl = await getLeaseAgreementUrl(leaseAgreementId);
        setState(() {
          this.documentUrl = documentUrl;
        });
        await fetchUserSignature(leaseAgreementId);
      }
    } catch (e) {
      print("Failed to fetch lease agreement details: $e");
    }
  }

  Future<void> fetchUserSignature(String leaseAgreementId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> leaseAgreementDoc = await FirebaseFirestore.instance
          .collection('lease_agreements')
          .doc(leaseAgreementId)
          .get();

      String? userId = leaseAgreementDoc.data()?['userId'];
      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        String? signatureUrl = userDoc.data()?['signatureUrl'];
        setState(() {
          userSignatureUrl = signatureUrl;
        });
      }
    } catch (e) {
      print("Failed to fetch user signature: $e");
    }
  }

  void proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          landlordEmail: 'landlord@example.com', // Replace with actual value
          estateId: widget.propertyId, // Pass the estateId (or propertyId)
          amount: '1000', // Replace with actual amount
          landlordMobileMoneyNumber: '1234567890', price: '', // Replace with actual number
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agreements'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (documentUrl != null) ...[
                Text(
                  'Lease Agreement Document',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Image.network(
                    documentUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      launch(documentUrl!);
                    },
                    child: Text(
                      'View Lease Agreement Document',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ] else
                Center(child: CircularProgressIndicator()),

              if (userSignatureUrl != null) ...[
                Text(
                  'User Signature',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Image.network(
                    userSignatureUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                CheckboxListTile(
                  title: Text(
                    'I have read the tenant-landlord agreement and verify my signature',
                  ),
                  value: hasReadAndVerified,
                  onChanged: (bool? value) {
                    setState(() {
                      hasReadAndVerified = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ] else
                Center(child: CircularProgressIndicator()),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: hasReadAndVerified ? proceedToPayment : null, // Enable only if checkbox is checked
                child: Center(
                  child: Text('Proceed to Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
