import 'package:flutter/material.dart';

// Library imports
import 'dart:io';

// Package imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// Firebase SDK imports
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget imports
import 'package:chat_app/widgets/user_image_picker.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
const uuid = Uuid();

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Rendering parameters
  bool _isLogin = true;

  // Credential parameters
  String _enteredEmail = '';
  String _eneteredPassword = '';
  String _enteredUsername = '';

  // Image parameters
  File? _selectedImage;
  bool _isAuthenticating = false;

  Future<void> _submit() async {
    bool isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      // show error message
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        // Log users in
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _enteredEmail, password: _eneteredPassword);
      } else {
        // Sign users up
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _eneteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(userCredentials.user!.uid)
            .child("${uuid.v4()}.jpg");

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication failed."),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 256,
                margin: const EdgeInsets.only(
                  top: 32,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter at least 4 characters';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredUsername = newValue!;
                              },
                            ),
                          TextFormField(
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (value) {
                              if (value == null) {
                                return "Please enter a password";
                              }
                              if (value.trim().length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _eneteredPassword = newValue!;
                            },
                          ),
                          const SizedBox(height: 16),
                          !_isAuthenticating
                              ? ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: Text(_isLogin ? "Sign In" : "Sign Up"),
                                )
                              : const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? "Create an account"
                                    : "I already have an account",
                              ),
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
    );
  }
}
