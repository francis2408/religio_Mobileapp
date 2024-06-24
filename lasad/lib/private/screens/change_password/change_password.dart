import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lasad/helper/helper_function.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/custom_clipper/bezier_container.dart';
import 'package:lasad/widget/custom_clipper/bottom_nav_bar.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Password is changed successfully',
        Colors.green
    );
  }

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  update(String newPassword, confirmPassword) async {
    if (newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty ||
        formKey.currentState!.validate()) {

      if(newPassword == confirmPassword) {
        if(validNewPassword != true && validConfirmPassword != true) {
          var request = http.Request('PUT', Uri.parse('$baseUrl/write/res.users?ids=[$userId]&values={"password":"$confirmPassword"}'));
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            var data = json.decode(await response.stream.bytesToString())['status'];

            if(data == 'success') {
              setState(() {
                _isLoading = false;
              });

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('userLoggedInkey');
              await prefs.remove('userAuthTokenKey');
              await prefs.remove('userIdKey');
              await prefs.remove('userCongregationIdKey');
              await prefs.remove('userProvinceIdKey');
              await prefs.remove('userUserIdKey');
              await prefs.remove('userUserNameKey');
              await prefs.remove('userUserRoleKey');
              await prefs.remove('userCommunityIdKey');
              await prefs.remove('setUserCommunityIDKey');
              await prefs.remove('userInstituteIdKey');
              await prefs.remove('setUserInstituteIDKey');
              await prefs.remove('userMemberIdKey');
              // await prefs.clear();
              await HelperFunctions.setUserLoginSF(false);
              // await HelperFunctions.saveUserLoggedInStatus(false);
              await Future.delayed(const Duration(seconds: 1));

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const BottomNavBarScreen()));
              _flush();
            }
          } else {
            var message = json.decode(await response.stream.bytesToString())['message'];
            setState(() {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ErrorAlertDialog(
                    message: message,
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
                'Please enter the valid password.',
                Colors.red
            );
          });
        }
      } else {
        setState(() {
          AnimatedSnackBar.show(
              context,
              'Your entered the New Password and Confirm Password is not same.',
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        AnimatedSnackBar.show(
            context,
            'Please enter the New Password and Confirm Password.',
            Colors.red
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
                          'Change Password',
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
                          text: 'Update',
                          size: size.height * 0.025,
                          onPressed: () {
                            if(newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
                              setState(() {
                                _isLoading = true;
                                update(
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
                                    'Please enter the confirm password.',
                                    Colors.red
                                );
                              });
                            } else if(newPasswordController.text.isEmpty &&
                                confirmPasswordController.text.isNotEmpty) {
                              setState(() {
                                userNewPassword = true;
                                AnimatedSnackBar.show(
                                    context,
                                    'Please enter the password.',
                                    Colors.red
                                );
                              });
                            } else {
                              setState(() {
                                userConfirmPassword = true;
                                userNewPassword = true;
                                AnimatedSnackBar.show(
                                    context,
                                    'Please enter the new password and confirm password.',
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
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Back to screen ?',
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
