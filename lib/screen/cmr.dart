// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
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
//   bool _emojiShowing = false;
//   final TextEditingController _controller = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ScrollController _scrollController = ScrollController(); // Scroll controller
//   final ImagePicker _picker = ImagePicker(); // Image picker instance
//
//   // Function to toggle the emoji keyboard
//   void _toggleEmojiKeyboard() {
//     if (_emojiShowing) {
//       FocusScope.of(context).requestFocus(FocusNode());
//     } else {
//       FocusScope.of(context).unfocus();
//     }
//     setState(() {
//       _emojiShowing = !_emojiShowing;
//     });
//   }
//
//   // Function to send the message
//   void _sendMessage({String? imageUrl, String? videoUrl}) async {
//     if (_controller.text.isNotEmpty || imageUrl != null || videoUrl != null) {
//       await _firestore.collection('messages').add({
//         'sender': widget.currentUsername,
//         'receiver': widget.selectedUsername,
//         'message': _controller.text.isNotEmpty ? _controller.text : null,
//         'imageUrl': imageUrl, // Add image URL if present
//         'videoUrl': videoUrl, // Add video URL if present
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       _controller.clear();
//       _scrollToBottom();
//     }
//   }
//
//   // Function to automatically scroll to the bottom
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     }
//   }
//
//   // Function to pick image or video from gallery
//   Future<void> _pickMedia() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery) ??
//         await _picker.pickVideo(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       File file = File(pickedFile.path);
//       String fileType = pickedFile.mimeType!.startsWith('image') ? 'image' : 'video';
//
//       // Upload to Firebase Storage
//       String downloadUrl = await _uploadFile(file, fileType);
//
//       // Send the message with the uploaded media
//       if (fileType == 'image') {
//         _sendMessage(imageUrl: downloadUrl);
//       } else if (fileType == 'video') {
//         _sendMessage(videoUrl: downloadUrl);
//       }
//     }
//   }
//
//   // Function to upload the file to Firebase Storage
//   Future<String> _uploadFile(File file, String fileType) async {
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference storageRef = _storage
//         .ref()
//         .child('chat_media')
//         .child(fileType)
//         .child('$fileName.${fileType == 'image' ? 'jpg' : 'mp4'}');
//
//     UploadTask uploadTask = storageRef.putFile(file);
//     TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFE7ECEF),
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
//                   const SizedBox(width: 20),
//                   Text(
//                     "${widget.selectedUsername}",
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 25,
//                     ),
//                   ),
//                   const Spacer(),
//                   NeumorphicButton(
//                     icon: Icons.call,
//                     onPressed: () {
//                       // Your onPressed logic here
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   NeumorphicButton(
//                     icon: Icons.video_call,
//                     onPressed: () {
//                       // Your onPressed logic here
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   NeumorphicButton(
//                     icon: Icons.more_vert,
//                     onPressed: () {
//                       // Your onPressed logic here
//                     },
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
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(25),
//                       topRight: Radius.circular(25),
//                     ),
//                     color: const Color(0xFFE7ECEF),
//                     boxShadow: [
//                       const BoxShadow(
//                         offset: Offset(-8, -8),
//                         color: Colors.white,
//                         blurRadius: 4.5,
//                       ),
//                       BoxShadow(
//                         offset: const Offset(5, 5),
//                         color: Colors.black38.withOpacity(0.2),
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
//                           return Align(
//                             alignment: isCurrentUser
//                                 ? Alignment.centerRight
//                                 : Alignment.centerLeft,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 15, horizontal: 20),
//                               margin: const EdgeInsets.symmetric(
//                                   vertical: 8, horizontal: 10),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   const BoxShadow(
//                                     color: Colors.white,
//                                     offset: Offset(-4, -4),
//                                     blurRadius: 10,
//                                   ),
//                                   BoxShadow(
//                                     color: Colors.grey[500]!,
//                                     offset: const Offset(3, 3),
//                                     blurRadius: 5,
//                                   ),
//                                 ],
//                               ),
//                               child: Text(
//                                 message['message'] ?? '',
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16,
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
//                             controller: _controller,
//                             decoration: InputDecoration(
//                               hintText: 'Message...',
//                               filled: true,
//                               fillColor: Colors.grey[300],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         NeumorphicButton(
//                           icon: Icons.camera_alt,
//                           onPressed: _pickMedia,
//                         ),
//                         const SizedBox(width: 10),
//                         NeumorphicButton(
//                           icon: Icons.send,
//                           onPressed: () => _sendMessage(),
//                         ),
//                       ],
//                     ),
//                     if (_emojiShowing)
//                       EmojiPicker(
//                         onEmojiSelected: (category, emoji) {
//                           _controller.text += emoji.emoji;
//                         },
//                       ),
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
