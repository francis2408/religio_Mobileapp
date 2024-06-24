import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scb/private/screens/member/family_info/add_family_info.dart';
import 'package:scb/private/screens/member/family_info/edit_family_info.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/common/snackbar.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberFamilyInfoScreen extends StatefulWidget {
  const MemberFamilyInfoScreen({Key? key}) : super(key: key);

  @override
  State<MemberFamilyInfoScreen> createState() => _MemberFamilyInfoScreenState();
}

class _MemberFamilyInfoScreenState extends State<MemberFamilyInfoScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;
  List data = [];
  List family = [];
  final format = DateFormat("dd-MM-yyyy");
  int selected = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getFamilyData() async {
    String familyUrl = '';

    familyUrl = "$baseUrl/search_read/res.religious.family?domain=[('member_id','=',$memberId)]&fields=['name','gender','relationship','contact_number','occupation','birth_date']&order=relationship asc";

    var request = http.Request('GET', Uri.parse(familyUrl));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      family = data;
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getFamilyData();
    });
  }

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.religious.family?ids=[$familyId]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        Navigator.pop(context);
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Family data deleted successfully.',
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
      getFamilyData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getFamilyData();
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
          ) : family.isNotEmpty ? Container(
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
                          itemCount: family.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  int indexValue;
                                  indexValue = family[index]['id'];
                                  familyId = indexValue;
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
                                                message: 'Are you sure want to delete the family info data ?',
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
                                            MaterialPageRoute(builder: (context) => const EditFamilyInfoScreen()));
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
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                          Flexible(child: Text(family[index]['name'] + ' ' + '(${family[index]['relationship'] == 'Parent' && family[index]['gender'] == 'Male' ? 'Father' : family[index]['relationship'] == 'Parent' && family[index]['gender'] == 'Female' ? 'Mother' : 'Siblings'})', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                                        ],
                                      ),
                                      family[index]['contact_number'] != null && family[index]['contact_number'] != '' ? Container() : SizedBox(height: size.height * 0.015,),
                                      Row(
                                        children: [
                                          Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                          family[index]['contact_number'] != '' && family[index]['contact_number'] != null ? IntrinsicHeight(
                                            child: (family[index]['contact_number']).split(',').length != 1 ? Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          contentPadding: const EdgeInsets.all(10),
                                                          content: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  callAction((family[index]['contact_number']).split(',')[0].trim());
                                                                },
                                                                icon: const Icon(Icons.phone),
                                                                color: callColor,
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  smsAction((family[index]['contact_number']).split(',')[0].trim());
                                                                },
                                                                icon: const Icon(Icons.message),
                                                                color: smsColor,
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  whatsappAction((family[index]['contact_number']).split(',')[0].trim());
                                                                },
                                                                icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                color: whatsAppColor,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    (family[index]['contact_number']).split(',')[0].trim(),
                                                    style: GoogleFonts.secularOne(
                                                        color: mobileText,
                                                        fontSize: size.height * 0.02
                                                    ),),
                                                ),
                                                SizedBox(width: size.width * 0.01,),
                                                const VerticalDivider(
                                                  color: Colors.grey,
                                                  thickness: 2,
                                                ),
                                                SizedBox(width: size.width * 0.01,),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          contentPadding: const EdgeInsets.all(10),
                                                          content: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  callAction((family[index]['contact_number']).split(',')[1].trim());
                                                                },
                                                                icon: const Icon(Icons.phone),
                                                                color: callColor,
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  smsAction((family[index]['contact_number']).split(',')[1].trim());
                                                                },
                                                                icon: const Icon(Icons.message),
                                                                color: smsColor,
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  whatsappAction((family[index]['contact_number']).split(',')[1].trim());
                                                                },
                                                                icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                color: whatsAppColor,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    (family[index]['contact_number']).split(',')[1].trim(),
                                                    style: GoogleFonts.secularOne(
                                                        color: mobileText,
                                                        fontSize: size.height * 0.02
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ) : Row(
                                              children: [
                                                Text(
                                                  (family[index]['contact_number']).split(',')[0].trim(),
                                                  style: GoogleFonts.secularOne(
                                                    color: mobileText,
                                                    fontSize: size.height * 0.02,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        callAction((family[index]['contact_number']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: callColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        smsAction((family[index]['contact_number']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: smsColor,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        whatsappAction((family[index]['contact_number']).split(',')[0].trim());
                                                      },
                                                      icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                      color: whatsAppColor,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ) : Text(
                                            'NA',
                                            style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ],
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
      floatingActionButton: family.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddFamilyInfoScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.group_add, color: buttonIconColor,), // Customize the child widget here
      ) : ConditionalFloatingActionButton(
        isEmpty: false,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddFamilyInfoScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.group_add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
