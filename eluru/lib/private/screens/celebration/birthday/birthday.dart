import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:eluru/widget/common/common.dart';
import 'package:eluru/widget/common/internet_connection_checker.dart';
import 'package:eluru/widget/common/slide_animations.dart';
import 'package:eluru/widget/theme_color/theme_color.dart';
import 'package:eluru/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  List birthday = [];
  String today = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getBirthdayData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_birthday_details_v1?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = [];
      if(birthdayTab == 'Upcoming') {
        data = result['data']['next_30days'];
      } else {
        data = result['data']['results'];
      }
      setState(() {
        _isLoading = false;
      });
      birthday = data;
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
      getBirthdayData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getBirthdayData();
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
        child: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Center(
            child: _isLoading
                ? Center(
              child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/alert/spinner_1.gif"),
                    ),
                  )),
            ) : Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                birthday.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${birthday.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),),
                    const SizedBox(width: 5,),
                  ],
                ) : Container(),
                birthday.isNotEmpty ? SizedBox(
                  height: size.height * 0.01,
                ) : Container(),
                birthdayTab == 'Upcoming' ? birthday.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: birthday.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            today = DateFormat('dd - MMMM').format(now);
                            if(today == birthday[index]['birthday']) {
                              return Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  birthday[index]['birth_image'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(birthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                                  height: size.height * 0.1,
                                                  width: size.width * 0.16,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: <BoxShadow>[
                                                      if(birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != '') const BoxShadow(
                                                        color: Colors.grey,
                                                        spreadRadius: -1,
                                                        blurRadius: 5 ,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != ''
                                                          ? NetworkImage(birthday[index]['birth_image'])
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
                                                      Flexible(
                                                        child: Text(
                                                          birthday[index]['name'],
                                                          style: TextStyle(
                                                              fontSize: size.height * 0.02,
                                                              fontWeight: FontWeight.bold,
                                                              color: textHeadColor
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.01,
                                                      ),
                                                      Text(
                                                        birthday[index]['birthday'],
                                                        style: GoogleFonts.lalezar(fontSize: size.height * 0.02, color: emptyColor),
                                                      ),
                                                      birthday[index]['mobile'] != '' && birthday[index]['mobile'] != null ? Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                (birthday[index]['mobile'] as String)
                                                                    .split(',')[0]
                                                                    .trim(),
                                                                style: TextStyle(
                                                                  color: mobileText,
                                                                  fontSize: size.height * 0.02,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  if (birthday[index]['mobile'] != null && birthday[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (birthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (birthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        callAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (birthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        callAction((birthday[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : callAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: const Icon(Icons.phone),
                                                                    color: callColor,
                                                                  ),
                                                                  if (birthday[index]['mobile'] != null && birthday[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (birthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (birthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        smsAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (birthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        smsAction((birthday[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : smsAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: const Icon(Icons.message),
                                                                    color: smsColor,
                                                                  ),
                                                                  if (birthday[index]['mobile'] != null && birthday[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (birthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (birthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        whatsappAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (birthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        whatsappAction((birthday[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : whatsappAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                    color: whatsAppColor,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ) : Container()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: size.height * 0.03,
                                          right: size.width * 0.01,
                                          child: Center(
                                            child: Container(
                                              height: size.height * 0.06,
                                              width: size.width * 0.2,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage( "assets/images/happy-birthday.gif"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                ],
                              );
                            } else {
                              return Container(
                                padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            birthday[index]['birth_image'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(birthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                            height: size.height * 0.08,
                                            width: size.width * 0.15,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: <BoxShadow>[
                                                if(birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != '') const BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: -1,
                                                  blurRadius: 5 ,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != ''
                                                    ? NetworkImage(birthday[index]['birth_image'])
                                                    : const AssetImage('assets/images/profile.png') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        birthday[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            color: valueColor
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${birthday[index]['birthday']}",
                                                      style: GoogleFonts.lalezar(fontSize: size.height * 0.02, color: emptyColor),
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
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
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
                  ),
                ) : birthday.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: birthday.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            var todays = DateFormat('dd - MMMM').format(now);
                            return Container(
                              padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                              child: Stack(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              birthday[index]['birth_image'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(birthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                              height: size.height * 0.08,
                                              width: size.width * 0.15,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: <BoxShadow>[
                                                  if(birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != '') const BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: -1,
                                                    blurRadius: 5 ,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != ''
                                                      ? NetworkImage(birthday[index]['birth_image'])
                                                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          birthday[index]['name'],
                                                          style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.02,
                                                              color: valueColor
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${birthday[index]['birthday']}",
                                                        style: GoogleFonts.lalezar(fontSize: size.height * 0.02, color: emptyColor),
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
                                  if(todays == birthday[index]['birthday']) Positioned(
                                    bottom: size.height * 0.01,
                                    right: size.width * 0.01,
                                    child: Center(
                                      child: Container(
                                        height: size.height * 0.05,
                                        width: size.width * 0.1,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage( "assets/images/birthday.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}