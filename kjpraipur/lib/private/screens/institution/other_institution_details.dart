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

class OtherInstitutionDetailsScreen extends StatefulWidget {
  const OtherInstitutionDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OtherInstitutionDetailsScreen> createState() => _OtherInstitutionDetailsScreenState();
}

class _OtherInstitutionDetailsScreenState extends State<OtherInstitutionDetailsScreen> {
  int index = 0;
  bool _isLoading = true;
  List institute = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  myInstitution() async {
    var request = http.Request(
        'GET', Uri.parse("""$baseUrl/search_read/res.institution?fields=['name','image_1920','community_id','superior_name','diocese_id','parish_id','ministry_ids','institution_category_id','ministry_category_id','phone','mobile','email','street','street2','place','city','district_id','state_id','zip','country_id','establishment_date','members_count']&domain=[('id','=',$instituteID)]&context={"bypass":1}&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      institute = data;
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
    myInstitution();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
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
        ) : CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              automaticallyImplyLeading: false,
              expandedHeight: size.height * 0.3,
              pinned: true,
              floating: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white,),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: size.width * 0.1, end: size.width * 0.1, bottom: 5.0),
                centerTitle: true,
                title: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: backgroundColor,
                  ),
                  child: Text(
                    institute[index]['name'],
                    textScaleFactor: 1.0,
                    style: GoogleFonts.secularOne(
                        letterSpacing: 1,
                        color: Colors.white,
                        fontSize: size.height * 0.02
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                expandedTitleScale: 1,
                // ClipRRect added here for rounded corners
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  child: institute[index]['image_1920'] != null && institute[index]['image_1920'] != '' ? Image.network(
                      institute[index]['image_1920'],
                      fit: BoxFit.fill
                  ) : Image.asset('assets/images/institution.jpg',
                      fit: BoxFit.fill
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: SingleChildScrollView(
                child:  SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.05,),
                      institute[index]['ministry_ids_name'] != null && institute[index]['ministry_ids_name'] != '' ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    institute[index]['ministry_ids_name'],
                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                  )
                              ),
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
                      institute[index]['establishment_date'] != null && institute[index]['establishment_date'] != '' ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Establishment Date", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    institute[index]['establishment_date'],
                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                  )
                              ),
                            ],
                          ),
                        ),
                      ) : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Establishment Date", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                            ],
                          ),
                        ),
                      ),
                      institute[index]['diocese_id'].isNotEmpty && institute[index]['diocese_id'] != null && institute[index]['diocese_id'] != [] ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    institute[index]['diocese_id'][1],
                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                  )
                              ),
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
                      institute[index]['parish_id'].isNotEmpty && institute[index]['parish_id'] != null && institute[index]['parish_id'] != [] ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Parish", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    institute[index]['parish_id'][1],
                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                  )
                              ),
                            ],
                          ),
                        ),
                      ) : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Parish", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                            ],
                          ),
                        ),
                      ),
                      institute[index]['superior_name'] != '' && institute[index]['superior_name'] != null ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    institute[index]['superior_name'],
                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                  )
                              ),
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
                      institute[index]['email'] != null && institute[index]['email'] != '' ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: [
                              Flexible(
                                  child: Text(
                                    institute[index]['email'],
                                    style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                  )
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.email_outlined),
                            color: Colors.red,
                            onPressed: () {
                              emailAction(institute[index]['email']);
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
                      institute[index]['mobile'] != null && institute[index]['mobile'] != '' ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: (institute[index]['mobile'] as String)
                                .split(',')
                                .map<Widget>((mobile) {
                              // Trim leading and trailing spaces from the mobile number
                              mobile = mobile.trim();
                              return Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Show alert dialog with icon buttons
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        callAction(mobile);
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: Colors.blueAccent,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        smsAction(mobile);
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: Colors.orange,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        whatsappAction(mobile);
                                                      },
                                                      icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                                      color: Colors.green,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      mobile,
                                      style: GoogleFonts.secularOne(
                                        color: Colors.blueAccent,
                                        fontSize: size.height * 0.02,
                                      ),
                                    ),
                                  ),
                                  if (mobile !=
                                      (institute[index]['mobile'] as String)
                                          .split(',')
                                          .last
                                          .trim()) Text(
                                    '|',
                                    style: GoogleFonts.secularOne(
                                      color: Colors.grey,
                                      fontSize: size.height * 0.02,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
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
                      institute[index]['phone'] != null && institute[index]['phone'] != '' ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                          subtitle: Row(
                            children: (institute[index]['phone'] as String)
                                .split(',')
                                .map<Widget>((phone) {
                              // Trim leading and trailing spaces from the mobile number
                              phone = phone.trim();
                              return Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Show alert dialog with icon buttons
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        callAction(phone);
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      phone,
                                      style: GoogleFonts.secularOne(
                                        color: Colors.blueAccent,
                                        fontSize: size.height * 0.02,
                                      ),
                                    ),
                                  ),
                                  if (phone !=
                                      (institute[index]['phone'] as String)
                                          .split(',')
                                          .last
                                          .trim()) Text(
                                    '|',
                                    style: GoogleFonts.secularOne(
                                      color: Colors.grey,
                                      fontSize: size.height * 0.02,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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
                      (institute[index]['street'].isEmpty && institute[index]['street2'].isEmpty && institute[index]['place'].isEmpty && institute[index]['city'].isEmpty && institute[index]['district_id'].isEmpty && institute[index]['district_id'] != null && institute[index]['state_id'].isEmpty && institute[index]['state_id'] != null && institute[index]['country_id'].isEmpty && institute[index]['country_id'] != null && institute[index]['zip'].isEmpty) ? Card(
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
                              institute[index]['street'] != null && institute[index]['street'] != '' ? Text(institute[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              institute[index]['street2'] != null && institute[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                              institute[index]['street2'] != null && institute[index]['street2'] != '' ? Text(institute[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              institute[index]['place'] != null && institute[index]['place'] != '' ? const SizedBox(height: 3,) : Container(),
                              institute[index]['place'] != null && institute[index]['place'] != '' ? Text(institute[index]['place'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              const SizedBox(height: 3,),
                              institute[index]['city'] != null && institute[index]['city'] != '' ? Text(institute[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              const SizedBox(height: 3,),
                              institute[index]['district_id'] != null && institute[index]['district_id'].isNotEmpty ? Text(institute[index]['district_id'][1], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              const SizedBox(height: 3,),
                              institute[index]['state_id'] != null && institute[index]['state_id'].isNotEmpty ? Text(institute[index]['state_id'][1], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              const SizedBox(height: 3,),
                              (institute[index]['country_id'] != null && institute[index]['country_id'].isNotEmpty && institute[index]['zip'] != null && institute[index]['zip'] != '') ? Text("${institute[index]['country_id'][1]}  -  ${institute[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
