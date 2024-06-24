import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MyInstitutionScreen extends StatefulWidget {
  const MyInstitutionScreen({Key? key}) : super(key: key);

  @override
  State<MyInstitutionScreen> createState() => _MyInstitutionScreenState();
}

class _MyInstitutionScreenState extends State<MyInstitutionScreen> {
  int index = 0;
  bool _isLoading = true;
  List institute = [];
  List data = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  myInstitution() async {
    var request = http.Request(
        'GET', Uri.parse("""$baseUrl/search_read/res.institution?fields=['name','image_1920','community_id','superior_name','diocese_id','parish_id','ministry_ids','institution_category_id','ministry_category_id','phone','mobile','email','street','street2','place','city','district_id','state_id','zip','country_id','establishment_date']&domain=[('id','=',$userInstituteId)]&order=name asc&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
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
        ) : institute.isNotEmpty ? Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SlideFadeAnimation(
            duration: const Duration(seconds: 1),
            child: ListView.builder(itemCount: institute.length, itemBuilder: (BuildContext context, int index) {
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
                          image: institute[index]['image_1920'].isNotEmpty
                              ? NetworkImage(institute[index]['image_1920'])
                              : const AssetImage('assets/images/institution.jpg') as ImageProvider,
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
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        institute[index]['superior_name'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            dense:true,
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['superior_name']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
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
                        institute[index]['diocese_id'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            dense:true,
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['diocese_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
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
                        institute[index]['ministry_ids_name'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            dense:true,
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['ministry_ids_name']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
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
                        institute[index]['establishment_date'] != '' && institute[index]['establishment_date'] != null ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            dense:true,
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text("Establishment", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['establishment_date']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                              ],
                            ),
                          ),
                        ) : Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Establishment", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                              ],
                            ),
                          ),
                        ),
                        institute[index]['institution_category_id'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            dense:true,
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text("Institution Category", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['institution_category_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                              ],
                            ),
                          ),
                        ) : Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Institution Category", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                              ],
                            ),
                          ),
                        ),
                        institute[index]['ministry_category_id'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            dense:true,
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text("Ministry Category", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['ministry_category_id'][1]}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                              ],
                            ),
                          ),
                        ) : Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Ministry Category", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                              ],
                            ),
                          ),
                        ),
                        institute[index]['email'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['email']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
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
                        institute[index]['mobile'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                              title: Text("Mobile", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                              subtitle: Row(
                                children: [
                                  Text("${institute[index]['mobile']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.phone),
                                    color: Colors.blue,
                                    onPressed: () {
                                      callAction(institute[index]['mobile']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.message),
                                    color: Colors.orangeAccent,
                                    onPressed: () {
                                      smsAction(institute[index]['mobile']);
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
                        institute[index]['phone'].isNotEmpty ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Phone", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text("${institute[index]['phone']}", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone),
                                  color: Colors.blue,
                                  onPressed: () {
                                    callAction(institute[index]['phone']);
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
                        (institute[index]['street'].isEmpty &&
                            institute[index]['street2'].isEmpty &&
                            institute[index]['place'].isEmpty &&
                            institute[index]['city'].isEmpty &&
                            institute[index]['district_id'].isEmpty &&
                            institute[index]['state_id'].isEmpty &&
                            institute[index]['country_id'].isEmpty &&
                            institute[index]['zip'].isEmpty) ? Card(
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
                                institute[index]['street'].isNotEmpty ? Text("${institute[index]['street']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                institute[index]['street2'].isNotEmpty ? Text("${institute[index]['street2']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                institute[index]['place'].isNotEmpty ? Text("${institute[index]['place']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                institute[index]['city'].isNotEmpty ? Text("${institute[index]['city']},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                institute[index]['district_id'].isNotEmpty ? Text("${institute[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                institute[index]['state_id'].isNotEmpty ? Text("${institute[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                (institute[index]['country_id'].isNotEmpty && institute[index]['zip'].isNotEmpty) ? Text("${institute[index]['country_id'][1]}  -  ${institute[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    );
  }
}
