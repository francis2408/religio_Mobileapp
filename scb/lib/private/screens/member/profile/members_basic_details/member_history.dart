import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scb/private/screens/member/member_history/add_member_history.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/common/snackbar.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';

class MemberHistoryScreen extends StatefulWidget {
  const MemberHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MemberHistoryScreen> createState() => _MemberHistoryScreenState();
}

class _MemberHistoryScreenState extends State<MemberHistoryScreen> {
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
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_member_ministry?args=[$memberId]"));
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
    historyUrl = "$baseUrl/call/house.member/api_get_new_member_ministry?args=[$memberId,'history']";
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

  deleteData() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.member.education?ids=[$educationId]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Member history data deleted successfully.',
            Colors.green
        );
      });
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getMemberHistoryData();
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
      getMinistryDetails();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberHistoryData();
            getMinistryDetails();
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
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: ExpansionTile(
                                onExpansionChanged: (newState) {
                                  if(newState) {
                                    setState(() {
                                      int indexValue;
                                      indexValue = ministryData['house_id'];
                                      // ministryId = indexValue;
                                    });
                                  } else {
                                    setState(() {
                                      selected = -1;
                                    });
                                  }
                                },
                                title: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('House', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        SizedBox(width: size.width * 0.02,),
                                        houseName.isNotEmpty && houseName != '' ? Flexible(child: Text(houseName, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.015,),
                                    Row(
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        SizedBox(width: size.width * 0.02,),
                                        dateFrom.isNotEmpty && dateFrom != '' ? Text(dateFrom, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : const Text(""),
                                        SizedBox(width: size.width * 0.03,),
                                        Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),),
                                        SizedBox(width: size.width * 0.03,),
                                        dateTo.isNotEmpty && dateTo != '' ? Text(
                                          dateTo, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                        ) : Text(
                                          "Till Now", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.015,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        SizedBox(width: size.width * 0.02,),
                                        role.isNotEmpty && role != '' ? Flexible(child: Text(role, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.015,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Institution', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                        SizedBox(width: size.width * 0.02,),
                                        institution.isNotEmpty && institution != '' ? Flexible(child: Text(institution, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  // Container(
                                  //   padding: const EdgeInsets.only(right: 10, bottom: 10),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.end,
                                  //     children: [
                                  //       GFButton(
                                  //         onPressed: () async {
                                  //           String refresh = await Navigator.push(context,
                                  //               MaterialPageRoute(builder: (context) => const EditMemberHistoryScreen()));
                                  //           if(refresh == 'refresh') {
                                  //             changeData();
                                  //           }
                                  //         },
                                  //         text: "EDIT",
                                  //         icon: const Icon(Icons.edit, color: Colors.white,),
                                  //         shape: GFButtonShape.pills,
                                  //         color: Colors.green,
                                  //         size: GFSize.SMALL,
                                  //       ),
                                  //       const SizedBox(width: 10,),
                                  //       GFButton(
                                  //         onPressed: () {
                                  //           setState(() {
                                  //             QuickAlert.show(
                                  //               context: context,
                                  //               type: QuickAlertType.confirm,
                                  //               title: 'Confirm',
                                  //               text: 'Are you sure want to delete the education data.',
                                  //               confirmBtnColor: greenColor,
                                  //               showCancelBtn: true,
                                  //               onConfirmBtnTap: () {
                                  //                 deleteData();
                                  //               },
                                  //               onCancelBtnTap: () {
                                  //                 cancel();
                                  //               },
                                  //               width: 100.0,
                                  //             );
                                  //           });
                                  //         },
                                  //         text: "DELETE",
                                  //         icon: const Icon(Icons.delete, color: Colors.white,),
                                  //         shape: GFButtonShape.pills,
                                  //         color: Colors.red,
                                  //         size: GFSize.SMALL,
                                  //       ),
                                  //     ],
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
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
                                        child: ExpansionTile(
                                          key: Key(index.toString()),
                                          initiallyExpanded: index == selected,
                                          onExpansionChanged: (newState) {
                                            if(newState) {
                                              setState(() {
                                                selected = index;
                                                int indexValue;
                                                indexValue = historyData[index]['id'];
                                                // historyId = indexValue;
                                              });
                                            } else {
                                              setState(() {
                                                selected = -1;
                                              });
                                            }
                                          },
                                          title: Container(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('House', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                    SizedBox(width: size.width * 0.02,),
                                                    historyData[index]['house_name'] != null && historyData[index]['house_name'] != '' ? Flexible(child: Text(historyData[index]['house_name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                  ],
                                                ),
                                                SizedBox(height: size.height * 0.015,),
                                                Row(
                                                  children: [
                                                    Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                    SizedBox(width: size.width * 0.02,),
                                                    historyData[index]['date_from'] != null && historyData[index]['date_from'] != '' ? Text("${historyData[index]['date_from']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : const Text(""),
                                                    SizedBox(width: size.width * 0.03,),
                                                    Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),),
                                                    SizedBox(width: size.width * 0.03,),
                                                    historyData[index]['date_to'] != null && historyData[index]['date_to'] != '' ? Text(
                                                      "${historyData[index]['date_to']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                                    ) : Text(
                                                      "Till Now", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: size.height * 0.015,),
                                                Row(
                                                  children: [
                                                    Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Role', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                    SizedBox(width: size.width * 0.02,),
                                                    historyData[index]['member_roles']!= '' && historyData[index]['member_roles'] != null ? Flexible(child: Text('${historyData[index]['member_roles']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          children: [
                                            // Container(
                                            //   padding: const EdgeInsets.only(right: 10, bottom: 10),
                                            //   child: Row(
                                            //     mainAxisAlignment: MainAxisAlignment.end,
                                            //     children: [
                                            //       GFButton(
                                            //         onPressed: () async {
                                            //           String refresh = await Navigator.push(context,
                                            //               MaterialPageRoute(builder: (context) => const EditMemberHistoryScreen()));
                                            //           if(refresh == 'refresh') {
                                            //             changeData();
                                            //           }
                                            //         },
                                            //         text: "EDIT",
                                            //         icon: const Icon(Icons.edit, color: Colors.white,),
                                            //         shape: GFButtonShape.pills,
                                            //         color: Colors.green,
                                            //         size: GFSize.SMALL,
                                            //       ),
                                            //       const SizedBox(width: 10,),
                                            //       GFButton(
                                            //         onPressed: () {
                                            //           setState(() {
                                            //             QuickAlert.show(
                                            //               context: context,
                                            //               type: QuickAlertType.confirm,
                                            //               title: 'Confirm',
                                            //               text: 'Are you sure want to delete the education data.',
                                            //               confirmBtnColor: greenColor,
                                            //               showCancelBtn: true,
                                            //               onConfirmBtnTap: () {
                                            //                 deleteData();
                                            //               },
                                            //               onCancelBtnTap: () {
                                            //                 cancel();
                                            //               },
                                            //               width: 100.0,
                                            //             );
                                            //           });
                                            //         },
                                            //         text: "DELETE",
                                            //         icon: const Icon(Icons.delete, color: Colors.white,),
                                            //         shape: GFButtonShape.pills,
                                            //         color: Colors.red,
                                            //         size: GFSize.SMALL,
                                            //       ),
                                            //     ],
                                            //   ),
                                            // )
                                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddMemberHistoryScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: iconBackColor,
        child: const Icon(Icons.add, color: buttonIconColor,),
      ),
    );
  }
}
