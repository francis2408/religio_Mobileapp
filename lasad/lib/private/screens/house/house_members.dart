import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lasad/private/screens/member/members/member.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:http/http.dart' as http;

class HouseMembersScreen extends StatefulWidget {
  const HouseMembersScreen({Key? key}) : super(key: key);

  @override
  State<HouseMembersScreen> createState() => _HouseMembersScreenState();
}

class _HouseMembersScreenState extends State<HouseMembersScreen> {
  bool _isLoading = true;
  List memberList = [];
  List data = [];

  assignValues(indexValue, indexName) {
    house_memberId = indexValue;
    house_member_name = indexName;

    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const MemberScreen();
          }));
    });
  }

  membersList() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/member/house/$house_id"));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      memberList = data;
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
      memberList = results;
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
    membersList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      // backgroundColor: const Color(0xFFE4EBF7),
      appBar: AppBar(
        title: Text(house_name),
        backgroundColor: backgroundColor,
        toolbarHeight: 50,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SafeArea(
        child: Container(
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: [
          //       Color(0xFF3B4371),
          //       Color(0xFF859398),
          //       // Color(0xFF4E54C8),
          //       // Color(0xFFDBD4B4),
          //       // Color(0xFF7AA1D2),
          //     ],
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //   ),
          // ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: backgroundColor,)
                : Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchData(value);
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                        hintText: "Search",
                        hintStyle: const TextStyle(color: textColor),
                        suffixIcon: const Icon(Icons.search,  color: iconColor,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(width: 2, color: lightColor),
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
                      Text('${memberList.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  memberList.isNotEmpty ? Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      radius: const Radius.circular(15),
                      thickness: 8,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: memberList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: GestureDetector(
                              onTap: () {
                                int indexValue;
                                String indexName = '';
                                indexValue = memberList[index]['id'];
                                indexName = memberList[index]['member_name'];
                                assignValues(indexValue, indexName);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      height: 50,
                                      width: 50,
                                      // margin: const EdgeInsets.all(20.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: GestureDetector(
                                          onTap: () async {},
                                          child: Image(
                                            height: size.height * 0.05,
                                            width: size.width * 0.1,
                                            fit: BoxFit.cover,
                                            image: memberList[index]['image_1920'] != null && memberList[index]['image_1920'] != ''
                                                ? NetworkImage(memberList[index]['image_1920'])
                                                : const AssetImage('assets/images/profile.png') as ImageProvider,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(memberList[index]['member_name'],
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
