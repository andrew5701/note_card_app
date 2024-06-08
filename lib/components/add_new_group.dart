import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewGroup extends StatefulWidget {
  final Function onNewGroupAdded;
  const AddNewGroup({super.key, required this.onNewGroupAdded});

  @override
  // ignore: library_private_types_in_public_api
  _AddNewGroupState createState() => _AddNewGroupState();
}

class _AddNewGroupState extends State<AddNewGroup> {
  TextEditingController collectionNameController = TextEditingController();
  String errorMessage = '';

  Future<void> createCollectionAndCloseScreen(BuildContext context) async {
    String collectionName = collectionNameController.text;

    if (collectionName.isEmpty) {
      setState(() {
        errorMessage = 'Collection name cannot be empty';
      });
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({}, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('flashcard_groups')
            .doc(collectionName)
            .set({
          'created_at': FieldValue.serverTimestamp(),
        });



        widget.onNewGroupAdded();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Collection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: collectionNameController,
              decoration: InputDecoration(
                labelText: 'Collection Name',
                errorText: errorMessage.isNotEmpty ? errorMessage : null,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => createCollectionAndCloseScreen(context),
              child: Text('Create Collection'),
            ),
          ],
        ),
      ),
    );
  }
}
