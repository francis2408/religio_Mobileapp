import 'dart:convert';
import 'dart:io';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class ParishPriestHistoryScreen extends StatefulWidget {
  const ParishPriestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ParishPriestHistoryScreen> createState() => _ParishPriestHistoryScreenState();
}

class _ParishPriestHistoryScreenState extends State<ParishPriestHistoryScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List parish = [];
  int index = 0;

  getParishDetails() async {
    String url = '$baseUrl/res.parish';
    Map data = {
      "params": {
        "filter": "[['id','=',$parishId]]",
        "query": "{priest_history_ids{priest_id{id,image_1920,member_name},role_id,mobile,email,date_from,date_to}}"
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['result']['data']['result'];
      for(int i = 0; i < data.length; i++) {
        parish = data[i]['priest_history_ids'];
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      final message = jsonDecode(response.body)['result'];
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

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getParishDetails();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getParishDetails();
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
      body: SafeArea(
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ),
        ) : parish.isNotEmpty && parish != [] ? SingleChildScrollView(
          child:  AnimationLimiter(
            child: AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Column(
                        children: [
                          AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: parish.length,
                              itemBuilder: (BuildContext context, int indexs) {
                                return Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                parish[indexs]['priest_id']['image_1920'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(parish[indexs]['priest_id']['image_1920'], fit: BoxFit.cover,),
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
                                                    image: parish[indexs]['priest_id']['image_1920'] != null && parish[indexs]['priest_id']['image_1920'] != ''
                                                        ? NetworkImage(parish[indexs]['priest_id']['image_1920'])
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
                                                    parish[indexs]['priest_id']['member_name'] != null && parish[indexs]['priest_id']['member_name'] != '' ? Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text.rich(
                                                            textAlign: TextAlign.left,
                                                            TextSpan(
                                                                text: parish[indexs]['priest_id']['member_name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.018,
                                                                  color: Colors.black87,
                                                                ),
                                                                children: parish[indexs]['role_id']['name'] != null && parish[indexs]['role_id']['name'] != '' ? [
                                                                  const TextSpan(
                                                                    text: '  ',
                                                                  ),
                                                                  TextSpan(
                                                                    text: '(${parish[indexs]['role_id']['name']})',
                                                                    style: GoogleFonts.secularOne(
                                                                        fontSize: size.height * 0.018,
                                                                        color: Colors.black45,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  ),
                                                                ] : []
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ) : parish[indexs]['role_id']['name'] != null && parish[indexs]['role_id']['name'] != '' ? Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text.rich(
                                                            textAlign: TextAlign.left,
                                                            TextSpan(
                                                                text: parish[indexs]['priest_id']['member_name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.018,
                                                                  color: Colors.black87,
                                                                ),
                                                                children: parish[indexs]['role_id']['name'] != null && parish[indexs]['role_id']['name'] != '' ? [
                                                                  const TextSpan(
                                                                    text: '  ',
                                                                  ),
                                                                  TextSpan(
                                                                    text: '(${parish[indexs]['role_id']['name']})',
                                                                    style: GoogleFonts.secularOne(
                                                                        fontSize: size.height * 0.018,
                                                                        color: Colors.black45,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  ),
                                                                ] : []
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ) : Container(),
                                                    parish[indexs]['date_from'] != null && parish[indexs]['date_from'] != '' ? SizedBox(height: size.height * 0.005,) : Container(),
                                                    Row(
                                                      children: [
                                                        Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.access_time_filled, color: Colors.indigo,)),
                                                        parish[indexs]['date_from'].isNotEmpty && parish[indexs]['date_from'] != null && parish[indexs]['date_from'] != '' ? Text("${parish[indexs]['date_from']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : const Text(""),
                                                        SizedBox(width: size.width * 0.05,),
                                                        Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),),
                                                        SizedBox(width: size.width * 0.05,),
                                                        parish[indexs]['date_to'].isNotEmpty && parish[indexs]['date_to'] != null && parish[indexs]['date_to'] != '' ? Text(
                                                          "${parish[indexs]['date_to']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                                        ) : Text(
                                                          "Till Now", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                                        ),
                                                      ],
                                                    ),
                                                    parish[indexs]['email'] != null && parish[indexs]['email'] != '' ? SizedBox(height: size.height * 0.005,) : Container(),
                                                    parish[indexs]['email'] != null && parish[indexs]['email'] != '' ? GestureDetector(
                                                        onTap: () {
                                                          emailAction(parish[indexs]['email']);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                parish[indexs]['email'],
                                                                style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),),
                                                            ),
                                                          ],
                                                        )
                                                    ) : Container(),
                                                    parish[indexs]['mobile'] != null && parish[indexs]['mobile'] != '' ? SizedBox(height: size.height * 0.005,) : Container(),
                                                    parish[indexs]['mobile'] != null && parish[indexs]['mobile'] != '' ? GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                contentPadding: const EdgeInsets.all(10),
                                                                content: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        (parish[indexs]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                          (parish[indexs]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          callAction((parish[indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (parish[indexs]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          callAction((parish[indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : callAction((parish[indexs]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: Colors.blueAccent,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        (parish[indexs]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                          (parish[indexs]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          smsAction((parish[indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (parish[indexs]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          smsAction((parish[indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : smsAction((parish[indexs]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: Colors.orange,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        (parish[indexs]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                          (parish[indexs]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          whatsappAction((parish[indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (parish[indexs]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          whatsappAction((parish[indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : whatsappAction((parish[indexs]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                      color: Colors.green,
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Flexible(child: Text((parish[indexs]['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)),
                                                          ],
                                                        )) : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ) : Expanded(
          child: Center(
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
