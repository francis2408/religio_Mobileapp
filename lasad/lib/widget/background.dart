import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: -60,
            child: Image.asset(
              "assets/images/background/background.png",
              width: size.width,
            ),
          ),
          Positioned(
            top: -450,
            right: 130,
            child: Image.asset(
              "assets/images/background/light_1.png",
              width: size.width,
            ),
          ),
          Positioned(
            top: -480,
            right: 20,
            child: Image.asset(
              "assets/images/background/light_2.png",
              width: size.width,
            ),
          ),
          Positioned(
            top: -90,
            left: 150,
            child: Image.asset(
              "assets/images/background/clock.png",
              width: size.width,
            ),
          ),
          child
        ],
      ),
    );
  }
}