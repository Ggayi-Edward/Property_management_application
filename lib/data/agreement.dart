import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:propertysmart2/payment/payment_page.dart';
import 'package:propertysmart2/utilities/signatures.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

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
    // Wrap the entire init process in a try-catch to capture any errors
    try {
      fetchLeaseAgreementDetails(widget.propertyId);
    } catch (e, stackTrace) {
      debugPrint('Error during initState: $e\n$stackTrace');
    }
  }

  Future<void> fetchLeaseAgreementDetails(String propertyId) async {
    try {
      leaseAgreementId = await getLeaseAgreementId(propertyId);
      if (leaseAgreementId != null) {
        documentUrl = await getLeaseAgreementUrl(leaseAgreementId!);
        await fetchUserSignature();
      }
    } catch (e, stackTrace) {
      debugPrint("Failed to fetch lease agreement details: $e\n$stackTrace");
    }
  }

  Future<String?> getLeaseAgreementId(String propertyId) async {
    try {
      final propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();
      return propertyDoc.data()?['leaseAgreementId'];
    } catch (e, stackTrace) {
      debugPrint("Failed to get leaseAgreementId for property ID $propertyId: $e\n$stackTrace");
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
    } catch (e, stackTrace) {
      debugPrint("Failed to get document URL for leaseAgreementId $leaseAgreementId: $e\n$stackTrace");
      return null;
    }
  }

  Future<void> fetchUserSignature() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final signatureUrl = userDoc.data()?['signatureUrl'];
        
        if (signatureUrl != null && signatureUrl.isNotEmpty) {
          final response = await http.head(Uri.parse(signatureUrl));
          if (response.statusCode == 200) {
            setState(() {
              userSignatureUrl = signatureUrl;
            });
          } else {
            debugPrint("Signature image does not exist or is inaccessible.");
            setState(() {
              userSignatureUrl = null;
            });
          }
        } else {
          debugPrint("No signature URL found in the user's document.");
          setState(() {
            userSignatureUrl = null;
          });
        }
      } else {
        debugPrint("User document does not exist for user ${user.uid}");
        setState(() {
          userSignatureUrl = null;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Failed to fetch user signature: $e\n$stackTrace");
      setState(() {
        userSignatureUrl = null;
      });
    }
  }

  void proceedToPayment() {
    try {
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
    } catch (e, stackTrace) {
      debugPrint("Failed to navigate to PaymentPage: $e\n$stackTrace");
    }
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
    try {
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
              'assets/images/doc.jpeg',
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
    } catch (e, stackTrace) {
      debugPrint("Failed to build document section: $e\n$stackTrace");
      return const Text("Error loading document section.");
    }
  }

  Widget _buildSignatureSection() {
    try {
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
            child: CachedNetworkImage(
              imageUrl: userSignatureUrl!,
              width: 330,
              height: 230,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
    } catch (e, stackTrace) {
      debugPrint("Failed to build signature section: $e\n$stackTrace");
      return const Text("Error loading signature section.");
    }
  }

  Widget _buildNoSignatureSection() {
    try {
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
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignaturePad()),
                  ).then((_) {
                    fetchUserSignature(); // Refresh the signature after signing
                  });
                } catch (e, stackTrace) {
                  debugPrint("Failed to navigate to SignaturePad: $e\n$stackTrace");
                }
              },
              child: const Text('Sign Now'),
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint("Failed to build no signature section: $e\n$stackTrace");
      return const Text("Error loading no signature section.");
    }
  }
}
