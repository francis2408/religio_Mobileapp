import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/private/screen/member/formation/add_formation.dart';
import 'package:chengai/private/screen/member/formation/edit_formation.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class FormationScreen extends StatefulWidget {
  const FormationScreen({Key? key}) : super(key: key);

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List formation = [];
  int selected = -1;

  getFormationData() async {
    String url = '$baseUrl/member.formation';
    Map data = {
      "params": {
        "filter": "[['member_id','=',$memberId]]",
        "query": "{id,start_year,end_year,formation_stage_id,state,institution}"
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
      formation = data;
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

  deleteData() async {
    String url = '$baseUrl/delete/member.formation/$formationId';
    Map data = {};
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        _isLoading = false;
      });

      Navigator.maybePop(context, MaterialPageRoute(builder: (context) => FormationScreen()),).then((res) => setState(() {
        _isLoading = true;
        getFormationData();
      }));

      AnimatedSnackBar.material(
          message['message'],
          type: AnimatedSnackBarType.success,
          duration: const Duration(seconds: 2)
      ).show(context);
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getFormationData();
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
      getFormationData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getFormationData();
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
          ) : formation.isNotEmpty ? Container(
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
                            itemCount: formation.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: ScaleAnimation(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          int indexValue;
                                          indexValue = formation[index]['id'];
                                          formationId = indexValue;

                                          // Bottom sheet
                                          Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                            return Container(
                                              height: size.height * 0.15,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(25),
                                                    topLeft: Radius.circular(25)
                                                ),
                                                color: Color(0xFFCDCDCD),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      width: size.width * 0.3,
                                                      height: size.height * 0.008,
                                                      alignment: Alignment.topCenter,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: size.height * 0.05,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: size.width * 0.3,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              setState(() {
                                                                QuickAlert.show(
                                                                  context: context,
                                                                  type: QuickAlertType.confirm,
                                                                  title: 'Confirm',
                                                                  text: 'Are you sure want to delete the formation data.',
                                                                  confirmBtnColor: greenColor,
                                                                  // cancelBtnText: 'Cancel',
                                                                  showCancelBtn: true,
                                                                  onConfirmBtnTap: () {
                                                                    deleteData();
                                                                  },
                                                                  onCancelBtnTap: () {
                                                                    cancel();
                                                                  },
                                                                  width: 100.0,
                                                                );
                                                              });
                                                            }, icon: const Icon(Icons.delete), label: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),),
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.03,
                                                        ),
                                                        Container(
                                                          width: size.width * 0.3,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: TextButton.icon(
                                                            onPressed: () async {
                                                              Navigator.pop(context);
                                                              String refresh = await Navigator.push(context,
                                                                  MaterialPageRoute(builder: (context) => const EditFormationScreen()));

                                                              if(refresh == 'refresh') {
                                                                changeData();
                                                              }
                                                            },
                                                            icon: const Icon(Icons.edit),
                                                            label: const Text('Edit'),
                                                            style: TextButton.styleFrom(
                                                                foregroundColor: Colors.white,
                                                                backgroundColor: Colors.orange,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        });
                                      },
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
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Stage', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        formation[index]['formation_stage_id']['name'] != null && formation[index]['formation_stage_id']['name'] != '' ? Text(formation[index]['formation_stage_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                      ],
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    Row(
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Year', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        formation[index]['start_year'].isNotEmpty && formation[index]['start_year'] != null && formation[index]['start_year'] != '' ? Text("${formation[index]['start_year']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : const Text(""),
                                                        SizedBox(width: size.width * 0.05,),
                                                        formation[index]['state'] == 'Completed' && formation[index]['end_year'].isEmpty && formation[index]['end_year'] == '' ? Container() : Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),),
                                                        SizedBox(width: size.width * 0.05,),
                                                        formation[index]['end_year'].isNotEmpty && formation[index]['end_year'] != null && formation[index]['end_year'] != '' ? Text(
                                                          "${formation[index]['end_year']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                                        ) : formation[index]['state'] == 'Completed' && formation[index]['end_year'].isEmpty && formation[index]['end_year'] == '' ? Container() : Text(
                                                          "Till Now", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        formation[index]['institution']!= '' && formation[index]['institution'] != null ? Flexible(child: Text('${formation[index]['institution']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    alignment: Alignment.topRight,
                                                    child: Row(
                                                        children: [
                                                          formation[index]['state'].isNotEmpty && formation[index]['state'] != null && formation[index]['state'] != '' ? formation[index]['state'] == 'Completed' ? Container(
                                                            padding: const EdgeInsets.all(5),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
                                                              color: Colors.teal,
                                                            ),
                                                            child: Text('${formation[index]['state']}',style: GoogleFonts.secularOne(color: Colors.white),),
                                                          ) : Container(
                                                            padding: const EdgeInsets.all(5),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5),
                                                                color: greenColor
                                                            ),
                                                            child: Text('${formation[index]['state']}', style: GoogleFonts.secularOne(color: Colors.white),),
                                                          ) : Container(),
                                                        ]
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddFormationScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: const Color(0xFFFF512F),
        child: const Icon(Icons.add),
      ),
    );
  }
}
