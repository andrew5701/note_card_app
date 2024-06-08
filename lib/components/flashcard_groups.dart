import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_card_app/components/flashcard_view.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';
import 'package:note_card_app/firebase/login_register.dart';
import 'add_new_group.dart';

class FlashcardGroup extends StatefulWidget {
  const FlashcardGroup({super.key});

  @override
  State<FlashcardGroup> createState() => _FlashcardGroupState();
}

class _FlashcardGroupState extends State<FlashcardGroup> {
  List<String> groups = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchFlashcardGroups();
  }

  Future<void> fetchFlashcardGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        errorMessage = 'User is not logged in.';
      });
      return;
    }

    final userId = user.uid;
    try {
      DocumentSnapshot userDoc =
          await FirestoreService.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        QuerySnapshot flashcardGroupsSnapshot = await FirestoreService.instance
            .collection('users')
            .doc(userId)
            .collection('flashcard_groups')
            .orderBy('created_at', descending: false)
            .get();

        List<String> fetchedGroups =
            flashcardGroupsSnapshot.docs.map((doc) => doc.id).toList();

        setState(() {
          groups = fetchedGroups;
        });
      } else {
        setState(() {
          errorMessage = 'User document does not exist.';
        });
      }
    } catch (e) {
      setState(() {
        // errorMessage = 'Failed to fetch groups: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Groups'),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.exit_to_app_rounded),
            label: const Text('Sign Out'),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: groups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const Text(
                    'No groups created yet.\nClick the plus button to add a new group.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : GridView.count(
              crossAxisCount: 3,
              children: groups.map((group) {
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FlashcardView(collectionName: group),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        group,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddNewGroup(
                onNewGroupAdded: () {
                  setState(() {
                    fetchFlashcardGroups(); // Ensure this method updates the state with new data
                  });
                },
              )),
    );
  },
  icon: const Icon(Icons.add),
  label: const Text('Add A New Group'),
),
    );
  }
}
