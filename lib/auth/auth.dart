import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streak_meter/theme/colors.dart';
import 'package:streak_meter/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;

final OutlineInputBorder borderStyle = OutlineInputBorder(
  borderSide: const BorderSide(color: Colors.grey),
  borderRadius: BorderRadius.circular(16),
);

final OutlineInputBorder focusBorderStyle = OutlineInputBorder(
  borderSide: const BorderSide(color: kWhite),
  borderRadius: BorderRadius.circular(16),
);

final OutlineInputBorder errorBorderStyle = OutlineInputBorder(
  borderSide: const BorderSide(color: kAccentRedSecondary),
  borderRadius: BorderRadius.circular(16),
);

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  // Entered User Info
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  final TextEditingController _enteredConfirmPassword = TextEditingController();

  bool _isAuthenticating = false;
  bool _isLogin = true;

  // User Image File
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please make sure you have selected an image and all credentials are valid.',
          ),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child(
              'user_images',
            )
            .child(
              '${userCredentials.user!.uid}.jpg',
            );

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set(
          {
            'uid': userCredentials.user!.uid,
            'username': _enteredUsername,
            'email': _enteredEmail,
            'image': imageUrl,
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Authentication failed.',
          ),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  void dispose() {
    _enteredConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_isLogin)
                  const CircleAvatar(
                    backgroundColor: kPrimary,
                    foregroundImage: AssetImage('assets/images/streak_meter.png'),
                    radius: 150,
                  ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLogin)
                        Column(
                          children: [
                            UserImagePicker(
                              onPickImage: (pickedImage) => _selectedImage = pickedImage,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      if (!_isLogin)
                        TextFormField(
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            enabledBorder: borderStyle,
                            focusedBorder: focusBorderStyle,
                            errorBorder: errorBorderStyle,
                            focusedErrorBorder: errorBorderStyle,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: false,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().length < 4 || value.trim().length > 15) {
                              return 'Please enter a valid username between 4 to 15 characters long.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredUsername = newValue!;
                          },
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: borderStyle,
                          focusedBorder: focusBorderStyle,
                          errorBorder: errorBorderStyle,
                          focusedErrorBorder: errorBorderStyle,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: borderStyle,
                          focusedBorder: focusBorderStyle,
                          errorBorder: errorBorderStyle,
                          focusedErrorBorder: errorBorderStyle,
                        ),
                        autocorrect: false,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Your password should be at least 6 characters long';
                          }

                          if (_enteredConfirmPassword.text != value.toString() && !_isLogin) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (!_isLogin)
                        TextFormField(
                          cursorColor: Colors.grey,
                          controller: _enteredConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            enabledBorder: borderStyle,
                            focusedBorder: focusBorderStyle,
                            errorBorder: errorBorderStyle,
                            focusedErrorBorder: errorBorderStyle,
                          ),
                          autocorrect: false,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Your password should be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),
                      if (_isAuthenticating)
                        const CircularProgressIndicator(
                          color: kAccentRedPrimary,
                        ),
                      if (!_isAuthenticating)
                        ElevatedButton(
                          onPressed: _submit,
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(kAccentRedPrimary),
                          ),
                          child: Text(
                            _isLogin ? 'Login' : 'Register',
                            style: GoogleFonts.poppins(
                              color: kWhite,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      if (!_isAuthenticating)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? 'Create an account' : 'I already have an account',
                            style: GoogleFonts.poppins(
                              color: kWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
