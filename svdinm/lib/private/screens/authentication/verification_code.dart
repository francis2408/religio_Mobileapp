import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:svdinm/widget/common/common.dart';
import 'package:svdinm/widget/common/internet_connection_checker.dart';
import 'package:svdinm/widget/common/snackbar.dart';
import 'package:svdinm/widget/custom_clipper/bezier_container.dart';
import 'package:svdinm/widget/theme_color/theme_color.dart';
import 'package:svdinm/widget/widget.dart';

import 'login.dart';
import 'set_password.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final formKey = GlobalKey<FormState>();
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  final int length = 5;
  bool  isOTP = false;
  bool _isLoading = false;
  String otp = '';

  void updateOTPValue() {
    setState(() {
      otp = _controllers
          .map<String>((controller) => controller.text)
          .join();
    });
  }

  void verificationCode(otp) async {
    if (otp.isNotEmpty && otp != null && otp != '') {
      String url = '$baseUrl/confirm_verification_code';
      Map data = {
        "params": {'login': userLogin, 'code': otp}
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
        if (data["status"] == true) {
          setState(() {
            _isLoading = false;
            Navigator.of(context).pushReplacement(CustomRoute(widget: const SetPasswordScreen()));
            AnimatedSnackBar.show(
                context,
                data["message"],
                Colors.green
            );
          });
        } else {
          setState(() {
            _isLoading = false;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorAlertDialog(
                  message: data['message'],
                  onOkPressed: () async {
                    Navigator.pop(context);
                  },
                );
              },
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorAlertDialog(
                message: data['message'],
                onOkPressed: () async {
                  Navigator.pop(context);
                },
              );
            },
          );
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        AnimatedSnackBar.show(
            context,
            'Please enter the verification code',
            Colors.red
        );
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
    // Check the internet connection
    // internetCheck();
    super.initState();
    _focusNodes = List.generate(length, (index) => FocusNode());
    _controllers = List.generate(
      length,
          (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _focusNodes.forEach((node) => node.dispose());
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
          backgroundColor: screenColor,
          body: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: -size.height * 0.18,
                      right: -size.width * 0.4,
                      child: const BezierContainer()),
                  Positioned(
                      bottom: -size.height * 0.2,
                      left: -size.width * 0.6,
                      child: const BeziersContainer()),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.topLeft,
                            child: Image.asset(
                              'assets/images/svdinm.png',
                              height: size.height * 0.28,
                              width: size.width * 0.28,
                            )
                        ),
                        Transform.translate(
                          offset: Offset(0, -size.height / 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'Society of',
                                style: GoogleFonts.portLligatSans(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: size.height * 0.028,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' Divine Word ',
                                    style: TextStyle(color: textColor, fontSize: size.height * 0.028, fontWeight: FontWeight.w700,),
                                  ),
                                ]),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -size.height / 25),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'Indian',
                                style: GoogleFonts.portLligatSans(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: size.height * 0.023,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' Mumbai ',
                                    style: TextStyle(color: Colors.black, fontSize: size.height * 0.023, fontWeight: FontWeight.w700,),
                                  ),
                                  TextSpan(
                                    text: 'Province',
                                    style: TextStyle(color: Colors.black, fontSize: size.height * 0.023, fontWeight: FontWeight.w700,),
                                  ),
                                ]),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Verification Code',
                            style: GoogleFonts.portLligatSans(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: size.height * 0.025,
                              fontWeight: FontWeight.w700,
                              color: textHeadColor,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(length, (index) {
                                    return Container(
                                      width: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: inputColor,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: containerShadow.withOpacity(0.7),
                                            spreadRadius: 0.3,
                                            blurRadius: 3,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                      child: TextFormField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        style: const TextStyle(fontSize: 20),
                                        decoration: InputDecoration(
                                          counterText: '',
                                          contentPadding: EdgeInsets.zero,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: disableColor,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: disableColor,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty && index < length - 1) {
                                              _focusNodes[index].unfocus();
                                              _focusNodes[index + 1].requestFocus();
                                              isOTP = false;
                                            } else {
                                              isOTP = false;
                                            }
                                            updateOTPValue();
                                          },
                                      ),
                                    );
                                  }),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomLoadingButton(
                            text: 'Confirm',
                            size: size.height * 0.025,
                            onPressed: () {
                              if (otp.isNotEmpty && otp != null && otp != '') {
                                setState(() {
                                  _isLoading = true;
                                  verificationCode(otp);
                                });
                              } else {
                                setState(() {
                                  isOTP = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please fill the required fields',
                                      Colors.red
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
                                  color: textHeadColor,
                                ),
                              )
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
