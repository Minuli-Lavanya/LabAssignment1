import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:recipies/screens/signUp.dart';
import 'package:recipies/screens/home.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your Email',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter the Password',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  var email = emailController.text.trim();
                  var password = passwordController.text.trim();
                  if (email.isEmpty || password.isEmpty) {
                    // show error toast
                    Fluttertoast.showToast(msg: 'Please complete all the fields');
                    return;
                  }

                  // request to firebase auth

                  ProgressDialog progressDialog = ProgressDialog(
                    context,
                    title: const Text('Logging In'),
                    message: const Text('Please wait'),
                  );

                  progressDialog.show();

                  try {
                    FirebaseAuth auth = FirebaseAuth.instance;

                    UserCredential userCredential =
                        await auth.signInWithEmailAndPassword(
                            email: email, password: password);

                    if (userCredential.user != null) {
                      progressDialog.dismiss();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return const Home();
                      }));
                    }
                  } on FirebaseAuthException catch (e) {
                    progressDialog.dismiss();

                    if (e.code == 'user-not-found') {
                      Fluttertoast.showToast(msg: 'No users found');
                    } else if (e.code == 'wrong-password') {
                      Fluttertoast.showToast(msg: 'Password incorrect');
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'There was an issue.');
                    progressDialog.dismiss();
                  }
                },
                child: const Text('Login')),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Currently Unregistered'),
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SignUpScreen();
                      }));
                    },
                    child: const Text('Sign up now')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
