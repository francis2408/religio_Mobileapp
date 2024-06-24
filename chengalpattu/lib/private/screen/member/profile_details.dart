import 'dart:convert';
import 'dart:io';

import 'package:chengai/private/screen/member/profile/basic_details.dart';
import 'package:chengai/private/screen/member/profile/education.dart';
import 'package:chengai/private/screen/member/profile/family_info.dart';
import 'package:chengai/private/screen/member/profile/formation.dart';
import 'package:chengai/private/screen/member/profile/health.dart';
import 'package:chengai/private/screen/member/profile/holy_order.dart';
import 'package:chengai/private/screen/member/profile/ministry.dart';
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

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({Key? key}) : super(key: key);

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  final bool _canPop = false;
  List member = [];
  int index = 0;

  List<Widget> tabsContent = [
    const ProfileBasicDetailsScreen(),
    const ProfileEducationScreen(),
    const ProfileFormationScreen(),
    const ProfileHolyOrderScreen(),
    const ProfileFamilyInfoScreen(),
    const ProfileMinistryScreen(),
    const ProfileHealthScreen(),
  ];

  List<Widget> tabs = [
    const ProfileBasicDetailsScreen(),
    const ProfileMinistryScreen(),
  ];

  getMemberDetails() async {
    String url = '$baseUrl/res.member';
    Map data = {
      "params": {
        "filter": "[['id','=',$userMember]]",
        "query": "{id,name,middle_name,last_name,member_name,image_1920,title_id,unique_code,gender,living_status,marital_status_id,blood_group_id,mother_tongue_id,occupation_status,occupation_id,occupation_type,dob,is_dob_or_age,age,active,physical_status_id,citizenship_id,religion_id,name_in_regional_language,native_place,native_district_id,driving_license_no,known_language_ids,twitter_account,fb_account,linkedin_account,whatsapp_no,mobile,email,passport_country_id,known_popularly_as,place_of_birth,membership_type,member_type_id,member_type_code,pancard_no,aadhaar_proof,aadhaar_proof_name,pan_proof,pan_proof_name,passport_no,passport_proof,passport_proof_name,passport_exp_date,voter_id,voter_proof_name,voter_proof,license_exp_date,street,street2,city,district_id,state_id,country_id,zip,native_diocese_id,native_parish_id}"
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
      member = data;
    }
    else {
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
    userProfile == "Profile";
    if (expiryDateTime!.isAfter(currentDateTime)) {
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
  dispose() {
    super.dispose();
    userProfile = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          Navigator.pop(context, 'refresh');
          return false;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: _isLoading ? Center(
                child: SizedBox(
                  height: size.height * 0.06,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                  ),
                ),
            ) : AnimationLimiter(
              child: AnimationConfiguration.staggeredList(
                duration: const Duration(milliseconds: 375),
                position: index,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: DefaultTabController(
                      length: userLevel == 'Diocese Mgmt Admin' && membershipType == 'RE' ? tabs.length : userLevel == 'Diocesan Member' && membershipType == 'RE' ? tabs.length : tabsContent.length,
                      child: Stack(
                          children: [
                            Positioned.fill(
                              top: 0,
                              child: Image.asset(
                                'assets/images/one.jpg',
                                fit: BoxFit.fill,
                                opacity: const AlwaysStoppedAnimation(.7),
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
                                          style: GoogleFonts.kavoon(
                                            letterSpacing: 1,
                                            fontSize: size.height * 0.025,
                                            color: const Color(0xffad2e27),
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
                                                                  (member[index]['mobile'] as String).split(',')[0].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  callAction((member[index]['mobile'] as String).split(',')[0].trim());
                                                                },
                                                              ),
                                                              const Divider(),
                                                              ListTile(
                                                                title: Text(
                                                                  (member[index]['mobile'] as String).split(',')[1].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  callAction((member[index]['mobile'] as String).split(',')[1].trim());
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ) : callAction((member[index]['mobile'] as String).split(',')[0].trim());
                                              },
                                              icon: Icon(Icons.phone, size: size.height * 0.030,),
                                              color: Colors.blueAccent,
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
                                                                  (member[index]['mobile'] as String).split(',')[0].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  smsAction((member[index]['mobile'] as String).split(',')[0].trim());
                                                                },
                                                              ),
                                                              const Divider(),
                                                              ListTile(
                                                                title: Text(
                                                                  (member[index]['mobile'] as String).split(',')[1].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  smsAction((member[index]['mobile'] as String).split(',')[1].trim());
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
                                              color: Colors.orange,
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
                                                                  (member[index]['mobile'] as String).split(',')[0].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  whatsappAction((member[index]['mobile'] as String).split(',')[0].trim());
                                                                },
                                                              ),
                                                              const Divider(),
                                                              ListTile(
                                                                title: Text(
                                                                  (member[index]['mobile'] as String).split(',')[1].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  whatsappAction((member[index]['mobile'] as String).split(',')[1].trim());
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
                                              icon: Icon(LineAwesomeIcons.what_s_app, size: size.height * 0.030,),
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
                                                color: Colors.red,
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
                                                                  (member[index]['mobile'] as String).split(',')[0].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  callAction((member[index]['mobile'] as String).split(',')[0].trim());
                                                                },
                                                              ),
                                                              const Divider(),
                                                              ListTile(
                                                                title: Text(
                                                                  (member[index]['mobile'] as String).split(',')[1].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  callAction((member[index]['mobile'] as String).split(',')[1].trim());
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ) : callAction((member[index]['mobile'] as String).split(',')[0].trim());
                                              },
                                              icon: Icon(Icons.phone, size: size.height * 0.030,),
                                              color: Colors.blueAccent,
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
                                                                  (member[index]['mobile'] as String).split(',')[0].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  smsAction((member[index]['mobile'] as String).split(',')[0].trim());
                                                                },
                                                              ),
                                                              const Divider(),
                                                              ListTile(
                                                                title: Text(
                                                                  (member[index]['mobile'] as String).split(',')[1].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  smsAction((member[index]['mobile'] as String).split(',')[1].trim());
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
                                              color: Colors.orange,
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
                                                                  (member[index]['mobile'] as String).split(',')[0].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  whatsappAction((member[index]['mobile'] as String).split(',')[0].trim());
                                                                },
                                                              ),
                                                              const Divider(),
                                                              ListTile(
                                                                title: Text(
                                                                  (member[index]['mobile'] as String).split(',')[1].trim(),
                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context); // Close the dialog
                                                                  whatsappAction((member[index]['mobile'] as String).split(',')[1].trim());
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
                                              icon: Icon(LineAwesomeIcons.what_s_app, size: size.height * 0.030,),
                                              color: Colors.green,
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
                                                    emailAction(memberEmail);
                                                  },
                                                  icon: Icon(Icons.email_outlined, size: size.height * 0.030,),
                                                  color: Colors.red,
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
                                            style: GoogleFonts.secularOne(color: const Color(0xFFE1A243)),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    Container(
                                      alignment: userLevel == 'Diocese Mgmt Admin' && membershipType == 'RE' ? Alignment.center : userLevel == 'Diocesan Member' && membershipType == 'RE' ? Alignment.center : Alignment.topLeft,
                                      constraints: BoxConstraints.expand(height: size.height * 0.04),
                                      child : TabBar(
                                          unselectedLabelColor: Colors.redAccent,
                                          indicatorSize: TabBarIndicatorSize.tab,
                                          labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                          isScrollable: true,
                                          indicator: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              color: Colors.redAccent),
                                          tabs: userLevel == 'Diocese Mgmt Admin' && membershipType == 'RE' ? [
                                            Tab(
                                              child: Container(
                                                padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
                                                child: const Align(
                                                  alignment: Alignment.center,
                                                  child: Text("Ministry"),
                                                ),
                                              ),
                                            ),
                                          ] : userLevel == 'Diocesan Member' && membershipType == 'RE' ? [
                                          Tab(
                                            child: Container(
                                              padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(color: Colors.redAccent, width: 1.5)),
                                              child: const Align(
                                                alignment: Alignment.center,
                                                child: Text("Ministry"),
                                              ),
                                            ),
                                          ),
                                          ] : [
                                            Tab(
                                              child: Container(
                                                padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
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
                                                    borderRadius: BorderRadius.circular(50),
                                                    border: Border.all(color: Colors.redAccent, width: 1.5)),
                                                child: const Align(
                                                  alignment: Alignment.center,
                                                  child: Text("Health"),
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
                                        children: userLevel == 'Diocese Mgmt Admin' && membershipType == 'RE' ? tabs : userLevel == 'Diocesan Member' && membershipType == 'RE' ? tabs : tabsContent,
                                      ),
                                    )
                                  ]),
                            ),
                            Positioned(
                              top: 60,
                              left: size.width / 2.8,
                              child: GestureDetector(
                                onTap: () {
                                  member[index]['image_1920'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(member[index]['image_1920'], fit: BoxFit.cover,),
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.grey,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 2,
                                        color: Colors.white,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundImage: member[index]['image_1920'] != null && member[index]['image_1920'] != ''
                                          ? NetworkImage(member[index]['image_1920'])
                                          : const AssetImage('assets/images/profile.png') as ImageProvider,
                                    ),
                                  ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
