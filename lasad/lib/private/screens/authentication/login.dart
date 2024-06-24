import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lasad/helper/helper_function.dart';
import 'package:lasad/private/screens/authentication/forgot_password.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/custom_clipper/bezier_container.dart';
import 'package:lasad/widget/custom_clipper/bottom_nav_bar.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  bool userNameValid = false;
  bool userPasswordValid = false;
  bool _rememberMe = false;

  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  void login(String userName, password, database) async {
    database = db;
    if (userNameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty ||
        formKey.currentState!.validate()) {

      // SharedPreferences  using save the username and password
      if(_rememberMe) {
        HelperFunctions.setNameSF(userName);
        HelperFunctions.setPasswordSF(password);
        HelperFunctions.setUserRememberSF(_rememberMe);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('setName');
        await prefs.remove('setPassword');
        HelperFunctions.setUserRememberSF(_rememberMe);
      }

      String url = '$baseUrl/user/get_token';
      Map data = {
        "params": {'username': userName, 'password': password, 'db': database}
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
          HelperFunctions.setDatabaseNameSF(database);
          HelperFunctions.setUserLoginSF(data['status']);
          HelperFunctions.setAuthTokenSF(data["access_token"]);
          HelperFunctions.setTokenExpiresSF(data['expires']);
          HelperFunctions.setCongregationIdSF(data["user_cong_id"]);
          HelperFunctions.setProvinceIdSF(data["user_prov_id"]);
          HelperFunctions.setUserNameSF(data["user_name"]);
          HelperFunctions.setUserRoleSF(data["user_role"]);
          if(data["user_comu_id"] != '') {
            HelperFunctions.setCommunityIdSF(data["user_comu_id"]);
          } else {
            HelperFunctions.setCommunityIdsSF(data["user_comu_id"]);
          }
          if(data["user_inst_id"] != '') {
            HelperFunctions.setInstituteIdSF(data["user_inst_id"]);
          } else {
            HelperFunctions.setInstituteIdsSF(data["user_inst_id"]);
          }
          if(data["member_id"] != '') {
            HelperFunctions.setMemberIdSF(data["member_id"]);
          } else {
            HelperFunctions.setMemberIdsSF(data["member_id"]);
          }
          if(data['uid'] != '') {
            HelperFunctions.setUserIdSF(data['uid']);
          } else {
            var userId = "";
            HelperFunctions.setUserIdsSF(userId);
          }
          HelperFunctions.saveUserLoggedInStatus(true);
          getDeviceToken();
          Navigator.of(context).pushReplacement(CustomRoute(widget: const BottomNavBarScreen()));

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
          _isLoading = false;
          AnimatedSnackBar.show(
              context,
              data["message"],
              Colors.red
          );
        });
      }
    } else {
      setState(() {
        userNameValid = true;
        userPasswordValid = true;
        AnimatedSnackBar.show(
            context,
            'Please enter the Username and Password',
            Colors.red
        );
      });
    }
  }

  Future<void> getDeviceToken() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    deviceToken = token.toString();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('userIdKey')) {
      userId = (prefs.getInt('userIdKey'))!;
    }

    if(prefs.containsKey('userIdsKey')) {
      userId = (prefs.getString('userIdsKey'))!;
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
    Map data = {
      "params": {
        "device_name": deviceName,
        "token": deviceToken,
        "user_id": userId
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final datas = jsonDecode(response.body)['result'];
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorAlertDialog(
              message: message['message'],
              onOkPressed: () async {
                Navigator.pop(context);
              },
            );
          },
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

  getSharedPreferenceData() async {
    if (loginName != '' && loginName != null && loginPassword != '' && loginPassword != null && remember != false) {
      userNameController.text = loginName;
      passwordController.text = loginPassword;
      _rememberMe = remember!;
    }
  }

  @override
  void initState() {
    getSharedPreferenceData();
    // Check the internet connection
    internetCheck();
    super.initState();
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
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
                            'Login',
                            style: GoogleFonts.portLligatSans(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.03,),
                              Container(
                                padding: const EdgeInsets.only(top: 5, bottom: 10),
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
                                      Icons.person,
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
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Password',
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
                                  controller: passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: _obscureText,
                                  autocorrect: true,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  style: GoogleFonts.breeSerif(
                                      color: Colors.black,
                                      letterSpacing: 0.2
                                  ),
                                  decoration: InputDecoration(
                                      hintText: "Your Password",
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.lock,
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
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: _obscureText ? Icon(
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
                                      userPasswordValid = true;
                                    } else {
                                      userPasswordValid = false;
                                    }
                                    return null;
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
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                                    },
                                    child: Text(
                                      'Forgot Password ?',
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      activeColor: backgroundColor,
                                      checkColor: Colors.white,
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                    ),
                                    Text(
                                        "Remember Me",
                                        style: GoogleFonts.signika(
                                          fontSize: size.height * 0.02,
                                          color: backgroundColor,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: size.height * 0.05,
                          width: size.width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomLoadingButton(
                            text: 'Login',
                            size: size.height * 0.025,
                            onPressed: () {
                              if(userNameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                  login(
                                    userNameController.text.toString(),
                                    passwordController.text.toString(),
                                    db,
                                  );
                                });
                              } else if(userNameController.text.isNotEmpty &&
                                  passwordController.text.isEmpty) {
                                setState(() {
                                  userPasswordValid = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the Password',
                                      Colors.red
                                  );
                                });
                              } else if(userNameController.text.isEmpty &&
                                  passwordController.text.isNotEmpty) {
                                setState(() {
                                  userNameValid = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the Username',
                                      Colors.red
                                  );
                                });
                              } else {
                                setState(() {
                                  userNameValid = true;
                                  userPasswordValid = true;
                                  AnimatedSnackBar.show(
                                      context,
                                      'Please enter the username and password',
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
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => const BottomNavBarScreen()));
                              },
                              child: Text(
                                'Back to home page',
                                style: TextStyle(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              )
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                Text(
                                  'By Continuing, you agree to the ',
                                  style: TextStyle(
                                    fontSize: size.height * 0.018,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Text(
                                  'Terms of Services & Privacy Policy',
                                  style: TextStyle(
                                      fontSize: size.height * 0.018,
                                      color: Colors.black
                                  ),
                                )
                              ],
                            ),
                        ),
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