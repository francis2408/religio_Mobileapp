import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBackgroundColor,
        title: const Text('About'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/scb.png",
                      height: 250.0,
                      width: 130.0,
                    ),
                    Text(
                      'St. Charles Borromeo Eastern Province v$curentVersion',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        fontSize: size.height * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02,),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: '© ${DateTime.now().year}.',
                          style: GoogleFonts.robotoSlab(
                            fontSize: size.height * 0.02,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' Powered by ',
                              style: GoogleFonts.robotoSlab(
                                fontSize: size.height * 0.02,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Boscosoft Technologies',
                              style: GoogleFonts.robotoSlab(
                                fontSize: size.height * 0.02,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                                decorationThickness: 2.0,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  webAction('https://www.boscosofttech.com/about');
                                },
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "assets/images/bosco_logo.png",
                    height: 100.0,
                    width: 100.0,
                  ),
                  Image.asset(
                    "assets/images/cristo_logo.png",
                    height: 100.0,
                    width: 100.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}