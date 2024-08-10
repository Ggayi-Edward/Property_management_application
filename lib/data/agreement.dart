import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    fetchLeaseAgreementDetails(widget.propertyId);
  }

  // Get the leaseAgreementId from the properties collection
  Future<String?> getLeaseAgreementId(String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();

      leaseAgreementId = propertyDoc.data()?['leaseAgreementId'];
      print("Property ID: $propertyId");
      print("Lease Agreement ID: $leaseAgreementId");

      return leaseAgreementId;
    } catch (e) {
      print("Failed to get leaseAgreementId for property ID $propertyId: $e");
      return null;
    }
  }

  // Use the leaseAgreementId to get the URL from the lease_agreements collection
  Future<String?> getLeaseAgreementUrl(String leaseAgreementId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> leaseAgreementDoc = await FirebaseFirestore.instance
          .collection('lease_agreements')
          .doc(leaseAgreementId)
          .get();

      print("Lease Agreement Document Data: ${leaseAgreementDoc.data()}");

      String? documentUrl = leaseAgreementDoc.data()?['documents']?.first;
      print("Lease Agreement ID: $leaseAgreementId");
      print("Document URL: $documentUrl");

      return documentUrl;
    } catch (e) {
      print("Failed to get document URL for leaseAgreementId $leaseAgreementId: $e");
      return null;
    }
  }

  // Fetch the lease agreement URL and user signature using the propertyId
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

  // Fetch the user signature URL from the Users collection
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
        print("Signature URL from Firestore: $signatureUrl");

        setState(() {
          userSignatureUrl = signatureUrl;
        });
      } else {
        print("No userId found for leaseAgreementId $leaseAgreementId");
      }
    } catch (e) {
      print("Failed to fetch user signature: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agreements'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (documentUrl != null)
              Column(
                children: [
                  // Display the document image (assuming it's a PDF thumbnail or similar)
                  Image.network(
                    documentUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text('Lease Agreement Document'),
                ],
              )
            else
              CircularProgressIndicator(),
            SizedBox(height: 20),
            if (userSignatureUrl != null)
              Column(
                children: [
                  // Display the user's signature image
                  Image.network(
                    userSignatureUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text('User Signature'),
                ],
              )
            else
              CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (documentUrl != null) {
                  // Open the document URL in the browser
                  launch(documentUrl!);
                }
              },
              child: Text('View Lease Agreement Document'),
            ),
          ],
        ),
      ),
    );
  }
}
