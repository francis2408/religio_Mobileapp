import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lasad/widget/custom_clipper/bottom_nav_bar.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xFFEC008C), Color(0xFFDA22FF)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  bool _isLoading = false;

  internetCheck() {
    CheckInternetConnection.checkInternet().then((value) {
      if(value) {
        return null;
      } else {
        showDialogBox();
      }
    });
  }

  showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningAlertDialog(
          message: 'Please check your internet connection.',
          onOkPressed: () {
            Navigator.pop(context);
            CheckInternetConnection.checkInternet().then((value) {
              if (value) {
                return null;
              } else {
                showDialogBox();
              }
            });
          },
        );
      },
    );
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const BottomNavBarScreen();
          }));
    });
  }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("assets/images/splash.jpg"), fit: BoxFit.cover),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height * 0.07,
            ),
            Container(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: size.height * 0.1,
                    width: size.width * 0.40,
                  ),
                )
            ),
            Text(
              'Welcome to',
              style: GoogleFonts.sacramento(
                  fontSize: size.height * 0.03,
                  fontWeight: FontWeight.bold,
                  color: textColor
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'DE LA SALLE BROTHERS',
              style: GoogleFonts.heebo(
                  fontSize: size.height * 0.03,
                  fontWeight: FontWeight.bold,
                  color: textColor
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: size.height * 0.08,
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Stack(
                children: [
                  Container(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 1,
                        child: Image.asset(
                          'assets/images/lasad_logo.png',
                          height: size.height * 0.3,
                          width: size.width * 0.5,
                        ),
                      )
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.07,
            ),
            Container(
              height: size.height * 0.05,
              width: size.width * 0.4,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomLoadingButton(
                text: 'Get Started',
                size: size.height * 0.022,
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    loadDataWithDelay();
                  });
                },
                isLoading: _isLoading, // Set to true to display the loading indicator
                buttonColor: backgroundColor, // Customize the button color
                loadingIndicatorColor: Colors.white, // Customize the loading indicator color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
