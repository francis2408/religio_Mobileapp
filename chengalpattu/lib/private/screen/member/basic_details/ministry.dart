import 'dart:convert';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class MinistryScreen extends StatefulWidget {
  const MinistryScreen({Key? key}) : super(key: key);

  @override
  State<MinistryScreen> createState() => _MinistryScreenState();
}

class _MinistryScreenState extends State<MinistryScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List ministry = [];
  int selected = -1;

  var headers = {
    'Authorization': authToken,
    'Content-Type': 'application/json',
  };

  getMinistryData() async {
    String url = '$baseUrl/member.ministry';
    Map data = {
      "params":
      {   "filter":"[['member_id','=',$memberId]]",
        "order":"status asc",
        "query":"{id,parish_id,date_from,date_to,ministry_line_ids{role_ids,institution_id},status}"
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
      ministry = data;
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getMinistryData();
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
      getMinistryData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMinistryData();
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
          ) : ministry.isNotEmpty ? Container(
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
                            itemCount: ministry.length,
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
                                          padding: const EdgeInsets.all(15),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Parish', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                      SizedBox(width: size.width * 0.02,),
                                                      ministry[index]['parish_id']['name'].isNotEmpty && ministry[index]['parish_id']['name'] != '' ? Flexible(child: Text(ministry[index]['parish_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                    ],
                                                  ),
                                                  SizedBox(height: size.height * 0.015,),
                                                  Row(
                                                    children: [
                                                      Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                      SizedBox(width: size.width * 0.02,),
                                                      ministry[index]['date_from'].isNotEmpty && ministry[index]['date_from'] != '' ? Text(ministry[index]['date_from'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : const Text(""),
                                                      SizedBox(width: size.width * 0.03,),
                                                      Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),),
                                                      SizedBox(width: size.width * 0.03,),
                                                      ministry[index]['date_to'].isNotEmpty && ministry[index]['date_to'] != '' ? Text(
                                                        ministry[index]['date_to'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
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
                                                      ministry[index]['ministry_line_ids'].isNotEmpty && ministry[index]['ministry_line_ids'][0]['role_ids_view'].isNotEmpty && ministry[index]['ministry_line_ids'][0]['role_ids_view'] != '' ? Flexible(child: Text(ministry[index]['ministry_line_ids'][0]['role_ids_view'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                    ],
                                                  ),
                                                  ministry[index]['status'] == 'Active' ? SizedBox(height: size.height * 0.015,) : Container(),
                                                  ministry[index]['status'] == 'Active' ? Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Institution', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                      SizedBox(width: size.width * 0.02,),
                                                      ministry[index]['ministry_line_ids'].isNotEmpty && ministry[index]['ministry_line_ids'][0]['institution_id']['name'].isNotEmpty && ministry[index]['ministry_line_ids'][0]['institution_id']['name'] != '' ? Flexible(child: Text(ministry[index]['ministry_line_ids'][0]['institution_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                    ],
                                                  ) : Container(),
                                                ],
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Row(
                                                    children: [
                                                      ministry[index]['status'] != null && ministry[index]['status'] != '' ? ministry[index]['status'] == 'Completed' ? Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: Colors.red
                                                        ),
                                                        constraints: const BoxConstraints(
                                                          minWidth: 13,
                                                          minHeight: 13,
                                                        ),
                                                      ) : Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: Colors.green
                                                        ),
                                                        constraints: const BoxConstraints(
                                                          minWidth: 13,
                                                          minHeight: 13,
                                                        ),
                                                      ) : Container(),
                                                    ]
                                                ),
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
    );
  }
}
