// import 'dart:async';
// import 'dart:io'; // For File
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:prj/ex/prf.dart';
//
// class Bck extends StatefulWidget {
//   final String currentUsername; // Sender's username (logged-in user)
//
//   Bck({Key? key, required this.currentUsername}) : super(key: key);
//
//   @override
//   State<Bck> createState() => _BckState();
// }
//
// class _BckState extends State<Bck> {
//   bool _isContainerVisible = false;
//   String? _profileImageUrl;
//   String? _backgroundImageUrl; // Separate variable for background image
//   String? _about;
//
//   final ImagePicker _picker =
//   ImagePicker(); // Create an instance of ImagePicker
//
//   @override
//   void initState() {
//     super.initState();
//     // Trigger the animation shortly after the page loads
//     Timer(const Duration(milliseconds: 100), () {
//       setState(() {
//         _isContainerVisible = true;
//       });
//     });
//     // Fetch profile data from Firestore
//     _fetchProfileData();
//   }
//
//   Future<void> _fetchProfileData() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('profile')
//           .doc(currentUser.uid)
//           .get();
//       if (userDoc.exists) {
//         setState(() {
//           _profileImageUrl = userDoc['profile_image_url'];
//           _backgroundImageUrl =
//           userDoc['background_image_url']; // Retrieve background image URL
//           _about = userDoc['about']; // Retrieve "about" field
//         });
//       }
//     }
//   }
//
//   Future<void> _pickImage(bool isProfileImage) async {
//     // Open the gallery to pick an image
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       if (isProfileImage) {
//         await _uploadImage(File(pickedFile.path), true);
//       } else {
//         await _uploadImage(File(pickedFile.path), false);
//       }
//     }
//   }
//
//   Future<void> _uploadImage(File image, bool isProfileImage) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       try {
//         // Create a reference for the correct image in Firebase Storage
//         final ref = isProfileImage
//             ? FirebaseStorage.instance
//             .ref('profile_images/${currentUser.uid}_profile.jpg')
//             : FirebaseStorage.instance
//             .ref('background_images/${currentUser.uid}_background.jpg');
//
//         // Upload the file
//         await ref.putFile(image);
//
//         // Get the download URL
//         final downloadUrl = await ref.getDownloadURL();
//
//         // Update Firestore with the new image URL
//         await FirebaseFirestore.instance
//             .collection('profile')
//             .doc(currentUser.uid)
//             .update(isProfileImage
//             ? {'profile_image_url': downloadUrl}
//             : {'background_image_url': downloadUrl});
//
//         // Update the state to display the new image
//         setState(() {
//           if (isProfileImage) {
//             _profileImageUrl = downloadUrl;
//           } else {
//             _backgroundImageUrl = downloadUrl;
//           }
//         });
//       } catch (e) {
//         print('Error uploading image: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 GestureDetector(
//                   onTap: () =>
//                       _pickImage(false), // Change to pick background image
//                   child: Container(
//                     width: double.infinity,
//                     height: 170,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       image: _backgroundImageUrl != null
//                           ? DecorationImage(
//                         image: NetworkImage(_backgroundImageUrl!),
//                         fit: BoxFit.cover,
//                       )
//                           : null,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // Sliding container with profile information
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//               bottom: _isContainerVisible ? 0 : -550,
//               left: 0,
//               right: 0,
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 alignment: Alignment.topCenter,
//                 children: [
//                   // Blue background container
//                   Container(
//                     height: 550,
//                     decoration: const BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(30),
//                         topLeft: Radius.circular(30),
//                       ),
//                     ),
//                   ),
//
//                   // Profile image in a circular cutout
//                   Positioned(
//                     top: -50,
//                     right: 50,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) => Profile()));
//                       }, // Change to pick profile image
//                       child: CircleAvatar(
//                         radius: 65,
//                         backgroundColor: Colors.black,
//                         backgroundImage: _profileImageUrl != null
//                             ? NetworkImage(_profileImageUrl!)
//                             : null,
//                         child: _profileImageUrl == null
//                             ? const Icon(Icons.person,
//                             size: 50, color: Colors.grey)
//                             : null,
//                       ),
//                     ),
//                   ),
//
//                   // User details inside sliding container
//                   Positioned(
//                     top: 30, // Adjusted to place text below the circle
//                     left: 20,
//                     right: 20,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.currentUsername,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24,
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//                         Text(
//                           _about ?? '', // Display "about" text
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 50),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                                 width: 150, height: 50, color: Colors.black),
//                             Container(
//                                 width: 150, height: 50, color: Colors.black),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }