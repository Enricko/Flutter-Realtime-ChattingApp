import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';

import 'Pages/ChattingPage.dart';
import 'Pages/LoginPage.dart';

void main() {
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
  final int sideBarWidth = 350;
  @override
  Widget build(BuildContext context) {
    // return ChattingPage();
    return LoginPage();
  }
}

