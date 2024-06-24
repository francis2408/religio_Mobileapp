import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/private/screens/house/other_house_details.dart';
import 'package:kjpraipur/private/screens/house/other_house_institution_list.dart';
import 'package:kjpraipur/private/screens/house/other_house_members_list.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

class ProvinceHouseListScreen extends StatefulWidget {
  const ProvinceHouseListScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceHouseListScreen> createState() => _ProvinceHouseListScreenState();
}

class _ProvinceHouseListScreenState extends State<ProvinceHouseListScreen> {
  bool _isLoading = true;
  List houseData = [];
  List data = [];
  int selected = -1;
  int? indexValue;
  String indexName = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.religious.province/api_get_house_name_list?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      houseData = data;
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
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      houseData = results;
    });
  }

  assignValues(indexValue, indexName) {
    houseID = indexValue;
    houseName = indexName;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const OtherHouseDetailsScreen()));
    });
  }

  assignMembersValues(indexValue, indexName) {
    houseID = indexValue;
    houseName = indexName;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const OtherHouseMembersListScreen()));
    });
  }

  assignInstitutionValues(indexValue, indexName) {
    houseID = indexValue;
    houseName = indexName;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const OtherHouseInstitutionListScreen()));
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
    getHouseData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('House'),
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
                )
            ),
          ) : Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
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
                    onChanged: (value) {
                      setState(() {
                        searchData(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),
                      suffixIcon: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)), color: tabBackColor),child: const Icon(Icons.search,  color: tabLabelColor,)),
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
                          color: tabBackColor,
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
                    Text('${houseData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                houseData.isNotEmpty ? Expanded(
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
                          itemCount: houseData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                indexValue = houseData[index]['id'];
                                indexName = houseData[index]['name'];
                                assignValues(indexValue,indexName);
                              },
                              child: Transform.translate(
                                offset: Offset(-3, -size.height / 70),
                                child: Container(
                                  height: size.height * 0.12,
                                  padding: const EdgeInsets.symmetric(horizontal: 10,),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: size.height * 0.1,
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
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  houseData[index]['name'],
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: size.height * 0.02,
                                                      fontWeight: FontWeight.bold,
                                                      color: textColor
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  houseData[index]['member_count'] != '' && houseData[index]['member_count'] != null && houseData[index]['member_count'] != 0 ? GestureDetector(
                                                    onTap: () {
                                                      indexValue = houseData[index]['id'];
                                                      indexName = houseData[index]['name'];
                                                      assignMembersValues(indexValue, indexName);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: buttonGreen,
                                                      ),
                                                      child: RichText(
                                                        text: TextSpan(
                                                            text: houseData[index]['member_count'].toString(),
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
                                                                fontWeight: FontWeight.bold,
                                                                color: buttonLabel,
                                                                fontStyle: FontStyle.italic
                                                            ),
                                                            children: <InlineSpan>[
                                                              houseData[index]['member_count'] == 1 ? TextSpan(
                                                                text: ' Member',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: buttonLabel,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              ) : TextSpan(
                                                                text: ' Members',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: buttonLabel,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              )
                                                            ]
                                                        ),
                                                      ),
                                                    ),
                                                  ) : Container(),
                                                  houseData[index]['member_count'] != '' && houseData[index]['member_count'] != null && houseData[index]['member_count'] != 0 ? SizedBox(
                                                    width: size.width * 0.05,
                                                  ) : Container(),
                                                  houseData[index]['institution_id'] != '' && houseData[index]['institution_id'] != null && houseData[index]['institution_id'] != 0 ? GestureDetector(
                                                    onTap: () {
                                                      indexValue = houseData[index]['id'];
                                                      indexName = houseData[index]['name'];
                                                      assignInstitutionValues(indexValue, indexName);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: buttonRed,
                                                      ),
                                                      child: RichText(
                                                        text: TextSpan(
                                                            text: houseData[index]['institution_id'].toString(),
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
                                                                fontWeight: FontWeight.bold,
                                                                color: buttonLabel,
                                                                fontStyle: FontStyle.italic
                                                            ),
                                                            children: <InlineSpan>[
                                                              houseData[index]['institution_id'] == 1 ? TextSpan(
                                                                text: ' Institution',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: buttonLabel,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              ) : TextSpan(
                                                                text: ' Institutions',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: buttonLabel,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              )
                                                            ]
                                                        ),
                                                      ),
                                                    ),
                                                  ) : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: size.height * 0.03,
                                        left: 0,
                                        right: size.width * 0.65,
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/images/community.png', fit: BoxFit.cover,),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: size.height * 0.08,
                                              width: size.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                shape: BoxShape.rectangle,
                                                image: const DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: AssetImage('assets/images/community.png'),
                                                ),
                                              ),
                                            ),
                                          ),
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
                          text: 'No Data available',
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
    );
  }
}
