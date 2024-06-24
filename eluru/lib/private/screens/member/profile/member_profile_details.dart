import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:eluru/widget/common/common.dart';
import 'package:eluru/widget/common/internet_connection_checker.dart';
import 'package:eluru/widget/theme_color/theme_color.dart';
import 'package:eluru/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'member_profile_details/view_member_profile.dart';
import 'members_basic_details/education.dart';
import 'members_basic_details/emergency_contact.dart';
import 'members_basic_details/family_info.dart';
import 'members_basic_details/formation.dart';
import 'members_basic_details/holy_order.dart';
import 'members_basic_details/ministry.dart';
import 'members_basic_details/profession.dart';
import 'members_basic_details/publication.dart';
import 'members_basic_details/statutory_renewals.dart';

class MemberProfileTabbarScreen extends StatefulWidget {
  const MemberProfileTabbarScreen({Key? key}) : super(key: key);

  @override
  State<MemberProfileTabbarScreen> createState() => _MemberProfileTabbarScreenState();
}

class _MemberProfileTabbarScreenState extends State<MemberProfileTabbarScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List member = [];
  int index = 0;

  List<Widget> tabsContent = [
    const ViewMemberProfileScreen(),
    const MemberEducationScreen(),
    const MemberProfessionScreen(),
    const MemberFormationScreen(),
    const MemberHolyOrderScreen(),
    const MemberFamilyInfoScreen(),
    const MemberMinistryScreen(),
    const MemberEmergencyContactScreen(),
    const MemberPublicationScreen(),
    const MemberStatutoryRenewalsScreen(),
  ];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['member_name','image_512','mobile','email','member_type']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      member = data;
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
      final whatsappUrl = 'whatsapp://send?phone=$whatsapp';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    } else {
      final whatsappUrl = 'https://api.whatsapp.com/send?phone=$whatsapp';
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
      getMemberDetails();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberDetails();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    clearImageCache();
    super.dispose();
    myProfile = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
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
        ) : DefaultTabController(
          length: 10,
          child: Stack(
              children: [
                Positioned.fill(
                  top: 0,
                  child: Image.asset(
                    'assets/images/one.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 120),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Container(
                            alignment: Alignment.center,
                            child: Text(
                              member[index]['member_name'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.secularOne(
                                letterSpacing: 1,
                                fontSize: size.height * 0.025,
                                color: textHeadColor,
                              ),
                            )
                        ),
                        const SizedBox(height: 5),
                        member[index]['mobile'] != '' && member[index]['email'] != '' ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  // color: Colors.white10,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    (member[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                      (member[index]['mobile']).split(',')[0].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      callAction((member[index]['mobile']).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (member[index]['mobile']).split(',')[1].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      callAction((member[index]['mobile']).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : callAction((member[index]['mobile']).split(',')[0].trim());
                                  },
                                  icon: Icon(Icons.phone, size: size.height * 0.030,),
                                  color: callColor,
                                )
                            ),
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  // color: Colors.white10,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    (member[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                      (member[index]['mobile']).split(',')[0].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      smsAction((member[index]['mobile']).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (member[index]['mobile']).split(',')[1].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      smsAction((member[index]['mobile']).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : smsAction((member[index]['mobile']).split(',')[0].trim());
                                  },
                                  icon: Icon(Icons.message, size: size.height * 0.030,),
                                  color: smsColor,
                                )
                            ),
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  // color: Colors.white,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    (member[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                      (member[index]['mobile']).split(',')[0].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((member[index]['mobile']).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (member[index]['mobile']).split(',')[1].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((member[index]['mobile']).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : whatsappAction((member[index]['mobile']).split(',')[0].trim());
                                  },
                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                  color: whatsAppColor,
                                )
                            ),
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  // color: Colors.white,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    emailAction(member[index]['email']);
                                  },
                                  icon: Icon(Icons.email_outlined, size: size.height * 0.030,),
                                  color: emailColor,
                                )
                            ),
                          ],
                        ) : member[index]['mobile'] != '' ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    (member[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                      (member[index]['mobile']).split(',')[0].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      callAction((member[index]['mobile']).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (member[index]['mobile']).split(',')[1].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      callAction((member[index]['mobile']).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : callAction((member[index]['mobile']).split(',')[0].trim());
                                  },
                                  icon: Icon(Icons.phone, size: size.height * 0.030,),
                                  color: callColor,
                                )
                            ),
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  // color: Colors.white10,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    (member[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                      (member[index]['mobile']).split(',')[0].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      smsAction((member[index]['mobile']).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (member[index]['mobile']).split(',')[1].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      smsAction((member[index]['mobile']).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : smsAction((member[index]['mobile'] as String).split(',')[0].trim());
                                  },
                                  icon: Icon(Icons.message, size: size.height * 0.030,),
                                  color: smsColor,
                                )
                            ),
                            Container(
                                height: size.height * 0.05,
                                width : size.width * 0.11,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    (member[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                      (member[index]['mobile']).split(',')[0].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((member[index]['mobile']).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (member[index]['mobile']).split(',')[1].trim(),
                                                      style: const TextStyle(color: mobileText),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((member[index]['mobile']).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : whatsappAction((member[index]['mobile'] as String).split(',')[0].trim());
                                  },
                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                  color: whatsAppColor,
                                )
                            ),
                          ],
                        ) : member[index]['email'] != '' ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: size.height * 0.05,
                                  width : size.width * 0.11,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      emailAction(member[index]['email']);
                                    },
                                    icon: Icon(Icons.email_outlined, size: size.height * 0.030,),
                                    color: emailColor,
                                  )
                              ),
                            ]
                        ) : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: size.height * 0.02),
                              alignment: Alignment.center,
                              child: Text(
                                'Communication details are not available',
                                style: GoogleFonts.secularOne(color: orangeColor),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          constraints: BoxConstraints.expand(height: size.height * 0.04),
                          alignment: userRole != 'Member' ? Alignment.topLeft : Alignment.center,
                          child : TabBar(
                              unselectedLabelColor: menuPrimaryColor,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                              isScrollable: true,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: menuPrimaryColor
                              ),
                              tabs: [
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Basic"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Education"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Profession"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Formation"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Holy Order"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Family Info"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Ministry"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Emergency Contact"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Publication"),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: menuPrimaryColor, width: 1.5)),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text("Statutory Renewals"),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: tabsContent,
                          ),
                        )
                      ]),
                ),
                Positioned(
                  top: 15,
                  left: size.width / 2.8,
                  child: GestureDetector(
                    onTap: () {
                      myProfile != '' ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Image.network(myProfile, fit: BoxFit.cover,),
                          );
                        },
                      ) : member[index]['image_512'] != '' ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Image.network(member[index]['image_512'], fit: BoxFit.cover,),
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
                    child: Stack(
                      children: [
                        Container(
                          height: size.height * 0.18,
                          width: size.width * 0.30,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: -1,
                                blurRadius: 5 ,
                                offset: Offset(0, 1),
                              ),
                            ],
                            image: myProfile != '' ? DecorationImage(
                              image: myProfile != null && myProfile != '' ? NetworkImage(myProfile) : const AssetImage('assets/images/profile.png') as ImageProvider,
                              fit: BoxFit.cover,
                            ) : DecorationImage(
                              image: member[index]['image_512'] != null && member[index]['image_512'] != '' ? NetworkImage(member[index]['image_512']) : const AssetImage('assets/images/profile.png') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: size.height * 0.0,
                          right: size.width * 0.0,
                          child: Container(
                            height: size.height * 0.028,
                            width: size.width * 0.06,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: member[index]['member_type'] == 'Priest' ? Colors.green : member[index]['member_type'] == 'Deacon' ? Colors.redAccent : member[index]['member_type'] == 'Novice' ? Colors.indigo : member[index]['member_type'] == 'Brother' ? Colors.deepPurpleAccent : Colors.pinkAccent,
                            ),
                            child: member[index]['member_type'] == 'Priest' ? Text('P',
                              style: GoogleFonts.heebo(
                                  fontSize: size.height * 0.02,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ) : member[index]['member_type'] == 'Deacon' ? Text('D',
                              style: GoogleFonts.heebo(
                                  fontSize: size.height * 0.02,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ) : member[index]['member_type'] == 'Novice' ? Text('N',
                              style: GoogleFonts.heebo(
                                  fontSize: size.height * 0.02,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ) : member[index]['member_type'] == 'Brother' ? Text('B',
                              style: GoogleFonts.heebo(
                                  fontSize: size.height * 0.02,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ) : Text('LB',
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
                ),
                Positioned(
                  top: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context, 'refresh');
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white,size: 30,),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        getMemberDetails();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
