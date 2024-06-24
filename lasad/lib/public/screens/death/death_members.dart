import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/widget/theme_color/color.dart';
import 'package:loading_indicator/loading_indicator.dart';

class DeathMembersScreen extends StatefulWidget {
  const DeathMembersScreen({Key? key}) : super(key: key);

  @override
  State<DeathMembersScreen> createState() => _DeathMembersScreenState();
}

class _DeathMembersScreenState extends State<DeathMembersScreen> with TickerProviderStateMixin {
  late List<GlobalKey> expansionTile;
  bool _isLoading = true;
  List deathData = [];
  List data = [];
  int selected = -1;
  String searchName = '';
  var searchController = TextEditingController();

  getDeathMembersData() async {
    var request = sectorTab == 'Indian Sector' ? http.Request('GET', Uri.parse("$baseUrl/member/province/death/$userProvinceId")) : http.Request('GET', Uri.parse("$baseUrl/member/province/death/$sri_sector_id"));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      deathData = data;
      var date = DateFormat('yyyy').format(DateFormat("dd-MM-yyyy").parse("06-05-1932"));
      var now = DateTime.now().year;
      var sum = now - int.parse(date);
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

  searchData(String searchWord) {
    List results = [];
    if (searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = data
          .where((user) =>
          user['member_name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      deathData = results;
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
    // Check Internet connection
    internetCheck();
    super.initState();
    getDeathMembersData();

    expansionTile = List<GlobalKey<_DeathMembersScreenState>>
        .generate(deathData.length, (index) => GlobalKey());
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
                SizedBox(
                  height: size.height * 0.01,
                ),
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
                              height: 50,
                              width: 45,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: iconBackColor,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 3,),
                    Text('${deathData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                deathData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
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
                                              deathData[index]['image'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(deathData[index]['image'], fit: BoxFit.cover,),
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
                                                  if(deathData[index]['image'] != null && deathData[index]['image'] != '') const BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: -1,
                                                    blurRadius: 5 ,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: deathData[index]['image'] != null && deathData[index]['image'] != ''
                                                      ? NetworkImage(deathData[index]['image'])
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
                                                        deathData[index]['member_name'],
                                                        style: GoogleFonts.secularOne(
                                                          fontSize: size.height * 0.02,
                                                          color: todays == formattedDates ? textColor : valueColor
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  deathData[index]['dob'] != null && deathData[index]['dob'] != '' ? Row(
                                                    children: [
                                                      Text(deathData[index]['dob'], style: GoogleFonts.secularOne(color: emptyColor, fontSize: size.height * 0.02),),
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
                            }
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
