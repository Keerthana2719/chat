import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteMessagesScreen extends StatelessWidget {
  final String currentUserId; // The current user's ID

  FavoriteMessagesScreen({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('favorites')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final favoriteMessages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteMessages.length,
            itemBuilder: (context, index) {
              final message = favoriteMessages[index];
              return ListTile(
                title: Text(message['messageText']),
                trailing: Icon(Icons.favorite, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
