import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/private/screens/member/members_details.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HouseMembersListScreen extends StatefulWidget {
  const HouseMembersListScreen({Key? key}) : super(key: key);

  @override
  State<HouseMembersListScreen> createState() => _HouseMembersListScreenState();
}

class _HouseMembersListScreenState extends State<HouseMembersListScreen> {
  bool _isLoading = true;
  List memberList = [];
  List data = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  void changeData() {
    setState(() {
      _isLoading = true;
      houseMembersList();
    });
  }

  assignValues(indexValue, indexName) async {
    id = indexValue;
    name = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MembersDetailsTabBarScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  houseMembersList() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_house_members?args=[$userCommunityId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      memberList = data;
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
    houseMembersList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Members'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A3F85),
                    Color(0xFFFA761E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
      ),
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
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 3,),
                    Text('${memberList.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                memberList.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: memberList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              int indexValue;
                              String indexName = '';
                              indexValue = memberList[index]['id'];
                              indexName = memberList[index]['name'];
                              assignValues(indexValue, indexName);
                            },
                            child: Transform.translate(
                              offset: Offset(-3, -size.height / 70),
                              child: Container(
                                height: size.height * 0.15,
                                padding: const EdgeInsets.symmetric(horizontal: 10,),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: size.height * 0.13,
                                        width: size.width,
                                        padding: EdgeInsets.only(left: size.width * 0.25),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                          boxShadow: const <BoxShadow>[
                                            BoxShadow(
                                              color: Colors.grey,
                                              spreadRadius: -1,
                                              blurRadius: 5 ,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Flexible(
                                              child: Text(
                                                memberList[index]['name'].toUpperCase(),
                                                style: GoogleFonts.secularOne(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.018,
                                                    color: textColor
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            memberList[index]['role'] != null && memberList[index]['role'] != '' ? Flexible(
                                              child: Text(
                                                memberList[index]['role'],
                                                style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontSize: size.height * 0.017,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ) : Flexible(
                                              child: Text(
                                                'No role assigned',
                                                style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontSize: size.height * 0.017,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                            memberList[index]['mobile'] != '' && memberList[index]['mobile'] != null ? Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      (memberList[index]['mobile'] as String)
                                                          .split(',')[0]
                                                          .trim(),
                                                      style: TextStyle(
                                                        color: Colors.blueAccent,
                                                        fontSize: size.height * 0.02,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (memberList[index]['mobile'] != null && memberList[index]['mobile'] != '') IconButton(
                                                          onPressed: () {
                                                            (memberList[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                              (memberList[index]['mobile'] as String).split(',')[0].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              callAction((memberList[index]['mobile'] as String).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (memberList[index]['mobile'] as String).split(',')[1].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              callAction((memberList[index]['mobile'] as String).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : callAction((memberList[index]['mobile'] as String).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.phone),
                                                          color: Colors.blueAccent,
                                                        ),
                                                        if (memberList[index]['mobile'] != null && memberList[index]['mobile'] != '') IconButton(
                                                          onPressed: () {
                                                            (memberList[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                              (memberList[index]['mobile'] as String).split(',')[0].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              smsAction((memberList[index]['mobile'] as String).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (memberList[index]['mobile'] as String).split(',')[1].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              smsAction((memberList[index]['mobile'] as String).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : smsAction((memberList[index]['mobile'] as String).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.message),
                                                          color: Colors.orange,
                                                        ),
                                                        if (memberList[index]['mobile'] != null && memberList[index]['mobile'] != '') IconButton(
                                                          onPressed: () {
                                                            (memberList[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                              (memberList[index]['mobile'] as String).split(',')[0].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              whatsappAction((memberList[index]['mobile'] as String).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (memberList[index]['mobile'] as String).split(',')[1].trim(),
                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              whatsappAction((memberList[index]['mobile'] as String).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : whatsappAction((memberList[index]['mobile'] as String).split(',')[0].trim());
                                                          },
                                                          icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                                          color: Colors.green,
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
                                    Positioned(
                                      top: size.height * 0.03,
                                      left: 0,
                                      right: size.width * 0.68,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            memberList[index]['image_1920'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(memberList[index]['image_1920'], fit: BoxFit.cover,),
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
                                            width: size.width * 0.20,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: memberList[index]['image_1920'] != null && memberList[index]['image_1920'] != ''
                                                    ? NetworkImage(memberList[index]['image_1920'])
                                                    : const AssetImage('assets/images/profile.png') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
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
              ],
            ),
          )
      ),
    );
  }
}
