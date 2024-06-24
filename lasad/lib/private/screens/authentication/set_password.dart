import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lasad/private/screens/authentication/login.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/custom_clipper/bezier_container.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final bool _canPop = false;
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

  var reg = RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[!@#\$&*~])(?=.*?[0-9]).{8,}$");

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

  void setPassword(String newPassword, confirmPassword) async {
    if (newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty ||
        formKey.currentState!.validate()) {

      String url = '$baseUrl/set_password';
      Map data = {
        "params": {'login': user_login, 'password': newPassword, 'confirm_password': confirmPassword,}
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
            context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        AnimatedSnackBar.show(
            context,
            data["message"],
            Colors.green
        );
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
        AnimatedSnackBar.show(
            context,
            'Please enter the valid login ID and password',
            Colors.red
        );
      });
    }
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
                            'Set Password',
                            style: GoogleFonts.portLligatSans(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Your new password and confirmation password must be equal.",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Text(
                            "Your password must be in this format: abcd@1234",
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
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
                                    color: inputColor
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
                                    color: inputColor
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