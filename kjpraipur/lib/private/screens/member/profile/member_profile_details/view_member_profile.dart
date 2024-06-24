import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kjpraipur/private/screens/member/basic/edit_basic_details.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMemberProfileScreen extends StatefulWidget {
  const ViewMemberProfileScreen({Key? key}) : super(key: key);

  @override
  State<ViewMemberProfileScreen> createState() => _ViewMemberProfileScreenState();
}

class _ViewMemberProfileScreenState extends State<ViewMemberProfileScreen> {
  final reverse = DateFormat("yyyy-MM-dd");

  bool _isLoading = true;
  List profile = [];

  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  memberProfileDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['full_name','name','middle_name','image_1920','last_name','membership_type','display_roles','member_type','place_of_birth','unique_code','gender','dob','physical_status_id','diocese_id','parish_id','vicariate_id','blood_group_id','personal_mobile','personal_email','whatsapp_no','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','community_id','role_ids','aadhar_proof','pan_proof','voter_proof','passport_proof']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      profile = data;
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
    Future.delayed(Duration.zero,() async {
      memberProfileDetails();
    });
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
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  profile[index]['image_1920'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(profile[index]['image_1920'], fit: BoxFit.cover,),
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
                                      image: profile[index]['image_1920'] != null && profile[index]['image_1920'] != ''
                                          ? NetworkImage(profile[index]['image_1920'])
                                          : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                                    height: size.height * 0.11,
                                    width: size.width,
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                profile[index]['full_name'].toUpperCase(),
                                                style: GoogleFonts.secularOne(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.018,
                                                    // fontWeight: FontWeight.bold,
                                                    color: textColor
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // SizedBox(
                                        //   height: size.height * 0.01,
                                        // ),
                                        profile[index]['role_ids_name'] != '' && profile[index]['role_ids_name'] != null ? Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                profile[index]['role_ids_name'],
                                                style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontSize: size.height * 0.017,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontStyle: FontStyle.italic,
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
                                        // SizedBox(
                                        //   height: size.height * 0.01,
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                        child: profile[index]['mobile'] != null && profile[index]['mobile'] != '' && profile[index]['email'] != null && profile[index]['email'] != '' ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                profile[index]['mobile'] != null && profile[index]['mobile'] != '' ? IconButton(
                                  onPressed: () {
                                    (profile[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                      (profile[index]['mobile'] as String).split(',')[0].trim(),
                                                      style: const TextStyle(color: Colors.blueAccent),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context); // Close the dialog
                                                      callAction((profile[index]['mobile'] as String).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (profile[index]['mobile'] as String).split(',')[1].trim(),
                                                      style: const TextStyle(color: Colors.blueAccent),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context); // Close the dialog
                                                      callAction((profile[index]['mobile'] as String).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : callAction((profile[index]['mobile'] as String).split(',')[0].trim());
                                  },
                                  icon: const Icon(Icons.phone),
                                  color: Colors.blueAccent,
                                  iconSize: 30,
                                ) : Container(),
                                profile[index]['mobile'] != null && profile[index]['mobile'] != '' ? IconButton(
                                  onPressed: () {
                                    (profile[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                      (profile[index]['mobile'] as String).split(',')[0].trim(),
                                                      style: const TextStyle(color: Colors.blueAccent),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context); // Close the dialog
                                                      smsAction((profile[index]['mobile'] as String).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (profile[index]['mobile'] as String).split(',')[1].trim(),
                                                      style: const TextStyle(color: Colors.blueAccent),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context); // Close the dialog
                                                      smsAction((profile[index]['mobile'] as String).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : smsAction((profile[index]['mobile'] as String).split(',')[0].trim());
                                  },
                                  icon: const Icon(Icons.message),
                                  color: Colors.orange,
                                  iconSize: 30,
                                ) : Container(),
                                profile[index]['mobile'] != null && profile[index]['mobile'] != '' ? IconButton(
                                  onPressed: () {
                                    (profile[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                      (profile[index]['mobile'] as String).split(',')[0].trim(),
                                                      style: const TextStyle(color: Colors.blueAccent),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context); // Close the dialog
                                                      whatsappAction((profile[index]['mobile'] as String).split(',')[0].trim());
                                                    },
                                                  ),
                                                  const Divider(),
                                                  ListTile(
                                                    title: Text(
                                                      (profile[index]['mobile'] as String).split(',')[1].trim(),
                                                      style: const TextStyle(color: Colors.blueAccent),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context); // Close the dialog
                                                      whatsappAction((profile[index]['mobile'] as String).split(',')[1].trim());
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ) : whatsappAction((profile[index]['mobile'] as String).split(',')[0].trim());
                                  },
                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 25, width: 25,),
                                  color: Colors.green,
                                  iconSize: 30,
                                ) : Container(),
                                profile[index]['email'] != null && profile[index]['email'] != '' ? IconButton(
                                  onPressed: () {
                                    emailAction(profile[index]['email']);
                                  },
                                  icon: const Icon(Icons.email),
                                  color: Colors.red,
                                    iconSize: 30,
                                ) : Container(),
                              ],
                            ),
                          ),
                        ) : Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 10),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Birthday', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['dob'] != '' && profile[index]['dob'] != null ? Flexible(child: Text(DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(profile[index]['dob'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['mobile'] != '' && profile[index]['mobile'] != null ? Text('${profile[index]['mobile']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['email'] != '' && profile[index]['email'] != null ? Text('${profile[index]['email']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place of Birth', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['place_of_birth'] != '' && profile[index]['place_of_birth'] != null ? Flexible(child: Text('${profile[index]['place_of_birth']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Blood Group', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['blood_group_id'] != '' && profile[index]['blood_group_id'] != null && profile[index]['blood_group_id'].isNotEmpty ? Text('${profile[index]['blood_group_id'][1]}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Home Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    profile[index]['street'] == '' && profile[index]['street2'] == '' && profile[index]['city'] == '' && profile[index]['district_id'].isEmpty && profile[index]['state_id'].isEmpty && profile[index]['country_id'].isEmpty && profile[index]['zip'] == '' ? Text(
                                      'NA',
                                      style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ) : Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          profile[index]['street'] != '' && profile[index]['street'] != null ? Text("${profile[index]['street']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['street2'] != '' && profile[index]['street2'] != null ? Text("${profile[index]['street2']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['place'] != '' && profile[index]['place'] != null ? Text("${profile[index]['place']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['city'] != '' && profile[index]['city'] != null ? Text("${profile[index]['city']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['district_id'] != '' && profile[index]['district_id'] != null && profile[index]['district_id'].isNotEmpty ? Text("${profile[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['state_id'] != '' && profile[index]['state_id'] != null && profile[index]['state_id'].isNotEmpty ? Text("${profile[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          profile[index]['country_id'] != '' && profile[index]['country_id'] != null && profile[index]['country_id'].isNotEmpty ? Row(
                                            children: [
                                              profile[index]['country_id'] != '' && profile[index]['country_id'] != null && profile[index]['country_id'].isNotEmpty ? Text("${profile[index]['country_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                              profile[index]['zip'] != '' && profile[index]['zip'] != null ? Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                              profile[index]['zip'] != '' && profile[index]['zip'] != null ? Text("${profile[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container()
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
