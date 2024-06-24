import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          title: const Text('About'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF512F),
                      Color(0xFFF09819)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
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
                        "assets/images/chengai.png",
                        height: 250.0,
                        width: 200.0,
                      ),
                      Text(
                        'Diocese of Chingleput v$curentVersion',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(
                          fontSize: size.height * 0.023,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02,),
                      GestureDetector(
                        onTap: () {
                          webAction('https://www.boscosofttech.com/about');
                        },
                        child: Text(
                          "© ${DateTime.now().year}. Powered by Boscosoft Technologies",
                          style: GoogleFonts.robotoSlab(
                            fontSize: size.height * 0.02,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
