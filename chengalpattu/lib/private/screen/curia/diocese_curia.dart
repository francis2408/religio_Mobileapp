import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DioceseCurioScreen extends StatefulWidget {
  const DioceseCurioScreen({Key? key}) : super(key: key);

  @override
  State<DioceseCurioScreen> createState() => _DioceseCurioScreenState();
}

class _DioceseCurioScreenState extends State<DioceseCurioScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  int selected = -1;
  List curia = [];

  getDioceseCuriaData() async {
    String url = '$baseUrl/res.ecclesia.diocese';
    Map datas = {
      "params": {
        "filter": "[['id','=',$userDiocese],['diocese_curia_ids.status','=','Active']]",
        "query": "{id,diocese_curia_ids{id,member_id{id,member_name,image_1920,email,mobile},role_ids,date_from,date_to,status,sequence}}"
      }
    };
    var body = jsonEncode(datas);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      for(int i = 0; i < data.length; i++) {
        curia = data[i]['diocese_curia_ids'];
      }
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isLoading = false;
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

  Future<void> smsAction(String number) async {
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    if (Platform.isAndroid) {
      var whatsappUrl ="whatsapp://send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    } else {
      var whatsappUrl ="https://api.whatsapp.com/send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    }
  }

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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

  _authTokenExpire() {
    AnimatedSnackBar.material(
        'Your session was expired; please login again.',
        type: AnimatedSnackBarType.info,
        duration: const Duration(seconds: 10)
    ).show(context);
  }

  clearSharedPreferenceData() async {
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
    _authTokenExpire();
  }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getDioceseCuriaData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDioceseCuriaData();
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
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Diocese Curia'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF512F),
                    Color(0xFFF09819)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                getDioceseCuriaData();
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ) : curia.isNotEmpty ? Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: curia.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: ScaleAnimation(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.005,
                                        ),
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    curia[index]['member_id']['image_1920'] != '' ? showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return Dialog(
                                                          child: Image.network(curia[index]['member_id']['image_1920'], fit: BoxFit.cover,),
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
                                                  child: Container(
                                                    height: size.height * 0.11,
                                                    width: size.width * 0.18,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: const <BoxShadow>[
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          spreadRadius: -1,
                                                          blurRadius: 5 ,
                                                          offset: Offset(0, 1),
                                                        ),
                                                      ],
                                                      shape: BoxShape.rectangle,
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: curia[index]['member_id']['image_1920'] != null && curia[index]['member_id']['image_1920'] != ''
                                                            ? NetworkImage(curia[index]['member_id']['image_1920'])
                                                            : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 15, right: 10),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                curia[index]['member_id']['member_name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.02,
                                                                  color: textColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.height * 0.005,
                                                        ),
                                                        Row(
                                                          children: [
                                                            curia[index]['role_ids_view'] != null && curia[index]['role_ids_view'] != '' ? Flexible(
                                                              child: Text(
                                                                curia[index]['role_ids_view'],
                                                                style: TextStyle(
                                                                  letterSpacing: 0.5,
                                                                  fontSize: size.height * 0.018,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black54,
                                                                ),
                                                              ),
                                                            ) : Flexible(
                                                              child: Text(
                                                                'No role assigned',
                                                                style: TextStyle(
                                                                  letterSpacing: 0.5,
                                                                  fontSize: size.height * 0.018,
                                                                  color: Colors.grey,
                                                                  fontStyle: FontStyle.italic,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              (curia[index]['member_id']['mobile']).split(',')[0].trim(),
                                                              style: TextStyle(
                                                                fontSize: size.height * 0.018,
                                                                color: Colors.blue,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                if(curia[index]['member_id']['mobile'] != null && curia[index]['member_id']['mobile'] != '') IconButton(
                                                                  onPressed: () {
                                                                    (curia[index]['member_id']['mobile']).split(',').length != 1 ? showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          contentPadding: const EdgeInsets.all(10),
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  ListTile(
                                                                                    title: Text(
                                                                                      (curia[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                      style: const TextStyle(color: Colors.blueAccent),
                                                                                    ),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                      callAction((curia[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                    },
                                                                                  ),
                                                                                  const Divider(),
                                                                                  ListTile(
                                                                                    title: Text(
                                                                                      (curia[index]['member_id']['mobile']).split(',')[1].trim(),
                                                                                      style: const TextStyle(color: Colors.blueAccent),
                                                                                    ),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                      callAction((curia[index]['member_id']['mobile']).split(',')[1].trim());
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ) : callAction((curia[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  icon: const Icon(Icons.phone),
                                                                  color: Colors.blueAccent,
                                                                ),
                                                                if(curia[index]['member_id']['mobile'] != null && curia[index]['member_id']['mobile'] != '') IconButton(
                                                                  onPressed: () {
                                                                    (curia[index]['member_id']['mobile']).split(',').length != 1 ? showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          contentPadding: const EdgeInsets.all(10),
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  ListTile(
                                                                                    title: Text(
                                                                                      (curia[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                      style: const TextStyle(color: Colors.blueAccent),
                                                                                    ),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                      smsAction((curia[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                    },
                                                                                  ),
                                                                                  const Divider(),
                                                                                  ListTile(
                                                                                    title: Text(
                                                                                      (curia[index]['member_id']['mobile']).split(',')[1].trim(),
                                                                                      style: const TextStyle(color: Colors.blueAccent),
                                                                                    ),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                      smsAction((curia[index]['member_id']['mobile']).split(',')[1].trim());
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ) : smsAction((curia[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  icon: const Icon(Icons.message),
                                                                  color: Colors.orange,
                                                                ),
                                                                if(curia[index]['member_id']['mobile'] != null && curia[index]['member_id']['mobile'] != '') IconButton(
                                                                  onPressed: () {
                                                                    (curia[index]['member_id']['mobile']).split(',').length != 1 ? showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          contentPadding: const EdgeInsets.all(10),
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  ListTile(
                                                                                    title: Text(
                                                                                      (curia[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                      style: const TextStyle(color: Colors.blueAccent),
                                                                                    ),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                      whatsappAction((curia[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                    },
                                                                                  ),
                                                                                  const Divider(),
                                                                                  ListTile(
                                                                                    title: Text(
                                                                                      (curia[index]['member_id']['mobile']).split(',')[1].trim(),
                                                                                      style: const TextStyle(color: Colors.blueAccent),
                                                                                    ),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context); // Close the dialog
                                                                                      whatsappAction((curia[index]['member_id']['mobile']).split(',')[1].trim());
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ) : whatsappAction((curia[index]['member_id']['mobile']).split(',')[0].trim());
                                                                  },
                                                                  icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                  color: Colors.green,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
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
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) : Center(
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
              child: SizedBox(
                height: 50,
                width: 180,
                child: textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
