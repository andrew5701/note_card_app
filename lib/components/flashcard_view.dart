import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:note_card_app/card_operations/new_card.dart';

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
          child: Text(text),
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
  List<Map<String, String>> flashcards = [];
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
          .collection(widget.collectionName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'No flashcards found.';
        });
      } else {
        List<Map<String, String>> fetchedFlashcards = querySnapshot.docs.map((doc) {
          return {
            'front': doc['front'] as String,
            'back': doc['back'] as String,
          };
        }).toList();
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
      onPressed: () {
        // Navigate to add new card screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewCard(
              collectionName: widget.collectionName,
            ),
          ),
        );
      },
      child: const Text('Add New Card'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Flashcard View'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: showPreviousCard,
                      ),
                      buildAddNewCardButton(),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: showNextCard,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
