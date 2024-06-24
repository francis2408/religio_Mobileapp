import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProvinceCommissionScreen extends StatefulWidget {
  const ProvinceCommissionScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceCommissionScreen> createState() => _ProvinceCommissionScreenState();
}

class _ProvinceCommissionScreenState extends State<ProvinceCommissionScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool _isCommission = true;
  List commission = [];
  List members = [];
  int selected = -1;
  int selected2 = -1;
  bool isCategoryExpanded = false;
  bool isSubCategoryExpanded = false;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getCommissionData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/call/res.member/get_commission_details"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      setState(() {
        _isLoading = false;
      });
      commission = data;
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

  getCommissionMembersData() async {
    setState(() {
      _isCommission = true;
    });
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.commission.member?&domain=[('commission_id','=',$commissionID),('status','=','active')]&fields=['role_id','partner_id','date_from','date_to','status']"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      members = data;
      for(int i = 0; i < members.length; i++) {

      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isCommission = false;
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
    setState(() {
      _isCommission = false;
    });
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
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Can not launch url";
    }
  }

  Future<void> webAction(String web) async {
    if (await canLaunch(web)) {
      await launch(web,forceWebView: true,forceSafariVC: false);
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
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getCommissionData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getCommissionData();
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
        child: Center(
          child: _isLoading
              ? Container(
              height: size.height * 0.1,
              width: size.width * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage( "assets/alert/spinner_1.gif"),
                ),
              )
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: commission.isNotEmpty ? ListView.builder(
                        key: Key('builder ${selected.toString()}'),
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        itemCount: commission.length,
                        itemBuilder: (BuildContext context, int index) {
                          final isTileExpanded = index == selected;
                          final textExpandColor = isTileExpanded ? textColor : enableColor;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                // gradient: const LinearGradient(
                                //   colors: [Colors.white],
                                //   begin: Alignment.topLeft,
                                //   end: Alignment.bottomRight,
                                // ),
                                  borderRadius: BorderRadius.circular(15.0)
                              ),
                              child: ExpansionTile(
                                key: Key(index.toString()),// Use the generated GlobalKey for each expansion tile
                                initiallyExpanded: index == selected,
                                backgroundColor: Colors.white,
                                iconColor: iconColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                onExpansionChanged: (newState) {
                                  if (newState) {
                                    setState(() {
                                      selected = index;
                                      selected2 = -1;
                                      _isCommission = false;
                                      isCategoryExpanded = true;
                                    });
                                  } else {
                                    setState(() {
                                      selected = -1;
                                      _isCommission = true;
                                      isCategoryExpanded = false;
                                    });
                                  }
                                },
                                title: Container(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${commission[index]['name']}',
                                        style: GoogleFonts.signika(
                                          fontSize: size.height * 0.022,
                                          color: textExpandColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.01,),
                                      commission[index]['description'].replaceAll(exp, '') != null && commission[index]['description'].replaceAll(exp, '') != '' ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              commission[index]['description'].replaceAll(exp, ''),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.01,),
                                          GestureDetector(
                                            onTap: () {
                                              // Bottom sheet
                                              showModalBottomSheet<void>(
                                                context: context,
                                                backgroundColor: screenBackgroundColor,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                ),
                                                builder: (BuildContext context) {
                                                  return CustomContentBottomSheet(
                                                      size: size,
                                                      title: "Description",
                                                      content: commission[index]['description']
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                                alignment: Alignment.topRight,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    const Text('More', style: TextStyle(
                                                        color: mobileText
                                                    ),),
                                                    SizedBox(width: size.width * 0.018,),
                                                    const Icon(Icons.arrow_forward_ios, color: mobileText, size: 11,)
                                                  ],
                                                )
                                            ),
                                          )
                                        ],
                                      ) :  Text(
                                        'No description',
                                        style: GoogleFonts.secularOne(
                                          letterSpacing: 0.5,
                                          fontSize: size.height * 0.017,
                                          color: emptyColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                children: [
                                  _isCommission ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child:Container(
                                            height: size.height * 0.1,
                                            width: size.width * 0.2,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage( "assets/alert/spinner_1.gif"),
                                              ),
                                            )
                                        ),
                                      )
                                    ],
                                  ) : commission[index]['members'].isNotEmpty && commission[index]['members'] != [] ? ListView.builder(
                                    key: Key('builder ${selected2.toString()}'),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: isCategoryExpanded ? commission[index]['members'].length : 0, // Update the itemCount to 2 for two expansion tiles
                                    itemBuilder: (BuildContext context, int indexs) {
                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    commission[index]['members'][indexs]['image'] != '' ? showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return Dialog(
                                                          child: Image.network(commission[index]['members'][indexs]['image'], fit: BoxFit.cover,),
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
                                                      boxShadow: <BoxShadow>[
                                                        if(commission[index]['members'][indexs]['image'] != null && commission[index]['members'][indexs]['image'] != '') const BoxShadow(
                                                          color: Colors.grey,
                                                          spreadRadius: -1,
                                                          blurRadius: 5 ,
                                                          offset: Offset(0, 1),
                                                        ),
                                                      ],
                                                      shape: BoxShape.rectangle,
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: commission[index]['members'][indexs]['image'] != null && commission[index]['members'][indexs]['image'] != ''
                                                            ? NetworkImage(commission[index]['members'][indexs]['image'])
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
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                commission[index]['members'][indexs]['name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.018,
                                                                  color: orangeColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: size.height * 0.01,),
                                                        Row(
                                                          children: [
                                                            commission[index]['members'][indexs]['role'] != null && commission[index]['members'][indexs]['role'] != '' ? Text(
                                                              commission[index]['members'][indexs]['role'],
                                                              style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.017,
                                                                color: emptyColor,
                                                              ),
                                                            ) : Text(
                                                              'No role assigned',
                                                              style: TextStyle(
                                                                letterSpacing: 0.5,
                                                                fontSize: size.height * 0.017,
                                                                color: emptyColor,
                                                                fontStyle: FontStyle.italic,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        commission[index]['members'][indexs]['email'] != null && commission[index]['members'][indexs]['email'] != '' ? SizedBox(
                                                          height: size.height * 0.005,
                                                        ) : Container(),
                                                        Row(
                                                          children: [
                                                            commission[index]['members'][indexs]['email'] != null && commission[index]['members'][indexs]['email'] != '' ? Flexible(
                                                                child: GestureDetector(
                                                                    onTap: () {
                                                                      emailAction(commission[index]['members'][indexs]['email']);
                                                                    },
                                                                    child: Text(
                                                                      '${commission[index]['members'][indexs]['email']}',
                                                                      style: GoogleFonts.secularOne(
                                                                          color: emailColor,
                                                                          fontSize: size.height * 0.017
                                                                      ),
                                                                    )
                                                                )
                                                            ) : Container(),
                                                          ],
                                                        ),
                                                        commission[index]['members'][indexs]['mobile'] != '' && commission[index]['members'][indexs]['mobile'] != null && (commission[index]['members'][indexs]['mobile']).split(',').length != 1 ? SizedBox(
                                                          height: size.height * 0.005,
                                                        ) : Container(),
                                                        Row(
                                                          children: [
                                                            commission[index]['members'][indexs]['mobile'] != '' && commission[index]['members'][indexs]['mobile'] != null ? IntrinsicHeight(
                                                              child: (commission[index]['members'][indexs]['mobile']).split(',').length != 1 ? Row(
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
                                                                                    callAction((commission[index]['members'][indexs]['mobile']).split(',')[0].trim());
                                                                                  },
                                                                                  icon: const Icon(Icons.phone),
                                                                                  color: callColor,
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                    smsAction((commission[index]['members'][indexs]['mobile']).split(',')[0].trim());
                                                                                  },
                                                                                  icon: const Icon(Icons.message),
                                                                                  color: smsColor,
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                    whatsappAction((commission[index]['members'][indexs]['mobile']).split(',')[0].trim());
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
                                                                      (commission[index]['members'][indexs]['mobile']).split(',')[0].trim(),
                                                                      style: GoogleFonts.secularOne(
                                                                          color: mobileText,
                                                                          fontSize: size.height * 0.017
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
                                                                                    callAction((commission[index]['members'][indexs]['mobile']).split(',')[1].trim());
                                                                                  },
                                                                                  icon: const Icon(Icons.phone),
                                                                                  color: callColor,
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                    smsAction((commission[index]['members'][indexs]['mobile']).split(',')[1].trim());
                                                                                  },
                                                                                  icon: const Icon(Icons.message),
                                                                                  color: smsColor,
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                    whatsappAction((commission[index]['members'][indexs]['mobile']).split(',')[1].trim());
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
                                                                      (commission[index]['members'][indexs]['mobile']).split(',')[1].trim(),
                                                                      style: GoogleFonts.secularOne(
                                                                          color: mobileText,
                                                                          fontSize: size.height * 0.017
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ) : Row(
                                                                children: [
                                                                  Text(
                                                                    (commission[index]['members'][indexs]['mobile']).split(',')[0].trim(),
                                                                    style: GoogleFonts.secularOne(
                                                                      color: mobileText,
                                                                      fontSize: size.height * 0.017,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed: () {
                                                                          callAction((commission[index]['members'][indexs]['mobile']).split(',')[0].trim());
                                                                        },
                                                                        icon: const Icon(Icons.phone),
                                                                        color: callColor,
                                                                      ),
                                                                      IconButton(
                                                                        onPressed: () {
                                                                          smsAction((commission[index]['members'][indexs]['mobile']).split(',')[0].trim());
                                                                        },
                                                                        icon: const Icon(Icons.message),
                                                                        color: smsColor,
                                                                      ),
                                                                      IconButton(
                                                                        onPressed: () {
                                                                          whatsappAction((commission[index]['members'][indexs]['mobile']).split(',')[0].trim());
                                                                        },
                                                                        icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                        color: whatsAppColor,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ) : Container(),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if(indexs < commission[index]['members'].length - 1) const Divider(
                                            thickness: 2,
                                          ),
                                        ],
                                      );
                                    },
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
                                  )
                                ],
                              ),
                            ),
                          );
                        },
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
