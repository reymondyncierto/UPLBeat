/*

[Catindig-Cruz-Rada-Yncierto] 
UPLBeat: A Health Monitoring App
CMSC 23 Final Project 2S AY 22-23
[Section B-5L Sir Aldrin Hao] 

*/

// flutterfire configure --project=health-monitoring-system-640fb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/todo_page.dart';
import '../screens/user_details.dart';
import '../screens/login.dart';
import '../screens/EM_logs.dart';
import '../screens/admin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../screens/signup.dart';
import 'screens/scan_qr_camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create the built-in admin account
  // await createPreBuiltInAdminAccount();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => TodoListProvider())),
        ChangeNotifierProvider(create: ((context) => AuthProvider())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5A0011);
    final MaterialColor maroonSwatch = MaterialColor(
      maroonColor.value,
      const <int, Color>{
        50: maroonColor,
        100: maroonColor,
        200: maroonColor,
        300: maroonColor,
        400: maroonColor,
        500: maroonColor,
        600: maroonColor,
        700: maroonColor,
        800: maroonColor,
        900: maroonColor,
      },
    );
    return MaterialApp(
      title: 'UPLBeat',
      initialRoute: '/login',
      theme: ThemeData(
        primarySwatch: maroonSwatch,
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/todo': (context) => const TodoPage(),
        '/signup': (context) => const SignupPage(),
        '/user_details': (context) => const UserDetailsPage(),
        '/em_logs': (context) => const EMLogsPage(),
        '/admin': (context) => const AdminPage(),
        '/scanqr': (context) => const QRViewExample(),
      },
    );
  }
}
