// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class Profile extends StatefulWidget {
//   const Profile({super.key});
//
//   @override
//   State<Profile> createState() => _ProfileState();
// }
//
// class _ProfileState extends State<Profile> {
//   Uint8List? _image;
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _aboutController = TextEditingController(); // Controller for about text
//   User? currentUser;
//   bool _isLoading = false;
//   String? _profileImageUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatus();
//     _fetchCurrentUserProfileImage();
//   }
//
//   Future<void> _checkAuthStatus() async {
//     currentUser = _auth.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User not authorized. Please log in.")),
//       );
//       return;
//     }
//   }
//
//   Future<void> _fetchCurrentUserProfileImage() async {
//     if (currentUser != null) {
//       DocumentSnapshot userDoc =
//       await _firestore.collection('profile').doc(currentUser!.uid).get();
//       if (userDoc.exists && userDoc.data() != null) {
//         setState(() {
//           _profileImageUrl = userDoc['profile_image_url'];
//           _aboutController.text = userDoc['about'] ?? ''; // Load about text if it exists
//         });
//       }
//     }
//   }
//
//   Future<void> selectImage() async {
//     if (currentUser == null) {
//       await _checkAuthStatus();
//       return;
//     }
//
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       Uint8List img = await pickedFile.readAsBytes();
//       setState(() {
//         _image = img;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No image selected.")),
//       );
//     }
//   }
//
//   Future<void> uploadImageToFirebase() async {
//     if (_image == null && _aboutController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No image selected or about text entered.")),
//       );
//       return;
//     }
//
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//
//       String? downloadUrl;
//       if (_image != null) {
//         String fileName = "images/${currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg";
//         UploadTask uploadTask = _storage.ref(fileName).putData(_image!);
//         TaskSnapshot snapshot = await uploadTask;
//         downloadUrl = await snapshot.ref.getDownloadURL();
//       }
//
//       // Save image URL and about text to Firestore
//       await _firestore.collection('profile').doc(currentUser!.uid).set({
//         'profile_image_url': downloadUrl ?? _profileImageUrl,
//         'about': _aboutController.text, // Save about text
//       }, SetOptions(merge: true));
//
//       setState(() {
//         _profileImageUrl = downloadUrl ?? _profileImageUrl;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Profile updated successfully.")),
//       );
//     } catch (e) {
//       print("Error uploading profile data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error uploading profile data: $e")),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _aboutController.dispose(); // Dispose controller when widget is disposed
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 64,
//                   backgroundImage: _image != null
//                       ? MemoryImage(_image!)
//                       : (_profileImageUrl != null
//                       ? NetworkImage(_profileImageUrl!)
//                       : null),
//                   backgroundColor: Colors.blue,
//                 ),
//                 Positioned(
//                   bottom: -10,
//                   left: 80,
//                   child: IconButton(
//                     onPressed: selectImage,
//                     icon: const Icon(Icons.add_a_photo),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _aboutController, // Link TextEditingController
//               decoration: InputDecoration(
//                 labelText: 'About',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: uploadImageToFirebase,
//               child: const Text("Save Profile"),
//             ),
//             if (_isLoading)
//               const Padding(
//                 padding: EdgeInsets.only(top: 20.0),
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
