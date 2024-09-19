// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class Message extends StatefulWidget {
//   final String currentUsername;
//   final String selectedUsername;
//
//   const Message({
//     Key? key,
//     required this.currentUsername,
//     required this.selectedUsername,
//   }) : super(key: key);
//
//   @override
//   _MessageState createState() => _MessageState();
// }
//
// class _MessageState extends State<Message> {
//   bool _isRecording = false;
//   String? _audioFilePath;
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _initRecorder();
//   }
//
//   Future<void> _initRecorder() async {
//     // Check for microphone permission
//     final status = await Permission.microphone.request();
//
//     if (status.isGranted) {
//       await _recorder.openRecorder();
//     } else if (status.isDenied) {
//       // Permission is denied, show a message (optional)
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Microphone permission denied'),
//       ));
//     } else if (status.isPermanentlyDenied) {
//       // Permission permanently denied, open app settings
//       openAppSettings();
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     _recorder.closeRecorder();
//     super.dispose();
//   }
//
//   Future<void> _toggleRecording() async {
//     // Recheck permission before starting/stopping recording
//     final status = await Permission.microphone.status;
//
//     if (status.isGranted) {
//       if (_isRecording) {
//         _audioFilePath = await _stopRecording();
//         if (_audioFilePath != null) {
//           await _uploadAudio();
//         }
//       } else {
//         await _startRecording();
//       }
//
//       setState(() {
//         _isRecording = !_isRecording;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Microphone permission not granted'),
//       ));
//     }
//   }
//
//   Future<void> _startRecording() async {
//     final directory = await getTemporaryDirectory();
//     final path = '${directory.path}/audio.aac';
//     await _recorder.startRecorder(
//       toFile: path,
//       codec: Codec.aacADTS,
//     );
//   }
//
//   Future<String?> _stopRecording() async {
//     return await _recorder.stopRecorder();
//   }
//
//   Future<void> _uploadAudio() async {
//     if (_audioFilePath == null) return;
//
//     final file = File(_audioFilePath!);
//     final storageRef = FirebaseStorage.instance
//         .ref()
//         .child('voice_messages/${DateTime.now().millisecondsSinceEpoch}.aac');
//
//     final uploadTask = storageRef.putFile(file);
//     final snapshot = await uploadTask.whenComplete(() {});
//
//     final downloadUrl = await snapshot.ref.getDownloadURL();
//     _sendAudioMessage(downloadUrl);
//   }
//
//   void _sendAudioMessage(String audioUrl) async {
//     await _firestore.collection('messages').add({
//       'sender': widget.currentUsername,
//       'receiver': widget.selectedUsername,
//       'voice_message': audioUrl,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//     _scrollToBottom();
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFE7ECEF),
//         body: Stack(
//           children: [
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey[300],
//                           hintText: 'Type a message',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: Icon(
//                         _isRecording ? Icons.stop : Icons.mic,
//                         color: _isRecording ? Colors.red : Colors.black,
//                       ),
//                       onPressed: _toggleRecording,
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

