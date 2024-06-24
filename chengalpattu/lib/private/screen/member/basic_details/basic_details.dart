import 'dart:convert';

import 'package:chengai/private/screen/member/edit_basic/edit_basic_details.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class BasicDetailsScreen extends StatefulWidget {
  const BasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List member = [];
  List holyOrder = [];
  int index = 0;
  int selected = -1;

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  String orderDate = '';
  String count = '';

  getMemberDetails() async {
    String url = '$baseUrl/res.member';
    Map data = {
      "params": {
        "filter": "[['id','=',$memberId]]",
        "query": "{id,member_name,image_1920,blood_group_id,dob,age,mobile,email,place_of_birth,street,street2,city,district_id,state_id,country_id,zip,role_ids,holyorder_ids{order,date}}"
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
      for(int i = 0; i < member.length; i++) {
        List ordination = member[i]['holyorder_ids'];
        for(int j = 0; j < ordination.length; j++) {
          if(ordination[j]['order'] == 'Priest') {
            final date = format.parse(ordination[j]['date']);
            var holyDate = reverse.format(date);
            DateTime dateTime = DateTime.parse(holyDate);
            orderDate = DateFormat('MMM d, y').format(dateTime);
            var dateNow = DateTime.now();
            var diff = dateNow.difference(dateTime);
            var year = ((diff.inDays)/365).round();
            count = year.toString();
          }
        }
      }
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

  void changeData() {
    setState(() {
      _isLoading = true;
      getMemberDetails();
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ) : member.isNotEmpty ? Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: member.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: ScaleAnimation(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['role_ids_view'] != '' && member[index]['role_ids_view'] != null ? Flexible(child: Text('${member[index]['role_ids_view']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['mobile'] != '' && member[index]['mobile'] != null ? Text('${member[index]['mobile']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['email'] != '' && member[index]['email'] != null ? Flexible(child: Text('${member[index]['email']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Birthday', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['dob'] != '' && member[index]['dob'] != null ? Row(
                                                    children: [
                                                      Text('${member[index]['dob']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                      SizedBox(width: size.width * 0.01,),
                                                      Text('(age: ${member[index]['age']})', style: GoogleFonts.signika(color: Colors.grey, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),),
                                                    ],
                                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place of Birth', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['place_of_birth'] != '' && member[index]['place_of_birth'] != null ? Flexible(child: Text('${member[index]['place_of_birth']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Blood Group', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['blood_group_id']['name'] != '' && member[index]['blood_group_id']['name'] != null ? Text('${member[index]['blood_group_id']['name']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Ordination Day', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  orderDate != '' && orderDate != null ? Row(
                                                    children: [
                                                      Text(orderDate, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                      SizedBox(width: size.width * 0.02,),
                                                      count != '' && count != null ? Text('($count years)', style: GoogleFonts.signika(color: Colors.grey, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),) : Container(),
                                                    ],
                                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Parish Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  member[index]['street'] == '' && member[index]['street2'] == '' && member[index]['city'] == '' && member[index]['district_id']['name'] == '' && member[index]['state_id']['name'] == '' && member[index]['country_id']['name'] == '' && member[index]['zip'] == '' ? Text(
                                                    'NA',
                                                    style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),
                                                  ) : Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        member[index]['street'] != '' && member[index]['street'] != null ? Text("${member[index]['street']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                        member[index]['street2'] != '' && member[index]['street2'] != null ? Text("${member[index]['street2']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                        member[index]['place'] != '' && member[index]['place'] != null ? Text("${member[index]['place']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                        member[index]['city'] != '' && member[index]['city'] != null ? Text("${member[index]['city']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                        member[index]['district_id']['name'] != '' && member[index]['district_id']['name'] != null ? Text("${member[index]['district_id']['name']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                        member[index]['state_id']['name'] != '' && member[index]['state_id']['name'] != null ? Text("${member[index]['state_id']['name']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                        member[index]['country_id']['name'] != '' && member[index]['country_id']['name'] != null ? Row(
                                                          children: [
                                                            member[index]['country_id']['name'] != '' && member[index]['country_id']['name'] != null ? Text("${member[index]['country_id']['name']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                            member[index]['zip'] != '' && member[index]['zip'] != null ? Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                            member[index]['zip'] != '' && member[index]['zip'] != null ? Text("${member[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container()
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
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) : Center(
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
      floatingActionButton: userLevel != 'Diocesan Member' ? FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const EditBasicDetailsScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: const Color(0xFFFF512F),
        child: const Icon(Icons.edit),
      ) : Container(),
    );
  }
}
