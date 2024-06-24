import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:svdinm/private/screens/member/formation/add_formation.dart';
import 'package:svdinm/private/screens/member/formation/edit_formation.dart';
import 'package:svdinm/widget/common/common.dart';
import 'package:svdinm/widget/common/internet_connection_checker.dart';
import 'package:svdinm/widget/common/slide_animations.dart';
import 'package:svdinm/widget/common/snackbar.dart';
import 'package:svdinm/widget/theme_color/theme_color.dart';
import 'package:svdinm/widget/widget.dart';

class MembersFormationScreen extends StatefulWidget {
  const MembersFormationScreen({Key? key}) : super(key: key);

  @override
  State<MembersFormationScreen> createState() => _MembersFormationScreenState();
}

class _MembersFormationScreenState extends State<MembersFormationScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;
  List data = [];
  List formation = [];
  int selected = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getFormationData() async {
    String formationUrl = '';
    formationUrl = "$baseUrl/search_read/res.formation?domain=[('member_id','=',$id)]&fields=['formation_stage_id','house_id','start_year','end_year','study_info','state']&order=start_year desc";
    var request = http.Request('GET', Uri.parse(formationUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      formation = data;
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

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.formation?ids=[$formationId]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Formation data deleted successfully.',
            Colors.green
        );
      });
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
          ) : formation.isNotEmpty ? Container(
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
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: formation.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int indexValue;
                                    indexValue = formation[index]['id'];
                                    formationId = indexValue;
                                    // Bottom Sheet
                                    Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                      return CustomBottomSheet(
                                        size: size, // Pass the 'size' variable
                                        onDeletePressed: () {
                                          setState(() {
                                            Navigator.pop(context);
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmAlertDialog(
                                                  message: 'Are you sure want to delete the formation data ?',
                                                  onCancelPressed: () {
                                                    cancel();
                                                  },
                                                  onYesPressed: () {
                                                    if(load) {
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible: false,
                                                        builder: (BuildContext context) {
                                                          return const CustomLoadingDialog();
                                                        },
                                                      );
                                                      delete();
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          });
                                        },
                                        onEditPressed: () async {
                                          Navigator.pop(context);
                                          String refresh = await Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => const EditFormationScreen()));
                                          if(refresh == 'refresh') {
                                            changeData();
                                          }
                                        },
                                      );
                                    });
                                  });
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Stage', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                formation[index]['formation_stage_id'] != [] && formation[index]['formation_stage_id'].isNotEmpty ? Text(formation[index]['formation_stage_id'][1], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              children: [
                                                Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Year', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                SizedBox(width: size.width * 0.02,),
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
                                              children: [
                                                Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Unit/LCF', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                formation[index]['house_id'].isNotEmpty && formation[index]['house_id'] != [] ? Text('${formation[index]['house_id'][1]}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                                  formation[index]['state'] != null && formation[index]['state'] != '' ? formation[index]['state'] == 'Completed' ? Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: statusCompleted,
                                                    ),
                                                    child: Text('${formation[index]['state']}',style: GoogleFonts.secularOne(color: statusTextColor),),
                                                  ) : Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: statusActive,
                                                    ),
                                                    child: Text('${formation[index]['state']}', style: GoogleFonts.secularOne(color: statusTextColor),),
                                                  ) : Container(),
                                                ]
                                            ),
                                          ),
                                        )
                                      ],
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
      floatingActionButton: formation.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddFormationScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ) : ConditionalFloatingActionButton(
        isEmpty: false,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddFormationScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
