import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/private/screen/member/family_info/add_family_info.dart';
import 'package:chengai/private/screen/member/family_info/edit_family_info.dart';
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

class ProfileFamilyInfoScreen extends StatefulWidget {
  const ProfileFamilyInfoScreen({Key? key}) : super(key: key);

  @override
  State<ProfileFamilyInfoScreen> createState() => _ProfileFamilyInfoScreenState();
}

class _ProfileFamilyInfoScreenState extends State<ProfileFamilyInfoScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List family = [];
  final format = DateFormat("dd-MM-yyyy");
  int selected = -1;

  getFamilyInfoData() async {
    String url = '$baseUrl/member.family';
    Map data = {
      "params": {
        "filter": "[['member_id','=',$userMember]]",
        "query": "{id,name,contact_number,relationship,gender}"
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
      family = data;
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

  deleteData() async {
    String url = '$baseUrl/delete/member.family/$familyId';
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

      Navigator.maybePop(context, MaterialPageRoute(builder: (context) => ProfileFamilyInfoScreen()),).then((res) => setState(() {
        _isLoading = true;
        getFamilyInfoData();
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

  void changeData() {
    setState(() {
      _isLoading = true;
      getFamilyInfoData();
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
      getFamilyInfoData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getFamilyInfoData();
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
          ) : family.isNotEmpty ? Container(
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
                          itemCount: family.length,
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
                                        indexValue = family[index]['id'];
                                        familyId = indexValue;

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
                                                                text: 'Are you sure want to delete the family data.',
                                                                confirmBtnColor: greenColor,
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
                                                                MaterialPageRoute(builder: (context) => const EditFamilyInfoScreen()));

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
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  Flexible(child: Text(family[index]['name'] + ' ' + '(${family[index]['relationship'] == 'Parent' && family[index]['gender'] == 'Male' ? 'Father' : family[index]['relationship'] == 'Parent' && family[index]['gender'] == 'Female' ? 'Mother' : 'Siblings'})', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                                                ],
                                              ),
                                              // SizedBox(height: size.height * 0.015,),
                                              // Row(
                                              //   children: [
                                              //     Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Gender', style: GoogleFonts.signika(fontSize: size.height * 0.021, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                              //     family[index]['gender'] != '' && family[index]['gender'] != null ? Text('${family[index]['gender']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.021, color: Colors.grey, fontStyle: FontStyle.italic),),
                                              //   ],
                                              // ),
                                              family[index]['contact_number'] != null && family[index]['contact_number'] != '' ? Container() : SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  family[index]['contact_number'] != null && family[index]['contact_number'] != '' ? Text('${family[index]['contact_number']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                  family[index]['contact_number'] != null && family[index]['contact_number'] != '' ? SizedBox(width: size.width * 0.022,) : Container(),
                                                  family[index]['contact_number'] != null && family[index]['contact_number'] != '' ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: family[index]['contact_number'] != null && family[index]['contact_number'] != "" ? const Icon(Icons.phone) : Container(),
                                                        color: Colors.blue,
                                                        onPressed: () {
                                                          callAction(family[index]['contact_number']);
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: family[index]['contact_number'] != null && family[index]['contact_number'] != "" ? const Icon(Icons.message) : Container(),
                                                        color: Colors.orangeAccent,
                                                        onPressed: () {
                                                          smsAction(family[index]['contact_number']);
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: family[index]['contact_number'] != null && family[index]['contact_number'] != "" ? const Icon(LineAwesomeIcons.what_s_app) : Container(),
                                                        color: Colors.green,
                                                        onPressed: () {
                                                          whatsappAction(family[index]['contact_number']);
                                                        },
                                                      )
                                                    ],
                                                  ) : Container()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
              MaterialPageRoute(builder: (context) => const AddFamilyInfoScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: const Color(0xFFFF512F),
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
