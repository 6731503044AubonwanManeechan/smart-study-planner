import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/app_language.dart';
import 'screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

// 🔥 notification
import 'services/notification_service.dart';

// 🔥 workmanager
import 'package:workmanager/workmanager.dart';
import 'services/notification_worker.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotification() async {
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const settings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settings);

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // 🔥 permission Android 13+
  await androidPlugin?.requestNotificationsPermission();

  // 🔥 channel (สำคัญมาก)
  const channel = AndroidNotificationChannel(
    'channel_id',
    'Task Notifications',
    importance: Importance.max,
  );

  await androidPlugin?.createNotificationChannel(channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();

  await initNotification();
  await NotificationService.initFCM();

  // 🔥 WORKMANAGER INIT
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // 🔥 ทำงาน background ทุก 15 นาที
  Workmanager().registerPeriodicTask(
    "task-check",
    "checkTasks",
    frequency: const Duration(minutes: 15),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppLanguage()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<AppLanguage>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Study Planner',

      themeMode: themeProvider.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFECECEC),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      locale: languageProvider.locale,

      supportedLocales: const [
        Locale('en'),
        Locale('th'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const AuthWrapper(),
    );
  }
}

/// 🔥 login checker
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}