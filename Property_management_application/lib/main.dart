import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 146, 133, 133), //  gray background
        body: SafeArea( // Padding on devices with a notch or status bar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "How are you, Jake?",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://th.bing.com/th/id/R.5c87bf3c1fc4153a6ef714f635708d3a?rik=Q4sXnsAb2f/BSg&pid=ImgRaw&r=qs'),
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Discover",
                  style: TextStyle(
                    color: Color(0xFF007bff), // Blue accent color
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Suitable Home",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          // Add a prefix icon (customizable)
                          prefixIcon: const Icon(Icons.search),

                          // Set a hint text with optional styling
                          hintText: 'Find a good home',
                          hintStyle: const TextStyle(fontSize: 16.0, color: Colors.grey),

                          // Control the background color and style
                          fillColor: const Color.fromARGB(255, 214, 209, 209),
                          filled: true,

                          // Customize the border
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft:Radius.circular(30.0),
                              bottomLeft:Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0)
                            ),
                            borderSide: BorderSide(color: Color.fromARGB(255, 102, 98, 98)),
                            
                          ),

                          // Add a focused border (optional)
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.blue, width: 2.0), // Example of blue focused border
                          ),

                          // Control content padding (optional)
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width:5.0, 
                    ),
                    Stack(
                      children:<Widget> [
                        const Icon(Icons.notifications_none),
                        Positioned(
                          top: 1,
                          right: 1,
                          child:Container(
                            padding:const EdgeInsets.all(2.0),
                            decoration: const BoxDecoration(
                              color:Colors.orange,
                              shape: BoxShape.circle,
                              ),
                            child: const Text("2",style:TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            )),
                            ),
                        )
                        ],
                      )
                    ],
              
                  ),
                ]

              ),
            ),
          )
        )
      );
    }
  }