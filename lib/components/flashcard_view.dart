import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/widgets.dart';
import 'package:note_card_app/card_operations/delete_card.dart';
import 'package:note_card_app/card_operations/new_card.dart';
import 'package:note_card_app/card_operations/update_card.dart';
import 'package:note_card_app/components/flashcard_groups.dart';

class CardView extends StatelessWidget {
  final String text;
  const CardView({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(text,
              style: const TextStyle(
                fontSize: 20,
              ),),

        ),
      ),
    );
  }
}

class FlashcardView extends StatefulWidget {
  final String collectionName;

  const FlashcardView({Key? key, required this.collectionName})
      : super(key: key);

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  List<Map<String, dynamic>> flashcards = [];
  String errorMessage = '';
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFlashcards();
  }

  Future<void> fetchFlashcards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        errorMessage = 'User is not logged in.';
      });
      return;
    }

    final userId = user.uid;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcard_groups')
          .doc(widget.collectionName)
          .collection('flashcards')
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'No flashcards found.';
        });
      } else {
        List<Map<String, dynamic>> fetchedFlashcards =
            querySnapshot.docs.map((doc) {
          return {
            'front': doc['front'],
            'back': doc['back'],
            'docId': doc.id,
            'createdAt': doc['createdAt'],
          };
        }).toList();

        fetchedFlashcards.sort((a, b) => (a['createdAt'] as Timestamp)
            .compareTo(b['createdAt'] as Timestamp));
        setState(() {
          flashcards = fetchedFlashcards;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch flashcards: $e';
      });
    }
  }

  void showNextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % flashcards.length;
    });
  }

  void showPreviousCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + flashcards.length) % flashcards.length;
    });
  }

  Widget buildAddNewCardButton() {
    return ElevatedButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewCard(
              collectionName: widget.collectionName,
              onCardAdded: () {
                setState(() {
                  fetchFlashcards(); // Ensure this method updates the state with new data
                });
              },
            ),
          ),
        );
      },
      child: const Text('Add New Card'),
    );
  }

  void handleMenuAction(String value) async {
    if (value == 'Update Card') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateCard(
            front: flashcards[currentIndex]['front'] ?? '',
            back: flashcards[currentIndex]['back'] ?? '',
            collectionName: widget.collectionName,
            documentName: flashcards[currentIndex]['docId'] ?? '',
            onCardUpdated: () {
              setState(() {
                fetchFlashcards();
              });
            },
          ),
        ),
      );
    } else if (value == 'Add New Card') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewCard(
            collectionName: widget.collectionName,
            onCardAdded: () {
              setState(() {
                fetchFlashcards();
              });
            },
          ),
        ),
      );
    } else if (value == 'Delete Card') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeleteCard(
            collectionName: widget.collectionName,
            documentName: flashcards[currentIndex]['docId'] ?? '',
            onCardDeleted: () {
              setState(() {
                fetchFlashcards();
              });
            },
          ),
        ),
      );
    } else if (value == 'Delete Group') {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleMenuAction,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.settings),
                Text('Settings'),
              ],
            ),
            itemBuilder: (BuildContext context) {
              return flashcards.isEmpty
                  ? {'Add New Card', 'Delete Group'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList()
                  : {
                      'Add New Card',
                      'Update Card',
                      'Delete Card',
                      'Delete Group'
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: flashcards.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage.isNotEmpty
                        ? errorMessage
                        : 'No flashcards created yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    )
                  ),
                  const SizedBox(height: 20),
                  buildAddNewCardButton(),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 250,
                      width: 350,
                      child: FlipCard(
                        front: CardView(
                          text: flashcards[currentIndex]['front'] ?? '',
                        ),
                        back: CardView(
                          text: flashcards[currentIndex]['back'] ?? '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${currentIndex + 1} / ${flashcards.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 60, right: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 2.0, color: Colors.white),
                            left: BorderSide(width: 2.0, color: Colors.white),
                            bottom: BorderSide(width: 2.0, color: Colors.white),
                            right: BorderSide(width: 2.0, color: Colors.white),
                          ),
                        ),
                        child: IconButton(
                          iconSize: 120,
                          color: Colors.white,
                          icon: const Icon(Icons.arrow_left),
                          onPressed: showPreviousCard,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 60, left: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 2.0, color: Colors.white),
                            left: BorderSide(width: 2.0, color: Colors.white),
                            bottom: BorderSide(width: 2.0, color: Colors.white),
                            right: BorderSide(width: 2.0, color: Colors.white),
                          ),
                        ),
                        child: IconButton(
                          iconSize: 120,
                          color: Colors.white,
                          icon: const Icon(Icons.arrow_right),
                          onPressed: showNextCard,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
