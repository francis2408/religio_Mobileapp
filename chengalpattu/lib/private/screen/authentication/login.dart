import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/widget/bottom_nav_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _canPop = false;
  final formKey = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  bool _obscureText = true;
  bool userEmailValid = false;
  bool userPasswordValid = false;
  bool _rememberMe = false;

  void login(String username, password, database) async {
    if (userNameController.text.isNotEmpty && userNameController.text != '' &&
        passwordController.text.isNotEmpty && passwordController.text != '') {

      // SharedPreferences  using save the username and password
      if(_rememberMe) {
        HelperFunctions.setNameSF(username);
        HelperFunctions.setPasswordSF(password);
        HelperFunctions.setUserRememberSF(_rememberMe);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('setName');
        await prefs.remove('setPassword');
        HelperFunctions.setUserRememberSF(_rememberMe);
      }

      String url = '$baseUrl/auth/token';
      // String url = 'http://192.168.1.129:1010/api/auth/token';
      Map data = {
        "params": {'login': username, 'password': password, 'db': database}
      };
      var body = jsonEncode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        if(data['status_code'] == 200) {
          HelperFunctions.setDatabaseNameSF(database);
          HelperFunctions.setUserLoginSF(data['status']);
          HelperFunctions.setAuthTokenSF(data['access_token']);
          String dateStr = "${data['expires']}";
          DateTime date = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateStr);
          String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
          HelperFunctions.setTokenExpiresSF(formattedDate);
          if(data['uid'] != false) {
            HelperFunctions.setIdSF(data['uid']);
          } else {
            var userId = "";
            HelperFunctions.setIdsSF(userId);
          }
          HelperFunctions.setUserNameSF(data['name']);
          HelperFunctions.setUserImageSF(data['image']);
          HelperFunctions.setUserLevelSF(data['level'][0]);
          if(data['email'] != false) {
            HelperFunctions.setUserEmailSF(data['email']);
          } else {
            var emails = "";
            HelperFunctions.setUserEmailSF(emails);
          }
          if(data['diocese_id'] != false) {
            HelperFunctions.setUserDioceseSF(data['diocese_id']);
          } else {
            var dioceses = "";
            HelperFunctions.setUserDiocesesSF(dioceses);
          }
          if(data['member_id'] != false) {
            HelperFunctions.setUserMemberSF(data['member_id']);
          } else {
            var members = "";
            HelperFunctions.setUserMembersSF(members);
          }
          HelperFunctions.saveUserLoggedInStatus(true);

          getDeviceToken();

          Navigator.of(context).pushReplacement(CustomRoute(widget: const BottomNavBarScreen()));

          formKey.currentState?.reset();

          AnimatedSnackBar.material(
              'Logged in successfully',
              type: AnimatedSnackBarType.success,
              duration: const Duration(seconds: 2)
          ).show(context);
        } else {
          setState(() {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: 'Please, enter valid credentials.',
              confirmBtnColor: greenColor,
              width: 100.0,
            );
          });
        }
      }
    } else {
      setState(() {
        userPasswordValid = true;
        userEmailValid = true;
        AnimatedSnackBar.material(
            'Please enter the Username and Password',
            type: AnimatedSnackBarType.error,
            duration: const Duration(seconds: 2)
        ).show(context);
      });
    }
  }

  Future<void> getDeviceToken() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    deviceToken = token.toString();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('userIdKey')) {
      userID = (prefs.getInt('userIdKey'))!;
    }

    if(prefs.containsKey('userIdsKey')) {
      userID = (prefs.getString('userIdsKey'))!;
    }
    getDeviceName();
  }

  void getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String name = '';
    String? model = '';
    String osVersion = '';
    if(Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      name = androidInfo.manufacturer;
      model = 'Android';
      osVersion = androidInfo.version.release;
    } else if(Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      name = iosInfo.name!;
      model = iosInfo.systemName!;
      osVersion = iosInfo.systemVersion!;
    } else {
      deviceName = 'Unknown Device';
    }
    deviceName = '$name ($model $osVersion)';
    // Store device token against the user
    getDeviceRegisteredToken();
  }

  getDeviceRegisteredToken() async {
    String url = '$baseUrl/device/token';
    Map datas = {
      "params": {
        "device_name": deviceName,
        "token": deviceToken,
        "user_id": userID
      }
    };
    var body = jsonEncode(datas);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: message['message'],
          confirmBtnColor: greenColor,
          width: 100.0,
        );
      });
    }
  }

  getSharedPreferenceData() async {
    if (loginName != '' && loginName != null && loginPassword != '' && loginPassword != null && remember != false) {
      userNameController.text = loginName;
      passwordController.text = loginPassword;
      _rememberMe = remember!;
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
    getSharedPreferenceData();
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
              top: size.height * -0.055,
                right: size.width * 0.02,
                child: Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: size.width * 0.58,
                  height: size.height * 0.58,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/login/log.png'),
                      // opacity: 0.8
                    ),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.13,
                child: Container(
                  padding: EdgeInsets.only(left: size.width * 0.03),
                  child: Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: size.height * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.63,
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
                          padding: const EdgeInsets.only(top: 5, bottom: 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Username',
                            style: GoogleFonts.signika(
                              fontSize: size.height * 0.025,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5,),
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
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            style: GoogleFonts.roboto(
                                letterSpacing: 2.0,
                                fontSize: size.height * 0.02,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
                              hintText: "Your Username",
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.email,
                                color: const Color(0xFFFF512F),
                                size: size.height * 0.03,
                              ),
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            // check tha validation
                            validator: (val) {
                              if (val!.isEmpty) {
                                userEmailValid = true;
                              } else {
                                userEmailValid = false;
                              }
                            },
                          ),
                        ),
                        userEmailValid ? Container(
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
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Password',
                            style: GoogleFonts.signika(
                              fontSize: size.height * 0.025,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, top: 5,),
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
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _obscureText,
                            autocorrect: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            style: GoogleFonts.roboto(
                                letterSpacing: 2.0,
                                fontSize: size.height * 0.02,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
                                hintText: "Your Password",
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
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: _obscureText ? Icon(
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
                                userPasswordValid = true;
                              } else {
                                userPasswordValid = false;
                              }
                            },
                          ),
                        ),
                        userPasswordValid ? Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 10, top: 8),
                            child: const Text(
                              'Password is required',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500
                              ),
                            )
                        ) : Container(),
                        Container(
                          alignment: Alignment.center,
                          child: CheckboxListTile(
                            title: Text(
                                "Remember Me",
                                style: GoogleFonts.signika(
                                  fontSize: size.height * 0.022,
                                  color: const Color(0xFFFF512F),
                                )
                            ),
                            activeColor: backgroundColor,
                            checkColor: Colors.white,
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
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
                              if(userNameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                // Check Internet connection
                                internetCheck();
                                if (btnState == ButtonState.idle) {
                                  startLoading();
                                  login(
                                    userNameController.text.toString(),
                                    passwordController.text.toString(),
                                    db,
                                  );
                                  // call your network api
                                  await Future.delayed(const Duration(seconds: 3));
                                  stopLoading();
                                }
                              } else if(userNameController.text.isNotEmpty &&
                                  passwordController.text.isEmpty) {
                                // Check Internet connection
                                internetCheck();
                                setState(() {
                                  userPasswordValid = true;
                                  AnimatedSnackBar.material(
                                      'Please enter the Password',
                                      type: AnimatedSnackBarType.error,
                                      duration: const Duration(seconds: 2)
                                  ).show(context);
                                });
                              } else if(userNameController.text.isEmpty &&
                                  passwordController.text.isNotEmpty) {
                                // Check Internet connection
                                internetCheck();
                                setState(() {
                                  userEmailValid = true;
                                  AnimatedSnackBar.material(
                                      'Please enter the Username',
                                      type: AnimatedSnackBarType.error,
                                      duration: const Duration(seconds: 2)
                                  ).show(context);
                                });
                              } else {
                                // Check Internet connection
                                internetCheck();
                                login(
                                  userNameController.text.toString(),
                                  passwordController.text.toString(),
                                  db,
                                );
                              }
                            }),
                            child: Text(
                              "Login",
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
                              Navigator.of(context).pushReplacement(CustomRoute(widget: const ForgotPasswordScreen()));
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF512F),
                              ),
                            )
                        ),
                        Container(
                            alignment: Alignment.topCenter,
                            child: TextButton(
                              onPressed: () {},
                              child: Text.rich(
                                TextSpan(
                                    text: 'By Continuing, you agree to the ',
                                    style: TextStyle(
                                      fontSize: size.height * 0.018,
                                      color: Colors.grey,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: 'Terms of Services & Privacy Policy',
                                        style: TextStyle(
                                            fontSize: size.height * 0.018,
                                            color: Colors.black
                                        ),
                                      )
                                    ]
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                        )
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
