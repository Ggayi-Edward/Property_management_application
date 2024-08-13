import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutterwave_standard/flutterwave.dart';
import 'confirmation_page.dart';

class PaymentPage extends StatefulWidget {
  final String landlordEmail;
  final String landlordMobileMoneyNumber;
  final String price;
  final String estateId; // Estate ID
  final String amount;

  PaymentPage({
    required this.landlordEmail,
    required this.landlordMobileMoneyNumber,
    required this.price,
    required this.estateId,
    required this.amount,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tenantMobileNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _landlordMobileNumberController = TextEditingController(); // Added controller

  @override
  void initState() {
    super.initState();
    if (widget.estateId.isNotEmpty) {
      _fetchPropertyDetails(); // Fetch the details from Firestore
    } else {
      print('Error: estateId is empty or null');
    }
  }

  void _fetchPropertyDetails() async {
    try {
      print('Fetching details for estateId: ${widget.estateId}');
      
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.estateId)
          .get();

      if (snapshot.exists) {
        print('Document data: ${snapshot.data()}'); // Print the entire document data

        var data = snapshot.data() as Map<String, dynamic>;
        _amountController.text = data['price'].toString();
        _landlordMobileNumberController.text = data['ownerPhone']; // Pre-fill landlord mobile number

        // Print to confirm values
        print('Fetched price: ${_amountController.text}');
        print('Fetched ownerPhone: ${_landlordMobileNumberController.text}');
        
        setState(() {});
      } else {
        print('No such document!');
      }
    } catch (e) {
      print('Error fetching property details: $e');
    }
  }

  void _makePayment(BuildContext context) async {
    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: "FLWPUBK_TEST-585048afbc3e1f37a181cd178c26df20-X", // Replace with your actual public key
      currency: "UGX",
      amount: _amountController.text,
      customer: Customer(
        name: _nameController.text,
        phoneNumber: _tenantMobileNumberController.text,
        email: _emailController.text,
      ),
      paymentOptions: "mobilemoneyuganda",
      customization: Customization(title: "House Rental Payment"),
      isTestMode: true,
      txRef: DateTime.now().millisecondsSinceEpoch.toString(),
      redirectUrl: "propertysmart://payment-confirmation",
      meta: {
        "estate_id": widget.estateId,
        "landlord_mobile_number": _landlordMobileNumberController.text,
      },
    );

    try {
      final ChargeResponse response = await flutterwave.charge();
      if (response != null) {
        print(response.toJson());
        if (response.status == "successful") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationPage(
                transactionId: response.transactionId ?? "N/A",
                amount: _amountController.text, landlordPhoneNumber: '',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: ${response.status ?? 'Unknown error'}')),
          );
        }
      } else {
        print("Transaction failed");
      }
    } catch (error) {
      print("An error occurred: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
            
      backgroundColor: isDarkMode ? Colors.blueGrey[800] : Colors.white,
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isCollapsed)
                        Text(
                          'Payment',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blueGrey[900] : Colors.blueAccent,
                    ),
                  ),
                );
              },
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Card(
                    color: isDarkMode ? Colors.blueGrey[700] : Colors.blue[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enter Payment Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _nameController,
                            label: 'Name',
                            hint: 'Enter your name',
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _tenantMobileNumberController,
                            label: 'Mobile Number',
                            hint: 'Enter your mobile number',
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              return null;
                            },
                            enabled: true,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _amountController,
                            label: 'Amount',
                            hint: 'Enter the amount',
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _landlordMobileNumberController,
                            label: 'Landlord Mobile Number',
                            hint: 'Landlord mobile number',
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter landlord mobile number';
                              }
                              return null;
                            },
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _makePayment(context);
                              }
                            },
                            child: Text('Make Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? Colors.blueGrey[700] : Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDarkMode,
    required String? Function(String?) validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white30 : Colors.blue,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white30 : Colors.blue,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.blue,
            width: 2.0,
          ),
        ),
      ),
      validator: validator,
      enabled: enabled,
    );
  }
}
