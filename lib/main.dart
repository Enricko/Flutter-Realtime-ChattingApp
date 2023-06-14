import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'Pages/ChattingPage.dart';
import 'Pages/LoginPage.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChattingApp',
      themeMode: ThemeMode.dark,
      darkTheme: Theme.of(context).copyWith(
        platform: TargetPlatform.android,
        scaffoldBackgroundColor: Color(0xFF27374D),
        // primaryColor: Color.fromRGBO(21, 181, 114, 1),
        // canvasColor: Color.fromRGBO(7, 17, 26, 1),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      debugShowCheckedModeBanner: false,
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
  bool? isLogin;
  
  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return ChattingPage();
    return isLogin == true ? ChattingPage() :LoginPage();
  }
}

