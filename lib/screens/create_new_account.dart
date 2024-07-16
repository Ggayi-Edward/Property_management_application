// ignore_for_file: prefer_const_constructors
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:propertysmart2/widgets/widgets.dart';



class CreateNewAccount extends StatelessWidget {
  const CreateNewAccount({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
       children:[
        BackgroundImage(image:'assets/images/background3.jpg'),
        Scaffold(
          backgroundColor: Colors.transparent,
          body:SingleChildScrollView(
            child: Column(
            children:[
              SizedBox(
                height:size.width * 0.1,
              ),
              
              Stack(
                children: [
                  Center(
                    child: ClipOval(
                      child: BackdropFilter(
                        filter:ImageFilter.blur(
                          sigmaX: 6,
                        sigmaY:6 ),
                        child: CircleAvatar(
                          radius: size.width * 0.14,
                          backgroundColor:Colors.grey[500]?.withOpacity(0.5,
                          ),
                          child: Icon(
                            Icons.person,
                            color:Colors.white,
                            size:size.width * 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.08,
                    left:size.width * 0.56,
                    child: Container(
                      height: size.width * 0.12,
                      width: size.width * 0.12,
                      decoration: BoxDecoration(
                        color:Colors.blue,
                        shape:BoxShape.circle,
                        border:Border.all(color:Colors.white,
                        width:2,),
                      ),
                      child:Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height:size.width * 0.1,
              ),
              Column(
                children: [
                  TextInputField(
                     icon: Icons.person,
                     hint:'User',
                     inputType: TextInputType.name,
                     inputAction: TextInputAction.next, 
                  ),
                  TextInputField(
                    icon:Icons.mail,
                    hint:'Email',
                    inputType: TextInputType.emailAddress,
                    inputAction:TextInputAction.next,
                ),
                  PasswordInput(
                     icon:Icons.lock,
                     hint:'Password',
                     inputAction :TextInputAction.next, 
                    inputType: TextInputType.text,

                ),
                PasswordInput(
                  icon:Icons.lock,
                  hint:' Confirm Password',
                  inputAction :TextInputAction.done,
                  inputType: TextInputType.text,
                  ),
                  SizedBox(
                    height:25,
                  ),
                  RoundedButton(
                    buttonName:'SignUp'
                  ),
                  SizedBox(height: 30,
                  ),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap:() {
                          Navigator.pushNamed(context, '/');
                        },
                        child: Text('Login',
                          style:TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                                          ),
                                          ),
                      ),
                  ],),
                  SizedBox(height: 20,)
              ],
          ),
          ],
          ),
    ),
    ),
    ],
          );
        
    
       
    
  }
}