import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late BuildContext dialogContext;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dialogContext = context; // Save reference to parent context
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5A0011), // Maroon
                  Color(0xFFD4AF37), // Gold
                  Color(0xFF228B22), // Forest green
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'images/logo.png',
                      width: 175,
                      height: 175,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Welcome back, you've been missed!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF5A0011), // Maroon
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF5A0011), // Maroon
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final authProvider = context.read<AuthProvider>();
                          final loginSuccessful = await authProvider.signIn(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          if (loginSuccessful) {
                            Navigator.pushReplacementNamed(context, '/todo');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Invalid email or password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            emailController.clear();
                            passwordController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    RichText(
                      text: TextSpan(
                        text: "Don't have an account yet? ",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up here!",
                            style: const TextStyle(
                              color:
                                  Colors.deepPurple, // Customize the color here
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacementNamed(
                                    context, '/signup');
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Google sign in button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // sign in then get the user details
                          _googleSignIn.signIn().then((value) {
                            String userName = value!.displayName!;
                            String userEmail = value.email;
                            print(userName);
                            print(userEmail);
                            // save user in the authentification provider which requires email and password
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign In with Google',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
