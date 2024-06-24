import 'dart:convert';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:scb/private/screens/member/education/add_education.dart';
import 'package:scb/private/screens/member/education/edit_education.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/common/snackbar.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';

class MembersEducationScreen extends StatefulWidget {
  const MembersEducationScreen({Key? key}) : super(key: key);

  @override
  State<MembersEducationScreen> createState() => _MembersEducationScreenState();
}

class _MembersEducationScreenState extends State<MembersEducationScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;

  List data = [];
  List education = [];
  int selected = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getEducationData() async {
    String educationUrl = '';
    educationUrl = "$baseUrl/search_read/res.member.education?domain=[('member_id','=',$id)]&fields=['study_level_id','program_id','institution','year_of_passing','state','mode','result','attachment']&order=year_of_passing desc";
    var request = http.Request('GET', Uri.parse(educationUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      education = data;
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

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.member.education?ids=[$educationId]'));
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
            'Education data deleted successfully.',
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
      getEducationData();
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
      getEducationData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getEducationData();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    field = '';
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
          ) : education.isNotEmpty ? Container(
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
                            itemCount: education.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int indexValue;
                                    indexValue = education[index]['id'];
                                    educationId = indexValue;
                                    // Bottom sheet
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
                                                  message: 'Are you sure want to delete the education data ?',
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
                                              MaterialPageRoute(builder: (context) => const EditEducationScreen()));
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
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Study Level', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['study_level_id'] != [] ? Text("${education[index]['study_level_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Program', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['program_id'] != [] ? Text("${education[index]['program_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Institution', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['institution'] != '' && education[index]['institution'] != null ? Flexible(child: Text('${education[index]['institution']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Mode', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['mode'] != '' && education[index]['mode'] != null ? Text('${education[index]['mode']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Year of Passing', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['year_of_passing'] != '' && education[index]['year_of_passing'] != null ? Text('${education[index]['year_of_passing']}', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                                    education[index]['state'] != null && education[index]['state'] != '' ? education[index]['state'] == 'Completed' ? Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: statusCompleted,
                                                      ),
                                                      child: Text('${education[index]['state']}',style: GoogleFonts.secularOne(color: statusTextColor),),
                                                    ) : Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: statusActive
                                                      ),
                                                      child: Text('${education[index]['state']}', style: GoogleFonts.secularOne(color: statusTextColor),),
                                                    ) : Container(),
                                                  ]
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: education[index]['attachment'] != '' && education[index]['attachment'] != null ? GestureDetector(
                                                onTap: () {
                                                  localPath = education[index]['attachment'];
                                                  File file = File(localPath);
                                                  var path = file.path;
                                                  fileName = path.split("/").last;

                                                  Map<String, String> queryParams = Uri.parse(fileName).queryParameters;
                                                  // Extract the 'field' parameter
                                                  field = queryParams['field'] ?? '';

                                                  Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerUrl(url: localPath,),),);
                                                },
                                                child: const Icon(
                                                  Icons.attach_file,
                                                  color: menuPrimaryColor,
                                                )
                                            ) : Container(),
                                          ),
                                        ],
                                      ),
                                    )
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
      floatingActionButton: education.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEducationScreen()));
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
              MaterialPageRoute(builder: (context) => const AddEducationScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
