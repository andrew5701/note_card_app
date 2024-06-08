import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';

class DeleteCard extends StatefulWidget {

  final String documentName;
  final String collectionName;
  final Function onCardDeleted;

  const DeleteCard(
      {super.key,

      required this.documentName,
      required this.collectionName,
      required this.onCardDeleted});

  @override
  State<DeleteCard> createState() => _DeleteCardState();
}

class _DeleteCardState extends State<DeleteCard> {


  final user = FirebaseAuth.instance.currentUser;
  late final String? userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Card'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            
            ElevatedButton(
              onPressed: () {
                userId = user!.uid;
                FirestoreService.instance
                    .collection("users")
                    .doc(userId.toString())
                    .collection('flashcard_groups')
                    .doc(widget.collectionName.toString())
                    .collection('flashcards')
                    .doc(widget.documentName.toString())
                    .delete();
              

               
                widget.onCardDeleted();
                Navigator.pop(context);
              },
              child: const Text('Delete Card'),
            ),
          ],
        ),
      ),
    );
  }
}
