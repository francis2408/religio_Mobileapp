import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'members/education.dart';
import 'members/emergency_contact.dart';
import 'members/family_info.dart';
import 'members/formation.dart';
import 'members/member.dart';
import 'members/ministry.dart';
import 'members/profession.dart';
import 'members/publication.dart';
import 'members/statutory_renewals.dart';

class MembersDetailsTabBarScreen extends StatefulWidget {
  const MembersDetailsTabBarScreen({Key? key}) : super(key: key);

  @override
  State<MembersDetailsTabBarScreen> createState() => _MembersDetailsTabBarScreenState();
}

class _MembersDetailsTabBarScreenState extends State<MembersDetailsTabBarScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final bool _canPop = false;
  bool _isLoading = true;
  List member = [];
  int index = 0;
  String memberType = '';

  List<Widget> tabsContent = [
    const MemberScreen(),
    const MembersEducationScreen(),
    const MembersProfessionScreen(),
    const MembersFormationScreen(),
    const MembersFamilyInfoScreen(),
    const MembersMinistryScreen(),
    const MembersEmergencyContactScreen(),
    const MembersPublicationScreen(),
    const MembersStatutoryRenewalsScreen(),
  ];

  List<Widget> tabsContent3 = [
    const MemberScreen(),
    const MembersEducationScreen(),
    const MembersProfessionScreen(),
    const MembersFormationScreen(),
    const MembersFamilyInfoScreen(),
    const MembersMinistryScreen(),
    const MembersEmergencyContactScreen(),
    const MembersPublicationScreen(),
    const MembersStatutoryRenewalsScreen(),
  ];

  List<Widget> tabsContent2 = [
    const MemberScreen(),
  ];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberDetails() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$id)]&fields=['full_name','member_name','image_512','mobile','email','member_type','community_id']&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      member = data;
      for(int i = 0; i < member.length; i++) {
        memberType = member[i]['member_type'];
        if(member[i]['community_id'].isNotEmpty && member[i]['community_id'] != []) {
          communityId = member[i]['community_id'][0];
        }
      }
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
    userMember = '';
    myProfile = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
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
          ) : member.isNotEmpty ? DefaultTabController(
            length: memberType != 'Priest' ? 9 : 10,
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
                                    color: Colors.green,
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
                            alignment: userRole == 'House/Community' && userCommunityId != communityId ? Alignment.center : userRole != 'Member' ? Alignment.topLeft : Alignment.center,
                            child : TabBar(
                                unselectedLabelColor: menuPrimaryColor,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                isScrollable: true,
                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: menuPrimaryColor
                                ),
                                tabs: userRole == 'House/Community' && userCommunityId != communityId ? [
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
                                ] : userRole != 'Member' ? memberType != 'Priest' ? [
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
                                ] : [
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
                                ] : [
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
                                ]
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Expanded(
                            child: TabBarView(
                              children: userRole == 'House/Community' && userCommunityId != communityId ? tabsContent2 : userRole != 'Member' ? memberType != 'Priest' ? tabsContent3 : tabsContent : tabsContent2,
                            ),
                          )
                        ]),
                  ),
                  Positioned(
                    top: 12,
                    left: size.width / 2.9,
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
                            width: size.width * 0.3,
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
                            bottom: size.height * 0,
                            right: size.width * 0,
                            child: Container(
                              height: size.height * 0.03,
                              width: size.width * 0.06,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: member[index]['member_type'] == 'Sister' ? Colors.green : member[index]['member_type'] == 'Junior Sister' ? Colors.pinkAccent : member[index]['member_type'] == 'Novice' ? Colors.indigo : member[index]['member_type'] == 'Candidacy' ? Colors.cyan : member[index]['member_type'] == 'Postulancy' ? Colors.purple : Colors.redAccent,
                              ),
                              child: member[index]['member_type'] == 'Sister' ? Text('S',
                                style: GoogleFonts.heebo(
                                    fontSize: size.height * 0.02,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ) : member[index]['member_type'] == 'Junior Sister' ? Text('JS',
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
                              ) : member[index]['member_type'] == 'Candidacy' ? Text('C',
                                style: GoogleFonts.heebo(
                                    fontSize: size.height * 0.02,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ) : member[index]['member_type'] == 'Postulancy' ? Text('PO',
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
          ) : Center(
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
          ),
        ),
      ),
    );
  }
}
