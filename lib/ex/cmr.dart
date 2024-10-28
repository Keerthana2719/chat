import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:intl/intl.dart';
import 'package:prj/ex/vcall.dart';
import 'dart:io';
import '../class/fullscrnimg.dart';
import '../class/fullscrnvdo.dart';
import '../class/neum.dart';
import '../class/thumb.dart';

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
  final List<Map<String, dynamic>> menuItems = [
    {'value': 'Clear Chat', 'icon': Icons.clear_all, 'text': 'Clear'},
    {'value': 'Block', 'icon': Icons.block, 'text': 'Block'},
    {'value': 'Favorite', 'icon': Icons.favorite, 'text': 'Favorite'},
  ];

  bool _emojiShowing = false;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  File? _imageFile; // Holds the selected image
  File? _videoFile; // Holds the selected video
  final ImagePicker _picker = ImagePicker(); // For picking images/v ideos
  String? _downloadUrl; // To store the uploaded image's URL
  String? _videoDownloadUrl; // To store the uploaded video's URL
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase Authentication instance
  User? currentUser; // Holds the current logged-in user
  String? currentUsername;

  // Function to check if the user is authenticated
  Future<void> _checkAuthStatus() async {
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      await fetchUsername();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authorized. Please log in.")),
      );
    }
  }

  // Fetch the username from Firestore
  Future<void> fetchUsername() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentUsername = userDoc['username'];
        });
      } else {
        print("User document does not exist");
      }
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authorized. Please log in.")),
      );
      return; // Exit if user is not authenticated
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set the selected image
      });
      await _uploadAndSendImage(
          pickedFile); // Upload the image and send its URL as a message
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected.")),
      );
    }
  }

  // Upload the selected image and send its URL as part of the message
  Future<void> _uploadAndSendImage(XFile pickedFile) async {
    if (pickedFile == null) return; // Check if the file is null

    try {
      // Generate a unique file name using the user's UID and current timestamp
      String fileName =
          'images/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create a file object from the picked image
      File file = File(pickedFile.path);

      // Upload the image to Firebase Storage
      UploadTask uploadTask = _storage.ref(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Check if the upload was successful
      if (snapshot.state == TaskState.success) {
        // Retrieve the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print("Image uploaded successfully! URL: $downloadUrl");

        // Send the image URL as a message (implement _sendMessage)
        _sendMessage(imageUrl: downloadUrl);

        setState(() {
          _downloadUrl = downloadUrl; // Update the download URL in the UI
          _imageFile = null; // Clear selected image after upload
        });
        showFullScreenImage(downloadUrl); // Show the image in fullscreen
      } else {
        throw Exception("Image upload failed.");
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }

  void showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  // Pick a video from the gallery
  Future<void> _pickVideo() async {
    if (currentUser == null) {
      await _checkAuthStatus(); // Ensure that currentUser is authenticated
    }

    if (currentUser == null) {
      // If still not authenticated, show error and return
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authorized. Please log in.")),
      );
      return;
    }

    // Pick video from the gallery
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      setState(() {
        _videoFile = File(pickedVideo.path); // Set the selected video
      });
      await _uploadAndSendVideo(
          pickedVideo); // Upload the video and send its URL
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No video selected.")),
      );
    }
  }

// Upload the selected video and send its URL as part of the message
  Future<void> _uploadAndSendVideo(XFile pickedVideo) async {
    if (pickedVideo == null) return;

    try {
      // Generate unique file name based on the user's UID and current timestamp
      String fileName =
          'images/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      File file = File(pickedVideo.path);

      // Upload video to Firebase Storage
      UploadTask uploadTask = _storage.ref(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get download URL after successful upload
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print("Video uploaded successfully! URL: $downloadUrl");

        // Send the video URL as a message
        _sendMessage(videoUrl: downloadUrl);

        setState(() {
          _videoDownloadUrl = downloadUrl;
          _videoFile = null; // Clear selected video after upload
        });

        // Display the uploaded video in fullscreen
        showFullScreenVideo(downloadUrl);
      } else {
        throw Exception("Video upload failed.");
      }
    } catch (e) {
      print("Error uploading video: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading video: $e")),
      );
    }
  }

// Show video in fullscreen after uploading
  void showFullScreenVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoScreen(videoUrl: videoUrl),
      ),
    );
  }

  void _showMediaPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white30,
          shadowColor: Colors.black,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(60)),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _pickImage(); // Call the image picker function
              },
              child: ListTile(
                leading: Icon(Icons.image, color: Colors.black, size: 25),
                title: Text(
                  "Image",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _pickVideo(); // Call the video picker function
              },
              child: const ListTile(
                leading: Icon(
                  Icons.slow_motion_video_rounded,
                  color: Colors.black,
                  size: 25,
                ),
                title: Text(
                  "Video",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearChat() async {
    try {
      final messagesSentByCurrentUser = await _firestore
          .collection('messages')
          .where('sender', isEqualTo: widget.currentUsername)
          .where('receiver', isEqualTo: widget.selectedUsername)
          .get();

      final messagesSentByOtherUser = await _firestore
          .collection('messages')
          .where('sender', isEqualTo: widget.selectedUsername)
          .where('receiver', isEqualTo: widget.currentUsername)
          .get();

      final allMessages =
          messagesSentByCurrentUser.docs + messagesSentByOtherUser.docs;

      for (var doc in allMessages) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat cleared successfully')),
      );
    } catch (e) {
      print('Error clearing chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error clearing chat')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final messageRef = _firestore.collection('messages').doc(messageId);

      // Delete message
      await messageRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    } catch (e) {
      print('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting message')),
      );
    }
  }

  void _showOptionsDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white60,
          shadowColor: Colors.black,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Colors.black,
                  size: 25,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteMessage(messageId);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.favorite_outline,
                  color: Colors.black,
                  size: 25,
                ),
                title: const Text(
                  'Favorite',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Handle favorite action here
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Check authentication status on init
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus && _emojiShowing) {
        setState(() {
          _emojiShowing = false; // Hide emoji picker when TextField gains focus
        });
      }
    });
  }

  // Toggle the emoji keyboard visibility
  void _toggleEmojiKeyboard() {
    setState(() {
      _emojiShowing = !_emojiShowing;
    });

    if (_emojiShowing) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  String formatDate(Timestamp timestamp) {
    DateTime messageDate = timestamp.toDate();
    DateTime now = DateTime.now();

    Duration difference = now.difference(messageDate);

    if (difference.inHours < 24 && messageDate.day == now.day) {
      return 'Today'; // Show 'Today' if the message is sent today
    } else if (difference.inHours < 48 && now.day - messageDate.day == 1) {
      return 'Yesterday'; // Show 'Yesterday' if the message was sent yesterday
    } else {
      return DateFormat('EEEE')
          .format(messageDate); // Show day of the week (e.g., Monday)
    }
  }

  void _sendMessage({String? imageUrl, String? videoUrl}) async {
    if (_controller.text.isNotEmpty || imageUrl != null || videoUrl != null) {
      try {
        await _firestore.collection('messages').add({
          'sender': widget.currentUsername,
          'receiver': widget.selectedUsername,
          'message': _controller.text.isNotEmpty ? _controller.text : null,
          'imageUrl': imageUrl,
          'videoUrl': videoUrl,
          'timestamp': FieldValue.serverTimestamp(),
          "seen": false // New field for seen status
        });
        _controller.clear(); // Clear the text field after sending
        _scrollToBottom(); // Scroll to the bottom of the chat
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

  String replyText = '';

  void openKeyboard() {
    // Your method to open the keyboard goes here
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(17, 16, 47, 1),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 13, left: 10, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon:
                          Icon(Icons.arrow_back_ios, color: Colors.deepOrange)),
                  // NeumorphicButton(
                  //   icon: Icons.arrow_back_ios,
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  Text(
                    widget.selectedUsername,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.call, color: Colors.deepOrange)),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.video_call,
                        color: Colors.deepOrange,
                      )),
                  Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: Color.fromRGBO(17, 16, 47, 1),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.cyan),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'Clear Chat') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white60,
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              title: Center(
                                child: Text(
                                  'Are You Sure ?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.black),
                                ),
                              ),
                              content: Text(
                                  '     Do you want to clear this chat ?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.black)),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.indigo)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _clearChat();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.indigo)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => menuItems.map((item) {
                        return PopupMenuItem<String>(
                          value: item['value'],
                          child: ListTile(
                            leading: Icon(
                              item['icon'],
                              color: Colors.deepOrangeAccent,
                              size: 25,
                            ),
                            title: Text(
                              item['text'],
                              style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18),
                            ),
                          ),
                        );
                      }).toList(),
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 85),
                child: Container(
                  height: 535,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    color: Color.fromRGBO(25, 23, 61, 1),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(-5, -5),
                        color: Color.fromRGBO(51, 48, 108, 1),
                        blurRadius: 4.5,
                      ),
                      BoxShadow(
                        offset: Offset(9, 9),
                        color: Colors.black38,
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
                        final messageData =
                            message.data() as Map<String, dynamic>?;

                        if (messageData == null) return false;

                        final sender = messageData['sender'];
                        final receiver = messageData['receiver'];

                        return (sender != null && receiver != null) &&
                            ((sender == widget.currentUsername &&
                                    receiver == widget.selectedUsername) ||
                                (sender == widget.selectedUsername &&
                                    receiver == widget.currentUsername));
                      }).toList();

                      if (messages.isEmpty) {
                        return const Center(
                            child: Text('No relevant messages'));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final messageData =
                              messages[index].data() as Map<String, dynamic>;
                          final isCurrentUser =
                              messageData['sender'] == widget.currentUsername;
                          final timestamp =
                              messageData['timestamp'] as Timestamp?;
                          final isSeen = messageData['seen'] as bool? ??
                              false; // Check if the message is seen

                          if (timestamp == null) {
                            return SizedBox();
                          }

                          // Show date if it's a new day
                          bool showDate = true;
                          if (index > 0) {
                            final previousMessageData = messages[index - 1]
                                .data() as Map<String, dynamic>;
                            final previousTimestamp =
                                previousMessageData['timestamp'] as Timestamp?;

                            if (previousTimestamp != null) {
                              showDate = timestamp.toDate().day !=
                                  previousTimestamp.toDate().day;
                            }
                          }

                          // Update seen status in Firestore if the message has not been seen and belongs to currentUsername
                          if (!isSeen && !isCurrentUser) {
                            messages[index].reference.update({'seen': true});
                          }

                          return Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (showDate)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: Text(
                                      formatDate(timestamp),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              // Timestamp displayed above the container
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Text(
                                  DateFormat('hh:mm a')
                                      .format(timestamp.toDate()),
                                  style: TextStyle(
                                    color: isCurrentUser && isSeen
                                        ? Colors
                                            .green // Change to green if the message is seen
                                        : Colors.blue, // Else, show blue
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Dismissible(
                                key: UniqueKey(),
                                background: Container(
                                  color: Colors.green, // Color when swiped
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(Icons.reply, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  replyText = messageData[
                                      'message']; // Set the reply text
                                  await Future.delayed(Duration(
                                      milliseconds: 500)); // Optional delay
                                  openKeyboard(); // Open the keyboard for the user to reply
                                  return false; // Prevent the message from being dismissed
                                },
                                child: GestureDetector(
                                  onLongPress: () {
                                    _showOptionsDialog(messages[index].id);
                                  },
                                  onTap: () {
                                    final imageUrl = messageData['imageUrl'];
                                    final videoUrl = messageData['videoUrl'];

                                    if (imageUrl != null) {
                                      showFullScreenImage(imageUrl);
                                    } else if (videoUrl != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenVideoScreen(
                                            videoUrl: videoUrl,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Align(
                                    alignment: isCurrentUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.pinkAccent,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: Colors.white60,
                                            offset: Offset(-1, -1),
                                            blurRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: const Offset(5, 5),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (messageData['message'] != null)
                                            Text(
                                              messageData['message'],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                              ),
                                            ),
                                          if (messageData['imageUrl'] != null)
                                            Image.network(
                                              messageData['imageUrl'],
                                              height: 120,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          if (messageData['videoUrl'] != null)
                                            VideoMessageWidget(
                                                videoUrl:
                                                    messageData['videoUrl']),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _textFieldFocusNode,
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: 'Type your message...',
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.mic),
                                onPressed: () {},
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.camera),
                                    onPressed: _showMediaPickerDialog,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.emoji_emotions_outlined),
                                    onPressed: _toggleEmojiKeyboard,
                                  ),
                                ],
                              ),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                    Offstage(
                      offstage: !_emojiShowing,
                      child: SizedBox(
                        height: 250,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            _controller.text += emoji.emoji;
                          },
                          config: Config(
                            emojiSizeMax: 22 *
                                (foundation.defaultTargetPlatform ==
                                        TargetPlatform.iOS
                                    ? 1.3
                                    : 1.0),
                            columns: 6,
                            buttonMode: ButtonMode.MATERIAL,
                            skinToneIndicatorColor: Colors.grey,
                          ),
                        ),
                      ),
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
