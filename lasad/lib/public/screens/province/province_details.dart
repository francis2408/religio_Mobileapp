import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicProvinceDetailsScreen extends StatefulWidget {
  const PublicProvinceDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PublicProvinceDetailsScreen> createState() => _PublicProvinceDetailsScreenState();
}

class _PublicProvinceDetailsScreenState extends State<PublicProvinceDetailsScreen> {
  bool _isLoading = true;
  List province = [];
  int index = 0;

  getProvinceData() async {
    var request = sectorTab == 'Indian Sector' ? http.Request('GET', Uri.parse("$baseUrl/province/$userProvinceId")) : http.Request('GET', Uri.parse("$baseUrl/province/$sri_sector_id"));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = [];
      var request = json.decode(await response.stream.bytesToString());
      if(request['status'] == "success") {
        data = request['data'];
      }
      setState(() {
        _isLoading = false;
      });
      province = data;
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
    String? countryCode = extractCountryCode(whatsapp);

    if (countryCode != null) {
      // Perform the WhatsApp action here.
      if (Platform.isAndroid) {
        final whatsappUrl = 'whatsapp://send?phone=$whatsapp';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      } else {
        final whatsappUrl = 'https://api.whatsapp.com/send?phone=$whatsapp';
        await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
      }
    } else {
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
  }

  String? extractCountryCode(String whatsappNumber) {
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      if (whatsappNumber.startsWith('+')) {
        // The country code is assumed to be present at the beginning of the number.
        int endIndex = whatsappNumber.indexOf(' ');
        return endIndex != -1 ? whatsappNumber.substring(1, endIndex) : whatsappNumber.substring(1);
      }
    }
    return null; // Country code not found.
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
    // Check Internet connection
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
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Color(0xFFA5FECB), Color(0xFF20BDFF), Color(0xFF5433FF),],
            ),
          ),
        ) : province.isNotEmpty ? SingleChildScrollView(
          child:  SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(
              shrinkWrap: true,
              // scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: province.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Container(
                        width: size.width,
                        height: size.height * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: province[index]['image_1920'] != null && province[index]['image_1920'] != ''
                                ? NetworkImage(province[index]['image_1920'])
                                : const AssetImage('assets/images/lasad_logo.png') as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: size.width,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: backgroundColor,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              province[index]['name'],
                              textScaleFactor: 1.0,
                              style: GoogleFonts.secularOne(
                                  letterSpacing: 1,
                                  color: Colors.white,
                                  fontSize: size.height * 0.02
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    province[index]['house_id'].isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("House", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Flexible(child: Text("${province[index]['house_id']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                          ],
                        ),
                      ),
                    ) : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("House", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                    ),
                    province[index]['superior_id'].isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Flexible(child: Text("${province[index]['superior_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                          ],
                        ),
                      ),
                    ) : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                    ),
                    province[index]['email'].isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Flexible(child: Text("${province[index]['email']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.email_outlined),
                          color: Colors.red,
                          onPressed: () {
                            emailAction(province[index]['email']);
                          },
                        ),
                      ),
                    ) : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                    ),
                    province[index]['mobile'].isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                          title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Text("${province[index]['mobile']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.phone),
                                color: Colors.blue,
                                onPressed: () {
                                  callAction(province[index]['mobile']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.message),
                                color: Colors.orangeAccent,
                                onPressed: () {
                                  smsAction(province[index]['mobile']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(LineAwesomeIcons.what_s_app),
                                color: Colors.green,
                                onPressed: () {
                                  whatsappAction(province[index]['mobile']);
                                },
                              )
                            ],
                          )
                      ),
                    ) : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                    ),
                    province[index]['phone'].isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Text("${province[index]['phone']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.phone),
                              color: Colors.blue,
                              onPressed: () {
                                callAction( province[index]['phone']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ) : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                        subtitle: Row(
                          children: [
                            Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ) : Expanded(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: NoResult(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
