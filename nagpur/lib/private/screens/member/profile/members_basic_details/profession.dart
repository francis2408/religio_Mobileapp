import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nagpur/private/screens/member/profession/add_profession.dart';
import 'package:nagpur/private/screens/member/profession/edit_profession.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/common/internet_connection_checker.dart';
import 'package:nagpur/widget/common/slide_animations.dart';
import 'package:nagpur/widget/common/snackbar.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

class MemberProfessionScreen extends StatefulWidget {
  const MemberProfessionScreen({Key? key}) : super(key: key);

  @override
  State<MemberProfessionScreen> createState() => _MemberProfessionScreenState();
}

class _MemberProfessionScreenState extends State<MemberProfessionScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;
  List data = [];
  List profession = [];
  final format = DateFormat("dd-MM-yyyy");
  int selected = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getProfessionData() async {
    String professionUrl = '';
    professionUrl = "$baseUrl/search_read/res.profession?domain=[('member_id','=',$memberId)]&fields=['profession_date','place','type','years','state']&order=profession_date desc";
    var request = http.Request('GET', Uri.parse(professionUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      profession = data;
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
      getProfessionData();
    });
  }

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.profession?ids=[$professionId]'));
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
            'Profession data deleted successfully.',
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
      getProfessionData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getProfessionData();
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
          ) : profession.isNotEmpty ? Container(
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
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: profession.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int indexValue;
                                    indexValue = profession[index]['id'];
                                    professionId = indexValue;
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
                                                  message: 'Are you sure want to delete the profession data ?',
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
                                              MaterialPageRoute(builder: (context) => const EditProfessionScreen()));
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
                                                Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Mode', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                profession[index]['type'] != null && profession[index]['type'] != '' ? Text(profession[index]['type'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              children: [
                                                Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                profession[index]['profession_date'] != null && profession[index]['profession_date'] != '' ? Text(DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(profession[index]['profession_date'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                profession[index]['place'] != '' && profession[index]['place'] != null ? Flexible(child: Text('${profession[index]['place']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                                  profession[index]['state'] != null && profession[index]['state'] != '' ? profession[index]['state'] == 'Completed' ? Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: statusCompleted,
                                                    ),
                                                    child: Text('${profession[index]['state']}',style: GoogleFonts.secularOne(color: statusTextColor),),
                                                  ) : Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: statusActive,
                                                    ),
                                                    child: Text('${profession[index]['state']}', style: GoogleFonts.secularOne(color: statusTextColor),),
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
      floatingActionButton: profession.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddProfessionScreen()));
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
              MaterialPageRoute(builder: (context) => const AddProfessionScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
