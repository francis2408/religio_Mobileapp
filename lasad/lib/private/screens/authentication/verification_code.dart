import 'dart:convert';

import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lasad/private/screens/authentication/login.dart';
import 'package:lasad/private/screens/authentication/set_password.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/custom_clipper/bezier_container.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final formKey = GlobalKey<FormState>();
  var codeController = TextEditingController();
  bool  isOTP = false;
  bool _isLoading = false;

  String otp = '';

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


  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    super.initState();
  }

  void verificationCode(otp) async {
    if (otp.isNotEmpty && otp != null && otp != '') {
      String url = '$baseUrl/confirm_verification_code';
      Map data = {
        "params": {'login': user_login, 'code': otp}
      };
      var body = json.encode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const SetPasswordScreen()));
        AnimatedSnackBar.show(
            context,
            data["message"],
            Colors.green
        );
      } else {
        setState(() {
          AnimatedSnackBar.show(
              context,
              data["message"],
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        AnimatedSnackBar.show(
            context,
            'Please enter the verification code',
            Colors.red
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
          backgroundColor: screenBackgroundColor,
          body: SizedBox(
            height: size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: -size.height * 0.18,
                    right: -size.width * 0.4,
                    child: const BezierContainer()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.topLeft,
                            child: Image.asset(
                              'assets/images/lasad_logo.png',
                              height: size.height * 0.25,
                              width: size.width * 0.25,
                            )
                        ),
                        Transform.translate(
                          offset: Offset(0, -size.height / 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'DE LA',
                                style: GoogleFonts.portLligatSans(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF20BDFF),
                                ),
                                children: const [
                                  TextSpan(
                                    text: ' SALLE ',
                                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w700,),
                                  ),
                                  TextSpan(
                                    text: 'BROTHERS',
                                    style: TextStyle(color: Color(0xFF20BDFF), fontSize: 25, fontWeight: FontWeight.w700,),
                                  ),
                                ]),
                          ),
                        ),
                        // SizedBox(height: size.height * 0.05),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Verification Code',
                            style: GoogleFonts.portLligatSans(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Enter a one-time password and send it to your email ID.",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.05,),
                              Container(
                                padding: const EdgeInsets.only(left: 20,top: 5),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'OTP',
                                      style: GoogleFonts.signika(
                                        fontSize: size.height * 0.021,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.02,),
                                    Text('*', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: OtpTextField(
                                  numberOfFields: 5,
                                  fillColor: Colors.black.withOpacity(0.1),
                                  filled: true,
                                  focusedBorderColor: backgroundColor,
                                  onSubmit: (String verificationPin) {
                                    if(verificationPin != null && verificationPin != '') {
                                      otp = verificationPin;
                                      isOTP = false;
                                    } else {
                                      setState(() {
                                        isOTP = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                              isOTP ? Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 60, top: 8),
                                  child: const Text(
                                    "OTP is required",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                              ) : Container(),
                              SizedBox(height: size.height * 0.05,),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02,),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.4,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomLoadingButton(
                            text: 'Verify Code',
                            size: size.height * 0.025,
                            onPressed: () {
                              if(otp.isNotEmpty && otp != null && otp != '') {
                                setState(() async {
                                  isOTP = false;
                                  _isLoading = true;
                                  verificationCode(otp);
                                });
                              } else {
                                setState(() {
                                  isOTP = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please fill the required fields',
                                      Colors.green
                                  );
                                });
                              }
                            },
                            isLoading: _isLoading, // Set to true to display the loading indicator
                            buttonColor: backgroundColor, // Customize the button color
                            loadingIndicatorColor: Colors.white, // Customize the loading indicator color
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                              },
                              child: Text(
                                'Back to Sign in Page ?',
                                style: TextStyle(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}