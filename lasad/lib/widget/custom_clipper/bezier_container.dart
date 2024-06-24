import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lasad/widget/custom_clipper/custom_clipper.dart';

class BezierContainer extends StatelessWidget {
  const BezierContainer({Key ?key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Transform.rotate(
          angle: -pi / 3.5,
          child: ClipPath(
            clipper: ClipPainter(),
            child: Container(
              height: MediaQuery.of(context).size.height *.5,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFA5FECB), Color(0xFF20BDFF), Color(0xFF5433FF),]
                  )
              ),
            ),
          ),
        )
    );
  }
}