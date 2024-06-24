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

class ParishBasicScreen extends StatefulWidget {
  const ParishBasicScreen({Key? key}) : super(key: key);

  @override
  State<ParishBasicScreen> createState() => _ParishBasicScreenState();
}

class _ParishBasicScreenState extends State<ParishBasicScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List parish = [];
  List assPriest = [];
  int index = 0;

  getParishDetails() async {
    String url = '$baseUrl/res.parish';
    Map data = {
      "params": {
        "filter": "[['id','=',$parishId]]",
        "query": "{id,image_1920,name,diocese_id,vicariate_id,mobile,email,phone,establishment_date,street,street2,city,district_id,state_id,country_id,zip,priest_id{id,image_1920,member_name,email,mobile,role_ids},ass_priest_id{id,image_1920,member_name,email,mobile,role_ids},patron_id,priest_history_ids}"
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
      setState(() {
        _isLoading = false;
      });
      parish = data;
      for(int i = 0; i < parish.length; i++) {
        if(parish[i]['ass_priest_id'].isNotEmpty && parish[i]['ass_priest_id'] != []) {
          assPriest = parish[i]['ass_priest_id'];
        }
      }
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
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  parish[index]['street'] != null && parish[index]['street'] != '' ? Flexible(child: Text(parish[index]['street'], style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.022), textAlign: TextAlign.center,)) : Container(),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.21, alignment: Alignment.topLeft, child: Text('Patron', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  parish[index]['patron_id']['name'] != null && parish[index]['patron_id']['name'] != '' ? Flexible(child: Text(parish[index]['patron_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.21, alignment: Alignment.topLeft, child: Text('Vicariate', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  parish[index]['vicariate_id']['name'] != null && parish[index]['vicariate_id']['name'] != '' ? Flexible(child: Text(parish[index]['vicariate_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.21, alignment: Alignment.topLeft, child: Text('Est. Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  parish[index]['establishment_date'] != null && parish[index]['establishment_date'] != '' ? Flexible(child: Text(parish[index]['establishment_date'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
                                  parish[index]['priest_id']['image_1920'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(parish[index]['priest_id']['image_1920'], fit: BoxFit.cover,),
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
                                      image: parish[index]['priest_id']['image_1920'] != null && parish[index]['priest_id']['image_1920'] != ''
                                          ? NetworkImage(parish[index]['priest_id']['image_1920'])
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
                                      parish[index]['priest_id']['member_name'] != null && parish[index]['priest_id']['member_name'] != '' ? Row(
                                        children: [
                                          Flexible(
                                            child: Text.rich(
                                              textAlign: TextAlign.left,
                                              TextSpan(
                                                  text: parish[index]['priest_id']['member_name'],
                                                  style: GoogleFonts.secularOne(
                                                    fontSize: size.height * 0.018,
                                                    color: Colors.black87,
                                                  ),
                                                  children: parish[index]['priest_id']['role_ids_view'] != null && parish[index]['priest_id']['role_ids_view'] != '' ? [
                                                    const TextSpan(
                                                      text: '  ',
                                                    ),
                                                    TextSpan(
                                                      text: '(${parish[index]['priest_id']['role_ids_view']})',
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
                                      ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      parish[index]['priest_id']['email'] != null && parish[index]['priest_id']['email'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                      parish[index]['priest_id']['email'] != null && parish[index]['priest_id']['email'] != '' ? GestureDetector(
                                          onTap: () {
                                            emailAction(parish[index]['priest_id']['email']);
                                          },
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  parish[index]['priest_id']['email'],
                                                  style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),),
                                              ),
                                            ],
                                          )
                                      ) : Container(),
                                      parish[index]['priest_id']['mobile'] != null && parish[index]['priest_id']['mobile'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                      parish[index]['priest_id']['mobile'] != null && parish[index]['priest_id']['mobile'] != '' ? GestureDetector(
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
                                                          (parish[index]['priest_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                            (parish[index]['priest_id']['mobile']).split(',')[0].trim(),
                                                                            style: const TextStyle(color: Colors.blueAccent),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.pop(context); // Close the dialog
                                                                            callAction((parish[index]['priest_id']['mobile']).split(',')[0].trim());
                                                                          },
                                                                        ),
                                                                        const Divider(),
                                                                        ListTile(
                                                                          title: Text(
                                                                            (parish[index]['priest_id']['mobile']).split(',')[1].trim(),
                                                                            style: const TextStyle(color: Colors.blueAccent),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.pop(context); // Close the dialog
                                                                            callAction((parish[index]['priest_id']['mobile']).split(',')[1].trim());
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ) : callAction((parish[index]['priest_id']['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: Colors.blueAccent,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          (parish[index]['priest_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                            (parish[index]['priest_id']['mobile']).split(',')[0].trim(),
                                                                            style: const TextStyle(color: Colors.blueAccent),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.pop(context); // Close the dialog
                                                                            smsAction((parish[index]['priest_id']['mobile']).split(',')[0].trim());
                                                                          },
                                                                        ),
                                                                        const Divider(),
                                                                        ListTile(
                                                                          title: Text(
                                                                            (parish[index]['priest_id']['mobile']).split(',')[1].trim(),
                                                                            style: const TextStyle(color: Colors.blueAccent),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.pop(context); // Close the dialog
                                                                            smsAction((parish[index]['priest_id']['mobile']).split(',')[1].trim());
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ) : smsAction((parish[index]['priest_id']['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: Colors.orange,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          (parish[index]['priest_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                            (parish[index]['priest_id']['mobile']).split(',')[0].trim(),
                                                                            style: const TextStyle(color: Colors.blueAccent),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.pop(context); // Close the dialog
                                                                            whatsappAction((parish[index]['priest_id']['mobile']).split(',')[0].trim());
                                                                          },
                                                                        ),
                                                                        const Divider(),
                                                                        ListTile(
                                                                          title: Text(
                                                                            (parish[index]['priest_id']['mobile']).split(',')[1].trim(),
                                                                            style: const TextStyle(color: Colors.blueAccent),
                                                                          ),
                                                                          onTap: () {
                                                                            Navigator.pop(context); // Close the dialog
                                                                            whatsappAction((parish[index]['priest_id']['mobile']).split(',')[1].trim());
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ) : whatsappAction((parish[index]['priest_id']['mobile']).split(',')[0].trim());
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
                                              Flexible(child: Text((parish[index]['priest_id']['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)),
                                            ],
                                          )
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      assPriest.isNotEmpty ? Column(
                        children: [
                          AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: assPriest.length,
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
                                                assPriest[indexs]['image_1920'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(assPriest[indexs]['image_1920'], fit: BoxFit.cover,),
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
                                                    image: assPriest[indexs]['image_1920'] != null && assPriest[indexs]['image_1920'] != ''
                                                        ? NetworkImage(assPriest[indexs]['image_1920'])
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
                                                    assPriest[indexs]['member_name'] != null && assPriest[indexs]['member_name'] != '' ? Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text.rich(
                                                            textAlign: TextAlign.left,
                                                            TextSpan(
                                                                text: assPriest[indexs]['member_name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.018,
                                                                  color: Colors.black87,
                                                                ),
                                                                children: assPriest[indexs]['role_ids_view'] != null && assPriest[index]['role_ids_view'] != '' ? [
                                                                  const TextSpan(
                                                                    text: '  ',
                                                                  ),
                                                                  TextSpan(
                                                                    text: '(${assPriest[indexs]['role_ids_view']})',
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
                                                    assPriest[indexs]['email'] != null && assPriest[indexs]['email'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                                    assPriest[indexs]['email'] != null && assPriest[indexs]['email'] != '' ? GestureDetector(
                                                        onTap: () {
                                                          emailAction(assPriest[indexs]['email']);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                assPriest[indexs]['email'],
                                                                style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),),
                                                            ),
                                                          ],
                                                        )
                                                    ) : Container(),
                                                    assPriest[indexs]['mobile'] != null && assPriest[indexs]['mobile'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                                    assPriest[indexs]['mobile'] != null && assPriest[indexs]['mobile'] != '' ? GestureDetector(
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
                                                                        (assPriest[indexs]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                          (assPriest[indexs]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          callAction((assPriest[indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (assPriest[indexs]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          callAction((assPriest[indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : callAction((assPriest[indexs]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: Colors.blueAccent,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        (assPriest[indexs]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                          (assPriest[indexs]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          smsAction((assPriest[indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (assPriest[indexs]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          smsAction((assPriest[indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : smsAction((assPriest[indexs]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: Colors.orange,
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () {
                                                                        (assPriest[indexs]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                          (assPriest[indexs]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          whatsappAction((assPriest[indexs]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (assPriest[indexs]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          whatsappAction((assPriest[indexs]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : whatsappAction((assPriest[indexs]['mobile']).split(',')[0].trim());
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
                                                            Flexible(child: Text((assPriest[indexs]['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)),
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
                      ) : Container(),
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
                                  Container(width: size.width * 0.21, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        parish[index]['street'] != null && parish[index]['street'] != '' ? Text(parish[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                        parish[index]['street2'] != null && parish[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                                        parish[index]['street2'] != null && parish[index]['street2'] != '' ? Text(parish[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                        const SizedBox(height: 3,),
                                        parish[index]['city'] != null && parish[index]['city'] != '' ? Text(parish[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                        const SizedBox(height: 3,),
                                        parish[index]['district_id']['name'] != null && parish[index]['district_id']['name'] != '' ? Text(parish[index]['district_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                        const SizedBox(height: 3,),
                                        parish[index]['state_id']['name'] != null && parish[index]['state_id']['name'] != '' ? Text(parish[index]['state_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                        const SizedBox(height: 3,),
                                        (parish[index]['country_id']['name'] != null && parish[index]['country_id']['name'] != '' && parish[index]['zip'] != null && parish[index]['zip'] != '') ? Text("${parish[index]['country_id']['name']}  -  ${parish[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                        parish[index]['email'] != null && parish[index]['email'] != '' ? const SizedBox(height: 3,) : Container(),
                                        parish[index]['email'] != null && parish[index]['email'] != '' ? GestureDetector(
                                            onTap: () {
                                              emailAction(parish[index]['email']);
                                            },
                                            child: Text(
                                              parish[index]['email'],
                                              style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),)
                                        ) : Container(),
                                        parish[index]['mobile'] != null && parish[index]['mobile'] != '' ? const SizedBox(height: 3,) : Container(),
                                        parish[index]['mobile'] != null && parish[index]['mobile'] != '' ? GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    contentPadding: const EdgeInsets.all(10),
                                                    content: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            (parish[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                              (parish[index]['mobile']).split(',')[0].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              callAction((parish[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (parish[index]['mobile']).split(',')[1].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              callAction((parish[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : callAction((parish[index]['mobile']).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.phone),
                                                          color: Colors.blueAccent,
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            (parish[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                              (parish[index]['mobile']).split(',')[0].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              smsAction((parish[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (parish[index]['mobile']).split(',')[1].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              smsAction((parish[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : smsAction((parish[index]['mobile']).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.message),
                                                          color: Colors.orange,
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            (parish[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                              (parish[index]['mobile']).split(',')[0].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              whatsappAction((parish[index]['mobile']).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (parish[index]['mobile']).split(',')[1].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              whatsappAction((parish[index]['mobile']).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : whatsappAction((parish[index]['mobile']).split(',')[0].trim());
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
                                            child: Text((parish[index]['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)) : Container(),
                                        parish[index]['phone'] != null && parish[index]['phone'] != '' ? const SizedBox(height: 3,) : Container(),
                                        parish[index]['phone'] != null && parish[index]['phone'] != '' ? GestureDetector(
                                          onTap: () {
                                            callAction(parish[index]['phone']);
                                          },
                                          child: Text(
                                            parish[index]['phone'],
                                            style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
