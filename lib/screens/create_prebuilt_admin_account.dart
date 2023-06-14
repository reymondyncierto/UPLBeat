// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> createPreBuiltInAdminAccount() async {
//   final auth = FirebaseAuth.instance;
//   final firestore = FirebaseFirestore.instance;

//   try {
//     const adminEmail = 'admin@up.edu.ph';
//     const adminPassword = 'useruser';

//     final adminCredential = await auth.createUserWithEmailAndPassword(
//       email: adminEmail,
//       password: adminPassword,
//     );

//     final adminUserId = adminCredential.user!.uid;

//     // Save the admin data to Firestore with the UID as the document ID
//     await firestore.collection('admin').doc(adminUserId).set({
//       'email': adminEmail,
//       'userType': 'admin',
//       // Add additional admin data here if needed
//     });

//     print('Built-in admin account created successfully!');
//   } catch (error) {
//     print('Error creating built-in admin account: $error');
//   }
// }
