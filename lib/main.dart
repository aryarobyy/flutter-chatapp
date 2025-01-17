import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/pages/auth/auth.dart';
import 'package:chat_app/pages/loading_page.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!Firebase.apps.isEmpty) {
    print("Firebase already initialized in background handler");
    return;
  }
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'chat_channel',
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      category: NotificationCategory.Message,
      notificationLayout: NotificationLayout.Messaging,
      payload: message.data.map((key, value) => MapEntry(key, value.toString())),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatService>(
          create: (_) => ChatService(),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const InitializationScreen(),
      ),
    );
  }
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
    CloudinaryObject.fromCloudName(cloudName: cloudName);

    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );

    await NotificationService.initializeNotification();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    Provider.debugCheckInvalidValueType = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        return const Auth();
      },
    );
  }
}
