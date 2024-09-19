import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prj/screen/menu.dart';
import 'package:prj/screen/sign%20up.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyCFQLLL8a_4sqqFZMuCOW41E7IJfPH4v4M",
    authDomain: 'whatsapp-dd9b9.firebaseapp.com',
    projectId: 'whatsapp-dd9b9',
    storageBucket: 'whatsapp-dd9b9.appspot.com',
    messagingSenderId: '856276416659',
    appId: '856276416659:android:bf6c6fa95325f9fc528ee1',
   // measurementId: '8041727286',
  );

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Menu(),debugShowCheckedModeBanner: false,);
  }
}
