import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedSnackBar {
  static void show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AnimatedSnackBarContent(message: message, alertColor: color,),
      ),
    );
  }
}

class AnimatedSnackBarContent extends StatefulWidget {
  final String message;
  final Color alertColor;

  const AnimatedSnackBarContent({super.key, required this.message, required this.alertColor});

  @override
  State<AnimatedSnackBarContent> createState() => _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 2) + const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.reverse().whenComplete(() {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_animation),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.alertColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.message,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
