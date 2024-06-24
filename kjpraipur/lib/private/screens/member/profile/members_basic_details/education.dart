import 'dart:async';
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kjpraipur/private/screens/member/education/add_education.dart';
import 'package:kjpraipur/private/screens/member/education/edit_education.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

class MemberEducationScreen extends StatefulWidget {
  const MemberEducationScreen({Key? key}) : super(key: key);

  @override
  State<MemberEducationScreen> createState() => _MemberEducationScreenState();
}

class _MemberEducationScreenState extends State<MemberEducationScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool load = true;

  List data = [];
  List education = [];
  int selected = -1;

  Timer? glowTimer;
  bool isGlowing = false;
  double glowOpacity = 0.0;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getEducationData() async {
    String educationUrl = '';
    educationUrl = "$baseUrl/search_read/res.member.education?domain=[('member_id','=',$memberId)]&fields=['study_level_id','program_id','institution','year_of_passing','state','mode','result','attachment']&order=year_of_passing asc";
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
        load = false;
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

  void startGlowAnimation() {
    const duration = Duration(milliseconds: 800);
    glowTimer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        isGlowing = !isGlowing;
        glowOpacity = isGlowing ? 1.0 : 0.0;
      });
    });
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
    getEducationData();
    startGlowAnimation();
  }

  @override
  void dispose() {
    glowTimer?.cancel();
    super.dispose();
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
                                    // Bottom Sheet
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
                                                        String refresh = await Navigator.push(context,
                                                            MaterialPageRoute(builder: (context) => const EditEducationScreen()));
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
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Study Level', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['study_level_id'] != [] ? Text("${education[index]['study_level_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Program', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['program_id'] != [] ? Text("${education[index]['program_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Institution', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['institution'] != '' && education[index]['institution'] != null ? Flexible(child: Text('${education[index]['institution']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mode', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['mode'] != '' && education[index]['mode'] != null ? Text('${education[index]['mode']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Year of Passing', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  education[index]['year_of_passing'] != '' && education[index]['year_of_passing'] != null ? Text('${education[index]['year_of_passing']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
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
                                                    education[index]['status'] != null && education[index]['status'] != '' ? education[index]['status'] == 'Completed' ? Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: Colors.teal,
                                                      ),
                                                      child: Text('${education[index]['status']}',style: GoogleFonts.secularOne(color: Colors.white),),
                                                    ) : Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: greenColor
                                                      ),
                                                      child: Text('${education[index]['status']}', style: GoogleFonts.secularOne(color: Colors.white),),
                                                    ) : Container(),
                                                  ]
                                              ),
                                            ),
                                          ),
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
      floatingActionButton: education.isEmpty ? AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 55.0,
        height: 55.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(glowOpacity),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(glowOpacity),
              blurRadius: 10.0,
              spreadRadius: 5.0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            String refresh = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddEducationScreen()));
            if(refresh == 'refresh') {
              changeData();
            }
          },
          backgroundColor: iconBackColor,
          child: const Icon(Icons.add, color: buttonIconColor,),
        ),
      ) : FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEducationScreen()));
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
