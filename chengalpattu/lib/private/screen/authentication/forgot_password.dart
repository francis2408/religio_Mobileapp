import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/private/screen/authentication/set_password.dart';
import 'package:chengai/private/screen/authentication/verification_code.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_btn/loading_btn.dart';
import 'package:quickalert/quickalert.dart';

import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _canPop = false;
  final formKey = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  bool _isLoading = true;
  bool userNameValid = false;
  bool userEmailValid = false;
  bool userValidEmail = false;

  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  void forgot(String userName, email) async {
    if (userNameController.text.isNotEmpty && userNameController.text != '' &&
        emailController.text.isNotEmpty && emailController.text != '') {
      String url = '$baseUrl/forgot_password';
      loginUserName = userName;
      loginUserEmail = email;
      Map data = {
        "params":{
          "login": userName,
          "email": email
        }
      };
      var body = jsonEncode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        if (data["status"] == true) {
          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pushReplacement(CustomRoute(widget: const VerificationCodeScreen()));
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => const VerificationCodeScreen()));

          AnimatedSnackBar.material(
              data["message"],
              type: AnimatedSnackBarType.success,
              duration: const Duration(seconds: 2)
          ).show(context);
        } else {
          var message = jsonDecode(response.body)['message'];
          setState(() {
            _isLoading = false;
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: message,
              confirmBtnColor: greenColor,
              width: 100.0,
            );
          });
        }
      } else {
        setState(() {
          AnimatedSnackBar.material(
              'Please enter the valid login and email ID',
              type: AnimatedSnackBarType.warning,
              duration: const Duration(seconds: 2)
          ).show(context);
        });
      }
    } else {
      userNameValid = true;
      userEmailValid = true;
      setState(() {
        AnimatedSnackBar.material(
            'Please enter the required fields',
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
                        'FORGOT PASSWORD',
                        style: TextStyle(
                          fontSize: size.height * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * -0.11,
                    right: size.width * 0.02,
                    child: Container(
                      width: size.width * 0.7,
                      height: size.height * 0.7,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/login/forgot_password.png'),
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
                        SizedBox(height: size.height * 0.05,),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Provide your account's mail for which you want to reset your password.",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 0.3,
                                blurRadius: 3,
                                offset: Offset(3, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: userNameController,
                            autocorrect: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              hintText: "Your User Name",
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.person,
                                color: const Color(0xFFFF512F),
                                size: size.height * 0.03,
                              ),
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),
                            // check tha validation
                            validator: (val) {
                              if (val!.isEmpty) {
                                userNameValid = true;
                              } else {
                                userNameValid = false;
                              }
                            },
                          ),
                        ),
                        userNameValid ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              'Username is required',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        ) : Container(),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Email ID',
                            style: TextStyle(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 0.3,
                                blurRadius: 3,
                                offset: Offset(3, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: emailController,
                            autocorrect: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              hintText: "Your Email Address",
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.email,
                                color: const Color(0xFFFF512F),
                                size: size.height * 0.03,
                              ),
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
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
                              "Email address is required",
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
                              if(userNameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                                // Check Internet connection
                                internetCheck();
                                if (btnState == ButtonState.idle) {
                                  startLoading();
                                  forgot(
                                    userNameController.text.toString(),
                                    emailController.text.toString(),
                                  );
                                  // call your network api
                                  await Future.delayed(const Duration(seconds: 3));
                                  stopLoading();
                                }
                              } else if(userNameController.text.isNotEmpty &&
                                  emailController.text.isEmpty) {
                                // Check Internet connection
                                internetCheck();
                                setState(() {
                                  userEmailValid = true;
                                  AnimatedSnackBar.material(
                                      'Please enter the email ID',
                                      type: AnimatedSnackBarType.warning,
                                      duration: const Duration(seconds: 2)
                                  ).show(context);
                                });
                              } else if(userNameController.text.isEmpty &&
                                  emailController.text.isNotEmpty) {
                                // Check Internet connection
                                internetCheck();
                                setState(() {
                                  userEmailValid = true;
                                  AnimatedSnackBar.material(
                                      'Please enter the Username',
                                      type: AnimatedSnackBarType.warning,
                                      duration: const Duration(seconds: 2)
                                  ).show(context);
                                });
                              } else {
                                forgot(
                                  userNameController.text.toString(),
                                  emailController.text.toString(),
                                );
                              }
                            }),
                            child: Text(
                              "CONFIRM",
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
