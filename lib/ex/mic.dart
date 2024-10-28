import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'fav.dart';

class ChatScreen extends StatelessWidget {
  final String currentUserId; // Current user's ID
  final String selectedUserId; // Chat partner's ID

  ChatScreen({required this.currentUserId, required this.selectedUserId});

  // Function to show options dialog
  void _showOptionsDialog(BuildContext context, String messageId, String messageText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white30,
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
                onTap: () async {
                  Navigator.pop(context);
                  await _addMessageToFavorites(messageId, messageText);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Add the message to the favorites collection in Firestore
  Future<void> _addMessageToFavorites(String messageId, String messageText) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('favorites')
        .doc(messageId)
        .set({
      'messageId': messageId,
      'messageText': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'selectedUserId': selectedUserId, // Store the chat partner's ID
    });
  }

  // Example delete function (You can modify this based on your implementation)
  Future<void> _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(messageId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteMessagesScreen(currentUserId: currentUserId),
                ),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // Example message count
        itemBuilder: (context, index) {
          String messageId = 'message_$index'; // Example message ID
          String messageText = 'Message $index'; // Example message text

          return ListTile(
            title: Text(messageText),
            onLongPress: () => _showOptionsDialog(context, messageId, messageText),
          );
        },
      ),
    );
  }
}
