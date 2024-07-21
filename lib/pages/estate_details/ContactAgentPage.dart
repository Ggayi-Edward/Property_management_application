import 'package:flutter/material.dart';



class ContactAgentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Agent'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/rob.jpg'), // Replace with your image asset
                  ),
                  SizedBox(height: 20),
                  SocialMediaIcon(icon: Icons.facebook, url: 'https://facebook.com'),
                  SocialMediaIcon(icon: Icons.phone, url: 'tel:+256786396139'),

                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: miyajr@gmail.com'),
                  Text('Contact: +256-12345678'),
                  Text('Ratings/Reviews: Submit'),
                  Text('Comment: Approved'),
                  Text('Mobile: ++256-12345678'),
                  Text('WhatsApp: ++256-12345678'),
                  
                  Text('Company: PropertySmart'),
                  Text('Plot: Plot'),
                  Text('Street: Street'),
                  Text('Block/Suite/Room: Block'),
                  Text('Floor: Floor'),
                  Text('AgentID: 782'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Text(
                    'SEND MESSAGE TO AGENT',
                     style: TextStyle(
                      fontSize: 18,
                       fontWeight: FontWeight.bold,
                       color:Colors.blue,
                        ),
                      ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Phone'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Comment'),
                    maxLines: 4,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle form submission
                    },
                    child: Text(
                      'Send Message',
                      style: TextStyle(color:Colors.green),
                      
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialMediaIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  SocialMediaIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        // Handle social media icon tap
      },
    );
  }
}
