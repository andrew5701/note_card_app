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
      ),
      home: const WidgetTree(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Flashcard> flashcards = [

    

  ];


  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 11, 77, 190)),
      body: const FlashcardGroup(),
    );
  }
}
