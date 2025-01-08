import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  late final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  CloudinaryObject.fromCloudName(cloudName: cloudName);

  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );

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
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
