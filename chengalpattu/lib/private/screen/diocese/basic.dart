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

class DioceseBasicScreen extends StatefulWidget {
  const DioceseBasicScreen({Key? key}) : super(key: key);

  @override
  State<DioceseBasicScreen> createState() => _DioceseBasicScreenState();
}

class _DioceseBasicScreenState extends State<DioceseBasicScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List diocese = [];
  int index= 0;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getDioceseData() async {
    String url = '$baseUrl/res.ecclesia.diocese';
    Map data = {
      "params": {
        "filter": "[['id', '=', $userDiocese ]]",
        "query": "{id,image_1920,name,bishop_id,street,street2,city,district_id,state_id,country_id,zip,mobile,phone,email,website,history,org_image_ids,establishment_date,vision,mission}"
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
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      diocese = data;
    }
    else {
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

  Future<void> webAction(String web) async {
    var url = web;
    if(await canLaunch(url)){
      await launch(
        web,
        forceWebView: true,
        enableJavaScript: true,
        universalLinksOnly: false,
      );
    } else {
      throw 'Could not launch $url';
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
      getDioceseData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDioceseData();
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
        ) : diocese.isNotEmpty ? AnimationLimiter(
          child: AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  padding: EdgeInsets.only(left: size.width * 0.02, right: size.width * 0.02),
                  child: ListView(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Est. Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['establishment_date'] != null && diocese[index]['establishment_date'] != '' ? Flexible(child: Text(diocese[index]['establishment_date'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Vision', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['vision'] != null && diocese[index]['vision'] != '' ? Flexible(child: Text(diocese[index]['vision'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mission', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['mission'] != null && diocese[index]['mission'] != '' ? Flexible(child: Text(diocese[index]['mission'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['email'] != null && diocese[index]['email'] != '' ? Flexible(
                                    child: GestureDetector(
                                        onTap: () {
                                          emailAction(diocese[index]['email']);
                                        },
                                        child: Text(
                                          diocese[index]['email'],
                                          style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),)
                                    ),
                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['mobile'] != null && diocese[index]['mobile'] != '' ? Flexible(
                                    child: GestureDetector(
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
                                                        (diocese[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                          (diocese[index]['mobile']).split(',')[0].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          callAction((diocese[index]['mobile']).split(',')[0].trim());
                                                                        },
                                                                      ),
                                                                      const Divider(),
                                                                      ListTile(
                                                                        title: Text(
                                                                          (diocese[index]['mobile']).split(',')[1].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          callAction((diocese[index]['mobile']).split(',')[1].trim());
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ) : callAction((diocese[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: Colors.blueAccent,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        (diocese[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                          (diocese[index]['mobile']).split(',')[0].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          smsAction((diocese[index]['mobile']).split(',')[0].trim());
                                                                        },
                                                                      ),
                                                                      const Divider(),
                                                                      ListTile(
                                                                        title: Text(
                                                                          (diocese[index]['mobile']).split(',')[1].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          smsAction((diocese[index]['mobile']).split(',')[1].trim());
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ) : smsAction((diocese[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: Colors.orange,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        (diocese[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                          (diocese[index]['mobile']).split(',')[0].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          whatsappAction((diocese[index]['mobile']).split(',')[0].trim());
                                                                        },
                                                                      ),
                                                                      const Divider(),
                                                                      ListTile(
                                                                        title: Text(
                                                                          (diocese[index]['mobile']).split(',')[1].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          whatsappAction((diocese[index]['mobile']).split(',')[1].trim());
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ) : whatsappAction((diocese[index]['mobile']).split(',')[0].trim());
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
                                        child: Text((diocese[index]['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)),
                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Phone', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['phone'] != null && diocese[index]['phone'] != '' ? Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        callAction(diocese[index]['phone']);
                                      },
                                      child: Text(
                                        diocese[index]['phone'],
                                        style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),
                                      ),
                                    ),
                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Website', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  diocese[index]['website'] != null && diocese[index]['website'] != '' ? Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        webAction(diocese[index]['website']);
                                      },
                                      child: Text(
                                        diocese[index]['website'],
                                        style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),
                                      ),
                                    ),
                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      diocese[index]['street'] != null && diocese[index]['street'] != '' ? Text(diocese[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                      diocese[index]['street2'] != null && diocese[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                                      diocese[index]['street2'] != null && diocese[index]['street2'] != '' ? Text(diocese[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                      const SizedBox(height: 3,),
                                      diocese[index]['city'] != null && diocese[index]['city'] != '' ? Text(diocese[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                      const SizedBox(height: 3,),
                                      diocese[index]['district_id']['name'] != null && diocese[index]['district_id']['name'] != '' ? Text(diocese[index]['district_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                      const SizedBox(height: 3,),
                                      diocese[index]['state_id']['name'] != null && diocese[index]['state_id']['name'] != '' ? Text(diocese[index]['state_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                      const SizedBox(height: 3,),
                                      (diocese[index]['country_id']['name'] != null && diocese[index]['country_id']['name'] != '' && diocese[index]['zip'] != null && diocese[index]['zip'] != '') ? Text("${diocese[index]['country_id']['name']}  -  ${diocese[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      )
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
