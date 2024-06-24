import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProvinceBasicDetailsScreen extends StatefulWidget {
  const ProvinceBasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceBasicDetailsScreen> createState() => _ProvinceBasicDetailsScreenState();
}

class _ProvinceBasicDetailsScreenState extends State<ProvinceBasicDetailsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
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

  // Superior Details
  String superiorImage = '';
  String superiorName = '';
  String superiorRole = '';
  String superiorEmail = '';
  String superiorMobile = '';

  // House Details
  var house_id;
  String street = '';
  String street2 = '';
  String place = '';
  String city = '';
  String district = '';
  String state = '';
  String country = '';
  String zip = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getProvinceData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.religious.province?domain=[('id','=',$userProvinceId)]&fields=['name','code','image_1920','establishment_year','motto','charism','patron_id','founder','email','mobile','phone','history','website','vision','mission','superior_id','house_id']"));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
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
        if(province[i]['superior_id'].isNotEmpty && province[i]['superior_id'] != []) {
          house_id = province[i]['house_id'][0];
          getHouseData();
        }
        if(province[i]['superior_id'].isNotEmpty && province[i]['superior_id'] != []) {
          superiorId = province[i]['superior_id'][0];
          getSuperiorData();
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
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

  getSuperiorData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$superiorId)]&fields=['image_512','member_name','member_type','mobile','email','role_ids']&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      for(int i = 0; i < data.length; i++) {
        superiorImage = data[i]['image_512'];
        superiorName = data[i]['member_name'];
        superiorRole = data[i]['role_ids_name'];
        superiorMobile = data[i]['mobile'];
        superiorEmail = data[i]['email'];
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

  getHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?domain=[('id','=',$house_id)]&fields=['name','street','street2','place','city','district_id','state_id','country_id','zip']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      for(int j = 0; j < data.length; j++) {
        street = data[j]['street'];
        street2 = data[j]['street2'];
        place = data[j]['place'];
        city = data[j]['city'];
        if(data[j]['district_id'].isNotEmpty && data[j]['district_id'] != [] && data[j]['district_id'] != '') {
          district = data[j]['district_id'][1];
        }
        if(data[j]['state_id'].isNotEmpty && data[j]['state_id'] != [] && data[j]['state_id'] != '') {
          state = data[j]['state_id'][1];
        }
        if(data[j]['country_id'].isNotEmpty && data[j]['country_id'] != [] && data[j]['country_id'] != '') {
          country = data[j]['country_id'][1];
        }
        zip = data[j]['zip'];
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
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
      throw "Can not launch url";
    }
  }

  Future<void> telCallAction(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
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
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e'; // Handle any exceptions that occur during launch
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
      getProvinceData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getProvinceData();
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
        ) : province.isNotEmpty ? SlideFadeAnimation(
          duration: const Duration(seconds: 1),
          child: ListView.builder(itemCount: province.length, itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Motto', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                province[index]['motto'].isNotEmpty && province[index]['motto'] != '' ? Flexible(child: Text("${province[index]['motto']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                              ],
                            ),
                            SizedBox(height: size.height * 0.01,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Charism', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                province[index]['charism'].isEmpty && province[index]['charism'] == '' ? Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),) : Container(),
                              ],
                            ),
                            province[index]['charism'].isEmpty && province[index]['charism'] == '' ? SizedBox(height: size.height * 0.01,) : Container(),
                            province[index]['charism'].isNotEmpty && province[index]['charism'] != '' ? Row(
                              children: [
                                Flexible(child: Text("${province[index]['charism']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02), textAlign: TextAlign.justify,)),
                              ],
                            ) : Container(),
                          ],
                        ),
                      )
                  ),
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Patron', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                province[index]['patron_id'].isNotEmpty && province[index]['patron_id'] != [] ? Flexible(child: Text("${province[index]['patron_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                              ],
                            ),
                            SizedBox(height: size.height * 0.01,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Founder', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                province[index]['founder'].isNotEmpty && province[index]['founder'] != '' ? Flexible(child: Text("${province[index]['founder']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                              ],
                            ),
                            SizedBox(height: size.height * 0.01,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Est. Year', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                province[index]['establishment_year'] != '' && province[index]['establishment_year'] != null ? Flexible(child: Text(province[index]['establishment_year'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                    child: Text('Superior', style: GoogleFonts.portLligatSans(fontSize: size.height * 0.02, color: valueColor, fontWeight: FontWeight.bold),),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              superiorImage != '' ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Image.network(superiorImage, fit: BoxFit.cover,),
                                  );
                                },
                              ) : showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: size.height * 0.11,
                              width: size.width * 0.18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: -1,
                                    blurRadius: 5 ,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: superiorImage != null && superiorImage != ''
                                      ? NetworkImage(superiorImage)
                                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 15, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  superiorName != null && superiorName != '' ? Row(
                                    children: [
                                      Flexible(
                                        child: Text.rich(
                                          textAlign: TextAlign.left,
                                          TextSpan(
                                              text: superiorName,
                                              style: GoogleFonts.secularOne(
                                                fontSize: size.height * 0.02,
                                                color: textHeadColor,
                                              ),
                                              children: superiorRole != null && superiorRole != '' ? [
                                                const TextSpan(
                                                  text: '  ',
                                                ),
                                                TextSpan(
                                                  text: '($superiorRole)',
                                                  style: GoogleFonts.secularOne(
                                                      fontSize: size.height * 0.018,
                                                      color: Colors.black45,
                                                      fontStyle: FontStyle.italic
                                                  ),
                                                ),
                                              ] : []
                                          ),
                                        ),
                                      ),
                                    ],
                                  ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  superiorEmail != null && superiorEmail != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                  superiorEmail != null && superiorEmail != '' ? GestureDetector(
                                      onTap: () {
                                        emailAction(superiorEmail);
                                      },
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              superiorEmail,
                                              style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),),
                                          ),
                                        ],
                                      )
                                  ) : Container(),
                                  superiorMobile != null && superiorMobile != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                  superiorMobile != '' && superiorMobile != null ? IntrinsicHeight(
                                    child: (superiorMobile).split(',').length != 1 ? Row(
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
                                                          callAction((superiorMobile).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: callColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          smsAction((superiorMobile).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: smsColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          whatsappAction((superiorMobile).split(',')[0].trim());
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
                                            (superiorMobile).split(',')[0].trim(),
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
                                                          callAction((superiorMobile).split(',')[1].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: callColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          smsAction((superiorMobile).split(',')[1].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: smsColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          whatsappAction((superiorMobile).split(',')[1].trim());
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
                                            (superiorMobile).split(',')[1].trim(),
                                            style: GoogleFonts.secularOne(
                                                color: mobileText,
                                                fontSize: size.height * 0.02
                                            ),),
                                        )
                                      ],
                                    ) : GestureDetector(
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
                                                      callAction((superiorMobile).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.phone),
                                                    color: callColor,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      smsAction((superiorMobile).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.message),
                                                    color: smsColor,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((superiorMobile).split(',')[0].trim());
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
                                        (superiorMobile).split(',')[0].trim(),
                                        style: GoogleFonts.secularOne(
                                            color: mobileText,
                                            fontSize: size.height * 0.02
                                        ),),
                                    ),
                                  ) : Container(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Community Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                          SizedBox(width: size.width * 0.02,),
                          street == '' && street2 == '' && place == '' && city == '' && district == '' && state == '' && country == '' && zip == '' ? Text(
                            'NA',
                            style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),
                          ) : Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                street != '' ? Text("$street,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                street2 != '' ? Text("$street2,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                place != '' ? Text("$place,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                city != '' ? Text("$city,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                district != '' ? Text("$district,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                state != '' ? Text("$state,", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                country != '' ? Row(
                                  children: [
                                    country != '' ? Text(country, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                    zip != '' ? Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                    zip != '' ? Text("$zip.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container()
                                  ],
                                ) : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                              provinceEmail != '' && provinceEmail != null ? Flexible(child: GestureDetector(onTap: () {emailAction(provinceEmail);}, child: Text(provinceEmail, style: GoogleFonts.secularOne(color: emailColor, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                              provinceMobile != '' && provinceMobile != null ? IntrinsicHeight(
                                child: (provinceMobile).split(',').length != 1 ? Row(
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
                                                      callAction((provinceMobile).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.phone),
                                                    color: callColor,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      smsAction((provinceMobile).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.message),
                                                    color: smsColor,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((provinceMobile).split(',')[0].trim());
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
                                        (provinceMobile).split(',')[0].trim(),
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
                                                      callAction((provinceMobile).split(',')[1].trim());
                                                    },
                                                    icon: const Icon(Icons.phone),
                                                    color: callColor,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      smsAction((provinceMobile).split(',')[1].trim());
                                                    },
                                                    icon: const Icon(Icons.message),
                                                    color: smsColor,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      whatsappAction((provinceMobile).split(',')[1].trim());
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
                                        (provinceMobile).split(',')[1].trim(),
                                        style: GoogleFonts.secularOne(
                                            color: mobileText,
                                            fontSize: size.height * 0.02
                                        ),
                                      ),
                                    )
                                  ],
                                ) : GestureDetector(
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
                                                  callAction((provinceMobile).split(',')[0].trim());
                                                },
                                                icon: const Icon(Icons.phone),
                                                color: callColor,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  smsAction((provinceMobile).split(',')[0].trim());
                                                },
                                                icon: const Icon(Icons.message),
                                                color: smsColor,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  whatsappAction((provinceMobile).split(',')[0].trim());
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
                                    (provinceMobile).split(',')[0].trim(),
                                    style: GoogleFonts.secularOne(
                                        color: mobileText,
                                        fontSize: size.height * 0.02
                                    ),),
                                ),
                              ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Phone', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                              provincePhone != '' && provincePhone != null ? IntrinsicHeight(
                                child: (provincePhone).split(',').length != 1 ? Row(
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
                                                      telCallAction((provincePhone).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.phone),
                                                    color: callColor,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        (provincePhone).split(',')[0].trim(),
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
                                                      telCallAction((provincePhone).split(',')[1].trim());
                                                    },
                                                    icon: const Icon(Icons.phone),
                                                    color: callColor,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        (provincePhone).split(',')[1].trim(),
                                        style: GoogleFonts.secularOne(
                                            color: mobileText,
                                            fontSize: size.height * 0.02
                                        ),),
                                    )
                                  ],
                                ) : GestureDetector(
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
                                                  telCallAction((provincePhone).split(',')[0].trim());
                                                },
                                                icon: const Icon(Icons.phone),
                                                color: callColor,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    (provincePhone).split(',')[0].trim(),
                                    style: GoogleFonts.secularOne(
                                        color: mobileText,
                                        fontSize: size.height * 0.02
                                    ),),
                                ),
                              ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Website', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                              provinceWebsite != '' && provinceWebsite != null ? Flexible(child: GestureDetector(onTap: () {webAction(provinceWebsite);}, child: Text(provinceWebsite, style: GoogleFonts.secularOne(color: mobileText, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        children: [
                          vision != '' && vision != null ? ListTile(
                            title: Text("Vision", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),),
                            subtitle: Row(
                              children: [
                                Flexible(child: Text(vision, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.018), textAlign: TextAlign.justify,)),
                              ],
                            ),
                          ) : Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Vision', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          mission != '' && mission != null ? ListTile(
                            title: Text("Mission", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),),
                            subtitle: Row(
                              children: [
                                Flexible(child: Text(mission, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.018),textAlign: TextAlign.justify,)),
                              ],
                            ),
                          ) : Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mission', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: provinceHistory.replaceAll(exp, '') != null && provinceHistory.replaceAll(exp, '') != '' ? ListTile(
                      title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Html(
                          data: provinceHistory,
                          style: {
                            'html': Style(
                              textAlign: TextAlign.justify,
                            ),
                          },
                        ),
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('History', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                          Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
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
