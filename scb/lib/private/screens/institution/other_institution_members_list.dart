import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:scb/private/screens/member/members_details.dart';
import 'package:scb/private/screens/member/profile/member_profile_details.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherInstitutionMembersListScreen extends StatefulWidget {
  const OtherInstitutionMembersListScreen({Key? key}) : super(key: key);

  @override
  State<OtherInstitutionMembersListScreen> createState() => _OtherInstitutionMembersListScreenState();
}

class _OtherInstitutionMembersListScreenState extends State<OtherInstitutionMembersListScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  int index = 0;
  bool _isLoading = true;
  List otherMembers = [];
  List data = [];
  String searchName = '';
  var searchController = TextEditingController();

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  otherInstitutionMembers() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_institution_members?args=[$instituteID]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      otherMembers = data;
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

  void changeData() {
    setState(() {
      _isLoading = true;
      otherInstitutionMembers();
    });
  }

  assignValues(indexValue, indexName) async {
    id = indexValue;
    name = indexName;

    if(memberId == id) {
      userMember = '';
      memberId = id;
      String refresh = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MemberProfileTabbarScreen()));
      if(refresh == 'refresh') {
        changeData();
      }
    } else {
      userMember = 'Member';
      String refresh = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MembersDetailsTabBarScreen()));
      if(refresh == 'refresh') {
        changeData();
      }
    }
  }

  searchData(String searchWord) {
    List results = [];
    if (searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = data
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      otherMembers = results;
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
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      otherInstitutionMembers();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            otherInstitutionMembers();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    userMember = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: institution == 'Institution' ? AppBar(
        title: const Text('Members'),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        toolbarHeight: 50,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ) : house == 'House' ? AppBar(
        title: const Text('Members'),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        toolbarHeight: 50,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ) : null,
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
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                institution == 'Institution' ? SizedBox(
                  width: size.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: tabBackColor,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Members of $instituteName',
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
                ) : Container(),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchName = value;
                        searchData(searchName);
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchData(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: size.height * 0.02,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (searchName.isNotEmpty) {
                                setState(() {
                                  searchController.clear();
                                  searchName = '';
                                  searchData(searchName);
                                });
                              }
                            },
                            child: searchName.isNotEmpty && searchName != ''
                                ? const Icon(Icons.clear, color: redColor)
                                : Container(),
                          ),
                          SizedBox(width: size.width * 0.01),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                searchData(searchName);
                              });
                            },
                            child: Container(
                              height: size.height * 0.055,
                              width: size.width * 0.11,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: menuThirdColor,
                              ),
                              child: const Icon(Icons.search, color: whiteColor),
                            ),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(width: 1, color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                institution == 'Institution' ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('members :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${otherMembers.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                  ],
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${otherMembers.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                otherMembers.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: otherMembers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              int indexValue;
                              String indexName = '';
                              indexValue = otherMembers[index]['id'];
                              indexName = otherMembers[index]['name'];
                              assignValues(indexValue, indexName);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            otherMembers[index]['image_1920'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(otherMembers[index]['image_1920'] , fit: BoxFit.cover,),
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
                                                image: otherMembers[index]['image_1920'] != null && otherMembers[index]['image_1920'] != ''
                                                    ? NetworkImage(otherMembers[index]['image_1920'])
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
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        otherMembers[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          color: textHeadColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.005,
                                                ),
                                                Row(
                                                  children: [
                                                    otherMembers[index]['role'] != null && otherMembers[index]['role'] != '' ? Flexible(
                                                      child: Text(
                                                        otherMembers[index]['role'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.017,
                                                          color: emptyColor,
                                                        ),
                                                      ),
                                                    ) : Flexible(
                                                      child: Text(
                                                        'No role assigned',
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.017,
                                                          color: emptyColor,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                otherMembers[index]['mobile'] != '' && otherMembers[index]['mobile'] != null ? Row(
                                                  children: [
                                                    Text(
                                                      (otherMembers[index]['mobile'] as String)
                                                          .split(',')[0]
                                                          .trim(),
                                                      style: TextStyle(
                                                        color: mobileText,
                                                        fontSize: size.height * 0.018,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if(otherMembers[index]['mobile'] != null && otherMembers[index]['mobile'] != '') IconButton(
                                                          onPressed: () {
                                                            (otherMembers[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                              (otherMembers[index]['mobile'] as String).split(',')[0].trim(),
                                                                              style: const TextStyle(color: mobileText),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              callAction((otherMembers[index]['mobile'] as String).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (otherMembers[index]['mobile'] as String).split(',')[1].trim(),
                                                                              style: const TextStyle(color: mobileText),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              callAction((otherMembers[index]['mobile'] as String).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : callAction((otherMembers[index]['mobile'] as String).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.phone),
                                                          color: callColor,
                                                        ),
                                                        if(otherMembers[index]['mobile'] != null && otherMembers[index]['mobile'] != '') IconButton(
                                                          onPressed: () {
                                                            (otherMembers[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                              (otherMembers[index]['mobile'] as String).split(',')[0].trim(),
                                                                              style: const TextStyle(color: mobileText),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              smsAction((otherMembers[index]['mobile'] as String).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (otherMembers[index]['mobile'] as String).split(',')[1].trim(),
                                                                              style: const TextStyle(color: mobileText),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              smsAction((otherMembers[index]['mobile'] as String).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : smsAction((otherMembers[index]['mobile'] as String).split(',')[0].trim());
                                                          },
                                                          icon: const Icon(Icons.message),
                                                          color: smsColor,
                                                        ),
                                                        if(otherMembers[index]['mobile'] != null && otherMembers[index]['mobile'] != '') IconButton(
                                                          onPressed: () {
                                                            (otherMembers[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                              (otherMembers[index]['mobile'] as String).split(',')[0].trim(),
                                                                              style: const TextStyle(color: mobileText),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              whatsappAction((otherMembers[index]['mobile'] as String).split(',')[0].trim());
                                                                            },
                                                                          ),
                                                                          const Divider(),
                                                                          ListTile(
                                                                            title: Text(
                                                                              (otherMembers[index]['mobile'] as String).split(',')[1].trim(),
                                                                              style: const TextStyle(color: mobileText),
                                                                            ),
                                                                            onTap: () {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              whatsappAction((otherMembers[index]['mobile'] as String).split(',')[1].trim());
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) : whatsappAction((otherMembers[index]['mobile'] as String).split(',')[0].trim());
                                                          },
                                                          icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                          color: whatsAppColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ) : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: size.height * 0.01,
                                    right: size.width * 0.02,
                                    child: Container(
                                      height: size.height * 0.028,
                                      width: size.width * 0.06,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: otherMembers[index]['member_type'] == 'Sister' ? Colors.green : otherMembers[index]['member_type'] == 'Junior Sister' ? Colors.pinkAccent : otherMembers[index]['member_type'] == 'Novice' ? Colors.indigo : otherMembers[index]['member_type'] == 'Candidacy' ? Colors.cyan : otherMembers[index]['member_type'] == 'Postulancy' ? Colors.purpleAccent : Colors.redAccent,
                                      ),
                                      child: otherMembers[index]['member_type'] == 'Sister' ? Text('S',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : otherMembers[index]['member_type'] == 'Junior Sister' ? Text('JS',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : otherMembers[index]['member_type'] == 'Novice' ? Text('N',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : otherMembers[index]['member_type'] == 'Candidacy' ? Text('C',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : otherMembers[index]['member_type'] == 'Postulancy' ? Text('PO',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ) : Text('RS',
                                        style: GoogleFonts.heebo(
                                            fontSize: size.height * 0.02,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
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
              ],
            ),
          )
      ),
    );
  }
}
