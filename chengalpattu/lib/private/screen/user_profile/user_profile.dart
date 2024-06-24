import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/private/screen/member/profile_details.dart';
import 'package:chengai/private/screen/user_profile/about.dart';
import 'package:chengai/widget/change_theme_button.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;

  _flush() {
    AnimatedSnackBar.material(
        'Logout successfully',
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 2)
    ).show(context);
  }

  userDeviceTokenDelete() async {
    String url = '$baseUrl/device/delete/token';
    Map data = {
      "params": {
        "token": "",
        "user_id": userID
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

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      _isLoading = false;
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          return Scaffold(
            backgroundColor: themeNotifier.isDark ? const Color(0xFF303030) : Colors.white,
            body: Column(
              children: [
                Container(
                  width: size.width,
                  height: size.height * 0.25,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40)
                    ),
                    gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF512F),
                          Color(0xFFF09819)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black38,
                        spreadRadius: 3.5,
                        blurRadius: 5 ,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: size.height * 0.1,
                        left: size.width * 0.05,
                        child: SizedBox(
                          height: size.height * 0.1,
                          width: size.width * 0.2,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: Colors.white,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: userImage.isNotEmpty
                                    ? NetworkImage(userImage)
                                    : const AssetImage('assets/images/profile.png') as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.12,
                        left: size.width * 0.28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                                style: TextStyle(
                                  fontSize: size.height * 0.022,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            ),
                            userEmail.isNotEmpty ? Text(
                              userEmail,
                              style: TextStyle(
                                  fontSize: size.height * 0.02,
                                  color: Colors.white
                              ),
                            ) : Container()
                          ],
                        ),
                      ),
                      // Positioned(
                      //   top: size.height * 0.07,
                      //   right: size.width * 0.03,
                      //   child: IconButton(
                      //       icon: themeNotifier.isDark ? const Icon(Icons.nightlight_round, color: Colors.yellow,) : const Icon(Icons.wb_sunny, color: Colors.white,),
                      //       onPressed: () {
                      //         themeNotifier.isDark
                      //             ? themeNotifier.isDark = false
                      //             : themeNotifier.isDark = true;
                      //       }),
                      // )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                      height: size.height * 0.06,
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballSpinFadeLoader,
                        colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                      ),
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        userMember != '' && userMember != null ? SizedBox(
                          // height: size.height * 0.08,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.transparent
                            ),
                            onPressed: () {
                              // Check Internet connection
                              internetCheck();
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const MemberProfileScreen()));
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: const Color(0xFFF7DCD9),
                                    ),
                                    child: Icon(
                                        LineAwesomeIcons.user,
                                        color: const Color(0xFFF5402D),
                                        size: size.height * 0.03
                                    )
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Profile', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                              ],
                            ),
                          ),
                        ) : Container(),
                        SizedBox(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF373737),
                              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(CustomRoute(widget: const AboutScreen()));
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: const Color(0xFFF7DCD9),
                                    ),
                                    child: Icon(
                                        LineAwesomeIcons.info_circle,
                                        color: const Color(0xFFF5402D),
                                        size: size.height * 0.03
                                    )
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('About', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF373737),
                              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {
                              webAction('https://www.boscosofttech.com/about');
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: const Color(0xFFF7DCD9),
                                    ),
                                    child: Icon(
                                        LineAwesomeIcons.user_shield,
                                        color: const Color(0xFFF5402D),
                                        size: size.height * 0.03
                                    )
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Privacy', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                                Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(height: size.height * 0.005,),
                        // SizedBox(
                        //   height: size.height * 0.08,
                        //   child: TextButton(
                        //     style: TextButton.styleFrom(
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        //       shape:
                        //       RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(30)
                        //       ),
                        //       backgroundColor: Colors.transparent,
                        //     ),
                        //     onPressed: () {},
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //             height: size.height * 0.065,
                        //             width : size.width * 0.12,
                        //             alignment: Alignment.center,
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(25),
                        //               color: const Color(0xFFF7DCD9),
                        //             ),
                        //             child: Icon(
                        //                 LineAwesomeIcons.question_circle,
                        //                 color: const Color(0xFFF5402D),
                        //                 size: size.height * 0.03
                        //             )
                        //         ),
                        //         SizedBox(width: size.width * 0.05),
                        //         Expanded(child: Text('Help & Support', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                        //         Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: size.height * 0.01,),
                        // SizedBox(
                        //   height: size.height * 0.08,
                        //   child: TextButton(
                        //     style: TextButton.styleFrom(
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        //       shape:
                        //       RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(30)
                        //       ),
                        //       backgroundColor: Colors.transparent,
                        //     ),
                        //     onPressed: () {},
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //             height: size.height * 0.065,
                        //             width : size.width * 0.12,
                        //             alignment: Alignment.center,
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(25),
                        //               color: const Color(0xFFF7DCD9),
                        //             ),
                        //             child: Icon(
                        //                 LineAwesomeIcons.language,
                        //                 color: const Color(0xFFF5402D),
                        //                 size: size.height * 0.03
                        //             )
                        //         ),
                        //         SizedBox(width: size.width * 0.05),
                        //         Expanded(child: Text('Change Language', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                        //         Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: size.height * 0.01,),
                        // SizedBox(
                        //   height: size.height * 0.08,
                        //   child: TextButton(
                        //     style: TextButton.styleFrom(
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        //       shape:
                        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        //       backgroundColor: Colors.transparent,
                        //     ),
                        //     onPressed: () {},
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //             height: size.height * 0.065,
                        //             width : size.width * 0.12,
                        //             alignment: Alignment.center,
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(25),
                        //               color: const Color(0xFFF7DCD9),
                        //             ),
                        //             child: Icon(
                        //                 LineAwesomeIcons.lock,
                        //                 color: const Color(0xFFF5402D),
                        //                 size: size.height * 0.03
                        //             )
                        //         ),
                        //         SizedBox(width: size.width * 0.05),
                        //         Expanded(child: Text('Change Password', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                        //         Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: size.height * 0.01,),
                        // SizedBox(
                        //   height: size.height * 0.08,
                        //   child: TextButton(
                        //     style: TextButton.styleFrom(
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        //       shape:
                        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        //       backgroundColor: Colors.transparent,
                        //     ),
                        //     onPressed: () {},
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //             padding: const EdgeInsets.all(10),
                        //             alignment: Alignment.center,
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(25),
                        //               color: const Color(0xFFF7DCD9),
                        //             ),
                        //             child: Icon(
                        //                 LineAwesomeIcons.cog,
                        //                 color: const Color(0xFFF5402D),
                        //                 size: size.height * 0.03
                        //             )
                        //         ),
                        //         SizedBox(width: size.width * 0.05),
                        //         Expanded(child: Text('Settings', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                        //         Icon(Icons.arrow_forward_ios, color: themeNotifier.isDark ? Colors.white : Colors.black, size: size.height * 0.025,),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: size.height * 0.01,),
                        SizedBox(
                          // height: size.height * 0.08,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {
                              // Check Internet connection
                              internetCheck();
                              setState(() {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.info,
                                  title: 'Info',
                                  text: 'Are you sure you want to log out?',
                                  confirmBtnColor: greenColor,
                                  onConfirmBtnTap: () async {
                                    // Deleting user device token
                                    userDeviceTokenDelete();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const CustomLoadingDialog();
                                      },
                                    );
                                    // Deleting shared-preferences data
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('userAuthTokenKey');
                                    await prefs.remove('userTokenExpires');
                                    await prefs.remove('userIdKey');
                                    await prefs.remove('userNameKey');
                                    await prefs.remove('userEmailKey');
                                    await prefs.remove('userImageKey');
                                    await prefs.remove('userDioceseKey');
                                    await prefs.remove('userMemberKey');
                                    await HelperFunctions.setUserLoginSF(false);
                                    authToken = '';
                                    tokenExpire = '';
                                    userID = '';
                                    userName = '';
                                    userEmail = '';
                                    userImage = '';
                                    userLevel = '';
                                    userDiocese = '';
                                    userMember = '';
                                    await Future.delayed(const Duration(seconds: 1));

                                    Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
                                    _flush();
                                  },
                                  onCancelBtnTap: () {
                                    Navigator.pop(context);
                                  },
                                  confirmBtnText: 'Yes',
                                  cancelBtnText: 'No',
                                  showCancelBtn: true,
                                  width: 100.0,
                                );
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: const Color(0xFFF7DCD9),
                                    ),
                                    child: Icon(
                                        Icons.power_settings_new,
                                        color: const Color(0xFFF5402D),
                                        size: size.height * 0.03
                                    )
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(child: Text('Logout', style: TextStyle(fontSize: size.height * 0.02, color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}