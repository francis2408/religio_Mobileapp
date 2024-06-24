import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'other_institution_members_list.dart';

class OtherInstitutionDetailsScreen extends StatefulWidget {
  const OtherInstitutionDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OtherInstitutionDetailsScreen> createState() => _OtherInstitutionDetailsScreenState();
}

class _OtherInstitutionDetailsScreenState extends State<OtherInstitutionDetailsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final bool _canPop = false;
  int index = 0;
  bool _isLoading = true;
  List institute = [];

  // Superior Details
  String superiorImage = '';
  String superiorName = '';
  String superiorRole = '';
  String superiorEmail = '';
  String superiorMobile = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  otherInstitution() async {
    var request = http.Request(
        'GET', Uri.parse("""$baseUrl/search_read/res.institution?fields=['name','image_512','community_id','superior_id','diocese_id','parish_id','ministry_ids','institution_category_id','ministry_category_id','phone','mobile','email','street','street2','place','city','district_id','state_id','zip','country_id','establishment_date','members_count']&domain=[('id','=',$instituteID)]&context={"bypass":1}&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      institute = data;
      for(int i = 0; i < institute.length; i++) {
        if(institute[i]['superior_id'].isNotEmpty && institute[i]['superior_id'] != []) {
          superiorId = institute[i]['superior_id'][0];
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
      institute.clear();
      otherInstitution();
    });
  }

  institutionMembers(indexValue, indexName) async {
    instituteID = indexValue;
    instituteName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherInstitutionMembersListScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  String formatDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate); // Convert the string to a DateTime object
    String formattedDate = DateFormat('d MMMM y').format(date); // Format the DateTime object
    return formattedDate;
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

  Future<void> smsAction(String number) async {
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
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
      otherInstitution();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            otherInstitution();
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
                    child: institute[index]['image_512'] != null && institute[index]['image_512'] != '' ? Image.network(
                        institute[index]['image_512'],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.05,),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              institute[index]['members_count'] != '' && institute[index]['members_count'] != null && institute[index]['members_count'] != 0 ? GestureDetector(
                                onTap: () {
                                  int indexValue;
                                  String indexName;
                                  indexValue = institute[index]['id'];
                                  indexName = institute[index]['name'];
                                  institutionMembers(indexValue, indexName);
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
                                          text: institute[index]['members_count'].toString(),
                                          style: TextStyle(
                                              letterSpacing: 1,
                                              fontSize: size.height * 0.014,
                                              fontWeight: FontWeight.bold,
                                              color: customTextColor2,
                                              fontStyle: FontStyle.italic
                                          ),
                                          children: <InlineSpan>[
                                            institute[index]['members_count'] == 1 ? TextSpan(
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
                                      Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Diocese', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['diocese_id'].isNotEmpty && institute[index]['diocese_id'] != [] ? Flexible(child: Text("${institute[index]['diocese_id'][1]}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Ministry', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['ministry_ids_name'].isNotEmpty && institute[index]['ministry_ids_name'] != [] ? Flexible(child: Text("${institute[index]['ministry_ids_name']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Est. Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['establishment_date'] != '' && institute[index]['ministry_ids_name'] != null ? Flexible(child: Text(formatDate(institute[index]['establishment_date']), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                      Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Ins. Category', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['institution_category_id'].isNotEmpty && institute[index]['institution_category_id'] != [] ? Flexible(child: Text(institute[index]['institution_category_id'][1], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Min. Category', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['ministry_category_id'].isNotEmpty && institute[index]['ministry_category_id'] != [] ? Flexible(child: Text(institute[index]['ministry_category_id'][1], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                        institute[index]['superior_id'].isNotEmpty && institute[index]['superior_id'] != [] ? Padding(
                          padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                          child: Text('Superior', style: GoogleFonts.portLligatSans(fontSize: size.height * 0.02, color: valueColor, fontWeight: FontWeight.bold),),
                        ) : Container(),
                        institute[index]['superior_id'].isNotEmpty && institute[index]['superior_id'] != [] ? Card(
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
                                      Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['email'] != '' && institute[index]['email'] != null ? Flexible(child: GestureDetector(onTap: () {emailAction(institute[index]['email']);}, child: Text("${institute[index]['email']}", style: GoogleFonts.secularOne(color: emailColor, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                      institute[index]['mobile'] != '' && institute[index]['mobile'] != null ? IntrinsicHeight(
                                        child: (institute[index]['mobile'] as String).split(',').length != 1 ? Row(
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
                                                              callAction((institute[index]['mobile']).split(',')[0].trim());
                                                            },
                                                            icon: const Icon(Icons.phone),
                                                            color: callColor,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              smsAction((institute[index]['mobile']).split(',')[0].trim());
                                                            },
                                                            icon: const Icon(Icons.message),
                                                            color: smsColor,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              whatsappAction((institute[index]['mobile']).split(',')[0].trim());
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
                                                (institute[index]['mobile']).split(',')[0].trim(),
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
                                                              callAction((institute[index]['mobile']).split(',')[1].trim());
                                                            },
                                                            icon: const Icon(Icons.phone),
                                                            color: callColor,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              smsAction((institute[index]['mobile']).split(',')[1].trim());
                                                            },
                                                            icon: const Icon(Icons.message),
                                                            color: smsColor,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              whatsappAction((institute[index]['mobile']).split(',')[1].trim());
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
                                                (institute[index]['mobile']).split(',')[1].trim(),
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
                                                          callAction((institute[index]['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.phone),
                                                        color: callColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          smsAction((institute[index]['mobile']).split(',')[0].trim());
                                                        },
                                                        icon: const Icon(Icons.message),
                                                        color: smsColor,
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          whatsappAction((institute[index]['mobile']).split(',')[0].trim());
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
                                            (institute[index]['mobile']).split(',')[0].trim(),
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
                                      institute[index]['phone'] != '' && institute[index]['phone'] != null ? IntrinsicHeight(
                                        child: (institute[index]['phone'] as String).split(',').length != 1 ? Row(
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
                                                              telCallAction((institute[index]['phone']).split(',')[0].trim());
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
                                                (institute[index]['phone']).split(',')[0].trim(),
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
                                                              telCallAction((institute[index]['phone']).split(',')[1].trim());
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
                                                (institute[index]['phone']).split(',')[1].trim(),
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
                                                          telCallAction((institute[index]['phone']).split(',')[0].trim());
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
                                            (institute[index]['phone']).split(',')[0].trim(),
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
                                      (institute[index]['street'].isEmpty && institute[index]['street2'].isEmpty && institute[index]['place'].isEmpty && institute[index]['city'].isEmpty && institute[index]['district_id'].isEmpty && institute[index]['state_id'].isEmpty && institute[index]['country_id'].isEmpty && institute[index]['zip'].isEmpty) ? Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),) : Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            institute[index]['street'].isNotEmpty ? Text("${institute[index]['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            institute[index]['street2'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                            institute[index]['street2'].isNotEmpty ? Text("${institute[index]['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            institute[index]['place'].isNotEmpty ? Text("${institute[index]['place']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            institute[index]['city'].isNotEmpty ? Text("${institute[index]['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            institute[index]['district_id'].isNotEmpty ? Text("${institute[index]['district_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            institute[index]['state_id'].isNotEmpty ? Text("${institute[index]['state_id'][1]},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                            const SizedBox(height: 3,),
                                            (institute[index]['country_id'].isNotEmpty && institute[index]['zip'].isNotEmpty) ? Text("${institute[index]['country_id'][1]}  -  ${institute[index]['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
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
      ),
    );
  }
}
