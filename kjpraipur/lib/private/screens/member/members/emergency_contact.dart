import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kjpraipur/private/screens/member/emergency_contact/add_emergency_contact.dart';
import 'package:kjpraipur/private/screens/member/emergency_contact/edit_emergency_contact.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MembersEmergencyContactScreen extends StatefulWidget {
  const MembersEmergencyContactScreen({Key? key}) : super(key: key);

  @override
  State<MembersEmergencyContactScreen> createState() => _MembersEmergencyContactScreenState();
}

class _MembersEmergencyContactScreenState extends State<MembersEmergencyContactScreen> {
  bool _isLoading = true;
  bool load = true;
  List data = [];
  List emergency = [];
  final format = DateFormat("dd-MM-yyyy");
  int selected = -1;

  Timer? glowTimer;
  bool isGlowing = false;
  double glowOpacity = 0.0;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getEmergencyData() async {
    String professionUrl = '';
    professionUrl = "$baseUrl/search_read/emergency.contact.info?domain=[('member_id','=',$id)]&fields=['emer_name','emer_phone','emer_relationship_id','emer_street','emer_street2','emer_place','emer_city','emer_district_id','emer_state_id','emer_country_id','emer_zip']";
    var request = http.Request('GET', Uri.parse(professionUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      emergency = data;
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

  Future<void> smsAction(String number) async {
    const countryCode = '+91'; // Indian country code
    // Remove any non-digit characters from the phone number
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    final Uri uri = Uri(scheme: "sms", path: formattedNumber);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    const countryCode = '+91'; // Indian country code
    // Remove any non-digit characters from the phone number
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    final Uri uri = Uri(scheme: 'tel', path: formattedNumber);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Can not launch URL';
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    // Remove any non-digit characters from the phone number
    final cleanNumber = whatsapp.replaceAll(RegExp(r'\D'), '');
    // Extract the country code from the WhatsApp number
    const countryCode = '91'; // Assuming country code length is 2
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    if (Platform.isAndroid) {
      final whatsappUrl = 'whatsapp://send?phone=$formattedNumber';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    } else {
      final whatsappUrl = 'https://api.whatsapp.com/send?phone=$formattedNumber';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
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
      getEmergencyData();
    });
  }

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/emergency.contact.info?ids=[$emergencyId]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        Navigator.pop(context);
        load = false;
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Emergency contact data deleted successfully.',
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
    getEmergencyData();
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
          ) : emergency.isNotEmpty ? Container(
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
                            itemCount: emergency.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int indexValue;
                                    indexValue = emergency[index]['id'];
                                    emergencyId = indexValue;
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
                                                                message: 'Are you sure want to delete the emergency contact data ?',
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
                                                            MaterialPageRoute(builder: (context) => const EditEmergencyContactScreen()));
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
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                            emergency[index]['emer_name'] != '' && emergency[index]['emer_name'] != null ? Flexible(child: Text('${emergency[index]['emer_name']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Relation', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                            emergency[index]['emer_relationship_id'] != null && emergency[index]['emer_relationship_id'].isNotEmpty ? Flexible(child: Text('${emergency[index]['emer_relationship_id'][1]}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != '' ? Container() : SizedBox(height: size.height * 0.015,),
                                        Row(
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                            emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != '' ? Text('${emergency[index]['emer_phone']}', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                            // emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != '' ? SizedBox(width: size.width * 0.005,) : Container(),
                                            emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != '' ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != "" ? const Icon(Icons.phone) : Container(),
                                                  color: Colors.blue,
                                                  onPressed: () {
                                                    callAction(emergency[index]['emer_phone']);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != "" ? const Icon(Icons.message) : Container(),
                                                  color: Colors.orangeAccent,
                                                  onPressed: () {
                                                    smsAction(emergency[index]['emer_phone']);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: emergency[index]['emer_phone'] != null && emergency[index]['emer_phone'] != "" ? SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,) : Container(),
                                                  color: Colors.green,
                                                  onPressed: () {
                                                    whatsappAction(emergency[index]['emer_phone']);
                                                  },
                                                )
                                              ],
                                            ) : Container()
                                          ],
                                        ),
                                        emergency[index]['emer_phone'] == '' ? SizedBox(height: size.height * 0.015,) : Container(),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Home Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                            emergency[index]['emer_street'].isEmpty && emergency[index]['emer_street2'].isEmpty &&
                                                emergency[index]['emer_place'].isEmpty && emergency[index]['emer_city'].isEmpty && emergency[index]['emer_district_id'].isEmpty &&
                                                emergency[index]['emer_state_id'].isEmpty && emergency[index]['emer_country_id'].isEmpty && emergency[index]['emer_zip'].isEmpty ? Text(
                                              'NA',
                                              style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),
                                            ) : Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  emergency[index]['emer_street'] != '' && emergency[index]['emer_street'] != null ? Text("${emergency[index]['emer_street']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                  emergency[index]['emer_street2'] != '' && emergency[index]['emer_street2'] != null ? Text("${emergency[index]['emer_street2']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                  emergency[index]['emer_place'] != '' && emergency[index]['emer_place'] != null ? Text("${emergency[index]['emer_place']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                  emergency[index]['emer_city'] != '' && emergency[index]['emer_city'] != null ? Text("${emergency[index]['emer_city']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                  emergency[index]['emer_district_id'] != [] && emergency[index]['emer_district_id'].isNotEmpty ? Text("${emergency[index]['emer_district_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                  emergency[index]['emer_state_id'] != [] && emergency[index]['emer_state_id'].isNotEmpty ? Text("${emergency[index]['emer_state_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                  emergency[index]['emer_country_id'] != [] && emergency[index]['emer_country_id'].isNotEmpty ? Row(
                                                    children: [
                                                      emergency[index]['emer_country_id'] != [] && emergency[index]['emer_country_id'].isNotEmpty ? Text("${emergency[index]['emer_country_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                      emergency[index]['emer_zip'] != '' && emergency[index]['emer_zip'] != null ? Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                                      emergency[index]['emer_zip'] != '' && emergency[index]['emer_zip'] != null ? Text("${emergency[index]['emer_zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container()
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
      floatingActionButton: emergency.isEmpty ? AnimatedContainer(
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
                MaterialPageRoute(builder: (context) => const AddEmergencyContactScreen()));
            if(refresh == 'refresh') {
              changeData();
            }
          },
          backgroundColor: iconBackColor,
          child: const Icon(Icons.add),
        ),
      ) : FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEmergencyContactScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: iconBackColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
