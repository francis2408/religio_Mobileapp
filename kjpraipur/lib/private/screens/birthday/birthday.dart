import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  List birthday = [];
  String today = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getBirthdayData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_birthday_details?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      birthday = data;
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
    getBirthdayData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Birthday Wishes'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A3F85),
                    Color(0xFFFA761E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 5),
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
                  )),
            ) : Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                birthday.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: birthday.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            today = DateFormat('dd - MMMM').format(now);
                            if(today == birthday[index]['birthday']) {
                              return Column(
                                children: [
                                  Container(
                                    height: size.height * 0.15,
                                    padding: const EdgeInsets.symmetric(horizontal: 10,),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: size.height * 0.13,
                                            width: size.width,
                                            padding: EdgeInsets.only(left: size.width * 0.25),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: const <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: -1,
                                                  blurRadius: 5 ,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    birthday[index]['name'].toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: size.height * 0.02,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.indigo
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    birthday[index]['birthday'],
                                                    style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.grey),
                                                  ),
                                                ),
                                                birthday[index]['mobile'] != '' && birthday[index]['mobile'] != null ? Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          (birthday[index]['mobile'] as String)
                                                              .split(',')[0]
                                                              .trim(),
                                                          style: TextStyle(
                                                            color: Colors.blueAccent,
                                                            fontSize: size.height * 0.02,
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            if (birthday[index]['mobile'] != null && birthday[index]['mobile'] != '') IconButton(
                                                              onPressed: () {
                                                                (birthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (birthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  callAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                                },
                                                                              ),
                                                                              const Divider(),
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (birthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  callAction((birthday[index]['mobile'] as String).split(',')[1].trim());
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ) : callAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                              },
                                                              icon: const Icon(Icons.phone),
                                                              color: Colors.blueAccent,
                                                            ),
                                                            if (birthday[index]['mobile'] != null && birthday[index]['mobile'] != '') IconButton(
                                                              onPressed: () {
                                                                (birthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (birthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  smsAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                                },
                                                                              ),
                                                                              const Divider(),
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (birthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  smsAction((birthday[index]['mobile'] as String).split(',')[1].trim());
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ) : smsAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                              },
                                                              icon: const Icon(Icons.message),
                                                              color: Colors.orange,
                                                            ),
                                                            if (birthday[index]['mobile'] != null && birthday[index]['mobile'] != '') IconButton(
                                                              onPressed: () {
                                                                (birthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (birthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  whatsappAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                                                },
                                                                              ),
                                                                              const Divider(),
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (birthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  whatsappAction((birthday[index]['mobile'] as String).split(',')[1].trim());
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ) : whatsappAction((birthday[index]['mobile'] as String).split(',')[0].trim());
                                                              },
                                                              icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                                              color: Colors.green,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ) : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: size.height * 0.045,
                                          right: size.width * 0.01,
                                          child: Center(
                                            child: Container(
                                              height: size.height * 0.06,
                                              width: size.width * 0.2,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage( "assets/images/happy-birthday.gif"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: size.height * 0.03,
                                          left: 0,
                                          right: size.width * 0.7,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                birthday[index]['birth_image'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(birthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                                width: size.width * 0.20,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != ''
                                                        ? NetworkImage(birthday[index]['birth_image'])
                                                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                ],
                              );
                            } else {
                              return Container(
                                padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                                child: SizedBox(
                                  height: 80,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.03,
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: CircleAvatar(
                                            child: ClipOval(
                                              child: birthday[index]['birth_image'] != null && birthday[index]['birth_image'] != '' ? Image.network(
                                                  birthday[index]['birth_image'],
                                                  height: size.height * 0.15,
                                                  width: size.width * 0.2,
                                                  fit: BoxFit.cover
                                              ) : Image.asset(
                                                'assets/images/profile.png',
                                                height: size.height * 0.15,
                                                width: size.width * 0.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        birthday[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // const SizedBox(
                                                //   height: 5,
                                                // ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${birthday[index]['birthday']}",
                                                      style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.018, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                // const SizedBox(
                                                //   height: 5,
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ) : Center(
                  child: Container(
                    alignment: Alignment.center,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}