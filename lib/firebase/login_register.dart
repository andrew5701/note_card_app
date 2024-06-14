import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_card_app/auth.dart';
import 'package:note_card_app/components/flashcard_groups.dart';
import 'package:note_card_app/firebase/firestore_instance.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (mounted && FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlashcardGroup()),
        );
      } 
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Signing In'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          emailController.text, passwordController.text);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService.instance
            .collection('users')
            .doc(user.uid)
            .set({});
      }

      if (mounted && FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlashcardGroup()),
        );
      } 
    } catch (e) {
       showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  Widget _title() {
    return Text(isLogin ? 'Login Page' : 'Register Page');
  }

  Widget _entryField(String title, TextEditingController controller) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors
                  .blue, // Used for the underline and the label text when focused
            ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .blue), // Color of the underline when the TextField is focused
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: title == 'Password' ? true : false,
        decoration: InputDecoration(
          labelText: title,
          fillColor: Colors.white,
          filled: true,
        ),
        cursorColor: Colors.blue,
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade400,
        ),
        onPressed: isLogin
            ? signInWithEmailAndPassword
            : createUserWithEmailAndPassword,
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _loginOrRegister() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin
            ? 'Need an account? Register'
            : 'Already have an account? Login',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 170.0),
              child: Text(
                "FlashCraft",
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 1.0),
              child: _entryField('Email', emailController),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: _entryField('Password', passwordController),
            ),
            _submitButton(),
            _loginOrRegister(),
            Text(errorMessage ?? ''),
          ],
        ),
      ),
    );
  }
}
