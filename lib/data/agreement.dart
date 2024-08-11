import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:propertysmart2/payment/payment_page.dart';
import 'package:propertysmart2/utilities/signatures.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementsPage extends StatefulWidget {
  final String propertyId;

  const AgreementsPage({Key? key, required this.propertyId}) : super(key: key);

  @override
  _AgreementsPageState createState() => _AgreementsPageState();
}

class _AgreementsPageState extends State<AgreementsPage> {
  String? documentUrl;
  String? leaseAgreementId;
  String? userSignatureUrl;
  bool hasReadAndVerified = false;

  @override
  void initState() {
    super.initState();
    fetchLeaseAgreementDetails(widget.propertyId);
  }

  Future<void> fetchLeaseAgreementDetails(String propertyId) async {
    try {
      leaseAgreementId = await getLeaseAgreementId(propertyId);
      if (leaseAgreementId != null) {
        documentUrl = await getLeaseAgreementUrl(leaseAgreementId!);
        await fetchUserSignature();
      }
    } catch (e) {
      print("Failed to fetch lease agreement details: $e");
    }
  }

  Future<String?> getLeaseAgreementId(String propertyId) async {
    try {
      final propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();
      return propertyDoc.data()?['leaseAgreementId'];
    } catch (e) {
      print("Failed to get leaseAgreementId for property ID $propertyId: $e");
      return null;
    }
  }

  Future<String?> getLeaseAgreementUrl(String leaseAgreementId) async {
    try {
      final leaseAgreementDoc = await FirebaseFirestore.instance
          .collection('lease_agreements')
          .doc(leaseAgreementId)
          .get();
      return leaseAgreementDoc.data()?['documents']?.first;
    } catch (e) {
      print("Failed to get document URL for leaseAgreementId $leaseAgreementId: $e");
      return null;
    }
  }

  Future<void> fetchUserSignature() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';
      final userId = user.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userSignatureUrl = userDoc.data()?['signatureUrl'];
        });
      } else {
        setState(() {
          userSignatureUrl = null;
        });
      }
    } catch (e) {
      print("Failed to fetch user signature: $e");
      setState(() {
        userSignatureUrl = null;
      });
    }
  }

  void proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          landlordEmail: 'landlord@example.com', // Replace with actual value
          estateId: widget.propertyId,
          amount: '1000', // Replace with actual amount
          landlordMobileMoneyNumber: '1234567890', // Replace with actual number
          price: '', // Replace with actual price
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agreement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (documentUrl != null) ...[
                _buildDocumentSection(),
              ] else
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 20),

              if (userSignatureUrl != null) ...[
                _buildSignatureSection(),
              ] else ...[
                _buildNoSignatureSection(),
              ],

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: hasReadAndVerified ? proceedToPayment : null,
                  child: const Text('Proceed to Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lease Agreement Document:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Image.asset(
            'assets/images/doc.jpeg', // Replace with the actual path to your asset
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: () => launch(documentUrl!),
            child: Text(
              'View Agreement Document',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Signature:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Image.network(
            userSignatureUrl!,
            width: 330,
            height: 230,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          title: const Text(
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
      ],
    );
  }

  Widget _buildNoSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'No Signature Found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignaturePad()),
              ).then((_) {
                fetchUserSignature(); // Refresh the signature after signing
              });
            },
            child: const Text('Sign Now'),
          ),
        ),
      ],
    );
  }
}
