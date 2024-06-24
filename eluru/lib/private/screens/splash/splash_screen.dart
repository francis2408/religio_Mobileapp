import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eluru/private/screens/authentication/login.dart';
import 'package:eluru/widget/theme_color/theme_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3),
            ()=> Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
            const LoginScreen()
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                first,
                first,
              ]
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Image.asset(
                  "assets/images/eluru.png",
                  height: size.height * 0.5,
                  width: size.width * 0.5
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor:  AlwaysStoppedAnimation<Color>(textColor),
                ),
                SizedBox(height: size.height * 0.02,),
                Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: size.height * 0.02,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
