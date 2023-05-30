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
                'LOGIN WITH',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 32,
                  fontWeight: FontWeight.w900
                ),
              ),
              Container(
                width: 150,
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
                            color: Colors.white70,
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