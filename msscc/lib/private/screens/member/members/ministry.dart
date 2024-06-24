import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

class MembersMinistryScreen extends StatefulWidget {
  const MembersMinistryScreen({Key? key}) : super(key: key);

  @override
  State<MembersMinistryScreen> createState() => _MembersMinistryScreenState();
}

class _MembersMinistryScreenState extends State<MembersMinistryScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  var ministryData;

  String houseName = '';
  String dateFrom = '';
  String dateTo = '';
  String role = '';
  String institution = '';

  List historyData = [];
  int selected = -1;
  int select = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMinistryDetails() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_member_ministry?args=[$id]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      ministryData = data;
      houseName = ministryData['house_name'];
      dateFrom = ministryData['date_from'];
      dateTo = ministryData['date_to'];
      if(ministryData['role_ids'] != null && ministryData['role_ids'] != '') {
        for(int i = 0; i < ministryData['role_ids'].length; i++) {
          role = ministryData['role_ids'][i]['role_name'];
          institution = ministryData['role_ids'][i]['institution'];
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

  getMemberHistoryData() async {
    String historyUrl = '';
    historyUrl = "$baseUrl/call/house.member/api_get_new_member_ministry?args=[$id,'history']";
    var request = http.Request('GET', Uri.parse(historyUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      historyData = data;
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getMemberHistoryData();
      loadDataWithDelay();
    });
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getMinistryDetails();
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
      getMemberHistoryData();
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberHistoryData();
            loadDataWithDelay();
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
          ) : historyData.isNotEmpty ? Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ministryData.isNotEmpty ? Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('House', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            houseName != null && houseName != '' ? Flexible(child: Text(houseName, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            dateFrom != null && dateFrom != '' ? Text(dateFrom, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : const Text(""),
                                            SizedBox(width: size.width * 0.03,),
                                            Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),),
                                            SizedBox(width: size.width * 0.03,),
                                            dateTo != null && dateTo != '' ? Text(
                                              dateTo, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
                                            ) : Text(
                                              "Till Now", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            role != null && role != '' ? Flexible(child: Text(role, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Institution', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            institution != null && institution != '' ? Flexible(child: Text(institution, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Row(
                                          children: [
                                            dateTo != null && dateTo != '' ? Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: nonActiveColor
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 13,
                                                minHeight: 13,
                                              ),
                                            ) : Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: activeColor
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 13,
                                                minHeight: 13,
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ) : Container(),
                            ListView.builder(
                                key: Key('builder ${selected.toString()}'),
                                shrinkWrap: true,
                                // scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: historyData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('House', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                      SizedBox(width: size.width * 0.02,),
                                                      historyData[index]['house_name'] != null && historyData[index]['house_name'] != '' ? Flexible(child: Text(historyData[index]['house_name'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                                    ],
                                                  ),
                                                  SizedBox(height: size.height * 0.015,),
                                                  Row(
                                                    children: [
                                                      Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                      SizedBox(width: size.width * 0.02,),
                                                      historyData[index]['date_from'] != null && historyData[index]['date_from'] != '' ? Text("${historyData[index]['date_from']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : const Text(""),
                                                      SizedBox(width: size.width * 0.03,),
                                                      Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),),
                                                      SizedBox(width: size.width * 0.03,),
                                                      historyData[index]['date_to'] != null && historyData[index]['date_to'] != '' ? Text(
                                                        "${historyData[index]['date_to']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
                                                      ) : Text(
                                                        "Till Now", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: size.height * 0.015,),
                                                  Row(
                                                    children: [
                                                      Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                      SizedBox(width: size.width * 0.02,),
                                                      historyData[index]['member_roles']!= '' && historyData[index]['member_roles'] != null ? Flexible(child: Text('${historyData[index]['member_roles']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Row(
                                                    children: [
                                                      historyData[index]['date_to'] != null && historyData[index]['date_to'] != '' ? Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: nonActiveColor
                                                        ),
                                                        constraints: const BoxConstraints(
                                                          minWidth: 13,
                                                          minHeight: 13,
                                                        ),
                                                      ) : Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: activeColor
                                                        ),
                                                        constraints: const BoxConstraints(
                                                          minWidth: 13,
                                                          minHeight: 13,
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  );
                                }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
