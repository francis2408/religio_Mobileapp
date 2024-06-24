import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class InstitutionMembersListScreen extends StatefulWidget {
  const InstitutionMembersListScreen({Key? key}) : super(key: key);

  @override
  State<InstitutionMembersListScreen> createState() => _InstitutionMembersListScreenState();
}

class _InstitutionMembersListScreenState extends State<InstitutionMembersListScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List memberList = [];
  List data = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  void changeData() {
    setState(() {
      _isLoading = true;
      institutionMembersList();
    });
  }

  assignValues(indexValue, indexName) async {
    id = indexValue;
    name = indexName;

    // String refresh = await Navigator.push(context,
    //     MaterialPageRoute(builder: (context) => const MembersDetailsTabBarScreen()));
    //
    // if(refresh == 'refresh') {
    //   changeData();
    // }
  }

  institutionMembersList() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_institution_members?args=[$userInstituteId]"));
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      institutionMembersList();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            institutionMembersList();
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
        title: const Text('Members'),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        toolbarHeight: 50,
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
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${memberList.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
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
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            memberList[index]['image_512']  != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(memberList[index]['image_512'] , fit: BoxFit.cover,),
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
                                                image: memberList[index]['image_512'] != null && memberList[index]['image_512'] != ''
                                                    ? NetworkImage(memberList[index]['image_512'])
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
                                                        memberList[index]['full_name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          color: textHeadColor,
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
                                                    memberList[index]['role'] != null && memberList[index]['role'] != '' ? Flexible(
                                                      child: Text(
                                                        memberList[index]['role'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.017,
                                                          color: emptyColor,
                                                        ),
                                                      ),
                                                    ) : Flexible(
                                                      child: Text(
                                                        'No role assigned',
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.017,
                                                          color: emptyColor,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                memberList[index]['mobile'] != '' && memberList[index]['mobile'] != null ? Row(
                                                  children: [
                                                    Text(
                                                      (memberList[index]['mobile'] as String)
                                                          .split(',')[0]
                                                          .trim(),
                                                      style: TextStyle(
                                                        color: mobileText,
                                                        fontSize: size.height * 0.018,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if(memberList[index]['mobile'] != null && memberList[index]['mobile'] != '') IconButton(
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
                                                                              style: const TextStyle(color: mobileText),
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
                                                                              style: const TextStyle(color: mobileText),
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
                                                          color: callColor,
                                                        ),
                                                        if(memberList[index]['mobile'] != null && memberList[index]['mobile'] != '') IconButton(
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
                                                                              style: const TextStyle(color: mobileText),
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
                                                                              style: const TextStyle(color: mobileText),
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
                                                          color: smsColor,
                                                        ),
                                                        if(memberList[index]['mobile'] != null && memberList[index]['mobile'] != '') IconButton(
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
                                                                              style: const TextStyle(color: mobileText),
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
                                                                              style: const TextStyle(color: mobileText),
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
                                                          icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                          color: whatsAppColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ) : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: size.height * 0.01,
                                    right: size.width * 0.02,
                                    child: Container(
                                      height: size.height * 0.028,
                                      width: size.width * 0.06,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: memberList[index]['member_type'] == 'Sister' ? Colors.green : memberList[index]['member_type'] == 'Junior Sister' ? Colors.pinkAccent : memberList[index]['member_type'] == 'Novice' ? Colors.indigo : memberList[index]['member_type'] == 'Candidacy' ? Colors.cyan : memberList[index]['member_type'] == 'Postulancy' ? Colors.purpleAccent : Colors.redAccent,
                                      ),
                                      child: memberList[index]['member_type'] == 'Sister' ? Text('S',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : memberList[index]['member_type'] == 'Junior Sister' ? Text('JS',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : memberList[index]['member_type'] == 'Novice' ? Text('N',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : memberList[index]['member_type'] == 'Candidacy' ? Text('C',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : memberList[index]['member_type'] == 'Postulancy' ? Text('PO',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : Text('RS',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
