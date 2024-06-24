import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHouseScreen extends StatefulWidget {
  const MyHouseScreen({Key? key}) : super(key: key);

  @override
  State<MyHouseScreen> createState() => _MyHouseScreenState();
}

class _MyHouseScreenState extends State<MyHouseScreen> {
  bool _isLoading = true;
  List house = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  houseDetails() async{
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?fields=['name','ministry_ids','diocese_id','parish_id','superior_id','street','street2','place','city','district_id','state_id','zip','country_id','email','phone','mobile','members_count','institution_count']&domain=[('id','=',$userCommunityId)]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      house = data;
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
    houseDetails();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: Center(
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
          ) : house.isNotEmpty ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: ListView.builder(itemCount: house.length, itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15,),
                      child: Container(
                        width: size.width,
                        height: size.height * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: house[index]['image_1920'] != null && house[index]['image_1920'] != ''
                                ? NetworkImage(house[index]['image_1920'])
                                : const AssetImage('assets/images/house.jpg') as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            width: size.width,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: backgroundColor,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  house[index]['name'],
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
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          house[index]['superior_id'].isNotEmpty ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              dense:true,
                              contentPadding: const EdgeInsets.only(left: 20.0),
                              title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("${house[index]['superior_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
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
                          house[index]['diocese_id'].isNotEmpty ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              dense:true,
                              contentPadding: const EdgeInsets.only(left: 20.0),
                              title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("${house[index]['diocese_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                ],
                              ),
                            ),
                          ) : Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                            ),
                          ),
                          house[index]['ministry_ids_name'].isNotEmpty ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              dense:true,
                              contentPadding: const EdgeInsets.only(left: 20.0),
                              title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Flexible(child: Text("${house[index]['ministry_ids_name']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                                ],
                              ),
                            ),
                          ) : Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                            ),
                          ),
                          house[index]['email'].isNotEmpty ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Flexible(child: Text("${house[index]['email']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.email_outlined),
                                color: Colors.red,
                                onPressed: () {
                                  emailAction(house[index]['email']);
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
                          house[index]['mobile'].isNotEmpty ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                                title: Text("Mobile", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("${house[index]['mobile']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.phone),
                                      color: Colors.blue,
                                      onPressed: () {
                                        callAction(house[index]['mobile']);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.message),
                                      color: Colors.orangeAccent,
                                      onPressed: () {
                                        smsAction(house[index]['mobile']);
                                      },
                                    ),
                                    IconButton(
                                      icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                      color: Colors.green,
                                      onPressed: () {
                                        whatsappAction(house[index]['mobile']);
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
                              title: Text("Mobile", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                            ),
                          ),
                          house[index]['phone'].isNotEmpty ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text("Phone", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("${house[index]['phone']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.phone),
                                    color: Colors.blue,
                                    onPressed: () {
                                      callAction( house[index]['phone']);
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
                              title: Text("Phone", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                            ),
                          ),
                          (house[index]['street'].isEmpty && house[index]['street2'].isEmpty && house[index]['place'].isEmpty && house[index]['city'].isEmpty && house[index]['district_id'].isEmpty && house[index]['state_id'].isEmpty && house[index]['country_id'].isEmpty && house[index]['zip'].isEmpty) ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text("Address", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                ],
                              ),
                            ),
                          ) : Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text("Address", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5,),
                                  house[index]['street'].isNotEmpty ? Text("${house[index]['street']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  house[index]['street2'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                  house[index]['street2'].isNotEmpty ? Text("${house[index]['street2']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  const SizedBox(height: 3,),
                                  house[index]['place'].isNotEmpty ? Text("${house[index]['place']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  const SizedBox(height: 3,),
                                  house[index]['city'].isNotEmpty ? Text("${house[index]['city']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  const SizedBox(height: 3,),
                                  house[index]['district_id'].isNotEmpty ? Text("${house[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  const SizedBox(height: 3,),
                                  house[index]['state_id'].isNotEmpty ? Text("${house[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  const SizedBox(height: 3,),
                                  (house[index]['country_id'].isNotEmpty && house[index]['zip'].isNotEmpty) ? Text("${house[index]['country_id'][1]}  -  ${house[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              }),
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
    );
  }
}
