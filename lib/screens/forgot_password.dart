// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:propertysmart2/widgets/widgets.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(height: size.height * 0.1,
        ),
        BackgroundImage(image: 'assets/images/background2.jpg'),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar( 
          backgroundColor:Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon:Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ) 
            ),
            title: Text( 
              'Forgot Password',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,),
            ),
            centerTitle: true,
            ),
            body: Column(children: [
              Container(
                 width: size.width * 0.8,
                 child: Text('Enter your email we will send the instruction te reet your password',
                 style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,),
                  ),
              ),

              TextInputField(icon:Icons.mail, 
               hint: 'Email', 
              inputType: TextInputType.emailAddress, 
              inputAction: TextInputAction.done,
              ),
              SizedBox(
                height: 20,
              ),
              RoundedButton(buttonName: 'Send')
            ],
            ),
        ),
      ],
    );
  }
}