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

const double expandedHeight = 300;
const double roundedContainerHeight = 50;

class OtherHouseDetailsScreen extends StatefulWidget {
  const OtherHouseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OtherHouseDetailsScreen> createState() => _OtherHouseDetailsScreenState();
}

class _OtherHouseDetailsScreenState extends State<OtherHouseDetailsScreen> {
  bool _isLoading = true;
  List houseData = [];
  int index = 0;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getOtherHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?domain=[('id','=',$houseID)]&fields=['name','ministry_ids','diocese_id','parish_id','superior_id','street','street2','place','city','district_id','state_id','zip','country_id','email','phone','mobile']&limit=40&offset=0"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      houseData = data;
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
    // TODO: implement initState
    super.initState();
    getOtherHouseData();
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
                      houseData[index]['name'],
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
                  child: houseData[index]['image_1920'] != null && houseData[index]['image_1920'] != '' ? Image.network(
                      houseData[index]['image_1920'],
                      fit: BoxFit.fill
                  ) : Image.asset('assets/images/house.jpg',
                      fit: BoxFit.fill
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: SingleChildScrollView(
                child:  SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.05,),
                        houseData[index]['ministry_ids_name'] != null && houseData[index]['ministry_ids_name'] != '' ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                      houseData[index]['ministry_ids_name'],
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
                        houseData[index]['diocese_id'].isNotEmpty && houseData[index]['diocese_id'] != null && houseData[index]['diocese_id'] != [] ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                      houseData[index]['diocese_id'][1],
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
                        houseData[index]['parish_id'].isNotEmpty && houseData[index]['parish_id'] != null && houseData[index]['parish_id'] != [] ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Parish", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                      houseData[index]['parish_id'][1],
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
                        houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != null && houseData[index]['superior_id'] != [] ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                      houseData[index]['superior_id'][1],
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
                        houseData[index]['email'] != null && houseData[index]['email'] != '' ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                      houseData[index]['email'],
                                      style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                    )
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.email_outlined),
                              color: Colors.red,
                              onPressed: () {
                                emailAction(houseData[index]['email']);
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
                        houseData[index]['mobile'] != null && houseData[index]['mobile'] != '' ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text(
                                  houseData[index]['mobile'],
                                  style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone),
                                  color: Colors.blue,
                                  onPressed: () {
                                    callAction(houseData[index]['mobile']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  color: Colors.orangeAccent,
                                  onPressed: () {
                                    smsAction(houseData[index]['mobile']);
                                  },
                                ),
                                IconButton(
                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                  color: Colors.green,
                                  onPressed: () {
                                    whatsappAction(houseData[index]['mobile']);
                                  },
                                )
                              ],
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
                        houseData[index]['phone'] != null && houseData[index]['phone'] != '' ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                            subtitle: Row(
                              children: [
                                Text(
                                  houseData[index]['phone'],
                                  style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone),
                                  color: Colors.blue,
                                  onPressed: () {
                                    callAction(houseData[index]['phone']);
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
                        (houseData[index]['street'].isEmpty && houseData[index]['street2'].isEmpty && houseData[index]['place'].isEmpty && houseData[index]['city'].isEmpty && houseData[index]['district_id'].isEmpty && houseData[index]['district_id'] != null && houseData[index]['state_id'].isEmpty && houseData[index]['state_id'] != null && houseData[index]['country_id'].isEmpty && houseData[index]['country_id'] != null && houseData[index]['zip'].isEmpty) ? Card(
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
                                houseData[index]['street'] != null && houseData[index]['street'] != '' ? Text(houseData[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                houseData[index]['street2'] != null && houseData[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                                houseData[index]['street2'] != null && houseData[index]['street2'] != '' ? Text(houseData[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                houseData[index]['place'] != null && houseData[index]['place'] != '' ? const SizedBox(height: 3,) : Container(),
                                houseData[index]['place'] != null && houseData[index]['place'] != '' ? Text(houseData[index]['place'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                const SizedBox(height: 3,),
                                houseData[index]['city'] != null && houseData[index]['city'] != '' ? Text(houseData[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                const SizedBox(height: 3,),
                                houseData[index]['district_id'] != null && houseData[index]['district_id'].isNotEmpty ? Text(houseData[index]['district_id'][1], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                const SizedBox(height: 3,),
                                houseData[index]['state_id'] != null && houseData[index]['state_id'].isNotEmpty ? Text(houseData[index]['state_id'][1], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                const SizedBox(height: 3,),
                                (houseData[index]['country_id'] != null && houseData[index]['country_id'].isNotEmpty && houseData[index]['zip'] != null && houseData[index]['zip'] != '') ? Text("${houseData[index]['country_id'][1]}  -  ${houseData[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}