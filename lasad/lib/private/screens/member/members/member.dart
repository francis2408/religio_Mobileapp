import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lasad/private/screens/member/basic/edit_basic_details.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final bool _canPop = false;
  bool _isLoading = true;
  List membersDetail = [];
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

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  memberDetails() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$id)]&fields=['member_name','name','middle_name','image_1920','last_name','member_type','title','place_of_birth','dob','age','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','blood_group_id','role_ids']&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      membersDetail = data;
      for(int i = 0; i < membersDetail.length; i++) {
        myProfile = membersDetail[i]['image_1920'];
      }
      getMinistryDetails();
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

  loading() {
    setState(() {
      _isLoading = false;
    });
  }

  getMinistryDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_member_ministry?args=[$id]"));
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
      throw "Can not launch url";
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    String? countryCode = extractCountryCode(whatsapp);

    if (countryCode != null) {
      // Perform the WhatsApp action here.
      if (Platform.isAndroid) {
        final whatsappUrl = 'whatsapp://send?phone=$whatsapp';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      } else {
        final whatsappUrl = 'https://api.whatsapp.com/send?phone=$whatsapp';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      }
    } else {
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
  }

  String? extractCountryCode(String whatsappNumber) {
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      if (whatsappNumber.startsWith('+')) {
        // The country code is assumed to be present at the beginning of the number.
        int endIndex = whatsappNumber.indexOf(' ');
        return endIndex != -1 ? whatsappNumber.substring(1, endIndex) : whatsappNumber.substring(1);
      }
    }
    return null; // Country code not found.
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      memberDetails();
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
      memberDetails();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            memberDetails();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    clearImageCache();
    super.dispose();
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
        backgroundColor: screenBackgroundColor,
        body: SafeArea(
            child: Center(
              child: _isLoading ? Center(
                child: SizedBox(
                  height: size.height * 0.05,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.lineScalePulseOutRapid,
                    colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                  ),
                ),
              ) : membersDetail.isNotEmpty ? Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: ListView.builder(itemCount: membersDetail.length, itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    membersDetail[index]['image_1920'] != '' ? showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Image.network(membersDetail[index]['image_1920'], fit: BoxFit.cover,),
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
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: whiteColor,
                                    ),
                                    child: Container(
                                      height: size.height * 0.11,
                                      width: size.width * 0.20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: membersDetail[index]['image_1920'] != null && membersDetail[index]['image_1920'] != ''
                                              ? NetworkImage(membersDetail[index]['image_1920'])
                                              : const AssetImage('assets/images/profile.png') as ImageProvider,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.02,
                                ),
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      height: size.height * 0.12,
                                      width: size.width,
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  membersDetail[index]['member_name'],
                                                  style: GoogleFonts.secularOne(
                                                    fontSize: size.height * 0.02,
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          membersDetail[index]['member_type'] != '' && membersDetail[index]['member_type'] != null ? Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  membersDetail[index]['member_type'],
                                                  style: TextStyle(
                                                    fontSize: size.height * 0.017,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ) : Text(
                                            'No role assigned',
                                            style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: size.height * 0.017,
                                              // fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                        ),
                        membersDetail[index]['mobile'] != null && membersDetail[index]['mobile'] != '' || membersDetail[index]['email'] != null && membersDetail[index]['email'] != '' ? Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  membersDetail[index]['mobile'] != null && membersDetail[index]['mobile'] != '' ? IconButton(
                                    onPressed: () {
                                      (membersDetail[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                        (membersDetail[index]['mobile'] as String).split(',')[0].trim(),
                                                        style: const TextStyle(color: Colors.blueAccent),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context); // Close the dialog
                                                        callAction((membersDetail[index]['mobile'] as String).split(',')[0].trim());
                                                      },
                                                    ),
                                                    const Divider(),
                                                    ListTile(
                                                      title: Text(
                                                        (membersDetail[index]['mobile'] as String).split(',')[1].trim(),
                                                        style: const TextStyle(color: Colors.blueAccent),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context); // Close the dialog
                                                        callAction((membersDetail[index]['mobile'] as String).split(',')[1].trim());
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ) : callAction((membersDetail[index]['mobile'] as String).split(',')[0].trim());
                                    },
                                    icon: const Icon(Icons.phone),
                                    color: Colors.blueAccent,
                                    iconSize: 30,
                                  ) : Container(),
                                  membersDetail[index]['mobile'] != null && membersDetail[index]['mobile'] != '' ? IconButton(
                                    onPressed: () {
                                      (membersDetail[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                        (membersDetail[index]['mobile'] as String).split(',')[0].trim(),
                                                        style: const TextStyle(color: Colors.blueAccent),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context); // Close the dialog
                                                        callAction((membersDetail[index]['mobile'] as String).split(',')[0].trim());
                                                      },
                                                    ),
                                                    const Divider(),
                                                    ListTile(
                                                      title: Text(
                                                        (membersDetail[index]['mobile'] as String).split(',')[1].trim(),
                                                        style: const TextStyle(color: Colors.blueAccent),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context); // Close the dialog
                                                        callAction((membersDetail[index]['mobile'] as String).split(',')[1].trim());
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ) : callAction((membersDetail[index]['mobile'] as String).split(',')[0].trim());
                                    },
                                    icon: const Icon(Icons.message),
                                    color: Colors.orange,
                                    iconSize: 30,
                                  ) : Container(),
                                  membersDetail[index]['mobile'] != null && membersDetail[index]['mobile'] != '' ? IconButton(
                                    onPressed: () {
                                      (membersDetail[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                        (membersDetail[index]['mobile'] as String).split(',')[0].trim(),
                                                        style: const TextStyle(color: Colors.blueAccent),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context); // Close the dialog
                                                        callAction((membersDetail[index]['mobile'] as String).split(',')[0].trim());
                                                      },
                                                    ),
                                                    const Divider(),
                                                    ListTile(
                                                      title: Text(
                                                        (membersDetail[index]['mobile'] as String).split(',')[1].trim(),
                                                        style: const TextStyle(color: Colors.blueAccent),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context); // Close the dialog
                                                        callAction((membersDetail[index]['mobile'] as String).split(',')[1].trim());
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ) : callAction((membersDetail[index]['mobile'] as String).split(',')[0].trim());
                                    },
                                    icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 25, width: 25,),
                                    color: Colors.green,
                                    iconSize: 30,
                                  ) : Container(),
                                  membersDetail[index]['email'] != null && membersDetail[index]['email'] != '' ? IconButton(
                                    onPressed: () {
                                      emailAction(membersDetail[index]['email']);
                                    },
                                    icon: const Icon(Icons.email),
                                    color: Colors.red,
                                    iconSize: 30,
                                  ) : Container(),
                                ],
                              ),
                            ),
                          ),
                        ) : Container(),
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
                                      membersDetail[index]['role_ids_name'] != '' && membersDetail[index]['role_ids_name'] != null ? Flexible(
                                        child: Text(
                                          membersDetail[index]['role_ids_name'],
                                          style: GoogleFonts.secularOne(
                                            fontSize: size.height * 0.02,
                                            color: valueColor,
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
                                      membersDetail[index]['dob'] != '' && membersDetail[index]['dob'] != null ? Row(
                                        children: [
                                          Text(DateFormat('dd-MMM-yyyy').format(DateTime.parse(membersDetail[index]['dob'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),),
                                          SizedBox(width: size.width * 0.01,),
                                          Text('(age: ${membersDetail[index]['age']})', style: GoogleFonts.signika(color: emptyColor, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),),
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
                                      membersDetail[index]['mobile'] != '' && membersDetail[index]['mobile'] != null ? Text('${membersDetail[index]['mobile']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.015,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      SizedBox(width: size.width * 0.02,),
                                      membersDetail[index]['email'] != '' && membersDetail[index]['email'] != null ? Flexible(child: Text('${membersDetail[index]['email']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.015,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Place of Birth', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      SizedBox(width: size.width * 0.02,),
                                      membersDetail[index]['place_of_birth'] != '' && membersDetail[index]['place_of_birth'] != null ? Flexible(child: Text('${membersDetail[index]['place_of_birth']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.015,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Blood Group', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      SizedBox(width: size.width * 0.02,),
                                      membersDetail[index]['blood_group_id'] != '' && membersDetail[index]['blood_group_id'] != null && membersDetail[index]['blood_group_id'].isNotEmpty ? Text('${membersDetail[index]['blood_group_id'][1]}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                      membersDetail[index]['street'] == '' && membersDetail[index]['street2'] == '' && membersDetail[index]['city'] == '' && membersDetail[index]['district_id'].isEmpty && membersDetail[index]['state_id'].isEmpty && membersDetail[index]['country_id'].isEmpty && membersDetail[index]['zip'] == '' ? Text(
                                        'NA',
                                        style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                      ) : Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            membersDetail[index]['street'] != '' && membersDetail[index]['street'] != null ? Text("${membersDetail[index]['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            membersDetail[index]['street2'] != '' && membersDetail[index]['street2'] != null ? Text("${membersDetail[index]['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            membersDetail[index]['place'] != '' && membersDetail[index]['place'] != null ? Text("${membersDetail[index]['place']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            membersDetail[index]['city'] != '' && membersDetail[index]['city'] != null ? Text("${membersDetail[index]['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            membersDetail[index]['district_id'] != '' && membersDetail[index]['district_id'] != null && membersDetail[index]['district_id'].isNotEmpty ? Text("${membersDetail[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            membersDetail[index]['state_id'] != '' && membersDetail[index]['state_id'] != null && membersDetail[index]['state_id'].isNotEmpty ? Text("${membersDetail[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            membersDetail[index]['country_id'] != '' && membersDetail[index]['country_id'] != null && membersDetail[index]['country_id'].isNotEmpty ? Row(
                                              children: [
                                                membersDetail[index]['country_id'] != '' && membersDetail[index]['country_id'] != null && membersDetail[index]['country_id'].isNotEmpty ? Text("${membersDetail[index]['country_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                                membersDetail[index]['zip'] != '' && membersDetail[index]['zip'] != null ? Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                                membersDetail[index]['zip'] != '' && membersDetail[index]['zip'] != null ? Text("${membersDetail[index]['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
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
                    ),
                  ),
                ),
              ),
            )
        ),
        floatingActionButton: userRole == 'House/Community' && userCommunityId != communityId ? Container() : userRole != 'Member'? sectorTab == 'Indian Sector' ? FloatingActionButton(
          onPressed: () async {
            String refresh = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EditBasicDetailsScreen()));

            if(refresh == 'refresh') {
              changeData();
            }
          },
          backgroundColor: iconBackColor,
          child: const Icon(Icons.edit, color: buttonIconColor,),
        ) : Container() : Container(),
      ),
    );
  }
}
