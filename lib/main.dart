import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/service/auth/auth_gate.dart';
import 'package:chat_app/service/auth/login_or_register.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/service/navigation_service.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/contact_page.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

void setupLocator() {
  GetIt.instance.registerLazySingleton<NavigationService>(() => NavigationService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StorageService>(
          create: (_) => StorageService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = GetIt.instance<NavigationService>();

    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      navigatorKey: navigationService.navigatorKey, // Use navigatorKey from GetIt instance
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
