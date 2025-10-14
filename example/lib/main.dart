import 'package:flutter/material.dart';
import 'package:ff_chat/ff_chat.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'chat_messages',
    'Chat Messages',
    description: 'Notification channel for chat messages',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure FlutterFire with the command 'Flutterfire configure' and then uncomment the code below.
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //For Notifications.
  await initializeNotifications();
   await setupFCM(
    currentUserId: 'user2',
    vapidKey:
        'BDjklMFCrOwY92Ra6ykDqxJh8Teca9vyF41hAOnNt82D3KuUNv72cz07Vr-meHLVLGPmpkQwhjZHnnWQhNNVHV8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FF Chat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatScreen(
        currentUserId: 'user2',
        receiverId: 'user1',
        receiverEmail: 'user1@gmail.com',
      ),
    );
  }
}
