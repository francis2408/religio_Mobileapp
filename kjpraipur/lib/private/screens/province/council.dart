import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProvinceCouncilDetailsScreen extends StatefulWidget {
  const ProvinceCouncilDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceCouncilDetailsScreen> createState() => _ProvinceCouncilDetailsScreenState();
}

class _ProvinceCouncilDetailsScreenState extends State<ProvinceCouncilDetailsScreen> {
  int index = 0;
  bool _isLoading = true;
  List members = [];
  String councilName = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getProvinceHeadData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.religious.province/api_get_province_head_members?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      members = data;
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

  Future<void> smsAction(String number) async {
    const countryCode = '+91'; // Indian country code
    // Remove any non-digit characters from the phone number
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    final Uri uri = Uri(scheme: "sms", path: formattedNumber);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    const countryCode = '+91'; // Indian country code
    // Remove any non-digit characters from the phone number
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    final Uri uri = Uri(scheme: 'tel', path: formattedNumber);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Can not launch URL';
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    // Remove any non-digit characters from the phone number
    final cleanNumber = whatsapp.replaceAll(RegExp(r'\D'), '');
    // Extract the country code from the WhatsApp number
    const countryCode = '91'; // Assuming country code length is 2
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    if (Platform.isAndroid) {
      final whatsappUrl = 'whatsapp://send?phone=$formattedNumber';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    } else {
      final whatsappUrl = 'https://api.whatsapp.com/send?phone=$formattedNumber';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
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
    if (await canLaunch(web)) {
      await launch(
        web,
        forceWebView: true,
        forceSafariVC: false, // Set this to false for Android devices
      );
    } else {
      throw 'Could not launch $web';
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

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    super.initState();
    getProvinceHeadData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: Container(
              height: size.height * 0.1,
              width: size.width * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage( "assets/alert/spinner_1.gif"),
                ),
              )
          ),
        ) : members.isNotEmpty ? SlideFadeAnimation(
          duration: const Duration(seconds: 1),
          child: SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                // scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.18, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  members[index]['member_name'] != '' && members[index]['member_name'] != null ? Flexible(child: Text('${members[index]['member_name']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.015,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: size.width * 0.18, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  members[index]['role'] != '' && members[index]['role'] != null ? Flexible(child: Text('${members[index]['role']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              members[index]['email'] != null && members[index]['email'] != '' ? SizedBox(height: size.height * 0.015,) : Container(),
                              Row(
                                children: [
                                  Container(width: size.width * 0.18, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  members[index]['email'] != null && members[index]['email'] != '' ? Flexible(child: GestureDetector(onTap: () {emailAction(members[index]['email']);},child: Text('${members[index]['email']}', style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              members[index]['mobile'] != null && members[index]['mobile'] != '' ? Container() : SizedBox(height: size.height * 0.015,),
                              Row(
                                children: [
                                  Container(width: size.width * 0.18, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                  members[index]['mobile'] != null && members[index]['mobile'] != '' ? Text((members[index]['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  members[index]['mobile'] != null && members[index]['mobile'] != '' ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                        onPressed: () {
                                          (members[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                            (members[index]['mobile']).split(',')[0].trim(),
                                                            style: const TextStyle(color: Colors.blueAccent),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(context); // Close the dialog
                                                            callAction((members[index]['mobile']).split(',')[0].trim());
                                                          },
                                                        ),
                                                        const Divider(),
                                                        ListTile(
                                                          title: Text(
                                                            (members[index]['mobile']).split(',')[1].trim(),
                                                            style: const TextStyle(color: Colors.blueAccent),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(context); // Close the dialog
                                                            callAction((members[index]['mobile']).split(',')[1].trim());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ) : callAction((members[index]['mobile']).split(',')[0].trim());
                                        },
                                        icon: const Icon(Icons.phone),
                                        color: Colors.blueAccent,
                                      ),
                                      if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                        onPressed: () {
                                          (members[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                            (members[index]['mobile']).split(',')[0].trim(),
                                                            style: const TextStyle(color: Colors.blueAccent),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(context); // Close the dialog
                                                            smsAction((members[index]['mobile']).split(',')[0].trim());
                                                          },
                                                        ),
                                                        const Divider(),
                                                        ListTile(
                                                          title: Text(
                                                            (members[index]['mobile']).split(',')[1].trim(),
                                                            style: const TextStyle(color: Colors.blueAccent),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(context); // Close the dialog
                                                            smsAction((members[index]['mobile']).split(',')[1].trim());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ) : smsAction((members[index]['mobile']).split(',')[0].trim());
                                        },
                                        icon: const Icon(Icons.message),
                                        color: Colors.orange,
                                      ),
                                      if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                        onPressed: () {
                                          (members[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                            (members[index]['mobile']).split(',')[0].trim(),
                                                            style: const TextStyle(color: Colors.blueAccent),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(context); // Close the dialog
                                                            whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                          },
                                                        ),
                                                        const Divider(),
                                                        ListTile(
                                                          title: Text(
                                                            (members[index]['mobile']).split(',')[1].trim(),
                                                            style: const TextStyle(color: Colors.blueAccent),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(context); // Close the dialog
                                                            whatsappAction((members[index]['mobile']).split(',')[1].trim());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ) : whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                        },
                                        icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                        color: Colors.green,
                                      ),
                                    ],
                                  ) : Container()
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.01,)
                      ],
                    ),
                  );
                }
            ),
          ),
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: NoResult(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  text: 'No Data available',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
