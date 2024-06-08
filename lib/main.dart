import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_card_app/components/flashcard.dart';
import 'package:note_card_app/components/flashcard_groups.dart';
import 'package:note_card_app/components/flashcard_view.dart';
import 'package:note_card_app/widget_tree.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note Card App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade800,
        fontFamily: 'Roboto',
      ),
      home: const WidgetTree(),
    );
  }
}


