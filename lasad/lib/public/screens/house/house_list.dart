import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/public/screens/house/house_details.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lasad/widget/common/common.dart';

class PublicHouseListScreen extends StatefulWidget {
  const PublicHouseListScreen({Key? key}) : super(key: key);

  @override
  State<PublicHouseListScreen> createState() => _PublicHouseListScreenState();
}

class _PublicHouseListScreenState extends State<PublicHouseListScreen> {
  bool _isLoading = true;
  List houseData = [];
  List data = [];
  int selected = -1;
  int? indexValue;
  String indexName = '';
  String searchName = '';
  var searchController = TextEditingController();

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/houses/province/$userProvinceId"));
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
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const PublicHouseDetailsScreen()));
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
    getHouseData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('House'),
        backgroundColor: backgroundColor,
        toolbarHeight: 50,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
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
                houseData.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Showing 1 - ${houseData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),),
                  ],
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Total: ${houseData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),),
                  ],
                ),
                houseData.isNotEmpty ? SizedBox(
                  height: size.height * 0.01,
                ) : Container(),
                houseData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        key: Key('builder ${selected.toString()}'),
                        shrinkWrap: true,
                        // scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: houseData.isEmpty ? 0 : houseData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: GestureDetector(
                              onTap: () {
                                indexValue = houseData[index]['id'];
                                indexName = houseData[index]['name'];
                                assignValues(indexValue, indexName);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          houseData[index]['image_1920'] != '' && houseData[index]['image_1920'] != null ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Image.network(houseData[index]['image_1920'], fit: BoxFit.cover,),
                                              );
                                            },
                                          ) : showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Image.asset('assets/images/community.png', fit: BoxFit.cover),
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
                                            image: DecorationImage(
                                              fit: BoxFit.fitHeight,
                                              image: houseData[index]['image_512'] != null && houseData[index]['image_512'] != ''
                                                  ? NetworkImage(houseData[index]['image_512'])
                                                  : const AssetImage('assets/images/community.png') as ImageProvider,
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
                                                      houseData[index]['name'],
                                                      style: GoogleFonts.secularOne(
                                                        fontSize: size.height * 0.02,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              houseData[index]['ministry_ids_name'] != '' && houseData[index]['ministry_ids_name'] != null ? SizedBox(
                                                height: size.height * 0.01,
                                              ) : Container(),
                                              Row(
                                                children: [
                                                  houseData[index]['ministry_ids_name'] != '' && houseData[index]['ministry_ids_name'] != null ? Flexible(
                                                    child: Text(
                                                      houseData[index]['ministry_ids_name'],
                                                      style: GoogleFonts.secularOne(
                                                        fontSize: size.height * 0.018,
                                                        color: valueColor,
                                                      ),
                                                    ),
                                                  ) : Container(),
                                                ],
                                              ),
                                              houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != [] && houseData[index]['superior_id'] != null ? SizedBox(
                                                height: size.height * 0.01,
                                              ) : Container(),
                                              houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != [] && houseData[index]['superior_id'] != null ? Row(
                                                children: [
                                                  Flexible(
                                                    child: RichText(
                                                      textAlign: TextAlign.left,
                                                      text: TextSpan(
                                                          text: houseData[index]['superior_id']['name'],
                                                          style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.018,
                                                              color: valueColor,
                                                              fontStyle: FontStyle.italic
                                                          ),
                                                          children: houseData[index]['superior_id']['role_ids'] != null && houseData[index]['superior_id']['role_ids'] != '' ? [
                                                            const TextSpan(
                                                              text: '  ',
                                                            ),
                                                            TextSpan(
                                                              text: '(${houseData[index]['superior_id']['role_ids']})',
                                                              style: TextStyle(
                                                                  fontSize: size.height * 0.018,
                                                                  color: emptyColor,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                            ),
                                                          ] : []
                                                      ),
                                                    ),
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: NoResult(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
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
