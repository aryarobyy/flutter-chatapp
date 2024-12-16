import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/service/auth/auth_gate.dart';
import 'package:chat_app/service/auth/login_or_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/service/navigation_service.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/contact.dart';
import 'package:chat_app/pages/settings.dart';

Future<void> main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/login',
      routes: {
        '/auth': (BuildContext _context) => LoginOrRegister(),
        '/home': (BuildContext _context) => Home(),
        '/contact': (BuildContext _context) => Contact(),
        '/setting': (BuildContext _context) => Settings(),
      },
    );
  }
}
