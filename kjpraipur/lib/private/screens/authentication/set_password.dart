import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/custom_clipper/bezier_container.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

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
  bool _isLoading = false;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  bool userNewPassword = false;
  bool validNewPassword = false;
  bool userConfirmPassword = false;
  bool validConfirmPassword = false;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  bool _hasPasswordSpecialCharter = false;
  bool _hasPasswordUpperCase = false;
  bool _isNotPasswordEightCharacters = false;
  bool _hasNotPasswordOneNumber = false;
  bool _hasNotPasswordSpecialCharter = false;
  bool _hasNotPasswordUpperCase = false;

  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  var reg = RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[!@#\$&*~])(?=.*?[0-9]).{8,}$");

  void setPassword(String newPassword, confirmPassword) async {
    if (newPasswordController.text.isNotEmpty && newPasswordController.text != '' &&
        confirmPasswordController.text.isNotEmpty && confirmPasswordController.text != '') {
      if(reg.hasMatch(newPasswordController.text) && reg.hasMatch(confirmPasswordController.text)) {
        if(newPasswordController.text == confirmPasswordController.text) {
          String url = '$baseUrl/set_password';
          Map data = {
            "params":{
              "login": userLogin,
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
                Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
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
                'Your password is not equal, So please enter valid password',
                Colors.red
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          AnimatedSnackBar.show(
              context,
              'Please enter the valid password',
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        userNewPassword = true;
        userConfirmPassword = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the New Password and Confirm Password',
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
    internetCheck();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
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
          backgroundColor: screenBackColor,
          body: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: -size.height * 0.20,
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: size.height * 0.25,
                            width: size.width * 0.25,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/images/logo.png",
                                  ),
                                )
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -size.height / 30),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'Khrist',
                                style: GoogleFonts.portLligatSans(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                children: const [
                                  TextSpan(
                                    text: ' Jyoti Province ',
                                    style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.w700,),
                                  ),
                                  TextSpan(
                                    text: '- Raipur',
                                    style: TextStyle(color: textColor, fontSize: 23, fontWeight: FontWeight.w700,),
                                  ),
                                ]),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Set Password',
                            style: GoogleFonts.portLligatSans(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: textHeadColor,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Please create a secure password including the following criteria below.",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(child: Icon(_isPasswordEightCharacters ? Icons.check : _isNotPasswordEightCharacters ? Icons.close : Icons.circle, color: _isPasswordEightCharacters ? Colors.green : _isNotPasswordEightCharacters ? Colors.red : Colors.grey, size: 15,),),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              "Contains at least 8 characters",
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: size.height * 0.005,),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(child: Icon(_hasPasswordUpperCase ? Icons.check : _hasNotPasswordUpperCase ? Icons.close : Icons.circle, color: _hasPasswordUpperCase ? Colors.green : _hasNotPasswordUpperCase ? Colors.red : Colors.grey, size: 15,),),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              "Contains at least 1 Uppercase",
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: size.height * 0.005,),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(child: Icon(_hasPasswordSpecialCharter ? Icons.check : _hasNotPasswordSpecialCharter ? Icons.close : Icons.circle, color: _hasPasswordSpecialCharter ? Colors.green : _hasNotPasswordSpecialCharter ? Colors.red : Colors.grey, size: 15,),),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              "Contains at least 1 Special Charter",
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: size.height * 0.005,),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(child: Icon(_hasPasswordOneNumber ? Icons.check : _hasNotPasswordOneNumber ? Icons.close : Icons.circle, color: _hasPasswordOneNumber ? Colors.green : _hasNotPasswordOneNumber ? Colors.red : Colors.grey, size: 15,),),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              "Contains at least 1 number",
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02,),
                              Container(
                                padding: const EdgeInsets.only(top: 5, bottom: 15),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'New Password',
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
                                  color: inputColor,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: iconActiveColor.withOpacity(0.5),
                                      spreadRadius: 0.3,
                                      blurRadius: 3,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: newPasswordController,
                                  focusNode: newPasswordFocusNode,
                                  obscureText: _obscurePasswordText,
                                  autocorrect: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                      hintText: "Your New Password",
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: iconColor,
                                        size: size.height * 0.03,
                                      ),
                                      hintStyle: const TextStyle(
                                          color: Colors.black
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
                                          color: Colors.black54,
                                        ) :  Icon(
                                            Icons.visibility,
                                            size: size.height * 0.03,
                                            color: iconColor
                                        ),
                                      )
                                  ),
                                  onChanged: (val) {
                                    final numericRegex = RegExp(r'[0-9]');
                                    final specialRegex = RegExp(r'[!@#\$&*~]');
                                    final upperRegex = RegExp(r'[A-Z]');
                                    setState(() {
                                      if(val.length >= 8) {
                                        _isPasswordEightCharacters = true;
                                        _isNotPasswordEightCharacters = false;
                                      } else {
                                        _isPasswordEightCharacters = false;
                                        _isNotPasswordEightCharacters = true;
                                      }
                                      if(numericRegex.hasMatch(val)) {
                                        _hasPasswordOneNumber = true;
                                        _hasNotPasswordOneNumber = false;
                                      } else {
                                        _hasPasswordOneNumber = false;
                                        _hasNotPasswordOneNumber = true;
                                      }
                                      if(specialRegex.hasMatch(val)) {
                                        _hasPasswordSpecialCharter = true;
                                        _hasNotPasswordSpecialCharter = false;
                                      } else {
                                        _hasPasswordSpecialCharter = false;
                                        _hasNotPasswordSpecialCharter = true;
                                      }
                                      if(upperRegex.hasMatch(val)) {
                                        _hasPasswordUpperCase = true;
                                        _hasNotPasswordUpperCase = false;
                                      } else {
                                        _hasPasswordUpperCase = false;
                                        _hasNotPasswordUpperCase = true;
                                      }
                                    });
                                  },
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
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(confirmPasswordFocusNode);
                                  },
                                ),
                              ),
                              userNewPassword ? Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 10, top: 8),
                                  child: const Text(
                                    "New password is required",
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
                              SizedBox(height: size.height * 0.01,),
                              Container(
                                padding: const EdgeInsets.only(top: 10, bottom: 15),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Conform Password',
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
                                  color: inputColor,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: iconActiveColor.withOpacity(0.5),
                                      spreadRadius: 0.3,
                                      blurRadius: 3,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: confirmPasswordController,
                                  focusNode: confirmPasswordFocusNode,
                                  obscureText: _obscureConfirmPasswordText,
                                  autocorrect: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                      hintText: "Your Confirm Password",
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.verified_user_rounded,
                                        color: iconColor,
                                        size: size.height * 0.03,
                                      ),
                                      hintStyle: const TextStyle(
                                          color: Colors.black
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
                                          color: Colors.black54,
                                        ) :  Icon(
                                            Icons.visibility,
                                            size: size.height * 0.03,
                                            color: iconColor
                                        ),
                                      )
                                  ),
                                  onChanged: (val) {
                                    _isPasswordEightCharacters = false;
                                    _hasPasswordOneNumber = false;
                                    _hasPasswordSpecialCharter = false;
                                    _hasPasswordUpperCase = false;
                                    _isNotPasswordEightCharacters = false;
                                    _hasNotPasswordOneNumber = false;
                                    _hasNotPasswordSpecialCharter = false;
                                    _hasNotPasswordUpperCase = false;
                                    final numericRegex = RegExp(r'[0-9]');
                                    final specialRegex = RegExp(r'[!@#\$&*~]');
                                    final upperRegex = RegExp(r'[A-Z]');
                                    setState(() {
                                      if(val.length >= 8) {
                                        _isPasswordEightCharacters = true;
                                        _isNotPasswordEightCharacters = false;
                                      } else {
                                        _isPasswordEightCharacters = false;
                                        _isNotPasswordEightCharacters = true;
                                      }
                                      if(numericRegex.hasMatch(val)) {
                                        _hasPasswordOneNumber = true;
                                        _hasNotPasswordOneNumber = false;
                                      } else {
                                        _hasPasswordOneNumber = false;
                                        _hasNotPasswordOneNumber = true;
                                      }
                                      if(specialRegex.hasMatch(val)) {
                                        _hasPasswordSpecialCharter = true;
                                        _hasNotPasswordSpecialCharter = false;
                                      } else {
                                        _hasPasswordSpecialCharter = false;
                                        _hasNotPasswordSpecialCharter = true;
                                      }
                                      if(upperRegex.hasMatch(val)) {
                                        _hasPasswordUpperCase = true;
                                        _hasNotPasswordUpperCase = false;
                                      } else {
                                        _hasPasswordUpperCase = false;
                                        _hasNotPasswordUpperCase = true;
                                      }
                                    });
                                  },
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
                                    return null;
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
                              SizedBox(height: size.height * 0.02,),
                            ],
                          ),
                        ),
                        // SizedBox(height: size.height * 0.01,),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomLoadingButton(
                            text: 'Save',
                            size: size.height * 0.025,
                            onPressed: () {
                              if(newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                  setPassword(
                                    newPasswordController.text.toString(),
                                    confirmPasswordController.text.toString(),
                                  );
                                });
                              } else if(newPasswordController.text.isNotEmpty &&
                                  confirmPasswordController.text.isEmpty) {
                                setState(() {
                                  userConfirmPassword = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the confirm password',
                                      Colors.red
                                  );
                                });
                              } else if(newPasswordController.text.isEmpty &&
                                  confirmPasswordController.text.isNotEmpty) {
                                setState(() {
                                  userNewPassword = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the password',
                                      Colors.red
                                  );
                                });
                              } else {
                                setState(() {
                                  userConfirmPassword = true;
                                  userNewPassword = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the new password and confirm password',
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
                                  color: textColor,
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
