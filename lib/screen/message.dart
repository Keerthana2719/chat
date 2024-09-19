// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' as foundation;
//
// import '../class/neum.dart';
//
// class Message extends StatefulWidget {
//   final String currentUsername; // Sender's username (logged-in user)
//   final String selectedUsername; // Receiver's username (selected user)
//
//   const Message({
//     super.key,
//     required this.currentUsername,
//     required this.selectedUsername,
//   });
//
//   @override
//   _MessageState createState() => _MessageState();
// }
//
// class _MessageState extends State<Message> {
//   final List<Map<String, dynamic>> menuItems = [
//     {'value': 'Clear Chat', 'icon': Icons.clear_all, 'text': 'Clear'},
//     {'value': 'Block', 'icon': Icons.block, 'text': 'Black'},
//     {'value': 'Favorite', 'icon': Icons.favorite, 'text': 'Favorite'},
//   ];
//
//   final TextEditingController _controller = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _textFieldFocusNode = FocusNode();
//   bool _emojiShowing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _textFieldFocusNode.addListener(() {
//       if (_textFieldFocusNode.hasFocus && _emojiShowing) {
//         setState(() {
//           _emojiShowing = false; // Hide emoji picker when TextField gains focus
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     _textFieldFocusNode.dispose();
//     super.dispose();
//   }
//
//   Future<void> _clearChat() async {
//     try {
//       final messagesSentByCurrentUser = await _firestore
//           .collection('messages')
//           .where('sender', isEqualTo: widget.currentUsername)
//           .where('receiver', isEqualTo: widget.selectedUsername)
//           .get();
//
//       final messagesSentByOtherUser = await _firestore
//           .collection('messages')
//           .where('sender', isEqualTo: widget.selectedUsername)
//           .where('receiver', isEqualTo: widget.currentUsername)
//           .get();
//
//       final allMessages =
//           messagesSentByCurrentUser.docs + messagesSentByOtherUser.docs;
//
//       for (var doc in allMessages) {
//         await doc.reference.delete();
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Chat cleared successfully')),
//       );
//     } catch (e) {
//       print('Error clearing chat: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error clearing chat')),
//       );
//     }
//   }
//
//   Future<void> _sendMessage() async {
//     if (_controller.text.isNotEmpty) {
//       await _firestore.collection('messages').add({
//         'sender': widget.currentUsername,
//         'receiver': widget.selectedUsername,
//         'message': _controller.text,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       _controller.clear();
//       _scrollToBottom();
//     }
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     }
//   }
//
//   void _toggleEmojiKeyboard() {
//     setState(() {
//       _emojiShowing = !_emojiShowing;
//     });
//
//     if (_emojiShowing) {
//       FocusScope.of(context).unfocus();
//     } else {
//       FocusScope.of(context).requestFocus(FocusNode());
//     }
//   }
//
//   Future<void> _deleteMessage(String messageId) async {
//     try {
//       final messageRef = _firestore.collection('messages').doc(messageId);
//
//       // Delete message
//       await messageRef.delete();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Message deleted')),
//       );
//     } catch (e) {
//       print('Error deleting message: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error deleting message')),
//       );
//     }
//   }
//
//   void _showOptionsDialog(String messageId) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.white30,
//           shadowColor: Colors.black,
//           shape: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.delete_outline, color: Colors.white70),
//                 title: const Text(
//                   'Delete',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   await _deleteMessage(messageId);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.favorite_outline, color: Colors.white70),
//                 title: const Text(
//                   'Favorite',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Handle favorite action here
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color(0xFFE7ECEF),
//         body: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 13, left: 10, right: 5),
//               child: Row(
//                 children: [
//                   NeumorphicButton(
//                     icon: Icons.arrow_back_ios,
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   SizedBox(width: 20),
//                   Text(
//                     widget.selectedUsername,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 25,
//                     ),
//                   ),
//                   Spacer(),
//                   NeumorphicButton(
//                     icon: Icons.call,
//                     onPressed: () {
//                       // Your onPressed logic here
//                     },
//                   ),
//                   SizedBox(width: 10),
//                   NeumorphicButton(
//                     icon: Icons.video_call,
//                     onPressed: () {
//                       // Your onPressed logic here
//                     },
//                   ),
//                   SizedBox(width: 10),
//                   Theme(
//                     data: Theme.of(context).copyWith(
//                       popupMenuTheme: PopupMenuThemeData(
//                         color: Colors.white70,
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                     child: PopupMenuButton<String>(
//                       onSelected: (value) async {
//                         if (value == 'Clear Chat') {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               shadowColor: Colors.black,
//                               backgroundColor: Colors.white70,
//                               shape: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
//                               title: Center(
//                                 child:  Text(
//                                   'Are You Sure ?',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18,
//                                       color: Colors.black),
//                                 ),
//                               ),
//                               content:  Text(
//                                   '    Do you want to clear this chat ?',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                       color: Colors.black)),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child:  Text('Cancel',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 16,
//                                           color: Colors.indigo)
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: () async {
//                                     await _clearChat();
//                                     Navigator.pop(context);
//                                   },
//                                   child: const Text('OK', style: TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 16,
//                                       color: Colors.indigo)),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                       },
//                       itemBuilder: (context) => menuItems.map((item) {
//                         return PopupMenuItem<String>(
//                           value: item['value'],
//                           child: ListTile(
//                             leading: Icon(item['icon'], color: Colors.black),
//                             title: Text(item['text']),
//                           ),
//                         );
//                       }).toList(),
//                       icon: const Icon(
//                         Icons.more_vert,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10, right: 10),
//                 child: Container(
//                   height: 580,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(25),
//                       topRight: Radius.circular(25),
//                     ),
//                     color: Color(0xFFE7ECEF),
//                     boxShadow: [
//                       BoxShadow(
//                         offset: Offset(-8, -8),
//                         color: Colors.white,
//                         blurRadius: 4.5,
//                       ),
//                       BoxShadow(
//                         offset: Offset(5, 5),
//                         color: Colors.black38,
//                         blurRadius: 1.5,
//                       ),
//                     ],
//                   ),
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _firestore
//                         .collection('messages')
//                         .orderBy('timestamp', descending: false)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(child: Text('No messages yet'));
//                       }
//
//                       final messages = snapshot.data!.docs.where((message) {
//                         final sender = message['sender'];
//                         final receiver = message['receiver'];
//
//                         return (sender == widget.currentUsername &&
//                             receiver == widget.selectedUsername) ||
//                             (sender == widget.selectedUsername &&
//                                 receiver == widget.currentUsername);
//                       }).toList();
//
//                       return ListView.builder(
//                         controller: _scrollController,
//                         itemCount: messages.length,
//                         itemBuilder: (context, index) {
//                           final message = messages[index];
//                           final isCurrentUser =
//                               message['sender'] == widget.currentUsername;
//
//                           return GestureDetector(
//                             onLongPress: () {
//                               // Show the options dialog (delete and favorite)
//                               _showOptionsDialog(message.id);
//                             },
//                             child: Align(
//                               alignment: isCurrentUser
//                                   ? Alignment.centerRight
//                                   : Alignment.centerLeft,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 15, horizontal: 20),
//                                 margin: EdgeInsets.symmetric(
//                                     vertical: 8, horizontal: 10),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[300],
//                                   borderRadius: BorderRadius.circular(20),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.white,
//                                       offset: Offset(-4, -4),
//                                       blurRadius: 10,
//                                     ),
//                                     BoxShadow(
//                                       color: Colors.grey[500]!,
//                                       offset: Offset(3, 3),
//                                       blurRadius: 5,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Text(
//                                   message['message'],
//                                   style: TextStyle(
//                                     color: isCurrentUser
//                                         ? Colors.black
//                                         : Colors.black,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 2,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 15, right: 15),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             focusNode: _textFieldFocusNode,
//                             controller: _controller,
//                             decoration: InputDecoration(
//                               hintText: 'Type your message...',
//                               prefixIcon: IconButton(
//                                 icon: const Icon(Icons.mic),
//                                 onPressed: () {},
//                               ),
//                               suffixIcon: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.camera_alt),
//                                     onPressed: () {},
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.emoji_emotions),
//                                     onPressed: _toggleEmojiKeyboard,
//                                   ),
//                                 ],
//                               ),
//                               border: const OutlineInputBorder(
//                                 borderRadius:
//                                 BorderRadius.all(Radius.circular(25)),
//                                 borderSide: BorderSide(color: Colors.black),
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius:
//                                 BorderRadius.all(Radius.circular(25)),
//                                 borderSide:
//                                 BorderSide(color: Colors.black, width: 2.0),
//                               ),
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.send),
//                           onPressed: _sendMessage,
//                         ),
//                       ],
//                     ),
//                     Offstage(
//                       offstage: !_emojiShowing,
//                       child: SizedBox(
//                         height: 250,
//                         child: EmojiPicker(
//                           onEmojiSelected: (category, emoji) {
//                             _controller.text += emoji.emoji;
//                           },
//                           config: Config(
//                             emojiSizeMax: 20 *
//                                 (foundation.defaultTargetPlatform ==
//                                     TargetPlatform.iOS
//                                     ? 1.3
//                                     : 1.0),
//                             columns: 6,
//                             buttonMode: ButtonMode.MATERIAL,
//                             skinToneIndicatorColor: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
