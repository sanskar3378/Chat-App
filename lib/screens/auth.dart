import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredusername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  final _form = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) return;

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpeg');

        await storageRef.putFile(_selectedImage!);
        //this command gives us a url that we can use later to show the profile picture of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredusername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication Failed'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      // backgroundColor: brightness == Brightness.dark
      //     ? ThemeData.dark().colorScheme.surface
      //     : Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(brightness == Brightness.dark
                  ? 'https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-b9db2.appspot.com/o/login_page%2Fwhatsapp-dark-theme.jpeg?alt=media&token=68211f9c-ba19-416a-9ece-58e98f595d0d'
                  : 'https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-b9db2.appspot.com/o/login_page%2Fwhatsapp-light-theme.jpg?alt=media&token=f199168d-b112-462d-9a92-2123d9715d45'),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  width: 200,
                  child: Image.asset('assets/images/chat app logo.png',
                      height: 100),
                ),
                const Text(
                  'Login to WhatsApp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              userImagePicker(
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Enter a valid email address';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'username',
                                ),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter atleast 4 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredusername = value!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              //this parameter hides the entered characters
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be atleast 6 characters long';
                                }

                                return null;
                              },
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(height: 12),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                              ),
                            if (!_isAuthenticating)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'Already have an account'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
