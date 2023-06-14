import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class createDrawer extends StatelessWidget {
  const createDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String?> _getUserType() async {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.getCurrentUser();
      final currentUserDoc =
          FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

      final snapshot = await currentUserDoc.get();
      final data = snapshot.data();
      final userType = data?['userType'] as String?;
      print(userType);
      return userType;
    }

    const header = DrawerHeader(
      decoration: BoxDecoration(
        color: Color(0xFF5A0011), // Maroon
      ),
      child: Center(
        child: Icon(
          Icons.medical_information_outlined,
          size: 75.0,
          color: Colors.white,
        ),
      ),
    );
    final homeTile = ListTile(
      title: const Text('Home'),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/todo");
        context.watch<AuthProvider>().fetchAuthentication();
      },
    );

    final emTile = ListTile(
      title: const Text("Logs Monitoring"),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/em_logs");
      },
    );

    final userTile = ListTile(
      title: const Text("Manage Users"),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/admin");
      },
    );

    final scanqrTile = ListTile(
      title: const Text("Scan QR"),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/scanqr");
      },
    );

    final logout = ListTile(
        title: const Text('Logout'),
        onTap: () {
          context.read<AuthProvider>().signOut();
          Navigator.pushReplacementNamed(context, '/login');
        });

    return FutureBuilder<String?>(
      future: _getUserType(),
      builder: (context, snapshot) {
        final userType = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the data, you can show a loading indicator or placeholder
          return const CircularProgressIndicator();
        } else {
          // Once the data is available, you can display it in the drawer
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                header,
                homeTile,
                if (userType == 'em') emTile,
                if (userType == 'em') scanqrTile,
                if (userType == 'admin') userTile,
                logout,
              ],
            ),
          );
        }
      },
    );
  }
}
