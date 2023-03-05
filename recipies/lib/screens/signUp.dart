import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Your Name',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter Your Email',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter Your Password',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'ReEnter Your Password',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    var name = nameController.text.trim();
                    var email = emailController.text.trim();
                    var password = passwordController.text.trim();
                    var confirmPass = confirmController.text.trim();

                    if (name.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        confirmPass.isEmpty) {
                      // display toast error

                      Fluttertoast.showToast(msg: 'Please complete all the fields');
                      return;
                    }

                    if (password.length < 6) {
                      // display toast error
                      Fluttertoast.showToast(
                          msg:
                              'Poor Password, you must use at least 6 characters');

                      return;
                    }

                    if (password != confirmPass) {
                      
                      Fluttertoast.showToast(msg: 'Passwords do not match');

                      return;
                    }

                    // ask for firebase authentication

                    ProgressDialog progressDialog = ProgressDialog(
                      context,
                      title: const Text('Signing Up'),
                      message: const Text('Please wait'),
                    );

                    progressDialog.show();
                    try {
                      FirebaseAuth auth = FirebaseAuth.instance;

                      UserCredential userCredential =
                          await auth.createUserWithEmailAndPassword(
                              email: email, password: password);

                      if (userCredential.user != null) {
                        // store user information in Firestore database

                        FirebaseFirestore firestore =
                            FirebaseFirestore.instance;

                        String userId = userCredential.user!.uid;

                        firestore.collection('users').doc(userId).set({
                          'userId': userId,
                          'name': name,
                          'email': email,
                          'password': password,
                        });

                        Fluttertoast.showToast(msg: 'Success');

                        Navigator.of(context).pop();
                      } else {
                        Fluttertoast.showToast(msg: 'Failed');
                      }

                      progressDialog.dismiss();
                    } on FirebaseAuthException catch (e) {
                      progressDialog.dismiss();
                      if (e.code == 'email-already-in-use') {
                        Fluttertoast.showToast(msg: 'Email is already in Use');
                      } else if (e.code == 'weak-password') {
                        Fluttertoast.showToast(msg: 'Password is weak');
                      }
                    } catch (e) {
                      progressDialog.dismiss();
                      Fluttertoast.showToast(msg: 'Something went wrong');
                    }
                  },
                  child: const Text('Register')),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
