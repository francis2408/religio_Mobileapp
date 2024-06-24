import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:svdinm/widget/common/common.dart';
import 'package:svdinm/widget/common/internet_connection_checker.dart';
import 'package:svdinm/widget/common/slide_animations.dart';
import 'package:svdinm/widget/theme_color/theme_color.dart';
import 'package:svdinm/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProvinceCouncilDetailsScreen extends StatefulWidget {
  const ProvinceCouncilDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceCouncilDetailsScreen> createState() => _ProvinceCouncilDetailsScreenState();
}

class _ProvinceCouncilDetailsScreenState extends State<ProvinceCouncilDetailsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
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
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Can not launch URL';
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    if (Platform.isAndroid) {
      final whatsappUrl = 'whatsapp://send?phone=$whatsapp';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    } else {
      final whatsappUrl = 'https://api.whatsapp.com/send?phone=$whatsapp';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    }
  }

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Can not launch url";
    }
  }

  Future<void> webAction(String web) async {
    if (await canLaunch(web)) {
      await launch(web,forceWebView: true,forceSafariVC: false);
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getProvinceHeadData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getProvinceHeadData();
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    members[index]['image'] != '' ? showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Image.network(members[index]['image'], fit: BoxFit.cover,),
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
                                      boxShadow: <BoxShadow>[
                                        if(members[index]['image'] != null && members[index]['image'] != '') const BoxShadow(
                                          color: Colors.grey,
                                          spreadRadius: -1,
                                          blurRadius: 5 ,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: members[index]['image'] != null && members[index]['image'] != ''
                                            ? NetworkImage(members[index]['image'])
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
                                                members[index]['member_name'],
                                                style: GoogleFonts.secularOne(
                                                    fontSize: size.height * 0.018,
                                                    color: menuTextColor
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
                                            members[index]['role'] != null && members[index]['role'] != '' ? Flexible(
                                              child: Text(
                                                members[index]['role'],
                                                style: GoogleFonts.secularOne(
                                                  fontSize: size.height * 0.017,
                                                  color: emptyColor,
                                                ),
                                              ),
                                            ) : Flexible(
                                              child: Text(
                                                'No role assigned',
                                                style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontSize: size.height * 0.017,
                                                  color: emptyColor,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        members[index]['email'] != null && members[index]['email'] != '' ? SizedBox(
                                          height: size.height * 0.005,
                                        ) : Container(),
                                        Row(
                                          children: [
                                            members[index]['email'] != null && members[index]['email'] != '' ? Flexible(
                                                child: GestureDetector(
                                                    onTap: () {
                                                      emailAction(members[index]['email']);
                                                      },
                                                    child: Text(
                                                      '${members[index]['email']}',
                                                      style: GoogleFonts.secularOne(
                                                          color: emailColor,
                                                          fontSize: size.height * 0.017
                                                      ),
                                                    )
                                                )
                                            ) : Container(),
                                          ],
                                        ),
                                        members[index]['mobile'] != '' && members[index]['mobile'] != null && (members[index]['mobile']).split(',').length != 1 ? SizedBox(
                                          height: size.height * 0.005,
                                        ) : Container(),
                                        Row(
                                          children: [
                                            members[index]['mobile'] != '' && members[index]['mobile'] != null ? IntrinsicHeight(
                                              child: (members[index]['mobile']).split(',').length != 1 ? Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            contentPadding: const EdgeInsets.all(10),
                                                            content: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    callAction((members[index]['mobile']).split(',')[0].trim());
                                                                  },
                                                                  icon: const Icon(Icons.phone),
                                                                  color: callColor,
                                                                ),
                                                                IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    smsAction((members[index]['mobile']).split(',')[0].trim());
                                                                  },
                                                                  icon: const Icon(Icons.message),
                                                                  color: smsColor,
                                                                ),
                                                                IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                                  },
                                                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                  color: whatsAppColor,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      (members[index]['mobile']).split(',')[0].trim(),
                                                      style: GoogleFonts.secularOne(
                                                          color: mobileText,
                                                          fontSize: size.height * 0.017
                                                      ),),
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  const VerticalDivider(
                                                    color: Colors.grey,
                                                    thickness: 2,
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            contentPadding: const EdgeInsets.all(10),
                                                            content: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    callAction((members[index]['mobile']).split(',')[1].trim());
                                                                  },
                                                                  icon: const Icon(Icons.phone),
                                                                  color: callColor,
                                                                ),
                                                                IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    smsAction((members[index]['mobile']).split(',')[1].trim());
                                                                  },
                                                                  icon: const Icon(Icons.message),
                                                                  color: smsColor,
                                                                ),
                                                                IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    whatsappAction((members[index]['mobile']).split(',')[1].trim());
                                                                  },
                                                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                  color: whatsAppColor,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      (members[index]['mobile']).split(',')[1].trim(),
                                                      style: GoogleFonts.secularOne(
                                                          color: mobileText,
                                                          fontSize: size.height * 0.017
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ) : Row(
                                                children: [
                                                  Text(
                                                    (members[index]['mobile']).split(',')[0].trim(),
                                                    style: GoogleFonts.secularOne(
                                                      color: mobileText,
                                                      fontSize: size.height * 0.017,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          callAction((members[index]['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: callColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          smsAction((members[index]['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: smsColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                        color: whatsAppColor,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ) : Container(),
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
