import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PublicMembersListScreen extends StatefulWidget {
  const PublicMembersListScreen({Key? key}) : super(key: key);

  @override
  State<PublicMembersListScreen> createState() => _PublicMembersListScreenState();
}

class _PublicMembersListScreenState extends State<PublicMembersListScreen> {
  bool _isLoading = true;
  String membersCount = '';

  List data = [];
  List membersListData = [];
  List members = [];
  String searchName = '';
  var searchController = TextEditingController();

  void getMembersData() async {
    setState(() {
      _isLoading = true;
    });

    var request = sectorTab == 'Indian Sector' ? http.Request('GET', Uri.parse("$baseUrl/member/province/$userProvinceId")) : http.Request('GET', Uri.parse("$baseUrl/member/province/$sri_sector_id"));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      members = data;
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

    setState(() {
      _isLoading = false;
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getMembersData();
    });
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
      members = results;
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
    getMembersData();
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
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
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
                Expanded(
                  child: Column(
                    children: [
                      members.isNotEmpty ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Showing 1 - ${members.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),),
                        ],
                      ) : Container(),
                      members.isNotEmpty ? SizedBox(
                        height: size.height * 0.01,
                      ) : Container(),
                      members.isNotEmpty ? Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          radius: const Radius.circular(15),
                          thickness: 8,
                          child: SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: ListView.builder(
                              itemCount: members.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return InfoAlertDialog(
                                          message: 'Please login.',
                                          onOkPressed: () async {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  members[index]['image_1920'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(members[index]['image_1920'], fit: BoxFit.cover,),
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
                                                      if(members[index]['image_1920'] != null && members[index]['image_1920'] != '') const BoxShadow(
                                                        color: Colors.grey,
                                                        spreadRadius: -1,
                                                        blurRadius: 5 ,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: members[index]['image_1920'] != null && members[index]['image_1920'] != ''
                                                          ? NetworkImage(members[index]['image_1920'])
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
                                                              members[index]['member_name'],
                                                              style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.02,
                                                                  color: textColor
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
                                                          members[index]['role_ids'] != null && members[index]['role_ids'] != '' ? Flexible(
                                                            child: Text(
                                                              members[index]['role_ids'],
                                                              style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.017,
                                                                color: emptyColor,
                                                              ),
                                                            ),
                                                          ) : Flexible(
                                                            child: Text(
                                                              'No role assigned',
                                                              style: GoogleFonts.secularOne(
                                                                letterSpacing: 0.5,
                                                                fontSize: size.height * 0.017,
                                                                color: emptyColor,
                                                                fontStyle: FontStyle.italic,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
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
                                  ),
                                );
                              },
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
                )
              ],
            ),
          )
      ),
    );
  }
}
