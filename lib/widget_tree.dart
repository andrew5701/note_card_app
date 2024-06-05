import 'package:flutter/material.dart';
import 'package:note_card_app/auth.dart';
import 'package:note_card_app/components/flashcard_groups.dart';
import 'package:note_card_app/firebase/home_page.dart';
import 'package:note_card_app/firebase/login_register.dart';


class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().userChanges,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return FlashcardGroup();
        } else {
          return const LoginPage();
        }
        
      },

    );
  }
}