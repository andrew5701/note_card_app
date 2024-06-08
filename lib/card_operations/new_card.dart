import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note_card_app/components/flashcard_view.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';

class NewCard extends StatefulWidget {
  final String collectionName;
  final Function onCardAdded;

  const NewCard(
      {super.key, required this.collectionName, required this.onCardAdded});

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
        title: const Text('Add New Card'),
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
              margin: const EdgeInsets.only(top: 20.0),
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
            Container(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                ),
                onPressed: () async {

                  if(_frontcontroller.text == '' || _backcontroller.text == ''){
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Please fill in both fields'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  userId = user!.uid;
                  FirestoreService.instance
                      .collection("users")
                      .doc(userId.toString())
                      .collection('flashcard_groups')
                      .doc(widget.collectionName.toString())
                      .collection('flashcards')
                      .add({
                    'front': _frontcontroller.text,
                    'back': _backcontroller.text,
                    'createdAt': DateTime.now(),
                  });
                  _frontcontroller.clear();
                  _backcontroller.clear();

                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => FlashcardView(collectionName: widget.collectionName.toString())),
                  //   (Route<dynamic> route) => false,
                  // );
                  widget.onCardAdded();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Add Card',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
