import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lasad/private/screens/authentication/login.dart';
import 'package:lasad/private/screens/authentication/verification_code.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/custom_clipper/bezier_container.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  bool userNameValid = false;
  bool userEmailValid = false;
  bool userValidEmail = false;
  bool _isLoading = false;

  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

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

  void forgot(String login, email) async {
    if (userNameController.text.isNotEmpty && userNameController.text != '' &&
        emailController.text.isNotEmpty && emailController.text != '') {
      String url = '$baseUrl/forgot_password';
      user_login = login;
      user_email = email;
      Map data = {
        "params": {'login': user_login, 'email': email}
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
            context, MaterialPageRoute(builder: (context) => const VerificationCodeScreen()));

        AnimatedSnackBar.show(
            context,
            data["message"],
            Colors.green
        );
      } else {
        setState(() {
          AnimatedSnackBar.show(
              context,
              'Please enter the valid login and email ID',
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        AnimatedSnackBar.show(
            context,
            'Please enter the valid login and email ID',
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
                            'Forgot Password',
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
                            "Provide your account's email for which you want to reset your password.",
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
                                padding: const EdgeInsets.only(top: 5, bottom: 15),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Username',
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
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: inputColor
                                ),
                                child: TextFormField(
                                  controller: userNameController,
                                  keyboardType: TextInputType.text,
                                  autocorrect: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  style: GoogleFonts.breeSerif(
                                      color: Colors.black,
                                      letterSpacing: 0.2
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Your Username",
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: iconColor,
                                      size: size.height * 0.03,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    hintStyle: GoogleFonts.breeSerif(
                                      color: Colors.black87,
                                    ),
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
                                        color: enableColor,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  // check tha validation
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      userNameValid = true;
                                    } else {
                                      userNameValid = false;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              userNameValid ? Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 10, top: 8),
                                  child: const Text(
                                    "Username is required",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                              ) : Container(),
                              SizedBox(height: size.height * 0.01,),
                              Container(
                                padding: const EdgeInsets.only(top: 10, bottom: 15),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Email ID',
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
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: inputColor
                                ),
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  style: GoogleFonts.breeSerif(
                                      color: Colors.black,
                                      letterSpacing: 0.2
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Your Email Address",
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.mail,
                                      color: iconColor,
                                      size: size.height * 0.03,
                                    ),
                                    hintStyle: const TextStyle(
                                        color: Colors.black
                                    ),
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
                                        color: enableColor,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  // check tha validation
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      userEmailValid = true;
                                      userValidEmail = false;
                                    } else {
                                      if(val.isNotEmpty) {
                                        var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                        if(reg.hasMatch(val)) {
                                          userEmailValid = false;
                                          userValidEmail = false;
                                        } else {
                                          userValidEmail = true;
                                          userEmailValid = false;
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              userEmailValid ? Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 10, top: 8),
                                  child: const Text(
                                    'Email Address is required',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                              ) : Container(),
                              userValidEmail ? Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 10, top: 8),
                                  child: const Text(
                                    "Please enter a valid email address",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                              ) : Container(),
                              SizedBox(height: size.height * 0.03,),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.01,),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.4,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomLoadingButton(
                            text: 'Confirm',
                            size: size.height * 0.025,
                            onPressed: () {
                              if(userNameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                  forgot(
                                      userNameController.text.toString(),
                                      emailController.text.toString()
                                  );
                                });
                              } else if(userNameController.text.isNotEmpty &&
                                  emailController.text.isEmpty) {
                                setState(() {
                                  userEmailValid = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the valid email address',
                                      Colors.red
                                  );
                                });
                              } else if(userNameController.text.isEmpty &&
                                  emailController.text.isNotEmpty) {
                                setState(() {
                                  userNameValid = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the username',
                                      Colors.red
                                  );
                                });
                              } else {
                                setState(() {
                                  userEmailValid = true;
                                  userNameValid = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the username and email address',
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
