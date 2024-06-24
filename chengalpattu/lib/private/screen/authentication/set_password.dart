import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_btn/loading_btn.dart';
import 'package:quickalert/quickalert.dart';

import 'login.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  bool _canPop = false;
  final formKey = GlobalKey<FormState>();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  bool _isLoading = false;
  bool userNewPassword = false;
  bool validNewPassword = false;
  bool userConfirmPassword = false;
  bool validConfirmPassword = false;

  var reg = RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[!@#\$&*~])(?=.*?[0-9]).{8,}$");

  void setPassword(String newPassword, confirmPassword) async {
    if (newPasswordController.text.isNotEmpty && newPasswordController.text != '' &&
        confirmPasswordController.text.isNotEmpty && confirmPasswordController.text != '') {
      if(reg.hasMatch(newPasswordController.text) && reg.hasMatch(confirmPasswordController.text)) {
        if(newPasswordController.text == confirmPasswordController.text) {
          String url = '$baseUrl/set_password';
          Map data = {
            "params":{
              "login": loginUserName,
              "password": newPassword,
              "confirm_password": confirmPassword
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

              Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
              // Navigator.pushReplacement(
              //     context, MaterialPageRoute(builder: (context) => const LoginScreen()));

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
          setState(() {
            AnimatedSnackBar.material(
                'Your password is not equal, So please enter valid password',
                type: AnimatedSnackBarType.warning,
                duration: const Duration(seconds: 2)
            ).show(context);
          });
        }
      } else {
        setState(() {
          AnimatedSnackBar.material(
              'Please enter the valid password',
              type: AnimatedSnackBarType.warning,
              duration: const Duration(seconds: 2)
          ).show(context);
        });
      }
    } else {
      setState(() {
        userNewPassword = true;
        userConfirmPassword = true;
        AnimatedSnackBar.material(
            'Please enter the New Password and Confirm Password',
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
                        'SET PASSWORD',
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
                    right: size.width * 0.03,
                    child: Container(
                      width: size.width * 0.7,
                      height: size.height * 0.7,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/login/set_password.png'),
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
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Your new password and confirm password must be equal.",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
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
                            controller: newPasswordController,
                            obscureText: _obscurePasswordText,
                            autocorrect: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                hintText: "Your New Password",
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: const Color(0xFFFF512F),
                                  size: size.height * 0.03,
                                ),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscurePasswordText = !_obscurePasswordText;
                                    });
                                  },
                                  child: _obscurePasswordText ? Icon(
                                    Icons.visibility_off,
                                    size: size.height * 0.03,
                                    color: Colors.grey,
                                  ) :  Icon(
                                      Icons.visibility,
                                      size: size.height * 0.03,
                                      color: const Color(0xFFFF512F)
                                  ),
                                )
                            ),

                            // check tha validation
                            validator: (val) {
                              if (val!.isEmpty) {
                                userNewPassword = true;
                                validNewPassword = false;
                              } else {
                                if(val.isNotEmpty) {
                                  if(reg.hasMatch(val)) {
                                    userNewPassword = false;
                                    validNewPassword = false;
                                  } else {
                                    userNewPassword = false;
                                    validNewPassword = true;
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        userNewPassword ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              "Password is required",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        ) : Container(),
                        validNewPassword ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              "Please enter a valid password",
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
                            'Password',
                            style: TextStyle(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
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
                            controller: confirmPasswordController,
                            obscureText: _obscureConfirmPasswordText,
                            autocorrect: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                hintText: "Your Confirm Password",
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.verified_user_rounded,
                                  color: const Color(0xFFFF512F),
                                  size: size.height * 0.03,
                                ),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureConfirmPasswordText = !_obscureConfirmPasswordText;
                                    });
                                  },
                                  child: _obscureConfirmPasswordText ? Icon(
                                    Icons.visibility_off,
                                    size: size.height * 0.03,
                                    color: Colors.grey,
                                  ) :  Icon(
                                      Icons.visibility,
                                      size: size.height * 0.03,
                                      color: const Color(0xFFFF512F)
                                  ),
                                )
                            ),

                            // check tha validation
                            validator: (val) {
                              if (val!.isEmpty) {
                                userConfirmPassword = true;
                                validConfirmPassword = false;
                              } else {
                                if(val.isNotEmpty) {
                                  if(reg.hasMatch(val)) {
                                    userConfirmPassword = false;
                                    validConfirmPassword = false;
                                  } else {
                                    validConfirmPassword = true;
                                    userConfirmPassword = false;
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        userConfirmPassword ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              "Confirm password is required",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        ) : Container(),
                        validConfirmPassword ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              "Please enter a valid confirm password",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        ) : Container(),
                        SizedBox(
                          height: size.height * 0.05,
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
                              if(newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
                                // Check Internet connection
                                internetCheck();
                                if (btnState == ButtonState.idle) {
                                  startLoading();
                                  setPassword(
                                    newPasswordController.text.toString(),
                                    confirmPasswordController.text.toString(),
                                  );
                                  // call your network api
                                  await Future.delayed(const Duration(seconds: 3));
                                  stopLoading();
                                }
                              } else if(newPasswordController.text.isNotEmpty &&
                                  confirmPasswordController.text.isEmpty) {
                                // Check Internet connection
                                internetCheck();
                                setState(() {
                                  userConfirmPassword = true;
                                  AnimatedSnackBar.material(
                                      'Please enter the confirm password',
                                      type: AnimatedSnackBarType.warning,
                                      duration: const Duration(seconds: 2)
                                  ).show(context);
                                });
                              } else if(newPasswordController.text.isEmpty &&
                                  confirmPasswordController.text.isNotEmpty) {
                                // Check Internet connection
                                internetCheck();
                                setState(() {
                                  userNewPassword = true;
                                  AnimatedSnackBar.material(
                                      'Please enter the password',
                                      type: AnimatedSnackBarType.warning,
                                      duration: const Duration(seconds: 2)
                                  ).show(context);
                                });
                              } else {
                                // Check Internet connection
                                internetCheck();
                                setPassword(
                                  newPasswordController.text.toString(),
                                  confirmPasswordController.text.toString(),
                                );
                              }
                            }),
                            child: Text(
                              "SAVE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height * 0.02,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
                              // Navigator.pushReplacement(
                              //     context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
