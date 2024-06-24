import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

class ObituaryScreen extends StatefulWidget {
  const ObituaryScreen({Key? key}) : super(key: key);

  @override
  State<ObituaryScreen> createState() => _ObituaryScreenState();
}

class _ObituaryScreenState extends State<ObituaryScreen> with TickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late List<GlobalKey> expansionTile;
  bool _isLoading = true;
  bool _isToday = false;
  List deathData = [];
  int selected = -1;
  String today = '';
  String formattedDate = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getDeathMembersData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_death_members?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      today = result['data']['today'];
      List data = obituaryTab == "Upcoming" ? result['data']['next_30days'] : result['data']['obituary_results'];
      setState(() {
        _isLoading = false;
      });
      deathData = data;
      for(int i = 0; i < deathData.length; i++) {
        DateTime date = DateFormat("dd-MM-yyyy").parse(deathData[i]['death_date']);
        formattedDate = DateFormat('dd - MMMM').format(date);
        if(today == formattedDate) {
          _isToday = true;
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
      getDeathMembersData();
      expansionTile = List<GlobalKey<_ObituaryScreenState>>
          .generate(deathData.length, (index) => GlobalKey());
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDeathMembersData();
            expansionTile = List<GlobalKey<_ObituaryScreenState>>
                .generate(deathData.length, (index) => GlobalKey());
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
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: _isLoading
                ? Center(
              child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/alert/spinner_1.gif"),
                    ),
                  )),
            ) : Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                deathData.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${deathData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                  ],
                ) : Container(),
                deathData.isNotEmpty ? SizedBox(
                  height: size.height * 0.01,
                ) : Container(),
                obituaryTab == 'Upcoming' ? deathData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if(_isToday) Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'In Fond Memory',
                                    style: GoogleFonts.pacifico(
                                      color: Colors.indigo,
                                      fontSize: size.height * 0.026,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height:  size.height * 0.01,),
                            SlideFadeAnimation(
                              duration: const Duration(seconds: 1),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: deathData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  DateTime date = DateFormat("dd-MM-yyyy").parse(deathData[index]['death_date']);
                                  formattedDate = DateFormat('dd - MMMM').format(date);
                                  if(today == formattedDate) {
                                    return Container(
                                      padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      deathData[index]['image_1920'] != '' ? showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Dialog(
                                                            child: Image.network(deathData[index]['image_1920'], fit: BoxFit.cover,),
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
                                                          if(deathData[index]['image_1920'] != '')const BoxShadow(
                                                            color: Colors.grey,
                                                            spreadRadius: -1,
                                                            blurRadius: 5 ,
                                                            offset: Offset(0, 1),
                                                          ),
                                                        ],
                                                        shape: BoxShape.rectangle,
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: deathData[index]['image_1920'] != null && deathData[index]['image_1920'] != ''
                                                              ? NetworkImage(deathData[index]['image_1920'])
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
                                                                  deathData[index]['name'].toUpperCase(),
                                                                  style: GoogleFonts.secularOne(
                                                                    fontSize: size.height * 0.02,
                                                                    color: textColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: size.height * 0.01,
                                                          ),
                                                          deathData[index]['birth_date'] != null && deathData[index]['birth_date'] != '' ? Row(
                                                            children: [
                                                              Text(deathData[index]['birth_date'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                              SizedBox(width: size.width * 0.02,),
                                                              Text('-', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                              SizedBox(width: size.width * 0.02,),
                                                              Text(deathData[index]['death_date'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                            ],
                                                          ) : Text(deathData[index]['death_date'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              bottom: size.height * 0.001,
                                              right: size.width * 0.001,
                                              child: Center(
                                                child: Container(
                                                  height: size.height * 0.08,
                                                  width: size.width * 0.15,
                                                  decoration: const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage( "assets/images/death.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                deathData[index]['img_data'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(deathData[index]['img_data'], fit: BoxFit.cover,),
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
                                                    if(deathData[index]['img_data'] != null && deathData[index]['img_data'] != '') const BoxShadow(
                                                      color: Colors.grey,
                                                      spreadRadius: -1,
                                                      blurRadius: 5 ,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: deathData[index]['img_data'] != null && deathData[index]['img_data'] != ''
                                                        ? NetworkImage(deathData[index]['img_data'])
                                                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.only(top: 10, right: 5, left: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          deathData[index]['name'],
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    deathData[index]['birth_date'] != null && deathData[index]['birth_date'] != '' ? Row(
                                                      children: [
                                                        Text(deathData[index]['birth_date'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                        SizedBox(width: size.width * 0.02,),
                                                        Text('-', style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                        SizedBox(width: size.width * 0.02,),
                                                        Text(deathData[index]['death_date'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                      ],
                                                    ) : Text(deathData[index]['death_date'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Column(
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
                ) : deathData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: SlideFadeAnimation(
                          duration: const Duration(seconds: 1),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: deathData.length,
                            itemBuilder: (BuildContext context, int index) {
                              final now = DateTime.now();
                              var todays = DateFormat('dd - MMMM').format(now);
                              DateTime date = DateFormat("dd-MM-yyyy").parse(deathData[index]['death_date']);
                              var formattedDates = DateFormat('dd - MMMM').format(date);
                              return Stack(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              deathData[index]['image_1920'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(deathData[index]['image_1920'], fit: BoxFit.cover,),
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
                                                  if(deathData[index]['image_1920'] != null && deathData[index]['image_1920'] != '') const BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: -1,
                                                    blurRadius: 5 ,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: deathData[index]['image_1920'] != null && deathData[index]['image_1920'] != ''
                                                      ? NetworkImage(deathData[index]['image_1920'])
                                                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(top: 10, right: 5, left: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        deathData[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  deathData[index]['birth_date'] != null && deathData[index]['birth_date'] != '' ? Row(
                                                    children: [
                                                      Text(deathData[index]['birth_date'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                      SizedBox(width: size.width * 0.02,),
                                                      Text('-', style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                      SizedBox(width: size.width * 0.02,),
                                                      Text(deathData[index]['death_date'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                    ],
                                                  ) : Text(deathData[index]['death_date'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if(todays == formattedDates) Positioned(
                                    bottom: size.height * 0.01,
                                    right: size.width * 0.01,
                                    child: Center(
                                      child: Container(
                                        height: size.height * 0.06,
                                        width: size.width * 0.15,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage( "assets/images/death.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Column(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
