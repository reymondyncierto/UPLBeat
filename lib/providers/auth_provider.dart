import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/firebase_auth_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> uStream;
  User? userObj;

  AuthProvider() {
    authService = FirebaseAuthAPI();
    fetchAuthentication();
  }

  Stream<User?> get userStream => uStream;

  void fetchAuthentication() {
    uStream = authService.getUser();

    notifyListeners();
  }

  Future<String> signUp(String email, String password) async {
    try {
      // Create the user account using Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the UID of the newly created user
      String userId = userCredential.user!.uid;

      // Return the UID
      return userId;
    } catch (error) {
      // Handle any errors that occurred during sign up
      print('Sign up error: $error');
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      // Sign in with email and password using Firebase authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true; // Sign in successful
    } catch (error) {
      print(error);
      return false; // Sign in failed
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<bool> isNewUser(String uid) async {
    try {
      final userDoc = await getUserDocument(uid);

      if (userDoc.exists) {
        final userData = userDoc.data();
        final isNewUser = userData?['isNewUser'] ?? false;
        return isNewUser == true;
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> updateIsNewUser(String userId, bool isNewUser) async {
    try {
      // Update the isNewUser field in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isNewUser': isNewUser});
    } catch (error) {
      print(error);
    }
  }
}
