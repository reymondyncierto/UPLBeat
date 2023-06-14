import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class createDrawer extends StatelessWidget {
  const createDrawer({Key? key});

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

    final header = DrawerHeader(
      decoration: BoxDecoration(
        color: Color(0xFF5A0011), // Maroon
      ),
      child: Center(
        child: Image.asset(
          'images/logo.png', // Replace with the path to your image file
          width: 150.0,
          height: 150.0,
        ),
      ),
    );

    final homeTile = ListTile(
      leading: Icon(Icons.home), // Customize leading icon
      title: const Text('Home'),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/todo");
        context.watch<AuthProvider>().fetchAuthentication();
      },
    );

    final emTile = ListTile(
      leading: Icon(Icons.monitor), // Customize leading icon
      title: const Text("Logs Monitoring"),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/em_logs");
      },
    );

    final userTile = ListTile(
      leading: Icon(Icons.people), // Customize leading icon
      title: const Text("Manage Users"),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/admin");
      },
    );

    final scanqrTile = ListTile(
      leading: Icon(Icons.qr_code), // Customize leading icon
      title: const Text("Scan QR"),
      onTap: () {
        Navigator.pushReplacementNamed(context, "/scanqr");
      },
    );

    final logout = ListTile(
      leading: Icon(Icons.logout), // Customize leading icon
      title: const Text('Logout'),
      onTap: () {
        context.read<AuthProvider>().signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
    );

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
                ListTileTheme(
                  selectedColor: Colors.blue, // Customize selected tile color
                  child: homeTile,
                ),
                if (userType == 'em') ListTileTheme(
                  selectedColor: Colors.blue,
                  child: emTile,
                ),
                if (userType == 'em') ListTileTheme(
                  selectedColor: Colors.blue,
                  child: scanqrTile,
                ),
                if (userType == 'admin') ListTileTheme(
                  selectedColor: Colors.blue,
                  child: userTile,
                ),
                ListTileTheme(
                  selectedColor: Colors.blue,
                  child: logout,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
