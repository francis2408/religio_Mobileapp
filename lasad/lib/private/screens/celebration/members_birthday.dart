import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivateMembersBirthdayScreen extends StatefulWidget {
  const PrivateMembersBirthdayScreen({Key? key}) : super(key: key);

  @override
  State<PrivateMembersBirthdayScreen> createState() => _PrivateMembersBirthdayScreenState();
}

class _PrivateMembersBirthdayScreenState extends State<PrivateMembersBirthdayScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool _thisMonth = true;
  bool _thisBirth = false;
  List celebration = [{'id': '1', 'name': 'Birthday'},{'id': '2', 'name': 'Feast'}];
  String celebrationName = 'Birthday';
  List category = [{'id': '1', 'name': 'Upcoming'},{'id': '2', 'name': 'All'}];
  String categoryName = 'Upcoming';
  List<DropDownValueModel> celebrationDropDown = [];
  List<DropDownValueModel> categoryDropDown = [];

  List thisMonthBirthday = [];
  List upcomingBirthday = [];
  List thisMonthFeast = [];
  List upcomingFeast = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getDropdownValue() {
    setState(() {
      _isLoading = true;
      getCelebrationValue();
      getCategoryValue();
      Future.delayed(const Duration(seconds: 1), () {
        _isLoading = false;
      });
    });
  }

  getCelebrationValue() {
    for(int i = 0; i < celebration.length; i++) {
      celebrationDropDown.add(DropDownValueModel(name: celebration[i]['name'], value: celebration[i]['id']));
    }
    return celebrationDropDown;
  }

  getCategoryValue() {
    for(int i = 0; i < category.length; i++) {
      categoryDropDown.add(DropDownValueModel(name: category[i]['name'], value: category[i]['id']));
    }
    return categoryDropDown;
  }

  getBirthdayData() async {
    var request;
    if(sectorTab == 'Indian Sector' && celebrationName == 'Birthday') {
      request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_birthday_details_v1?args=[$userProvinceId]"));
    } else {
      request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_birthday_details_v1?args=[$sri_sector_id]"));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      setState(() {
        _thisMonth = false;
        _thisBirth = true;
      });
      thisMonthBirthday = result['data']['results'];
      upcomingBirthday = result['data']['next_30days'];
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _thisMonth = false;
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

  getFeastData() async {
    var request;
    if(sectorTab == 'Indian Sector' && celebrationName == 'Feast') {
      request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_feast_list_v1?args=[$userProvinceId]"));
    } else {
      request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_feast_list_v1?args=[$sri_sector_id]"));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      print('data $data');
      setState(() {
        _thisMonth = false;
        _thisBirth = false;
      });
      for (int i = 0; i < data.length; i++) {
        if(i == 0) {
          upcomingFeast = data[0]['upcoming_feast_list'].isNotEmpty && data[0]['upcoming_feast_list'] != [] ? data[0]['upcoming_feast_list'] : [];
        }
        if(i == 1) {
          thisMonthFeast = data[1]['all_feast_list'].isNotEmpty && data[1]['all_feast_list'] != [] ? data[1]['all_feast_list'] : [];
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _thisMonth = false;
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
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getBirthdayData();
    });
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
    celebrationName = 'Birthday';
    categoryName = 'Upcoming';
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getDropdownValue();
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDropdownValue();
            loadDataWithDelay();
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
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
            ),
          ),
        ) : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: size.height * 0.055,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: DropDownTextField(
                        initialValue: celebrationName,
                        listSpace: 2,
                        listPadding: ListPadding(top: 5),
                        listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.018),
                        textStyle: GoogleFonts.breeSerif(color: Colors.black,  fontSize: size.height * 0.018),
                        dropDownItemCount: 6,
                        dropDownList: celebrationDropDown,
                        clearOption: false,
                        textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: celebrationName != '' && celebrationName != null ? celebrationName : "Select the Celebration",
                          hintStyle: GoogleFonts.breeSerif(
                            color: Colors.black87,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: disableColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: enableColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null && val != "") {
                            setState(() {
                              setState(() {
                                celebrationName = val.name;
                                if (sectorTab == 'Indian Sector' && celebrationName == 'Birthday' && categoryName == 'All') {
                                  _thisMonth = true;
                                  getBirthdayData();
                                } else if (sectorTab == 'Indian Sector' && celebrationName == 'Birthday' && categoryName == 'Upcoming') {
                                  _thisMonth = true;
                                  getBirthdayData();
                                } else if (sectorTab == 'Indian Sector' && celebrationName == 'Feast' && categoryName == 'All') {
                                  _thisMonth = true;
                                  getFeastData();
                                } else if (sectorTab == 'Indian Sector' && celebrationName == 'Feast' && categoryName == 'Upcoming') {
                                  _thisMonth = true;
                                  getFeastData();
                                } else if (sectorTab == 'Sri Lankan Sector' && celebrationName == 'Birthday' && categoryName == 'Upcoming') {
                                  _thisMonth = true;
                                  getBirthdayData();
                                } else if (sectorTab == 'Sri Lankan Sector' && celebrationName == 'Birthday' && categoryName == 'All') {
                                  _thisMonth = true;
                                  getBirthdayData();
                                } else if (sectorTab == 'Sri Lankan Sector' && celebrationName == 'Feast' && categoryName == 'All') {
                                  _thisMonth = true;
                                  getFeastData();
                                } else {
                                  _thisMonth = true;
                                  getFeastData();
                                }
                              });
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.02,),
                  Expanded(
                    child: Container(
                      height: size.height * 0.055,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: DropDownTextField(
                        initialValue: categoryName,
                        listSpace: 2,
                        listPadding: ListPadding(top: 5),
                        listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.018),
                        textStyle: GoogleFonts.breeSerif(color: Colors.black,  fontSize: size.height * 0.018),
                        dropDownItemCount: 6,
                        dropDownList: categoryDropDown,
                        clearOption: false,
                        textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: categoryName != '' && categoryName != null ? categoryName : "Select the Category",
                          hintStyle: GoogleFonts.breeSerif(
                            color: Colors.black87,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: disableColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: enableColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null && val != "") {
                            setState(() {
                              categoryName = val.name;
                              if (sectorTab == 'Indian Sector' && celebrationName == 'Birthday' && categoryName == 'All') {
                                _thisMonth = true;
                                getBirthdayData();
                              } else if (sectorTab == 'Indian Sector' && celebrationName == 'Birthday' && categoryName == 'Upcoming') {
                                _thisMonth = true;
                                getBirthdayData();
                              } else if (sectorTab == 'Indian Sector' && celebrationName == 'Feast' && categoryName == 'All') {
                                _thisMonth = true;
                                getFeastData();
                              } else if (sectorTab == 'Indian Sector' && celebrationName == 'Feast' && categoryName == 'Upcoming') {
                                _thisMonth = true;
                                getFeastData();
                              } else if (sectorTab == 'Sri Lankan Sector' && celebrationName == 'Birthday' && categoryName == 'All') {
                                _thisMonth = true;
                                getBirthdayData();
                              } else if (sectorTab == 'Sri Lankan Sector' && celebrationName == 'Birthday' && categoryName == 'Upcoming') {
                                _thisMonth = true;
                                getBirthdayData();
                              } else if (sectorTab == 'Sri Lankan Sector' && celebrationName == 'Feast' && categoryName == 'All') {
                                _thisMonth = true;
                                getFeastData();
                              } else {
                                _thisMonth = true;
                                getFeastData();
                              }
                            });
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            _thisBirth ? Expanded(
              child: _thisMonth ? Center(
                child: SizedBox(
                  height: size.height * 0.06,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.lineScalePulseOutRapid,
                    colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                  ),
                ),
              ) : upcomingBirthday.isNotEmpty && categoryName == 'Upcoming' ? sectorTab == 'Indian Sector' && celebrationName == 'Birthday' && categoryName == 'Upcoming' ? ListView.builder(
                itemCount: upcomingBirthday.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return todays == upcomingBirthday[index]['birthday'].trim() ? Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  upcomingBirthday[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(upcomingBirthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.1,
                                  width: size.width * 0.16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != ''
                                          ? NetworkImage(upcomingBirthday[index]['birth_image'])
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
                                      Text(
                                        upcomingBirthday[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        upcomingBirthday[index]['birthday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                      upcomingBirthday[index]['mobile'] != '' && upcomingBirthday[index]['mobile'] != null ? Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                style: TextStyle(
                                                  color: mobileText,
                                                  fontSize: size.height * 0.02,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (upcomingBirthday[index]['mobile'] != null && upcomingBirthday[index]['mobile'] != '') IconButton(
                                                    onPressed: () {
                                                      (upcomingBirthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                        (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                        style: const TextStyle(color: mobileText),
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                        callAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                                      },
                                                                    ),
                                                                    const Divider(),
                                                                    ListTile(
                                                                      title: Text(
                                                                        (upcomingBirthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                        style: const TextStyle(color: mobileText),
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                        callAction((upcomingBirthday[index]['mobile'] as String).split(',')[1].trim());
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ) : callAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.phone),
                                                    color: callColor,
                                                  ),
                                                  if (upcomingBirthday[index]['mobile'] != null && upcomingBirthday[index]['mobile'] != '') IconButton(
                                                    onPressed: () {
                                                      (upcomingBirthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                        (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                        style: const TextStyle(color: mobileText),
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                        smsAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                                      },
                                                                    ),
                                                                    const Divider(),
                                                                    ListTile(
                                                                      title: Text(
                                                                        (upcomingBirthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                        style: const TextStyle(color: mobileText),
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                        smsAction((upcomingBirthday[index]['mobile'] as String).split(',')[1].trim());
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ) : smsAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                    },
                                                    icon: const Icon(Icons.message),
                                                    color: smsColor,
                                                  ),
                                                  if (upcomingBirthday[index]['mobile'] != null && upcomingBirthday[index]['mobile'] != '') IconButton(
                                                    onPressed: () {
                                                      (upcomingBirthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                        (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                        style: const TextStyle(color: mobileText),
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                        whatsappAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                                      },
                                                                    ),
                                                                    const Divider(),
                                                                    ListTile(
                                                                      title: Text(
                                                                        (upcomingBirthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                        style: const TextStyle(color: mobileText),
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.pop(context); // Close the dialog
                                                                        whatsappAction((upcomingBirthday[index]['mobile'] as String).split(',')[1].trim());
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ) : whatsappAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                    },
                                                    icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                    color: whatsAppColor,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ) : Container()
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == upcomingBirthday[index]['birthday'].trim()) Positioned(
                          top: size.height * 0.03,
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
                      ],
                    ),
                  ) : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  upcomingBirthday[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(upcomingBirthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != ''
                                          ? NetworkImage(upcomingBirthday[index]['birth_image'])
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
                                      Text(
                                        upcomingBirthday[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        upcomingBirthday[index]['birthday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ) : sectorTab == 'Sri Lankan Sector' && celebrationName == 'Birthday' && categoryName == 'Upcoming' ? ListView.builder(
              itemCount: upcomingBirthday.length,
              itemBuilder: (BuildContext context, int index) {
                final now = DateTime.now();
                var todays = DateFormat('dd - MMMM').format(now);
                return todays == upcomingBirthday[index]['birthday'].trim() ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                upcomingBirthday[index]['birth_image'] != '' ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Image.network(upcomingBirthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                height: size.height * 0.1,
                                width: size.width * 0.16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: <BoxShadow>[
                                    if(upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != '') const BoxShadow(
                                      color: Colors.grey,
                                      spreadRadius: -1,
                                      blurRadius: 5 ,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != ''
                                        ? NetworkImage(upcomingBirthday[index]['birth_image'])
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
                                    Text(
                                      upcomingBirthday[index]['name'],
                                      style: TextStyle(
                                          fontSize: size.height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          color: textColor
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                      upcomingBirthday[index]['birthday'],
                                      style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                    ),
                                    upcomingBirthday[index]['mobile'] != '' && upcomingBirthday[index]['mobile'] != null ? Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                              style: TextStyle(
                                                color: mobileText,
                                                fontSize: size.height * 0.02,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (upcomingBirthday[index]['mobile'] != null && upcomingBirthday[index]['mobile'] != '') IconButton(
                                                  onPressed: () {
                                                    (upcomingBirthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                      (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                      style: const TextStyle(color: mobileText),
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator.pop(context); // Close the dialog
                                                                      callAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                  ),
                                                                  const Divider(),
                                                                  ListTile(
                                                                    title: Text(
                                                                      (upcomingBirthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                      style: const TextStyle(color: mobileText),
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator.pop(context); // Close the dialog
                                                                      callAction((upcomingBirthday[index]['mobile'] as String).split(',')[1].trim());
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ) : callAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                  },
                                                  icon: const Icon(Icons.phone),
                                                  color: callColor,
                                                ),
                                                if (upcomingBirthday[index]['mobile'] != null && upcomingBirthday[index]['mobile'] != '') IconButton(
                                                  onPressed: () {
                                                    (upcomingBirthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                      (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                      style: const TextStyle(color: mobileText),
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator.pop(context); // Close the dialog
                                                                      smsAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                  ),
                                                                  const Divider(),
                                                                  ListTile(
                                                                    title: Text(
                                                                      (upcomingBirthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                      style: const TextStyle(color: mobileText),
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator.pop(context); // Close the dialog
                                                                      smsAction((upcomingBirthday[index]['mobile'] as String).split(',')[1].trim());
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ) : smsAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                  },
                                                  icon: const Icon(Icons.message),
                                                  color: smsColor,
                                                ),
                                                if (upcomingBirthday[index]['mobile'] != null && upcomingBirthday[index]['mobile'] != '') IconButton(
                                                  onPressed: () {
                                                    (upcomingBirthday[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                      (upcomingBirthday[index]['mobile'] as String).split(',')[0].trim(),
                                                                      style: const TextStyle(color: mobileText),
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator.pop(context); // Close the dialog
                                                                      whatsappAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                  ),
                                                                  const Divider(),
                                                                  ListTile(
                                                                    title: Text(
                                                                      (upcomingBirthday[index]['mobile'] as String).split(',')[1].trim(),
                                                                      style: const TextStyle(color: mobileText),
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator.pop(context); // Close the dialog
                                                                      whatsappAction((upcomingBirthday[index]['mobile'] as String).split(',')[1].trim());
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ) : whatsappAction((upcomingBirthday[index]['mobile'] as String).split(',')[0].trim());
                                                  },
                                                  icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                  color: whatsAppColor,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ) : Container()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(todays == upcomingBirthday[index]['birthday'].trim()) Positioned(
                        top: size.height * 0.03,
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
                    ],
                  ),
                ) : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                upcomingBirthday[index]['birth_image'] != '' ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Image.network(upcomingBirthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                height: size.height * 0.08,
                                width: size.width * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: <BoxShadow>[
                                    if(upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != '') const BoxShadow(
                                      color: Colors.grey,
                                      spreadRadius: -1,
                                      blurRadius: 5 ,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: upcomingBirthday[index]['birth_image'] != null && upcomingBirthday[index]['birth_image'] != ''
                                        ? NetworkImage(upcomingBirthday[index]['birth_image'])
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
                                    Text(
                                      upcomingBirthday[index]['name'],
                                      style: TextStyle(
                                          fontSize: size.height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          color: textColor
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                      upcomingBirthday[index]['birthday'],
                                      style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ) : ListView.builder(
                itemCount: thisMonthBirthday.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  thisMonthBirthday[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(thisMonthBirthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(thisMonthBirthday[index]['birth_image'] != null && thisMonthBirthday[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: thisMonthBirthday[index]['birth_image'] != null && thisMonthBirthday[index]['birth_image'] != ''
                                          ? NetworkImage(thisMonthBirthday[index]['birth_image'])
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
                                      Text(
                                        thisMonthBirthday[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        thisMonthBirthday[index]['birthday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == thisMonthBirthday[index]['birthday'].trim()) Positioned(
                          bottom: size.height * 0.01,
                          right: size.width * 0.01,
                          child: Center(
                            child: Container(
                              height: size.height * 0.05,
                              width: size.width * 0.1,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage( "assets/images/celebration.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ) : thisMonthBirthday.isNotEmpty && categoryName == 'All' ? ListView.builder(
                itemCount: thisMonthBirthday.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  thisMonthBirthday[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(thisMonthBirthday[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(thisMonthBirthday[index]['birth_image'] != null && thisMonthBirthday[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: thisMonthBirthday[index]['birth_image'] != null && thisMonthBirthday[index]['birth_image'] != ''
                                          ? NetworkImage(thisMonthBirthday[index]['birth_image'])
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
                                      Text(
                                        thisMonthBirthday[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        thisMonthBirthday[index]['birthday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == thisMonthBirthday[index]['birthday'].trim()) Positioned(
                          bottom: size.height * 0.01,
                          right: size.width * 0.01,
                          child: Center(
                            child: Container(
                              height: size.height * 0.05,
                              width: size.width * 0.1,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage( "assets/images/celebration.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      ),
                    ),
                  )
                ],
              ),
            ) : Expanded(
              child: _thisMonth ? Center(
                child: SizedBox(
                  height: size.height * 0.06,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.lineScalePulseOutRapid,
                    colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                  ),
                ),
              ) : upcomingFeast.isNotEmpty && categoryName == 'Upcoming' ? sectorTab == 'Indian Sector' && celebrationName == 'Feast' && categoryName == 'Upcoming' ? ListView.builder(
                itemCount: upcomingFeast.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return todays == upcomingFeast[index]['feastday'].trim() ? Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  upcomingFeast[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(upcomingFeast[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.1,
                                  width: size.width * 0.16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != ''
                                          ? NetworkImage(upcomingFeast[index]['birth_image'])
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
                                      Text(
                                        upcomingFeast[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        upcomingFeast[index]['feastday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == upcomingFeast[index]['feastday'].trim()) Positioned(
                          top: size.height * 0.03,
                          right: size.width * 0.01,
                          child: Center(
                            child: Container(
                              height: size.height * 0.06,
                              width: size.width * 0.2,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage( "assets/images/celebration.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  upcomingFeast[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(upcomingFeast[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != ''
                                          ? NetworkImage(upcomingFeast[index]['birth_image'])
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
                                      Text(
                                        upcomingFeast[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        upcomingFeast[index]['feastday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ) : sectorTab == 'Sri Lankan Sector' && celebrationName == 'Feast' && categoryName == 'Upcoming' ? ListView.builder(
                itemCount: upcomingFeast.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return todays == upcomingFeast[index]['feastday'].trim() ? Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  upcomingFeast[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(upcomingFeast[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.1,
                                  width: size.width * 0.16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != ''
                                          ? NetworkImage(upcomingFeast[index]['birth_image'])
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
                                      Text(
                                        upcomingFeast[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        upcomingFeast[index]['feastday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == upcomingFeast[index]['feastday'].trim()) Positioned(
                          top: size.height * 0.03,
                          right: size.width * 0.01,
                          child: Center(
                            child: Container(
                              height: size.height * 0.06,
                              width: size.width * 0.2,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage( "assets/images/celebration.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  upcomingFeast[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(upcomingFeast[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: upcomingFeast[index]['birth_image'] != null && upcomingFeast[index]['birth_image'] != ''
                                          ? NetworkImage(upcomingFeast[index]['birth_image'])
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
                                      Text(
                                        upcomingFeast[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        upcomingFeast[index]['feastday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ) : ListView.builder(
                itemCount: thisMonthFeast.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  thisMonthFeast[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(thisMonthFeast[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(thisMonthFeast[index]['birth_image'] != null && thisMonthFeast[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: thisMonthFeast[index]['birth_image'] != null && thisMonthFeast[index]['birth_image'] != ''
                                          ? NetworkImage(thisMonthFeast[index]['birth_image'])
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
                                      Text(
                                        thisMonthFeast[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        thisMonthFeast[index]['feastday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == thisMonthFeast[index]['feastday'].trim()) Positioned(
                          bottom: size.height * 0.01,
                          right: size.width * 0.01,
                          child: Center(
                            child: Container(
                              height: size.height * 0.05,
                              width: size.width * 0.1,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage( "assets/images/celebration.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ) : thisMonthFeast.isNotEmpty && categoryName == 'All' ? ListView.builder(
                itemCount: thisMonthFeast.length,
                itemBuilder: (BuildContext context, int index) {
                  final now = DateTime.now();
                  var todays = DateFormat('dd - MMMM').format(now);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  thisMonthFeast[index]['birth_image'] != '' ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(thisMonthFeast[index]['birth_image'], fit: BoxFit.cover,),
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
                                  height: size.height * 0.08,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      if(thisMonthFeast[index]['birth_image'] != null && thisMonthFeast[index]['birth_image'] != '') const BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: -1,
                                        blurRadius: 5 ,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: thisMonthFeast[index]['birth_image'] != null && thisMonthFeast[index]['birth_image'] != ''
                                          ? NetworkImage(thisMonthFeast[index]['birth_image'])
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
                                      Text(
                                        thisMonthFeast[index]['name'],
                                        style: TextStyle(
                                            fontSize: size.height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: textColor
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Text(
                                        thisMonthFeast[index]['feastday'],
                                        style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: emptyColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(todays == thisMonthFeast[index]['feastday'].trim()) Positioned(
                          bottom: size.height * 0.01,
                          right: size.width * 0.01,
                          child: Center(
                            child: Container(
                              height: size.height * 0.05,
                              width: size.width * 0.1,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage( "assets/images/celebration.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}