import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:eluru/private/screens/member/basic/edit_basic_details.dart';
import 'package:eluru/widget/common/common.dart';
import 'package:eluru/widget/common/internet_connection_checker.dart';
import 'package:eluru/widget/common/slide_animations.dart';
import 'package:eluru/widget/common/snackbar.dart';
import 'package:eluru/widget/theme_color/theme_color.dart';
import 'package:eluru/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMemberProfileScreen extends StatefulWidget {
  const ViewMemberProfileScreen({Key? key}) : super(key: key);

  @override
  State<ViewMemberProfileScreen> createState() => _ViewMemberProfileScreenState();
}

class _ViewMemberProfileScreenState extends State<ViewMemberProfileScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final reverse = DateFormat("yyyy-MM-dd");

  bool _isLoading = true;
  List profile = [];
  List house = [];
  var member_house_id;

  // Address
  String street = '';
  String street2 = '';
  String place = '';
  String city = '';
  String district = '';
  String state = '';
  String country = '';
  String zip = '';

  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  memberProfileDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['full_name','name','middle_name','image_1920','last_name','membership_type','display_roles','member_type','place_of_birth','unique_code','gender','dob','age','physical_status_id','diocese_id','parish_id','vicariate_id','blood_group_id','personal_mobile','personal_email','whatsapp_no','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','community_id','role_ids','aadhar_proof','pan_proof','voter_proof','passport_proof']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      profile = data;
      for(int i = 0; i < profile.length; i++) {
        myProfile = profile[i]['image_1920'];
      }
      getMinistryDetails();
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

  loading() {
    setState(() {
      _isLoading = false;
    });
  }

  getMinistryDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_member_ministry?args=[$memberId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString())['data'];
      var ministryData = data;
      for(int i = 0; i < ministryData.length; i++) {
        member_house_id = ministryData['house_id'];
      }
      ministryData.isNotEmpty ? houseDetails() : loading();
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
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

  houseDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?fields=['name','ministry_ids','diocese_id','parish_id','superior_id','street','street2','place','city','district_id','state_id','zip','country_id','email','phone','mobile','members_count','institution_count']&domain=[('id','=',$member_house_id)]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      house = data;
      for(int j = 0; j < house.length; j++) {
        street = house[j]['street'];
        street2 = house[j]['street2'];
        place = house[j]['place'];
        city = house[j]['city'];
        if(house[j]['district_id'].isNotEmpty && house[j]['district_id'] != [] && house[j]['district_id'] != '') {
          district = house[j]['district_id'][1];
        }
        if(house[j]['state_id'].isNotEmpty && house[j]['state_id'] != [] && house[j]['state_id'] != '') {
          state = house[j]['state_id'][1];
        }
        if(house[j]['country_id'].isNotEmpty && house[j]['country_id'] != [] && house[j]['country_id'] != '') {
          country = house[j]['country_id'][1];
        }
        zip = house[j]['zip'];
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

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      setState(() {
        AnimatedSnackBar.show(
            context,
            'Can not launch email url',
            Colors.red
        );
      });
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

  void changeData() {
    setState(() {
      _isLoading = true;
      memberProfileDetails();
    });
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
      Future.delayed(Duration.zero,() async {
        memberProfileDetails();
      });
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            Future.delayed(Duration.zero,() async {
              memberProfileDetails();
            });
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
          child: Center(
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
            ) : profile.isNotEmpty ? Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SlideFadeAnimation(
                duration: const Duration(seconds: 1),
                child: ListView.builder(itemCount: profile.length, itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10, left: 10, right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 10),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['role_ids_name'] != '' && profile[index]['role_ids_name'] != null ? Flexible(
                                      child: Text(
                                        profile[index]['role_ids_name'],
                                        style: GoogleFonts.secularOne(
                                          fontSize: size.height * 0.02,
                                          color: valueColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ) : Text(
                                      'No role assigned',
                                      style: GoogleFonts.secularOne(
                                        fontSize: size.height * 0.02,
                                        color: emptyColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Birthday', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['dob'] != '' && profile[index]['dob'] != null ? Row(
                                      children: [
                                        Text(DateFormat('dd-MMM-yyyy').format(DateTime.parse(profile[index]['dob'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),),
                                        SizedBox(width: size.width * 0.01,),
                                        Text('(age: ${profile[index]['age']})', style: GoogleFonts.signika(color: emptyColor, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),),
                                      ],
                                    ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['mobile'] != '' && profile[index]['mobile'] != null ? Text('${profile[index]['mobile']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['email'] != '' && profile[index]['email'] != null ? Flexible(child: Text('${profile[index]['email']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Place of Birth', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['place_of_birth'] != '' && profile[index]['place_of_birth'] != null ? Flexible(child: Text('${profile[index]['place_of_birth']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Blood Group', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['blood_group_id'].isNotEmpty && profile[index]['blood_group_id'] != [] ? Flexible(child: Text('${profile[index]['blood_group_id'][1]}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Community Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    street == '' && street2 == '' && place == '' && city == '' && district == '' && state == '' && country == '' && zip == '' ? Text(
                                      'NA',
                                      style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                    ) : Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          street != '' ? Text("$street,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          street2 != '' ? Text("$street2,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          place != '' ? Text("$place,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          city != '' ? Text("$city,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          district != '' ? Text("$district,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          state != '' ? Text("$state,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          country != '' ? Row(
                                            children: [
                                              country != '' ? Text(country, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              zip != '' ? Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              zip != '' ? Text("$zip.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
                                            ],
                                          ) : Container(),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Home Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['street'] == '' && profile[index]['street2'] == '' && profile[index]['city'] == '' && profile[index]['district_id'].isEmpty && profile[index]['state_id'].isEmpty && profile[index]['country_id'].isEmpty && profile[index]['zip'] == '' ? Text(
                                      'NA',
                                      style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                    ) : Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          profile[index]['street'] != '' && profile[index]['street'] != null ? Text("${profile[index]['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['street2'] != '' && profile[index]['street2'] != null ? Text("${profile[index]['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['place'] != '' && profile[index]['place'] != null ? Text("${profile[index]['place']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['city'] != '' && profile[index]['city'] != null ? Text("${profile[index]['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['district_id'] != '' && profile[index]['district_id'] != null && profile[index]['district_id'].isNotEmpty ? Text("${profile[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['state_id'] != '' && profile[index]['state_id'] != null && profile[index]['state_id'].isNotEmpty ? Text("${profile[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['country_id'] != '' && profile[index]['country_id'] != null && profile[index]['country_id'].isNotEmpty ? Row(
                                            children: [
                                              profile[index]['country_id'] != '' && profile[index]['country_id'] != null && profile[index]['country_id'].isNotEmpty ? Text("${profile[index]['country_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              profile[index]['zip'] != '' && profile[index]['zip'] != null ? Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              profile[index]['zip'] != '' && profile[index]['zip'] != null ? Text("${profile[index]['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
                                            ],
                                          ) : Container(),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ) : Expanded(
              child: Center(
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
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const EditBasicDetailsScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: iconBackColor,
        child: const Icon(Icons.edit, color: buttonIconColor,),
      ),
    );
  }
}
