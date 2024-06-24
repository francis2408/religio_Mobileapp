import 'dart:convert';
import 'dart:io';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class DioceseBishopScreen extends StatefulWidget {
  const DioceseBishopScreen({Key? key}) : super(key: key);

  @override
  State<DioceseBishopScreen> createState() => _DioceseBishopScreenState();
}

class _DioceseBishopScreenState extends State<DioceseBishopScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List diocese = [];
  List bishopData = [];
  List bishopHolyOrder = [];
  int index= 0;

  String priest = '';
  String bishop = '';

  getBishopDetails() async {
    String url = '$baseUrl/res.member';
    Map data = {
      "params": {
        "filter": "[['id','=',$bishopID]]",
        "query": "{id,name,middle_name,last_name,member_name,image_1920,title_id,unique_code,gender,living_status,marital_status_id,blood_group_id,mother_tongue_id,occupation_status,occupation_id,occupation_type,dob,is_dob_or_age,age,active,physical_status_id,citizenship_id,religion_id,name_in_regional_language,native_place,native_district_id,driving_license_no,known_language_ids,twitter_account,fb_account,linkedin_account,whatsapp_no,mobile,email,passport_country_id,known_popularly_as,place_of_birth,membership_type,member_type_id,member_type_code,pancard_no,aadhaar_proof,aadhaar_proof_name,pan_proof,pan_proof_name,passport_no,passport_proof,passport_proof_name,passport_exp_date,voter_id,voter_proof_name,voter_proof,license_exp_date,street,street2,city,district_id,state_id,country_id,zip,native_diocese_id,native_parish_id}",
        "context": {"bypass": 1}
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
      bishopData = data;
    } else {
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

  getBishopHolyOrderData() async {
    String url = '$baseUrl/member.holyorder';
    Map data = {
      "params": {
        "filter": "[['member_id','=',$bishopID]]",
        "query": "{id,member_id,date,place,order,minister,state}"
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
      bishopHolyOrder = data;

      for(int j = 0; j < bishopHolyOrder.length; j++) {
        if(bishopHolyOrder[j]['order'] == 'Priest') {
          priest = bishopHolyOrder[j]['date'];
        } else {
          bishop = bishopHolyOrder[j]['date'];
        }
      }
    } else {
      final message = json.decode(response.body)['result'];
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

  String getMonthName(int monthNumber) {
    DateTime dateTime = DateTime(2000, monthNumber);
    return DateFormat('MMMM').format(dateTime);
  }

  getDioceseData() async {
    String url = '$baseUrl/res.ecclesia.diocese';
    Map data = {
      "params": {
        "filter": "[['id', '=', $userDiocese ]]",
        "query": "{id,image_1920,name,bishop_id,street,street2,city,district_id,state_id,country_id,zip,mobile,phone,email,website,history,org_image_ids,establishment_date,vision,mission,feast_month,feast_day}"
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
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      diocese = data;
      for(int i = 0; i < diocese.length; i++) {
        feastDay = diocese[i]['feast_day'];
        var month = diocese[i]['feast_month'];
        if(month != '' && month != null) {
          feastMonth = getMonthName(int.parse(month));
        }
      }
    } else {
      final message = json.decode(response.body)['result'];
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

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getBishopDetails();
      getBishopHolyOrderData();
      getDioceseData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getBishopDetails();
            getBishopHolyOrderData();
            getDioceseData();
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
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ),
        ) : bishopData.isNotEmpty ? AnimationLimiter(
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              // scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bishopData.length,
              itemBuilder: (BuildContext context, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    bishopData[index]['image_1920'] != '' ? showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Image.network(bishopData[index]['image_1920'], fit: BoxFit.cover,),
                                        );
                                      },
                                    ) : showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Image.asset('assets/others/member.png', fit: BoxFit.cover,),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: size.height * 0.15,
                                    width: size.width * 0.25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.grey,
                                          spreadRadius: -1,
                                          blurRadius: 5 ,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: bishopData[index]['image_1920'] != ''
                                            ? NetworkImage(bishopData[index]['image_1920'])
                                            : const AssetImage('assets/images/profile.png') as ImageProvider,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        bishopData[index]['member_name']!= null && bishopData[index]['member_name'] != '' ? Flexible(child: Text(bishopData[index]['member_name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        bishopData[index]['email'] != null && bishopData[index]['email'] != '' ? Flexible(
                                          child: GestureDetector(
                                              onTap: () {
                                                emailAction(bishopData[index]['email']);
                                                },
                                              child: Text(
                                                bishopData[index]['email'],
                                                style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),)
                                          ),
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        bishopData[index]['mobile'] != null && bishopData[index]['mobile'] != '' ? Flexible(
                                          child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      contentPadding: const EdgeInsets.all(10),
                                                      content: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              (bishopData[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                (bishopData[index]['mobile']).split(',')[0].trim(),
                                                                                style: const TextStyle(color: Colors.blueAccent),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.pop(context); // Close the dialog
                                                                                callAction((bishopData[index]['mobile']).split(',')[0].trim());
                                                                              },
                                                                            ),
                                                                            const Divider(),
                                                                            ListTile(
                                                                              title: Text(
                                                                                (bishopData[index]['mobile']).split(',')[1].trim(),
                                                                                style: const TextStyle(color: Colors.blueAccent),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.pop(context); // Close the dialog
                                                                                callAction((bishopData[index]['mobile']).split(',')[1].trim());
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ) : callAction((bishopData[index]['mobile']).split(',')[0].trim());
                                                            },
                                                            icon: const Icon(Icons.phone),
                                                            color: Colors.blueAccent,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              (bishopData[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                (bishopData[index]['mobile']).split(',')[0].trim(),
                                                                                style: const TextStyle(color: Colors.blueAccent),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.pop(context); // Close the dialog
                                                                                smsAction((bishopData[index]['mobile']).split(',')[0].trim());
                                                                              },
                                                                            ),
                                                                            const Divider(),
                                                                            ListTile(
                                                                              title: Text(
                                                                                (bishopData[index]['mobile']).split(',')[1].trim(),
                                                                                style: const TextStyle(color: Colors.blueAccent),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.pop(context); // Close the dialog
                                                                                smsAction((bishopData[index]['mobile']).split(',')[1].trim());
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ) : smsAction((bishopData[index]['mobile']).split(',')[0].trim());
                                                            },
                                                            icon: const Icon(Icons.message),
                                                            color: Colors.orange,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              (bishopData[index]['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                (bishopData[index]['mobile']).split(',')[0].trim(),
                                                                                style: const TextStyle(color: Colors.blueAccent),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.pop(context); // Close the dialog
                                                                                whatsappAction((bishopData[index]['mobile']).split(',')[0].trim());
                                                                              },
                                                                            ),
                                                                            const Divider(),
                                                                            ListTile(
                                                                              title: Text(
                                                                                (bishopData[index]['mobile']).split(',')[1].trim(),
                                                                                style: const TextStyle(color: Colors.blueAccent),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.pop(context); // Close the dialog
                                                                                whatsappAction((bishopData[index]['mobile']).split(',')[1].trim());
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ) : whatsappAction((bishopData[index]['mobile']).split(',')[0].trim());
                                                            },
                                                            icon: const Icon(LineAwesomeIcons.what_s_app),
                                                            color: Colors.green,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                                },
                                              child: Text((bishopData[index]['mobile']).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)),
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Born On', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        bishopData[index]['dob'] != null && bishopData[index]['dob'] != '' ? Flexible(
                                            child: Text(
                                              bishopData[index]['dob'],
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            )
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Born At', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        bishopData[index]['place_of_birth'] != null && bishopData[index]['place_of_birth'] != '' ? Flexible(
                                            child: Text(
                                              bishopData[index]['place_of_birth'],
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            )
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Feast', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        feastMonth != null && feastMonth != '' && feastDay != null && feastDay != '' ? Row(
                                          children: [
                                            Text(
                                              feastDay,
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            ),
                                            SizedBox(width: size.width * 0.01,),
                                            Text(
                                              '-',
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            ),
                                            SizedBox(width: size.width * 0.01,),
                                            Text(
                                              feastMonth,
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            ),
                                          ],
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Priestly Ordination', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        priest != null && priest != '' ? Flexible(
                                            child: Text(
                                              priest,
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            )
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Appointed as Bishop', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        bishop != null && bishop != '' ? Flexible(
                                            child: Text(
                                              bishop,
                                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                            )
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Episcopal Consecration', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        Text(
                                          '29-09-2002',
                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            bishopData[index]['street'] != null && bishopData[index]['street'] != '' ? Text(bishopData[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                            bishopData[index]['street2'] != null && bishopData[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                                            bishopData[index]['street2'] != null && bishopData[index]['street2'] != '' ? Text(bishopData[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            bishopData[index]['city'] != null && bishopData[index]['city'] != '' ? Text(bishopData[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            bishopData[index]['district_id']['name'] != null && bishopData[index]['district_id']['name'] != '' ? Text(bishopData[index]['district_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            bishopData[index]['state_id']['name'] != null && bishopData[index]['state_id']['name'] != '' ? Text(bishopData[index]['state_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            (bishopData[index]['country_id']['name'] != null && bishopData[index]['country_id']['name'] != '' && bishopData[index]['zip'] != null && bishopData[index]['zip'] != '') ? Text("${bishopData[index]['country_id']['name']}  -  ${bishopData[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("Ordained At", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Column(
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'St. Andrew’s Church, Choolai, Chennai',
                                                style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height*0.01,),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Philosophy',
                                                style: GoogleFonts.secularOne(color: Colors.indigo, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Jnanodaya, Salesian College',
                                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Yercaud 636 601, India',
                                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height*0.01,),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Theology',
                                                style: GoogleFonts.secularOne(color: Colors.indigo, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Morning Star Regional Seminary',
                                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Barrackpore West Bengal - 743',
                                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height*0.01,),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Diploma in Comparative Religion',
                                                style: GoogleFonts.secularOne(color: Colors.indigo, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Dharmaram Institute of Theology and philosophy, Bangalore',
                                                style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Text('*****', style: TextStyle(fontSize: size.height * 0.035, color: Colors.lightBlueAccent),),
                                  ListTile(
                                    title: Text("Positions held 1987-1991", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Column(
                                      children: [
                                        SizedBox(height: size.height*0.01,),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Assistant Director, Archdiocesan Pastoral Centre Director, Archdiocesan Pastoral Centre Vocation Promoter',
                                                style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("1997-1998", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Director, Chingleput Rural Development Society(The Official Social Service organ of the Diocese)',
                                                style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.01,),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Parish Priest, St. Joseph’s Church, Chingleput Parish Priest, Christ the King Church, Karumbakkam Vicar Forane, Chingleput Deanery, Member of the Priests’ Council, and Member of the College of Consultors',
                                                style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("1998-2000", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Master’s Degree in Pastoral Theology, St. John’s University, New York, USA',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("2000-2002", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Vice-Rector, Sacred Heart Seminary, Poonamallee Chennai',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("19.07.2002", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Announcement as the First Bishop of Chengalpattu Diocese',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("29.09.2002", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Episcopal Ordination',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("2003-2009", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Chairman of Women Commission',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("2010", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Chairman of Commission for SC/ST – TNBC Title of Doctor of Divinity (Honoris Causa)(The Academy of Ecumenical Indian Theology and Church Administration)',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("2011", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Chairman of Commission for SC/ST – CBCI',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.01,
                                  ),
                                  ListTile(
                                    title: Text("2016", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Vice President of Tamil Nadu Bishop Council',
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ) : Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
              child: SizedBox(
                height: 50,
                width: 180,
                child: textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
