import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/private/screens/institution/other_institution_details.dart';
import 'package:lasad/private/screens/institution/other_institution_members_list.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class HouseInstitutionListScreen extends StatefulWidget {
  const HouseInstitutionListScreen({Key? key}) : super(key: key);

  @override
  State<HouseInstitutionListScreen> createState() => _HouseInstitutionListScreenState();
}

class _HouseInstitutionListScreenState extends State<HouseInstitutionListScreen> {
  bool _isLoading = true;
  List institutionData = [];
  List data = [];
  int selected = -1;
  int? indexValue;
  String indexName = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getHouseInstitutionData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.institution?fields=['name','image_1920','community_id','superior_name','diocese_id','parish_id','ministry_ids','institution_category_id','ministry_category_id','phone','mobile','email','street','street2','place','city','district_id','state_id','zip','country_id','establishment_date','members_count']&domain=[('community_id','=',$userCommunityId)]&limit=40&offset=0&order=name asc"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      institutionData = data;
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
      institutionData = results;
    });
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
    if (Platform.isAndroid) {
      var whatsappUrl ="whatsapp://send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    } else {
      var whatsappUrl ="https://api.whatsapp.com/send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    }
  }

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  assignValues(indexValue, indexName) {
    institution_id = indexValue;
    institution_name = indexName;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const OtherInstitutionDetailsScreen()));
    });
  }

  institutionMembers(indexValue, indexName) {
    institution_id = indexValue;
    institution_name = indexName;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const OtherInstitutionMembersListScreen()));
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
    getHouseInstitutionData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Institution'),
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
        child: Center(
          child: _isLoading
              ? Center(
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
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(width: 1, color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: iconActiveColor,
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
                    Text('${institutionData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                institutionData.isNotEmpty ? Expanded(
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
                        itemCount: institutionData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: GestureDetector(
                              onTap: () {
                                indexValue = institutionData[index]['id'];
                                indexName = institutionData[index]['name'];
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
                                                  institutionData[index]['name'],
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
                                                  institutionData[index]['members_count'] != '' && institutionData[index]['members_count'] != null ? GestureDetector(
                                                    onTap: () {
                                                      int indexValue;
                                                      String indexName;
                                                      indexValue = institutionData[index]['id'];
                                                      indexName = institutionData[index]['name'];
                                                      institutionMembers(indexValue, indexName);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: lightTeal,
                                                      ),
                                                      child: RichText(
                                                        text: TextSpan(
                                                            text: institutionData[index]['members_count'].toString(),
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.015,
                                                                fontWeight: FontWeight.bold,
                                                                color: iconActiveColor,
                                                                fontStyle: FontStyle.italic
                                                            ),
                                                            children: <InlineSpan>[
                                                              institutionData[index]['members_count'] == 1 ? TextSpan(
                                                                text: ' Member',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: iconActiveColor,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              ) : TextSpan(
                                                                text: ' Members',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: iconActiveColor,
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
                                              institutionData[index]['image_1920'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(institutionData[index]['image_1920'], fit: BoxFit.cover,),
                                                  );
                                                },
                                              ) : showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/images/institution.png', fit: BoxFit.cover,),
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
                                                  fit: BoxFit.fill,
                                                  image: institutionData[index]['image_1920'] != null && institutionData[index]['image_1920'] != ''
                                                      ? NetworkImage(institutionData[index]['image_1920'])
                                                      : const AssetImage('assets/images/institution.png') as ImageProvider,
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
                            ),
                          );
                        },
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
