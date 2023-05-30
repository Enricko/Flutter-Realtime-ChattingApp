import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChattingApp',
          style: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.w900
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SafeArea(
        child: Container(
          child: Row(
            children: [
              MediaQuery.of(context).size.width <= 897 ? Container() :
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: 350,
                  minWidth: 350,
                ),
                child: Container(
                  color: Colors.white24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 350,
                        height: 60,
                        color: Colors.white,
                        child: Text(
                          'Profile & Settings'
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for(int x = 1;x < 10;x++)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white12,width: 1)
                                ),
                                height: 75,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(
                                          'assets/images/default.jpeg',
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enricko Putra H',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                          Text(
                                            'Enricko : Woi ${x}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 16,
                                              // fontWeight: FontWeight.w800
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 60,
                      color: Colors.white24,
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: IconButton(
                              icon: Icon(
                                Icons.attachment,
                                color: Colors.white24,
                                size: 30,
                              ),
                              onPressed: null,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              cursorColor: Colors.white30,
                              decoration: InputDecoration(
                                hintText: 'Kirim Pesan',
                                hintStyle: TextStyle(
                                  color: Colors.white
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.white
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color:Colors.white24, width: 3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:Colors.white24, width: 3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:Colors.white24, width: 3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: IconButton(
                              icon: Icon(
                                Icons.send
                              ),
                              onPressed: null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}
