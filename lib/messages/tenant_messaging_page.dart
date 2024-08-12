// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class TenantMessagingPage extends StatefulWidget {
//   final String landlordId;
//   final String tenantId;
//   final String chatId;
//   final String estateId;

//   const TenantMessagingPage({
//     Key? key,
//     required this.landlordId,
//     required this.tenantId,
//     required this.chatId,
//     required this.estateId, required String senderId,
//   }) : super(key: key);

//   @override
//   _TenantMessagingPageState createState() => _TenantMessagingPageState();
// }

// class _TenantMessagingPageState extends State<TenantMessagingPage> {
//   final TextEditingController _messageController = TextEditingController();
//   String senderName = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchSenderName();
//   }

//   Future<void> _fetchSenderName() async {
//     final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.tenantId).get();
//     setState(() {
//       senderName = userDoc.data()?['name'] ?? 'Unknown';
//     });
//   }

//   Future<void> onSendMessage(String message) async {
//     if (message.trim().isNotEmpty) {
//       await sendMessage(
//         widget.chatId,
//         message,
//         widget.tenantId,
//         senderName,
//       );
//       _messageController.clear();
//     }
//   }

//   Future<void> sendMessage(String chatId, String message, String senderId, String tenantUsername) async {
//     final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

//     await chatRef.collection('messages').add({
//       'messageText': message,
//       'senderId': senderId,
//       'senderName': tenantUsername,
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     await chatRef.update({
//       'lastMessage': message,
//       'tenantUsername': tenantUsername,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Tenant Messaging"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(widget.chatId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//                 var messages = snapshot.data!.docs;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     var message = messages[index].data() as Map<String, dynamic>;
//                     return ListTile(
//                       title: Container(
//                         padding: const EdgeInsets.all(8.0),
//                         decoration: BoxDecoration(
//                           color: message['senderId'] == widget.tenantId ? Colors.grey[200] : Colors.blue[100],
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Text(message['messageText']),
//                       ),
//                       subtitle: Text(
//                         message['senderName'] ?? 'Unknown',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       trailing: Text(
//                         DateFormat('HH:mm').format(message['timestamp']?.toDate() ?? DateTime.now()),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your message',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     onSendMessage(_messageController.text);
//                   },
//                   child: const Text('Send'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     backgroundColor: Colors.blueAccent,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
