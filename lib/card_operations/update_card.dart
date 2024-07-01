import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';

class UpdateCard extends StatefulWidget {
  final String front;
  final String back;
  final String documentName;
  final String collectionName;
  final Function onCardUpdated;

  const UpdateCard(
      {super.key,
      required this.front,
      required this.back,
      required this.documentName,
      required this.collectionName,
      required this.onCardUpdated});

  @override
  State<UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends State<UpdateCard> {
  final TextEditingController _frontcontroller = TextEditingController();
  final TextEditingController _backcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _frontcontroller.text = widget.front;
    _backcontroller.text = widget.back;
  }

  @override
  void dispose() {
    _frontcontroller.dispose();
    _backcontroller.dispose();
    super.dispose();
  }

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
            Container(
              margin: const EdgeInsets.only(top: 200.0),
              width: 380,
              child: TextField(
                controller: _frontcontroller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Front',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0,bottom: 30.0),
              width: 380,
              child: TextField(
                controller: _backcontroller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Back',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                ),
              onPressed: () {
                userId = user!.uid;
                FirestoreService.instance
                    .collection("users")
                    .doc(userId.toString())
                    .collection('flashcard_groups')
                    .doc(widget.collectionName.toString())
                    .collection('flashcards')
                    .doc(widget.documentName.toString())
                    .update({
                  'front': _frontcontroller.text,
                  'back': _backcontroller.text,
                });
                _frontcontroller.clear();
                _backcontroller.clear();

                widget.onCardUpdated();
                Navigator.pop(context);
              },
              child: const Text(
                  'Update Card',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
