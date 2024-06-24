import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicInstitutionDetailsScreen extends StatefulWidget {
  const PublicInstitutionDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PublicInstitutionDetailsScreen> createState() => _PublicInstitutionDetailsScreenState();
}

class _PublicInstitutionDetailsScreenState extends State<PublicInstitutionDetailsScreen> {
  int index = 0;
  bool _isLoading = true;
  List institute = [];

  myInstitution() async {
    var request = http.Request(
        'GET', Uri.parse("$baseUrl/institution/$institution_id"));
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

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
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
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Color(0xFFA5FECB), Color(0xFF20BDFF), Color(0xFF5433FF),],
            ),
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
                      textAlign: TextAlign.center,
                      style: GoogleFonts.secularOne(
                          color: Colors.white,
                          fontSize: size.height * 0.02
                      )
                  ),
                ),
                expandedTitleScale: 1,
                // ClipRRect added here for rounded corners
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  child: institute[index]['image_1920'] != '' && institute[index]['image_1920'] != ' ' ? Image.network(
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
                child: SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: ListView.builder(
                    shrinkWrap: true,
                    // scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: institute.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.05,),
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
                                        institute[index]['diocese_id'].isNotEmpty && institute[index]['diocese_id'] != '' && institute[index]['diocese_id'] != ' ' ? Flexible(child: Text("${institute[index]['diocese_id']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Parish', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        institute[index]['parish_id'].isNotEmpty && institute[index]['parish_id'] != '' && institute[index]['parish_id'] != ' ' ? Flexible(child: Text("${institute[index]['parish_id']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Ministry', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        institute[index]['ministry_ids'].isNotEmpty && institute[index]['ministry_ids_name'] != '' && institute[index]['ministry_ids_name'] != ' ' ? Flexible(child: Text("${institute[index]['ministry_ids']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Superior Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        institute[index]['superior_name'].isNotEmpty && institute[index]['superior_name'] != '' && institute[index]['superior_name'] != ' ' ? Flexible(child: Text(institute[index]['superior_name'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Ins. Category', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        institute[index]['institution_category_id'].isNotEmpty && institute[index]['institution_category_id'] != '' && institute[index]['institution_category_id'] != ' ' ? Flexible(child: Text(institute[index]['institution_category_id'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                        institute[index]['email'] != '' && institute[index]['email'] != ' ' ? Flexible(child: GestureDetector(onTap: () {emailAction(institute[index]['email']);}, child: Text("${institute[index]['email']}", style: GoogleFonts.secularOne(color: emailColor, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Mobile', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        institute[index]['mobile'] != '' && institute[index]['mobile'] != ' ' ? IntrinsicHeight(
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
                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Website', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                        institute[index]['website'] != '' && institute[index]['website'] != ' ' ? Flexible(child: GestureDetector(onTap: () {webAction(institute[index]['website']);}, child: Text("${institute[index]['website']}", style: GoogleFonts.secularOne(color: mobileText, fontSize: size.height * 0.02),))) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
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
                                              institute[index]['street'].isNotEmpty && institute[index]['street'] != ' ' ? Text("${institute[index]['street']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              institute[index]['street2'].isNotEmpty && institute[index]['street2'] != ' ' ? const SizedBox(height: 3,) : Container(),
                                              institute[index]['street2'].isNotEmpty && institute[index]['street2'] != ' ' ? Text("${institute[index]['street2']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              institute[index]['place'].isNotEmpty && institute[index]['place'] != ' ' ? Text("${institute[index]['place']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              institute[index]['city'].isNotEmpty && institute[index]['city'] != ' ' ? Text("${institute[index]['city']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              institute[index]['district_id'].isNotEmpty && institute[index]['district_id'] != ' ' ? Text("${institute[index]['district_id']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              institute[index]['state_id'].isNotEmpty && institute[index]['state_id'] != ' ' ? Text("${institute[index]['state_id']},", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
                                              const SizedBox(height: 3,),
                                              (institute[index]['country_id'].isNotEmpty && institute[index]['country_id'] != ' ' && institute[index]['zip'].isNotEmpty) ? Text("${institute[index]['country_id']}  -  ${institute[index]['zip']}.", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Container(),
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
                      );
                    },
                  ),
                ),
                // child:  AnimationLimiter(
                //   child: AnimationConfiguration.staggeredList(
                //     position: index,
                //     duration: const Duration(milliseconds: 375),
                //     child: SlideAnimation(
                //       verticalOffset: 50.0,
                //       child: FadeInAnimation(
                //         child: Column(
                //           children: [
                //             SizedBox(height: size.height * 0.05,),
                //             institute[index]['ministry_ids'] != ' ' && institute[index]['ministry_ids'] != '' ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Flexible(
                //                         child: Text(
                //                           institute[index]['ministry_ids'],
                //                           style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                //                         )
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Ministry", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             institute[index]['diocese_id'].isNotEmpty && institute[index]['diocese_id'] != [] && institute[index]['diocese_id'] != '' && institute[index]['diocese_id'] != ' ' ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Flexible(
                //                         child: Text(
                //                           institute[index]['diocese_id'],
                //                           style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                //                         )
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Diocese", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             institute[index]['parish_id'].isNotEmpty && institute[index]['parish_id'] != [] && institute[index]['parish_id'] != '' && institute[index]['parish_id'] != ' ' ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Parish", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Flexible(
                //                         child: Text(
                //                           institute[index]['parish_id'],
                //                           style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                //                         )
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Parish", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             institute[index]['superior_name'] != '' && institute[index]['superior_name'] != ' ' && institute[index]['superior_name'] != null ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Flexible(
                //                         child: Text(
                //                           institute[index]['superior_name'],
                //                           style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                //                         )
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Superior", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             institute[index]['email'] != null && institute[index]['email'] != '' && institute[index]['email'] != ' ' ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Flexible(
                //                         child: Text(
                //                           institute[index]['email'],
                //                           style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                //                         )
                //                     ),
                //                   ],
                //                 ),
                //                 trailing: IconButton(
                //                   icon: const Icon(Icons.email_outlined),
                //                   color: Colors.red,
                //                   onPressed: () {
                //                     emailAction(institute[index]['email']);
                //                   },
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             institute[index]['mobile'] != null && institute[index]['mobile'] != '' && institute[index]['mobile'] != ' ' ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text(
                //                       institute[index]['mobile'],
                //                       style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                //                     ),
                //                   ],
                //                 ),
                //                 trailing: Row(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     IconButton(
                //                       icon: const Icon(Icons.phone),
                //                       color: Colors.blue,
                //                       onPressed: () {
                //                         callAction(institute[index]['mobile']);
                //                       },
                //                     ),
                //                     IconButton(
                //                       icon: const Icon(Icons.message),
                //                       color: Colors.orangeAccent,
                //                       onPressed: () {
                //                         smsAction(institute[index]['mobile']);
                //                       },
                //                     ),
                //                     IconButton(
                //                       icon: const Icon(LineAwesomeIcons.what_s_app),
                //                       color: Colors.green,
                //                       onPressed: () {
                //                         whatsappAction(institute[index]['mobile']);
                //                       },
                //                     )
                //                   ],
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             institute[index]['phone'] != null && institute[index]['phone'] != '' ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: (institute[index]['phone'] as String)
                //                       .split(',')
                //                       .map<Widget>((phone) {
                //                     // Trim leading and trailing spaces from the mobile number
                //                     phone = phone.trim();
                //                     return Row(
                //                       children: [
                //                         TextButton(
                //                           onPressed: () {
                //                             // Show alert dialog with icon buttons
                //                             showDialog(
                //                               context: context,
                //                               builder: (BuildContext context) {
                //                                 return AlertDialog(
                //                                   content: Column(
                //                                     mainAxisSize: MainAxisSize.min,
                //                                     children: [
                //                                       Row(
                //                                         mainAxisAlignment:
                //                                         MainAxisAlignment.spaceEvenly,
                //                                         children: [
                //                                           IconButton(
                //                                             onPressed: () {
                //                                               callAction(phone);
                //                                             },
                //                                             icon: const Icon(Icons.phone),
                //                                             color: Colors.blueAccent,
                //                                           ),
                //                                         ],
                //                                       ),
                //                                     ],
                //                                   ),
                //                                 );
                //                               },
                //                             );
                //                           },
                //                           child: Text(
                //                             phone,
                //                             style: GoogleFonts.secularOne(
                //                               color: Colors.blueAccent,
                //                               fontSize: size.height * 0.02,
                //                             ),
                //                           ),
                //                         ),
                //                         if (phone != (institute[index]['phone'] as String).split(',').last.trim()) Text('|',
                //                           style: GoogleFonts.secularOne(
                //                             color: Colors.grey,
                //                             fontSize: size.height * 0.02,
                //                           ),
                //                         ),
                //                       ],
                //                     );
                //                   }).toList(),
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             (institute[index]['street'].isEmpty && institute[index]['street2'].isEmpty && institute[index]['place'].isEmpty && institute[index]['city'].isEmpty && institute[index]['district_id'].isEmpty && institute[index]['district_id'] != null && institute[index]['state_id'].isEmpty && institute[index]['state_id'] != null && institute[index]['country_id'].isEmpty && institute[index]['country_id'] != null && institute[index]['zip'].isEmpty) ? Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Address", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Row(
                //                   children: [
                //                     Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                //                   ],
                //                 ),
                //               ),
                //             ) : Card(
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: ListTile(
                //                 title: Text("Address", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                //                 subtitle: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                     const SizedBox(height: 5,),
                //                     institute[index]['street'] != null && institute[index]['street'] != '' && institute[index]['street'] != ' ' ? Text(institute[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                     institute[index]['street2'] != null && institute[index]['street2'] != '' && institute[index]['street2'] != ' ' ? const SizedBox(height: 3,) : Container(),
                //                     institute[index]['street2'] != null && institute[index]['street2'] != '' && institute[index]['street2'] != ' ' ? Text(institute[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                     institute[index]['place'] != null && institute[index]['place'] != '' && institute[index]['place'] != ' ' ? const SizedBox(height: 3,) : Container(),
                //                     institute[index]['place'] != null && institute[index]['place'] != '' && institute[index]['place'] != ' ' ? Text(institute[index]['place'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                     const SizedBox(height: 3,),
                //                     institute[index]['city'] != null && institute[index]['city'] != '' && institute[index]['city'] != ' ' ? Text(institute[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                     const SizedBox(height: 3,),
                //                     institute[index]['district_id'] != null && institute[index]['district_id'].isNotEmpty && institute[index]['district_id'] != '' && institute[index]['district_id'] != ' ' ? Text(institute[index]['district_id'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                     const SizedBox(height: 3,),
                //                     institute[index]['state_id'] != null && institute[index]['state_id'].isNotEmpty && institute[index]['state_id'] != '' && institute[index]['state_id'] != ' ' ? Text(institute[index]['state_id'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                     const SizedBox(height: 3,),
                //                     (institute[index]['country_id'] != null && institute[index]['country_id'].isNotEmpty && institute[index]['country_id'] != '' && institute[index]['country_id'] != ' ' && institute[index]['zip'] != null && institute[index]['zip'] != '') ? Text("${institute[index]['country_id']}  -  ${institute[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             SizedBox(
                //               height: size.height * 0.01,
                //             )
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
