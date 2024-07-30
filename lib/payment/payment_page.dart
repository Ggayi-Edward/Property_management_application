import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'confirmation_page.dart';

class PaymentPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tenantMobileNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final String landlordEmail; // Use landlord's email to map to subaccount ID

  PaymentPage({required this.landlordEmail, required String landlordMobileMoneyNumber});

  String _selectedNetwork = "VODAFONE"; // Default network

  // Example data structure to store landlord information
  final Map<String, String> landlordSubaccounts = {
    'landlord1@example.com': 'RS_FF6A27F50B9A8A6711B582A85A344A79',
    'landlord2@example.com': 'RS_1234567890ABCDEFGHIJKL',
    // Add more landlords as needed
  };

  String? getSubaccountId(String landlordEmail) {
    return landlordSubaccounts[landlordEmail];
  }

  void _makePayment(BuildContext context) async {
    final subaccountId = getSubaccountId(landlordEmail);
    if (subaccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid landlord information')),
      );
      return;
    }

    final Customer customer = Customer(
      name: _nameController.text,
      phoneNumber: _tenantMobileNumberController.text,
      email: _emailController.text,
    );

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: "FLWPUBK_TEST",
      currency: "UGX",
      amount: _amountController.text,
      customer: customer,
      paymentOptions: "mobilemoneyuganda",
      customization: Customization(title: "House Rental Payment"),
      isTestMode: true,
      txRef: DateTime.now().millisecondsSinceEpoch.toString(),
      redirectUrl: "propertysmart://payment-confirmation",
      meta: {
        "subaccount_id": subaccountId,
      },
    );

    try {
      final ChargeResponse response = await flutterwave.charge();
      if (response != null) {
        print(response.toJson());
        if (response.status == "successful") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConfirmationPage()),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/payment_background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enter Payment Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter your name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _tenantMobileNumberController,
                          decoration: InputDecoration(
                            labelText: 'Tenant Mobile Number',
                            hintText: 'Enter your mobile number',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter amount to pay',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the amount';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedNetwork,
                          items: [
                            const DropdownMenuItem(
                              value: "VODAFONE",
                              child: Text("Vodafone"),
                            ),
                            DropdownMenuItem(
                              value: "MTN",
                              child: Text("MTN"),
                            ),
                            DropdownMenuItem(
                              value: "AIRTEL",
                              child: Text("Airtel"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _selectedNetwork = value;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Network',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a network';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _makePayment(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Proceed to Confirmation',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _makePayment(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Test Payment',
                            style: TextStyle(fontSize: 16),
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
      ),
    );
  }
}
