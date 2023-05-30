import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';

import 'Pages/ChattingPage.dart';
import 'Pages/LoginPage.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        scaffoldBackgroundColor: Color.fromRGBO(7, 17, 26, 1),
        primaryColor: Color.fromRGBO(21, 181, 114, 1),
        canvasColor: Color.fromRGBO(7, 17, 26, 1),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
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

