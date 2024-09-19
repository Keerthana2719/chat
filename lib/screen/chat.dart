import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'call.dart';
import 'cmr.dart';
import 'ex.dart';
import 'message.dart';

class Chat extends StatefulWidget {
  final String currentUsername; // The logged-in user's username

  const Chat({super.key, required this.currentUsername});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];
  List<String> recentChats = []; // Keep track of recent chats
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  // Function to search for usernames in Firestore
  void searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      setState(() {
        searchResults = result.docs;
        isSearching = true;
      });
    } catch (e) {
      print("Error fetching search results: $e");
    }
  }

  // Function to load recent chats from Firestore
  void _loadRecentChats() async {
    var result = await FirebaseFirestore.instance
        .collection('messages')
        .where('sender', isEqualTo: widget.currentUsername)
        .get();

    setState(() {
      // Only add users with whom the current user has exchanged messages
      recentChats = result.docs.map((doc) => doc['receiver'] as String).toSet().toList();
    });
  }

  // Function to handle when a user is selected and a message is sent
  void _onUserSelected(String username) {
    // Navigate to the message screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Message(
          currentUsername: widget.currentUsername,
          selectedUsername: username,
        ),
      ),
    ).then((_) {
      // After sending a message, update the recent chats list
      _addRecentChat(username);

      // Clear the search field and results after returning from the message screen
      searchController.clear();
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    });
  }

  // Function to add a user to recent chats after sending a message
  void _addRecentChat(String username) {
    if (!recentChats.contains(username)) {
      setState(() {
        recentChats.add(username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chat",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Your Chat"),
              Tab(text: "Story"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Search field for usernames
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search username',
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (query) {
                  searchUsers(query);
                },
              ),
              const SizedBox(height: 20),
              // Display search results or chat history
              Expanded(
                child: TabBarView(
                  children: [
                    // Your Chat Tab
                    isSearching
                        ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        var user = searchResults[index];
                        return ListTile(
                          title: Text(user['username']),
                          onTap: () {
                            _onUserSelected(user['username']);
                          },
                        );
                      },
                    )
                        : ListView.builder(
                      itemCount: recentChats.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(recentChats[index]),
                          onTap: () {
                            _onUserSelected(recentChats[index]);
                          },
                        );
                      },
                    ),
                    const Center(child: Text("Story history")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

