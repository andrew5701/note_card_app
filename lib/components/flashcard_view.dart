import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:note_card_app/card_operations/delete_card.dart';
import 'package:note_card_app/card_operations/new_card.dart';
import 'package:note_card_app/card_operations/update_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'dart:io';

class CardView extends StatelessWidget {
  final String text;
  String imagePath;
  final FlutterTts flutterTts = FlutterTts();

  CardView({super.key, required this.text, this.imagePath = ''});

  void _speak() async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    bool hasText = text.isNotEmpty;


    print(imagePath.replaceFirst('File Path:', 'File:'));

    imagePath = imagePath.replaceFirst('File Path:', 'File:');

    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: _speak,
            ),
          ),
          Center(
            child: hasText
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      if (imagePath.isNotEmpty && File(imagePath).existsSync())
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 200.0,
                              maxHeight: 200.0,
                            ),
                            child: Image.file(
                              File("File: '/Users/andrewkrasuski/Library/Developer/CoreSimulator/Devices/310C7154-5830-4373-8947-6D4A18566389/data/Containers/Data/Application/71FAED07-4E86-47DC-A81D-CAE172878107/tmp/image_picker_905BB761-95CE-498F-9E7E-50BCFEC58102-5250-000000306A95A3BA.jpg'"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  )
                : (imagePath.isNotEmpty && File(imagePath).existsSync()
                    ? Container(
                        constraints: const BoxConstraints(
                          maxWidth: 200.0,
                          maxHeight: 200.0,
                        ),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container()),
          ),
        ],
      ),
    );
  }
}



class FlashcardView extends StatefulWidget {
  final String collectionName;
  final Function refreshGroupsCallback;

  const FlashcardView({super.key, required this.collectionName, required this.refreshGroupsCallback});

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
            'frontImage': doc['frontImage'],
            'backImage': doc['backImage'],
            'docId': doc.id,
            'createdAt': doc['createdAt'],
          };
        }).toList();

        fetchedFlashcards.sort((a, b) => (a['createdAt'] as Timestamp)
            .compareTo(b['createdAt'] as Timestamp));
        setState(() {
          flashcards = fetchedFlashcards;
          if (currentIndex >= flashcards.length) {
            currentIndex = flashcards.isEmpty ? 0 : flashcards.length - 1;
          }
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade400,
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewCard(
              collectionName: widget.collectionName,
              onCardAdded: () {
                fetchFlashcards(); // Ensure this method updates the state with new data
              },
            ),
          ),
        );
      },
      child: const Text(
        'Add New Card',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
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
              fetchFlashcards();
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
              fetchFlashcards();
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
              if (flashcards.length == 1) {
                flashcards = [];
              }
              fetchFlashcards();
            },
          ),
        ),
      );
    } else if (value == 'Delete Group') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Group'),
            content: const Text('Are you sure you want to delete this Group?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  try {
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('flashcard_groups')
                        .doc(widget.collectionName)
                        .delete();

                    widget.refreshGroupsCallback();

                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error deleting document: $e");
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: PopupMenuButton<String>(
              onSelected: handleMenuAction,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.more_vert),
                  Text('Options'),
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
          ),
        ],
      ),
      body: Center(
        child: flashcards.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No flashcards created yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildAddNewCardButton(),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      height: 250,
                      width: 350,
                      child: FlipCard(
                        front: CardView(
                          text: flashcards[currentIndex]['front'] ?? '',
                          imagePath: flashcards[currentIndex]['frontImage'] ?? '',
                        ),
                        back: CardView(
                          text: flashcards[currentIndex]['back'] ?? '',
                          imagePath: flashcards[currentIndex]['backImage'] ?? '',
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
