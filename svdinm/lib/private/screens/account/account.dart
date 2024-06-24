import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svdinm/private/screens/authentication/change_password.dart';
import 'package:svdinm/private/screens/authentication/login.dart';
import 'package:svdinm/private/screens/member/profile/member_profile_details.dart';
import 'package:svdinm/widget/common/common.dart';
import 'package:svdinm/widget/common/internet_connection_checker.dart';
import 'package:svdinm/widget/common/snackbar.dart';
import 'package:svdinm/widget/helper_function/helper_function.dart';
import 'package:svdinm/widget/theme_color/theme_color.dart';
import 'package:svdinm/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final bool _canPop = false;
  bool _isLoading = true;
  bool load = true;
  List member = [];

  // Member Details
  String memberName = '';
  String memberImage = '';
  String memberEmail = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberDetail() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['full_name','name','middle_name','image_1920','last_name','membership_type','display_roles','member_type','place_of_birth','unique_code','gender','dob','physical_status_id','diocese_id','parish_id','personal_mobile','personal_email','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','community_id','role_ids']&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      member = data;
      for(int i = 0; i < member.length; i++) {
        memberName = member[i]['full_name'];
        memberImage = member[i]['image_1920'];
        memberEmail = member[i]['email'];
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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

  userDeviceTokenDelete() async {
    String url = '$baseUrl/device/delete/token';
    Map data = {
      "params": {
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
      final data = jsonDecode(response.body)['result'];
    } else {
      final message = jsonDecode(response.body)['result'];
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
  }

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getMemberDetail();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberDetail();
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
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Account Settings'),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)
                ),
            ),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              )
          ),
        ),
        body: SafeArea(
          child: _isLoading ? Center(
            child: Container(
                height: size.height * 0.1,
                width: size.width * 0.2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage( "assets/alert/spinner_1.gif"),
                  ),
                )),
          ) : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.13,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: accountShadow.withOpacity(0.5),
                        spreadRadius: 0.3,
                        blurRadius: 3,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          memberImage != '' ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Image.network(memberImage, fit: BoxFit.cover,),
                              );
                            },
                          ) : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          height: size.height * 0.1,
                          width: size.width * 0.18,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                                color: Colors.white,
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: memberImage != '' && memberImage.isNotEmpty ? NetworkImage(memberImage) : const AssetImage('assets/images/profile.png') as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(left: size.width * 0.03),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memberName,
                                style: GoogleFonts.robotoSlab(
                                  fontSize: size.height * 0.02,
                                  color: textHeadColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                memberEmail,
                                style: GoogleFonts.maitree(
                                  fontSize: size.height * 0.018,
                                  color: valueColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accountShadow.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CustomRoute(widget: const MemberProfileTabbarScreen()));
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: menuPrimaryColor,
                                ),
                                child: SvgPicture.asset('assets/icons/user.svg', color: buttonIconColor, height: 20, width: 20)
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Profile', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accountShadow.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CustomRoute(widget: const AboutScreen()));
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: menuPrimaryColor,
                                ),
                                child: SvgPicture.asset('assets/icons/info.svg', color: buttonIconColor, height: 20, width: 20)
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('About', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accountShadow.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          webAction('https://www.boscosofttech.com/about');
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: menuPrimaryColor,
                                ),
                                child: SvgPicture.asset('assets/icons/shield.svg', color: buttonIconColor, height: 20, width: 20)
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Privacy', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.015,
                    ),
                    Text(
                      'Account',
                      style: TextStyle(
                          fontSize: size.height * 0.022,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: size.height * 0.015,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accountShadow.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(CustomRoute(widget: const ChangePasswordScreen()));
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: menuPrimaryColor,
                                ),
                                child: SvgPicture.asset('assets/icons/key.svg', color: buttonIconColor, height: 20, width: 20)
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Change Password', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                            Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accountShadow.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmAlertDialog(
                                message: 'Are you sure want to exit.',
                                onYesPressed: () {
                                  exit(0);
                                },
                                onCancelPressed: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: menuPrimaryColor,
                                ),
                                child: Icon(Icons.cancel, size: size.height * 0.025, color: buttonIconColor,)
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Exit', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accountShadow.withOpacity(0.5),
                            spreadRadius: 0.3,
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: navIconColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.transparent
                        ),
                        onPressed: () {
                          // userDeviceTokenDelete();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmAlertDialog(
                                message: 'Are you sure you want to logout?',
                                onCancelPressed: () {
                                  // Cancel button logic
                                  Navigator.of(context).pop();
                                },
                                onYesPressed: () async {
                                  if(load) {
                                    userDeviceTokenDelete();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const CustomLoadingDialog();
                                      },
                                    );
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('userLoggedInkey');
                                    await prefs.remove('userAuthTokenKey');
                                    await prefs.remove('userIdKey');
                                    await prefs.remove('userIdsKey');
                                    await prefs.remove('userCongregationIdKey');
                                    await prefs.remove('userProvinceIdKey');
                                    await prefs.remove('userNameKey');
                                    await prefs.remove('userRoleKey');
                                    await prefs.remove('userCommunityIdKey');
                                    await prefs.remove('userCommunityIdsKey');
                                    await prefs.remove('userInstituteIdKey');
                                    await prefs.remove('userInstituteIdsKey');
                                    await prefs.remove('userMemberIdKey');
                                    await prefs.remove('userMemberIdsKey');
                                    await HelperFunctions.setUserLoginSF(false);
                                    await Future.delayed(const Duration(seconds: 1));
                                    setState(() {
                                      load = false; // Set loading flag to false
                                    });
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                    _flush();
                                  }
                                },
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: menuPrimaryColor,
                                ),
                                child: SvgPicture.asset('assets/icons/logout.svg', color: buttonIconColor, height: 20, width: 20)
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: Text('Logout', style: TextStyle(fontSize: size.height * 0.019, color: Colors.black, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
