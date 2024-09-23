// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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
//   File? _selectedMediaFile;
//   String? _profileImageUrl; // Profile image URL
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile(); // Load profile image when the screen is loaded
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
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
//       try {
//         await _firestore.collection('messages').add({
//           'sender': widget.currentUsername,
//           'receiver': widget.selectedUsername,
//           'message': _controller.text.isNotEmpty ? _controller.text : null,
//           'imageUrl': imageUrl, // Store image URL if it exists
//           'videoUrl': videoUrl, // Store video URL if it exists
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//         _controller.clear();
//         _scrollToBottom();
//       } catch (e) {
//         print("Error sending message: $e");
//       }
//     }
//   }
//
//
//   // Function to automatically scroll to the bottom
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     }
//   }
//
//   // Function to pick an image and upload it to Firebase Storage
//   Future<void> _pickMedia({required String mediaType}) async {
//     XFile? pickedFile;
//     if (mediaType == 'image') {
//       pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     } else if (mediaType == 'video') {
//       pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     }
//
//     if (pickedFile != null) {
//       File mediaFile = File(pickedFile.path);
//       _showMediaPreviewDialog(mediaFile, mediaType);
//     }
//   }
//
//   // Function to upload the file to Firebase Storage
//   Future<String?> _uploadFile(File file, String fileType) async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print("User is not authenticated");
//       return null; // User is not authenticated
//     }
//
//     try {
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference storageRef = _storage
//           .ref()
//           .child('chat_media')
//           .child(fileType)
//           .child('$fileName.${fileType == 'image' ? 'jpg' : 'mp4'}');
//
//       UploadTask uploadTask = storageRef.putFile(file);
//       TaskSnapshot snapshot = await uploadTask;
//
//       // Get the download URL of the uploaded file
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print("Error uploading file: $e");
//       return null; // If something goes wrong, return null
//     }
//   }
//
//
//   // Show a dialog to preview the selected image or video
//   // Show a dialog to preview the selected image or video
//   void _showMediaPreviewDialog(File file, String fileType) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: fileType == 'image'
//               ? Image.file(file)
//               : const Icon(Icons.videocam), // Placeholder for video preview
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 String? downloadUrl;
//
//                 // Upload the file and get the download URL
//                 downloadUrl = await _uploadFile(file, fileType);
// print("object");
//                 // Send the message with the uploaded media
//                 if (fileType == 'image') {
//                   _sendMessage(imageUrl: downloadUrl);
//                 } else if (fileType == 'video') {
//                   _sendMessage(videoUrl: downloadUrl);
//                 }
//               },
//               child: const Text('Send'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   // Function to load the profile image from Firestore
//   Future<void> _loadProfile() async {
//     try {
//       final doc = await _firestore.collection('profiles').doc('user_profile_id').get();
//       if (doc.exists) {
//         final userData = doc.data() as Map<String, dynamic>;
//         setState(() {
//           _profileImageUrl = userData['imageUrl']; // Load the image URL
//         });
//       }
//     } catch (e) {
//       print("Error loading profile: $e");
//     }
//   }
//
//   // Widget to build and display the profile image
//   Widget _buildProfileImage() {
//     return _profileImageUrl != null
//         ? Image.network(_profileImageUrl!, height: 150, width: 150) // Show the profile image
//         : const Icon(Icons.person, size: 150); // Default icon if no image is available
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
//                     widget.selectedUsername,
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
//                       // Call logic here
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   NeumorphicButton(
//                     icon: Icons.video_call,
//                     onPressed: () {
//                       // Video call logic here
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   NeumorphicButton(
//                     icon: Icons.more_vert,
//                     onPressed: () {
//                       // More options logic here
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
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                               margin: const EdgeInsets.symmetric(
//                                 vertical: 4,
//                                 horizontal: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isCurrentUser
//                                     ? const Color(0xFFD1F2EB)
//                                     : const Color(0xFFFFF9C4),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   if (message['message'] != null)
//                                     Text(
//                                       message['message'],
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   if (message['imageUrl'] != null)
//                                     Image.network(message['imageUrl']),
//                                   if (message['videoUrl'] != null)
//                                     const Icon(Icons.videocam), // Placeholder for video preview
//                                 ],
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
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _controller,
//                             decoration: const InputDecoration(
//                               hintText: 'Type a message',
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(30),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: EdgeInsets.symmetric(
//                                 vertical: 8,
//                                 horizontal: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         NeumorphicButton(
//                           icon: Icons.emoji_emotions,
//                           onPressed: _toggleEmojiKeyboard,
//                         ),
//                         const SizedBox(width: 10),
//                         NeumorphicButton(
//                           icon: Icons.image,
//                           onPressed: () {
//                             _pickMedia(mediaType: 'image');
//                           },
//                         ),
//                         const SizedBox(width: 10),
//                         NeumorphicButton(
//                           icon: Icons.videocam,
//                           onPressed: () {
//                             _pickMedia(mediaType: 'video');
//                           },
//                         ),
//                         const SizedBox(width: 10),
//                         NeumorphicButton(
//                           icon: Icons.send,
//                           onPressed: () {
//                             _sendMessage();
//                           },
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

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:flutter/foundation.dart' as foundation;

  import '../class/neum.dart';

  class Message extends StatefulWidget {
    final String currentUsername; // Sender's username (logged-in user)
    final String selectedUsername; // Receiver's username (selected user)

    const Message({
      super.key,
      required this.currentUsername,
      required this.selectedUsername,
    });

    @override
    _MessageState createState() => _MessageState();
  }

  class _MessageState extends State<Message> {
    bool _emojiShowing = false;
    final TextEditingController _controller = TextEditingController();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final ScrollController _scrollController = ScrollController(); // Scroll controller
    final ImagePicker _picker = ImagePicker(); // Image picker instance

    File? _selectedMediaFile;
    String? _profileImageUrl; // Profile image URL

    @override
    void initState() {
      super.initState();
      _loadProfile(); // Load profile image when the screen is loaded
    }

    @override
    void dispose() {
      _controller.dispose();
      _scrollController.dispose();
      super.dispose();
    }

    // Function to toggle the emoji keyboard
    void _toggleEmojiKeyboard() {
      if (_emojiShowing) {
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        FocusScope.of(context).unfocus();
      }
      setState(() {
        _emojiShowing = !_emojiShowing;
      });
    }

    // Function to send the message
    void _sendMessage({String? imageUrl, String? videoUrl}) async {
      if (_controller.text.isNotEmpty || imageUrl != null || videoUrl != null) {
        try {
          await _firestore.collection('messages').add({
            'sender': widget.currentUsername,
            'receiver': widget.selectedUsername,
            'message': _controller.text.isNotEmpty ? _controller.text : null,
            'imageUrl': imageUrl, // Store image URL if it exists
            'videoUrl': videoUrl, // Store video URL if it exists
            'timestamp': FieldValue.serverTimestamp(),
          });
          _controller.clear();
          _scrollToBottom();
        } catch (e) {
          print("Error sending message: $e");
        }
      }
    }


    // Function to automatically scroll to the bottom
    void _scrollToBottom() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }

    // Function to pick an image and upload it to Firebase Storage
    Future<void> _pickMedia({required String mediaType}) async {
      XFile? pickedFile;
      if (mediaType == 'image') {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      } else if (mediaType == 'video') {
        pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        File mediaFile = File(pickedFile.path);
        _showMediaPreviewDialog(mediaFile, mediaType);
      }
    }

    // Function to upload the file to Firebase Storage
    // Function to upload the file to Firebase Storage
    Future<String?> _uploadFile(File file, String fileType) async {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is not authenticated");
        return null;
      }
      print("User is authenticated: ${user.uid}");

      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // Using the simplified storage reference
        Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName.${fileType == 'image' ? 'jpg' : 'mp4'}');

        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // Check for errors in upload
        if (snapshot.state == TaskState.error) {
          print("Upload failed");
          return null;
        }

        // Get the download URL of the uploaded file
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print("Error uploading file: $e");
        return null; // If something goes wrong, return null
      }
    }

    // Show a dialog to preview the selected image or video
    void _showMediaPreviewDialog(File file, String fileType) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: fileType == 'image'
                ? Image.file(file)
                : const Icon(Icons.videocam), // Placeholder for video preview
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  String? downloadUrl;

                  // Upload the file and get the download URL
                  downloadUrl = await _uploadFile(file, fileType);
                  print("object");
                  // Send the message with the uploaded media
                  if (fileType == 'image') {
                    _sendMessage(imageUrl: downloadUrl);
                  } else if (fileType == 'video') {
                    _sendMessage(videoUrl: downloadUrl);
                  }
                },
                child: const Text('Send'),
              ),
            ],
          );
        },
      );
    }


    // Function to load the profile image from Firestore
    Future<void> _loadProfile() async {
      try {
        final doc = await _firestore.collection('profiles').doc('user_profile_id').get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          setState(() {
            _profileImageUrl = userData['imageUrl']; // Load the image URL
          });
        }
      } catch (e) {
        print("Error loading profile: $e");
      }
    }

    // Widget to build and display the profile image
    Widget _buildProfileImage() {
      return _profileImageUrl != null
          ? Image.network(_profileImageUrl!, height: 150, width: 150) // Show the profile image
          : const Icon(Icons.person, size: 150); // Default icon if no image is available
    }

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFE7ECEF),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 13, left: 10, right: 5),
                child: Row(
                  children: [
                    NeumorphicButton(
                      icon: Icons.arrow_back_ios,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.selectedUsername,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const Spacer(),
                    NeumorphicButton(
                      icon: Icons.call,
                      onPressed: () {
                        // Call logic here
                      },
                    ),
                    const SizedBox(width: 10),
                    NeumorphicButton(
                      icon: Icons.video_call,
                      onPressed: () {
                        // Video call logic here
                      },
                    ),
                    const SizedBox(width: 10),
                    NeumorphicButton(
                      icon: Icons.more_vert,
                      onPressed: () {
                        // More options logic here
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    height: 580,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      color: const Color(0xFFE7ECEF),
                      boxShadow: [
                        const BoxShadow(
                          offset: Offset(-8, -8),
                          color: Colors.white,
                          blurRadius: 4.5,
                        ),
                        BoxShadow(
                          offset: const Offset(5, 5),
                          color: Colors.black38.withOpacity(0.2),
                          blurRadius: 1.5,
                        ),
                      ],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('messages')
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No messages yet'));
                        }

                        final messages = snapshot.data!.docs.where((message) {
                          final sender = message['sender'];
                          final receiver = message['receiver'];
                          return (sender == widget.currentUsername &&
                              receiver == widget.selectedUsername) ||
                              (sender == widget.selectedUsername &&
                                  receiver == widget.currentUsername);
                        }).toList();

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isCurrentUser =
                                message['sender'] == widget.currentUsername;

                            return Align(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? const Color(0xFFD1F2EB)
                                      : const Color(0xFFFFF9C4),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message['message'] != null)
                                      Text(
                                        message['message'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    if (message['imageUrl'] != null)
                                      Image.network(message['imageUrl']),
                                    if (message['videoUrl'] != null)
                                      const Icon(Icons.videocam), // Placeholder for video preview
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          NeumorphicButton(
                            icon: Icons.emoji_emotions,
                            onPressed: _toggleEmojiKeyboard,
                          ),
                          const SizedBox(width: 10),
                          NeumorphicButton(
                            icon: Icons.image,
                            onPressed: () {
                              _pickMedia(mediaType: 'image');
                            },
                          ),
                          const SizedBox(width: 10),
                          NeumorphicButton(
                            icon: Icons.videocam,
                            onPressed: () {
                              _pickMedia(mediaType: 'video');
                            },
                          ),
                          const SizedBox(width: 10),
                          NeumorphicButton(
                            icon: Icons.send,
                            onPressed: () {
                              _sendMessage();
                            },
                          ),
                        ],
                      ),
                      if (_emojiShowing)
                        EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            _controller.text += emoji.emoji;
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
//
// extension on TaskSnapshot {
//   get error => null;
// }