import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProvinceBasicDetailsScreen extends StatefulWidget {
  const ProvinceBasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceBasicDetailsScreen> createState() => _ProvinceBasicDetailsScreenState();
}

class _ProvinceBasicDetailsScreenState extends State<ProvinceBasicDetailsScreen> {
  int index = 0;
  bool _isLoading = true;
  List province = [];
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  String provinceName = '';
  String establishmentYear = '';
  String provinceEmail = '';
  String provinceMobile = '';
  String provincePhone = '';
  String provinceHistory = '';
  String provinceWebsite = '';
  String provinceImage = '';
  String vision = '';
  String mission = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getProvinceData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.religious.province?domain=[('id','=',$userProvinceId)]&fields=['name','code','image_1920','establishment_year','email','mobile','phone','history','website','vision','mission']"));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      province = data;

      for(int i = 0; i < province.length; i++) {
        provinceName = province[i]['name'];
        establishmentYear = province[i]['establishment_year'];
        provinceEmail = province[i]['email'];
        provinceMobile = province[i]['mobile'];
        provincePhone = province[i]['phone'];
        provinceHistory = province[i]['history'];
        provinceWebsite = province[i]['website'];
        provinceImage = province[i]['image_1920'];
        vision = province[i]['vision'];
        mission = province[i]['mission'];
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

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> webAction(String web) async {
    if (await canLaunch(web)) {
      await launch(
        web,
        forceWebView: true,
        forceSafariVC: false, // Set this to false for Android devices
      );
    } else {
      throw 'Could not launch $web';
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
    getProvinceData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: Container(
              height: size.height * 0.1,
              width: size.width * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage( "assets/alert/spinner_1.gif"),
                ),
              )
          ),
        ) : province.isNotEmpty ? SlideFadeAnimation(
          duration: const Duration(seconds: 1),
          child: ListView.builder(itemCount: province.length, itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                            SizedBox(width: size.width * 0.02,),
                            provinceEmail != '' && provinceEmail != null ? GestureDetector(
                                onTap: () {
                                  (provinceEmail).split(',').length != 1 ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.all(10),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    (provinceEmail).split(',')[0].trim(),
                                                    style: const TextStyle(color: Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context); // Close the dialog
                                                    emailAction((provinceEmail).split(',')[0].trim());
                                                  },
                                                ),
                                                const Divider(),
                                                ListTile(
                                                  title: Text(
                                                    (provinceEmail).split(',')[1].trim(),
                                                    style: const TextStyle(color: Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context); // Close the dialog
                                                    emailAction((provinceEmail).split(',')[0].trim());
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ) : emailAction((provinceEmail).split(',')[0].trim());
                                },
                                child: Text(
                                  (provinceEmail).split(',')[0].trim(),
                                  style: GoogleFonts.secularOne(
                                      color: Colors.black,
                                      fontSize: size.height * 0.02
                                  ),
                                )
                            ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.redAccent, fontStyle: FontStyle.italic),),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          children: [
                            Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                            SizedBox(width: size.width * 0.02,),
                            provinceMobile != null && provinceMobile != '' ? GestureDetector(
                                onTap: () {
                                  (provinceMobile).split(',').length != 1 ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.all(10),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    (provinceMobile).split(',')[0].trim(),
                                                    style: const TextStyle(color: Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context); // Close the dialog
                                                    callAction((provinceMobile).split(',')[0].trim());
                                                  },
                                                ),
                                                const Divider(),
                                                ListTile(
                                                  title: Text(
                                                    (provinceMobile).split(',')[1].trim(),
                                                    style: const TextStyle(color: Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context); // Close the dialog
                                                    callAction((provinceMobile).split(',')[0].trim());
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ) : callAction((provinceMobile).split(',')[0].trim());
                                },
                                child: Text(
                                  (provinceMobile).split(',')[0].trim(),
                                  style: GoogleFonts.secularOne(
                                      color: Colors.blueAccent,
                                      fontSize: size.height * 0.02
                                  ),
                                )
                            ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          children: [
                            Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Phone', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                            SizedBox(width: size.width * 0.02,),
                            provincePhone != null && provincePhone != '' ? GestureDetector(
                                onTap: () {
                                  (provincePhone).split(',').length != 1 ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.all(10),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    (provincePhone).split(',')[0].trim(),
                                                    style: const TextStyle(color: Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context); // Close the dialog
                                                    callAction((provincePhone).split(',')[0].trim());
                                                  },
                                                ),
                                                const Divider(),
                                                ListTile(
                                                  title: Text(
                                                    (provincePhone).split(',')[1].trim(),
                                                    style: const TextStyle(color: Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context); // Close the dialog
                                                    callAction((provincePhone).split(',')[0].trim());
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ) : callAction((provincePhone).split(',')[0].trim());
                                },
                                child: Text(
                                  (provincePhone).split(',')[0].trim(),
                                  style: GoogleFonts.secularOne(
                                      color: Colors.blueAccent,
                                      fontSize: size.height * 0.02
                                  ),
                                )
                            ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          children: [
                            Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Vision', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                            SizedBox(width: size.width * 0.02,),
                            vision != null && vision != '' ? Text(
                              vision,
                              style: GoogleFonts.secularOne(
                                  color: Colors.black,
                                  fontSize: size.height * 0.02
                              ),
                            ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          children: [
                            Container(width: size.width * 0.15, alignment: Alignment.topLeft, child: Text('Mission', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                            SizedBox(width: size.width * 0.02,),
                            mission != null && mission != '' ? Text(
                              mission,
                              style: GoogleFonts.secularOne(
                                  color: Colors.black,
                                  fontSize: size.height * 0.02
                              ),
                            ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                provinceHistory.isNotEmpty ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Html(
                      data: provinceHistory,
                    ),
                  ),
                ) : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Row(
                      children: [
                        Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                      ],
                    ),
                  ),
                ),
              ],
            );
            // return Column(
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.all(5),
            //       child: Column(
            //         children: [
            //           provinceEmail.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Flexible(child: Text((provinceEmail).split(',')[0].trim(), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
            //                 ],
            //               ),
            //               trailing: IconButton(
            //                 icon: const Icon(Icons.email_outlined),
            //                 color: Colors.red,
            //                 onPressed: () {
            //                   (provinceEmail).split(',').length != 1 ? showDialog(
            //                     context: context,
            //                     builder: (BuildContext context) {
            //                       return AlertDialog(
            //                         contentPadding: const EdgeInsets.all(10),
            //                         content: Column(
            //                           mainAxisSize: MainAxisSize.min,
            //                           children: [
            //                             Column(
            //                               children: [
            //                                 ListTile(
            //                                   title: Text(
            //                                     (provinceEmail).split(',')[0].trim(),
            //                                     style: const TextStyle(color: Colors.blueAccent),
            //                                   ),
            //                                   onTap: () {
            //                                     Navigator.pop(context); // Close the dialog
            //                                     emailAction((provinceEmail).split(',')[0].trim());
            //                                   },
            //                                 ),
            //                                 const Divider(),
            //                                 ListTile(
            //                                   title: Text(
            //                                     (provinceEmail).split(',')[1].trim(),
            //                                     style: const TextStyle(color: Colors.blueAccent),
            //                                   ),
            //                                   onTap: () {
            //                                     Navigator.pop(context); // Close the dialog
            //                                     emailAction((provinceEmail).split(',')[0].trim());
            //                                   },
            //                                 ),
            //                               ],
            //                             ),
            //                           ],
            //                         ),
            //                       );
            //                     },
            //                   ) : emailAction((provinceEmail).split(',')[0].trim());
            //                 },
            //               ),
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           provinceMobile.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //                 title: Text("Mobile", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //                 subtitle: Row(
            //                   children: [
            //                     Text(provinceMobile, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
            //                   ],
            //                 ),
            //                 trailing: Row(
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [
            //                     IconButton(
            //                       icon: const Icon(Icons.phone),
            //                       color: Colors.blue,
            //                       onPressed: () {
            //                         callAction(provinceMobile);
            //                       },
            //                     ),
            //                     IconButton(
            //                       icon: const Icon(Icons.message),
            //                       color: Colors.orangeAccent,
            //                       onPressed: () {
            //                         smsAction(provinceMobile);
            //                       },
            //                     ),
            //                     IconButton(
            //                       icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
            //                       color: Colors.green,
            //                       onPressed: () {
            //                         whatsappAction(provinceMobile);
            //                       },
            //                     )
            //                   ],
            //                 )
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Mobile", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           provincePhone.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Phone", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text(provincePhone, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
            //                 ],
            //               ),
            //               trailing: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   IconButton(
            //                     icon: const Icon(Icons.phone),
            //                     color: Colors.blue,
            //                     onPressed: () {
            //                       callAction(provincePhone);
            //                     },
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Phone", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           vision.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Vision", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Flexible(child: Text(vision, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
            //                 ],
            //               ),
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Vision", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           mission.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Mission", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Flexible(child: Text(mission, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
            //                 ],
            //               ),
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Mission", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           provinceWebsite.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Website", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text(provinceWebsite, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
            //                 ],
            //               ),
            //               trailing: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   IconButton(
            //                     icon: const Icon(Icons.language),
            //                     color: Colors.blue,
            //                     onPressed: () async {
            //                       webAction(provinceWebsite);
            //                     },
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("Website", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           provinceHistory.isNotEmpty ? Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Html(
            //                 data: provinceHistory,
            //               ),
            //             ),
            //           ) : Card(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(15.0),
            //             ),
            //             child: ListTile(
            //               title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
            //               subtitle: Row(
            //                 children: [
            //                   Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // );
          }),
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
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
            )
          ],
        ),
      ),
    );
  }
}
