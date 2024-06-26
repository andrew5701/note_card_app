import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

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
  File? _frontImage;
  File? _backImage;

  @override
  void dispose() {
    _frontcontroller.dispose();
    _backcontroller.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser;
  late final String? userId;

  Future<void> _pickImageFromGallery(bool isFront) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog(e);
    }
  }

  Future<void> _pickImageFromCamera(bool isFront) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog(e);
    }
  }

  Future<void> _showErrorDialog(dynamic e) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error picking image: $e'),
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

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      String fileName = Path.basename(image.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('uploads/${user!.uid}/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.whenComplete(() => null);
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorDialog(e);
      return null;
    }
  }

  Future<void> _addCard() async {
    if ((_frontcontroller.text.isEmpty || _backcontroller.text.isEmpty) && (_frontImage == null || _backImage == null)) {
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
    String? frontImageUrl;
    String? backImageUrl;

    if (_frontImage != null) {
      frontImageUrl = await _uploadImageToStorage(_frontImage!);
    }

    if (_backImage != null) {
      backImageUrl = await _uploadImageToStorage(_backImage!);
    }

    FirestoreService.instance
        .collection("users")
        .doc(userId.toString())
        .collection('flashcard_groups')
        .doc(widget.collectionName.toString())
        .collection('flashcards')
        .add({
      'front': _frontcontroller.text,
      'back': _backcontroller.text,
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'createdAt': DateTime.now(),
    });

    _frontcontroller.clear();
    _backcontroller.clear();
    setState(() {
      _frontImage = null;
      _backImage = null;
    });

    widget.onCardAdded();
    Navigator.pop(context);
  }

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
                onPressed: _addCard,
                child: const Text(
                  'Add Card',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'Front Image',
                      style: TextStyle(color: Colors.white),
                    ),
                    MaterialButton(
                      color: Colors.green,
                      child: const Text(
                        'Upload Image \n from gallery',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => _pickImageFromGallery(true),
                    ),
                    MaterialButton(
                      color: Colors.green,
                      child: const Text(
                        'Upload image \n from camera',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => _pickImageFromCamera(true),
                    ),
                    _frontImage != null
                        ? Image.file(
                            _frontImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const Text('No image selected')
                  ],
                ),
                // Column for Back
                Column(
                  children: [
                    const Text(
                      'Back Image',
                      style: TextStyle(color: Colors.white),
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        'Upload Image \n from gallery',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => _pickImageFromGallery(false),
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        'Upload image \n from camera',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => _pickImageFromCamera(false),
                    ),
                    _backImage != null
                        ? Image.file(
                            _backImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const Text('No image selected')
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
