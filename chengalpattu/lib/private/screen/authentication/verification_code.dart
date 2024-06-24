import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/private/screen/authentication/set_password.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:quickalert/quickalert.dart';

import 'login.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({Key? key}) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  bool _canPop = false;
  final formKey = GlobalKey<FormState>();
  var codeController = TextEditingController();
  bool _isLoading = false;
  bool isOTP = false;

  String otp = '';

  void verificationCode(otp) async {
    if (otp.isNotEmpty && otp != null && otp != '') {
      String url = '$baseUrl/confirm_verification_code';
      Map data = {
        "params" : {
          "login": loginUserName,
          "code": otp
        }
      };
      var body = jsonEncode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        if (data["status"] == true) {
          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pushReplacement(CustomRoute(widget: const SetPasswordScreen()));
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => const SetPasswordScreen()));

          AnimatedSnackBar.material(
              data["message"],
              type: AnimatedSnackBarType.success,
              duration: const Duration(seconds: 2)
          ).show(context);
        } else {
          setState(() {
            _isLoading = false;
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: data["message"],
              confirmBtnColor: greenColor,
              width: 100.0,
            );
          });
        }
      } else {
        var massage = jsonDecode(response.body)['result'];
        setState(() {
          AnimatedSnackBar.material(
              massage["message"],
              type: AnimatedSnackBarType.warning,
              duration: const Duration(seconds: 2)
          ).show(context);
        });
      }
    } else {
      setState(() {
        AnimatedSnackBar.material(
            'Please enter the verification code',
            type: AnimatedSnackBarType.warning,
            duration: const Duration(seconds: 2)
        ).show(context);
      });
    }
  }

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
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Warning',
      text: 'Please check your internet connection',
      confirmBtnColor: greenColor,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        CheckInternetConnection.checkInternet().then((value) {
          if (value) {
            return null;
          } else {
            showDialogBox();
          }
        });
      },
      width: 100.0,
    );
  }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFFF512F),
                    Color(0xFFF09819)
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * 0.08,
                    child: Container(
                      padding: EdgeInsets.only(left: size.width * 0.03),
                      child: Text(
                        'VERIFICATION CODE',
                        style: TextStyle(
                          fontSize: size.height * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * -0.065,
                    right: size.width * 0.03,
                    child: Container(
                      width: size.width * 0.6,
                      height: size.height * 0.6,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/login/verification_code.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.65,
                padding: EdgeInsets.only(left: size.width * 0.08, right: size.width * 0.08),
                decoration: const BoxDecoration(
                  color: screenBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.03,),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 50),
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Enter one time password send to Your Email ID.",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: OtpTextField(
                            numberOfFields: 5,
                            fillColor: Colors.black.withOpacity(0.1),
                            filled: true,
                            focusedBorderColor: const Color(0xFFFF512F),
                            onSubmit: (String verificationPin) {
                              if(verificationPin != null && verificationPin != '') {
                                otp = verificationPin;
                              } else {
                                isOTP = true;
                              }
                            },
                          ),
                        ),
                        isOTP ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              "OTP is required",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        ) : Container(),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          child: LoadingBtn(
                            height: 50,
                            borderRadius: 80,
                            animate: true,
                            color: const Color(0xFFFF512F),
                            width: size.width,
                            loader: Container(
                              padding: const EdgeInsets.all(10),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80.0),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            onTap: ((startLoading, stopLoading, btnState) async {
                              if(otp.isNotEmpty && otp != null && otp != '') {
                                isOTP = false;
                                if (btnState == ButtonState.idle) {
                                  startLoading();
                                  verificationCode(otp);
                                  // call your network api
                                  await Future.delayed(const Duration(seconds: 3));
                                  stopLoading();
                                }
                              } else {
                                isOTP = true;
                                AnimatedSnackBar.material(
                                    'Please fill the required fields',
                                    type: AnimatedSnackBarType.warning,
                                    duration: const Duration(seconds: 2)
                                ).show(context);
                              }
                            }),
                            child: Text(
                              "VERIFY CODE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height * 0.02,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
                            },
                            child: Text(
                              'Back to Sign in Page?',
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF512F),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
