import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';


class NewCard extends StatefulWidget {
  final String collectionName;

  const NewCard({Key? key, required this.collectionName}) : super(key: key);

  @override
  State<NewCard> createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {
  final TextEditingController _frontcontroller = TextEditingController();
  final TextEditingController _backcontroller = TextEditingController();

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
            TextField(
              controller: _frontcontroller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Front',
              ),
            ),
            TextField(
              controller: _backcontroller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Back',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                userId = user!.uid;
                FirestoreService.instance.collection("users").doc(userId.toString()).collection(widget.collectionName.toString()).add({
                  'front': _frontcontroller.text,
                  'back': _backcontroller.text,
                });
                _frontcontroller.clear();
                _backcontroller.clear();
              },
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }
}