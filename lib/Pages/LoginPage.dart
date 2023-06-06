import 'package:flutter/material.dart';

import '../Settings/Auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ChattingApp By Enricko',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDDE6ED),
                  fontSize: 36,
                  fontWeight: FontWeight.w900
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                'LOGIN WITH',
                style: TextStyle(
                  color: Color(0xFFDDE6ED),
                  fontSize: 24,
                  fontWeight: FontWeight.w600
                ),
              ),
              Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Color(0xFF526D82),
                  borderRadius: BorderRadius.circular(5)
                ),
                padding: EdgeInsets.all(5),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: (){
                      FirebaseAuthService().signInWithGoogle(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Google.svg.png',
                          width: 50,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Google",
                          style: TextStyle(
                            color: Color(0xFFDDE6ED),
                            fontSize: 18,
                            // fontWeight: FontWeight.w900
                          )
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}