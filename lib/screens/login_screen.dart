// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:propertysmart2/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  final Function() onNextTap;
  const LoginScreen({super.key,required this.onNextTap});

   @override
  Widget build(BuildContext context) {
    
    return Stack(
      children: [
        BackgroundImage(
          image:'assets/images/background1.jpeg',
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body:Column(
            children: [
              Flexible(
                child: Center(
                  child: Text('Property Smart',
                      style: TextStyle(
                        color: Color(0xFF304FFE),
                        fontSize: 55,
                        fontWeight: FontWeight.bold),
                       
                  
                   ),
                   
                    
              ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              TextInputField(
                icon: Icons.mail,
                hint: 'Email',
                inputType:TextInputType.emailAddress,
                inputAction: TextInputAction.next,
              ),
            PasswordInput(
               icon: Icons.lock,
                hint: 'Password',
                inputType:TextInputType.emailAddress,
                inputAction: TextInputAction.next,
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context,
              'ForgotPassword'),
              child: Text('Forgot Password',
              style: TextStyle(
            color: Colors.white,  // Text color
            fontSize: 16,
        ),
        ),
            ),
            
          
             //Text('Forgot Password',
               //style: TextStyle(
                  //color: Colors.white,
                  //fontSize: 15,
                  //fontWeight: FontWeight.bold,),
         // ),
              SizedBox(height: 25,
          ),

             RoundedButton(
            buttonName: 'Login',
          ),
           SizedBox(height: 25,
          ),
          
          ],
          ), 
           GestureDetector(
            onTap: onNextTap(),
             child: Container(
              decoration:
               BoxDecoration(border:
                  Border(bottom:BorderSide(width:1,
                  color: Colors.white),
                  ),
              ),
              
              child:Text('Create New Account',
              style:TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,), 
                       ),
                       ),
           ),
           SizedBox(
            height:20,
          )
          ],
           ),
        ),
            ],

          
        );
      
  }
}

