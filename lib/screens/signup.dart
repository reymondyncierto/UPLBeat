import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:email_validator/email_validator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  //TextEditingController lastNameController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController studentNumberController = TextEditingController();

  String? emailErrorMessage;
  String? passwordErrorMessage;
  String? nameErrorMessage;
  String? collegeErrorMessage;
  String? courseErrorMessage;
  String? studentNumberErrorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    //lastNameController.dispose();
    collegeController.dispose();
    courseController.dispose();
    studentNumberController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final email = emailController.text;
      final password = passwordController.text;
      final lastName = nameController.text;
      //  final lastName = lastNameController.text;
      final college = collegeController.text;
      final course = courseController.text;
      final studentNumber = studentNumberController.text;

      try {
        // Sign up the user and get the user ID
        final userId = await authProvider.signUp(email, password);

        // Save the user data to Firestore with the UID as the document ID
        final userDocRef =
            FirebaseFirestore.instance.collection('client').doc(userId);
        await userDocRef.set({
          'email': email,
          
          // User Classification
          'userType': "user", // can be admin, monitor
          'currentStatus': "Cleared",
          
          // For Admin and EM Only
          'empNo': '',
          'position': '',
          'homeUnit':'',
          // For Admin Only
          'requests': [],

          // Entrance Monitor
          'student_logs': [],

          //
          'name': lastName,
          //  'lastName': lastName,
          'college': college,
          'course': course,
          'studentNumber': studentNumber,
          'isGoogleUser': false, // 'true' if the user signed up using Google
          'isNewUser': true,
          'preExistingIllness': {
            'Hypertension': false,
            'Diabetes': false,
            'Tuberculosis': false,
            'Cancer': false,
            'Kidney Disease': false,
            'Cardiac Disease': false,
            'Autoimmune Disease': false,
            'Asthma': false,
            'Allergies': [],
          },
          'entries': []
        });

        // Navigate back to the login page
        Navigator.pushReplacementNamed(context, '/login');
      } catch (error) {
        // Handle the error
        String errorMessage = 'An unknown error occurred';

        if (error is FirebaseAuthException) {
          if (error.code == 'email-already-in-use') {
            errorMessage = 'The email address is already registered';
          }
        }

        // Display the error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = TextFormField(
      controller: emailController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: emailErrorMessage,
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: validateEmail,
      onChanged: (_) {
        setState(() {
          emailErrorMessage = null;
        });
      },
    );

    final password = TextFormField(
      controller: passwordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: passwordErrorMessage,
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: validatePassword,
      onChanged: (_) {
        setState(() {
          passwordErrorMessage = null;
        });
      },
    );

    final name = TextFormField(
      controller: nameController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Name',
        prefixIcon: const Icon(Icons.person),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: nameErrorMessage,
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: (value) => validateName(value, 'Last Name'),
      onChanged: (_) {
        setState(() {
          nameErrorMessage = null;
        });
      },
    );

    final college = TextFormField(
      controller: collegeController,
      decoration: InputDecoration(
        labelText: 'College',
        prefixIcon: const Icon(Icons.location_city),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: collegeErrorMessage,
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );

    final course = TextFormField(
      controller: courseController,
      decoration: InputDecoration(
        labelText: 'Course',
        prefixIcon: const Icon(Icons.book),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: courseErrorMessage,
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );

    final studentNumber = TextFormField(
      controller: studentNumberController,
      decoration: InputDecoration(
        labelText: 'Student Number',
        prefixIcon: const Icon(Icons.school),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: studentNumberErrorMessage,
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );

    final SignupButton = ElevatedButton(
      onPressed: signUp,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Sign up',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5A0011), // Maroon
                Color(0xFFD4AF37), // Gold
                Color(0xFF228B22),
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'images/logo.png',
                width: 175,
                height: 175,
              ),
              const SizedBox(height: 40),
              const Text(
                "Embrace a healthier you with us!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                    child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: name,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: studentNumber,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: course,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: college,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: email,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: password,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 48,
                        width: double.infinity,
                        child: SignupButton,
                      ),
                      const SizedBox(height: 25),
                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign In here!",
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
