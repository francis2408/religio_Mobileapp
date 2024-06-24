import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'other_house_institution_list.dart';
import 'other_house_members_list.dart';

const double expandedHeight = 300;
const double roundedContainerHeight = 50;

class OtherHouseDetailsScreen extends StatefulWidget {
  const OtherHouseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OtherHouseDetailsScreen> createState() => _OtherHouseDetailsScreenState();
}

class _OtherHouseDetailsScreenState extends State<OtherHouseDetailsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final bool _canPop = false;
  bool _isLoading = true;
  List houseData = [];
  int index = 0;

  // Superior Details
  String superiorImage = '';
  String superiorName = '';
  String superiorRole = '';
  String superiorEmail = '';
  String superiorMobile = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getOtherHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?domain=[('id','=',$houseID)]&fields=['image_512','name','ministry_ids','diocese_id','parish_id','establishment_year','superior_id','street','street2','place','city','district_id','state_id','zip','country_id','email','phone','mobile','members_count','institution_count']&limit=40&offset=0"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      houseData = data;
      for(int i = 0; i < houseData.length; i++) {
        if(houseData[i]['superior_id'].isNotEmpty && houseData[i]['superior_id'] != []) {
          superiorId = houseData[i]['superior_id'][0];
          getSuperiorData();
        } else {
          setState(() {
            _isLoading = false;
          });
        }
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

  void changeData() {
    setState(() {
      _isLoading = true;
      houseData.clear();
      getOtherHouseData();
    });
  }

  assignMembersValues(indexValue, indexName) async {
    houseID = indexValue;
    houseName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherHouseMembersListScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  assignInstitutionValues(indexValue, indexName) async {
    houseID = indexValue;
    houseName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherHouseInstitutionListScreen()));

    if(refresh == 'refresh') {
      changeData();
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
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getOtherHouseData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getOtherHouseData();
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
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          Navigator.pop(context, 'refresh');
          return false;
        }
      },
      child: Scaffold(
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
                backgroundColor: appBackgroundColor,
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
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: appBackgroundColor,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white,),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: size.width * 0.1, end: size.width * 0.1, bottom: 5.0),
                  centerTitle: true,
                  title: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: appBackgroundColor,
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
                    child: houseData[index]['image_512'] != null && houseData[index]['image_512'] != '' ? Image.network(
                        houseData[index]['image_512'],
                        fit: BoxFit.fill
                    ) : Image.asset('assets/images/no_image.jpg',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.05,),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                houseData[index]['members_count'] != '' && houseData[index]['members_count'] != null && houseData[index]['members_count'] != 0 ? GestureDetector(
                                  onTap: () {
                                    int indexValue;
                                    String indexName;
                                    indexValue = houseData[index]['id'];
                                    indexName = houseData[index]['name'];
                                    assignMembersValues(indexValue, indexName);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: customBackgroundColor2,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                            text: houseData[index]['members_count'].toString(),
                                            style: TextStyle(
                                                letterSpacing: 1,
                                                fontSize: size.height * 0.014,
                                                fontWeight: FontWeight.bold,
                                                color: customTextColor2,
                                                fontStyle: FontStyle.italic
                                            ),
                                            children: <InlineSpan>[
                                              houseData[index]['members_count'] == 1 ? TextSpan(
                                                text: ' Member',
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.014,
                                                    fontWeight: FontWeight.bold,
                                                    color: customTextColor2,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              ) : TextSpan(
                                                text: ' Members',
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.014,
                                                    fontWeight: FontWeight.bold,
                                                    color: customTextColor2,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              )
                                            ]
                                        ),
                                      ),
                                    ),
                                  ),
                                ) : Container(),
                                houseData[index]['members_count'] != '' && houseData[index]['members_count'] != null && houseData[index]['members_count'] != 0 ? houseData[index]['institution_count'] != '' && houseData[index]['institution_count'] != null && houseData[index]['institution_count'] != 0 ? SizedBox(width: size.width * 0.02,) : Container() : Container(),
                                houseData[index]['institution_count'] != '' && houseData[index]['institution_count'] != null && houseData[index]['institution_count'] != 0 ? GestureDetector(
                                  onTap: () {
                                    int indexValue;
                                    String indexName;
                                    indexValue = houseData[index]['id'];
                                    indexName = houseData[index]['name'];
                                    assignInstitutionValues(indexValue, indexName);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: customBackgroundColor1,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                            text: houseData[index]['institution_count'].toString(),
                                            style: TextStyle(
                                                letterSpacing: 1,
                                                fontSize: size.height * 0.014,
                                                fontWeight: FontWeight.bold,
                                                color: customTextColor1,
                                                fontStyle: FontStyle.italic
                                            ),
                                            children: <InlineSpan>[
                                              houseData[index]['institution_count'] == 1 ? TextSpan(
                                                text: ' Institution',
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.014,
                                                    fontWeight: FontWeight.bold,
                                                    color: customTextColor1,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              ) : TextSpan(
                                                text: ' Institutions',
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: size.height * 0.014,
                                                    fontWeight: FontWeight.bold,
                                                    color: customTextColor1,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              )
                                            ]
                                        ),
                                      ),
                                    ),
                                  ),
                                ) : Container(),
                              ],
                            ),
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
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Diocese', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        houseData[index]['diocese_id'].isNotEmpty && houseData[index]['diocese_id'] != [] ? Flexible(child: Text("${houseData[index]['diocese_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Ministry', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        houseData[index]['ministry_ids_name'].isNotEmpty && houseData[index]['ministry_ids_name'] != [] ? Flexible(child: Text("${houseData[index]['ministry_ids_name']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Est. Year', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        houseData[index]['establishment_year'] != '' && houseData[index]['establishment_year'] != null ? Flexible(child: Text(houseData[index]['establishment_year'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
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
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        houseData[index]['email'] != '' && houseData[index]['email'] != null ? Flexible(child: GestureDetector(onTap: () {emailAction(houseData[index]['email']);}, child: Text("${houseData[index]['email']}", style: GoogleFonts.secularOne(color: emailColor, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        houseData[index]['mobile'] != '' && houseData[index]['mobile'] != null ? IntrinsicHeight(
                                          child: (houseData[index]['mobile'] as String).split(',').length != 1 ? Row(
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
                                                                callAction((houseData[index]['mobile']).split(',')[0].trim());
                                                              },
                                                              icon: const Icon(Icons.phone),
                                                              color: callColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                smsAction((houseData[index]['mobile']).split(',')[0].trim());
                                                              },
                                                              icon: const Icon(Icons.message),
                                                              color: smsColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                whatsappAction((houseData[index]['mobile']).split(',')[0].trim());
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
                                                  (houseData[index]['mobile']).split(',')[0].trim(),
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
                                                                callAction((houseData[index]['mobile']).split(',')[1].trim());
                                                              },
                                                              icon: const Icon(Icons.phone),
                                                              color: callColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                smsAction((houseData[index]['mobile']).split(',')[1].trim());
                                                              },
                                                              icon: const Icon(Icons.message),
                                                              color: smsColor,
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                whatsappAction((houseData[index]['mobile']).split(',')[1].trim());
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
                                                  (houseData[index]['mobile']).split(',')[1].trim(),
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
                                                            callAction((houseData[index]['mobile']).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.phone),
                                                          color: callColor,
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            smsAction((houseData[index]['mobile']).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.message),
                                                          color: smsColor,
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            whatsappAction((houseData[index]['mobile']).split(',')[0].trim());
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
                                              (houseData[index]['mobile']).split(',')[0].trim(),
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
                                        houseData[index]['phone'] != '' && houseData[index]['phone'] != null ? IntrinsicHeight(
                                          child: (houseData[index]['phone'] as String).split(',').length != 1 ? Row(
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
                                                                telCallAction((houseData[index]['phone']).split(',')[0].trim());
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
                                                  (houseData[index]['phone']).split(',')[0].trim(),
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
                                                                telCallAction((houseData[index]['phone']).split(',')[1].trim());
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
                                                  (houseData[index]['phone']).split(',')[1].trim(),
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
                                                            telCallAction((houseData[index]['phone']).split(',')[0].trim());
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
                                              (houseData[index]['phone']).split(',')[0].trim(),
                                              style: GoogleFonts.secularOne(
                                                  color: mobileText,
                                                  fontSize: size.height * 0.02
                                              ),),
                                          ),
                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          ),
                          houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != [] ? Padding(
                            padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                            child: Text('Superior', style: GoogleFonts.portLligatSans(fontSize: size.height * 0.02, color: valueColor, fontWeight: FontWeight.bold),),
                          ) : Container(),
                          houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != [] ? Card(
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
                                                              color: emptyColor,
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
                                                      style: GoogleFonts.secularOne(color: emailColor, fontSize: size.height * 0.02),),
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
                          ) : Container(),
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
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        (houseData[index]['street'].isEmpty && houseData[index]['street2'].isEmpty && houseData[index]['place'].isEmpty && houseData[index]['city'].isEmpty && houseData[index]['district_id'].isEmpty && houseData[index]['state_id'].isEmpty && houseData[index]['country_id'].isEmpty && houseData[index]['zip'].isEmpty) ? Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),) : Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              houseData[index]['street'].isNotEmpty ? Text("${houseData[index]['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              houseData[index]['street2'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                              houseData[index]['street2'].isNotEmpty ? Text("${houseData[index]['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),) : Container(),
                                              const SizedBox(height: 3,),
                                              houseData[index]['place'].isNotEmpty ? Text("${houseData[index]['place']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              houseData[index]['city'].isNotEmpty ? Text("${houseData[index]['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              houseData[index]['district_id'].isNotEmpty ? Text("${houseData[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              houseData[index]['state_id'].isNotEmpty ? Text("${houseData[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              (houseData[index]['country_id'].isNotEmpty && houseData[index]['zip'].isNotEmpty) ? Text("${houseData[index]['country_id'][1]}  -  ${houseData[index]['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}