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

  String validateEmail(String email) {
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(email)) {
    return 'Please enter a valid email address.';
  }
  return 'Valid';
}



  String checkPasswordStrength(String password) {
  if (password.length < 8) {
    return 'Password is too short. It must be at least 8 characters long.';
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Password must contain at least one uppercase letter.';
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Password must contain at least one lowercase letter.';
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'Password must contain at least one digit.';
  }
  if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
    return 'Password must contain at least one special character.';
  }
  return 'Strong';
}


  Future<void> signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (mounted && FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlashcardGroup()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not formatted correctly.';
          break;
        case 'wrong-password':
          errorMessage = 'The password is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'The user corresponding to the given email has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'There is no user corresponding to the given email.';
          break;
        case 'invalid-credential':
          errorMessage = 'The password is invalid for the given email, or the account does not have a password set.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Signing in with email and password is not enabled.';
          break;
        default:
          errorMessage = 'An undefined error happened: ${e.message}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error Signing In'),
          content: Text(errorMessage ?? 'An unknown error occurred.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error Signing In'),
          content: Text('An error occurred: ${e.toString()}'),
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
  String emailValidationMessage = validateEmail(emailController.text);
  if (emailValidationMessage != 'Valid') {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Email'),
        content: Text(emailValidationMessage),
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
    return;
  }

  String passwordStrengthMessage = checkPasswordStrength(passwordController.text);
  if (passwordStrengthMessage != 'Strong') {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weak Password'),
        content: Text(passwordStrengthMessage),
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
    return;
  }

  try {
    await Auth().createUserWithEmailAndPassword(
      emailController.text,
      passwordController.text,
    );

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
              primary: Colors.blue, // Used for the underline and the label text when focused
            ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue, // Color of the underline when the TextField is focused
            ),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: title == 'Password',
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
        onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: const TextStyle(
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
        isLogin ? 'Need an account? Register' : 'Already have an account? Login',
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
              child: const Text(
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
            // Text(errorMessage ?? ''),
          ],
        ),
      ),
    );
  }
}
