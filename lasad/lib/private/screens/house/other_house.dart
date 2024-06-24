import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/private/screens/circular&news_letter/circular/circular.dart';
import 'package:lasad/private/screens/house/house_members.dart';
import 'package:lasad/private/screens/institution/institution.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherHouseScreen extends StatefulWidget {
  const OtherHouseScreen({Key? key}) : super(key: key);

  @override
  State<OtherHouseScreen> createState() => _OtherHouseScreenState();
}

class _OtherHouseScreenState extends State<OtherHouseScreen> {
  late List<GlobalKey> expansionTile;
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
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?domain=[('id','!=',$userCommunityId)]&fields=['name','ministry_ids','diocese_id','parish_id','superior_id','street','street2','place','city','district_id','state_id','zip','country_id','email','phone','mobile']&limit=40&offset=0"));
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const HouseMembersScreen();
          }));
    });
  }

  assignInstitution(indexValue, indexName) {
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const InstitutionScreen();
          }));
    });
  }

  assignCircular(indexValue, indexName) {
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const CircularScreen();
          }));
    });
  }

  assignCalendar(indexValue, indexName) {
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) {
      //       return const CalendarScreen();
      //     }));
    });
  }

  assignBirthday(indexValue, indexName) {
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) {
      //       return const MembersBirthdayScreen();
      //     }));
    });
  }

  assignOrdination(indexValue, indexName) {
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) {
      //       return const OrdinationScreen();
      //     }));
    });
  }

  assignDeath(indexValue, indexName) {
    house_id = indexValue;
    house_name = indexName;

    setState(() {
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) {
      //       return const DeathMembersScreen();
      //     }));
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
      body: SafeArea(
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
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.green,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ExpansionTile(
                                  key: Key(index.toString()),
                                  initiallyExpanded: index == selected,
                                  onExpansionChanged: (newState) {
                                    if(newState) {
                                      setState(() {
                                        selected = index;
                                        indexValue = houseData[index]['id'];
                                        indexName = houseData[index]['name'];
                                      });
                                    } else {
                                      setState(() {
                                        selected = -1;
                                      });
                                    }
                                  },
                                  title: Container(
                                    padding: const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: size.height * 0.05,
                                              width: size.width * 0.1,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: houseData[index]['image_1920'] != null
                                                      ? NetworkImage(houseData[index]['image_1920'])
                                                      : const AssetImage('assets/images/church.png') as ImageProvider,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: size.width * 0.03,),
                                            Flexible(
                                              child: Text(
                                                "${houseData[index]['name']}",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 15, right: 20, bottom: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    height: size.height * 0.04,
                                                    child: TextButton.icon(
                                                      onPressed: () {
                                                        assignValues(indexValue, indexName);
                                                      },
                                                      icon: const Icon(Icons.groups, size: 18,),
                                                      label: const Text('Members', style: TextStyle(fontSize: 12),),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: backgroundColor,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.0),
                                                        ),
                                                      ),),
                                                  ),
                                                  SizedBox(width: size.width * 0.02,),
                                                  SizedBox(
                                                    height: size.height * 0.04,
                                                    child: TextButton.icon(
                                                      onPressed: () {
                                                        assignInstitution(indexValue, indexName);
                                                      },
                                                      icon: const Icon(Icons.location_city, size: 18,),
                                                      label: const Text('Institution', style: TextStyle(fontSize: 12),),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: backgroundColor,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(7.0),
                                                        ),
                                                      ),),
                                                  ),
                                                  // SizedBox(
                                                  //     height: 30,
                                                  //     width: 75,
                                                  //     child: TextButton(
                                                  //       onPressed: (){
                                                  //         assignValues(indexValue, indexName);
                                                  //       },
                                                  //       style: TextButton.styleFrom(
                                                  //           foregroundColor: Colors.white,
                                                  //           backgroundColor: backgroundColor
                                                  //       ),
                                                  //       child: const Text('Members',style: TextStyle(fontSize: 11),),
                                                  //     )
                                                  // ),
                                                  // const SizedBox(width: 10,),
                                                  // SizedBox(
                                                  //     height: 30,
                                                  //     width: 75,
                                                  //     child: TextButton(
                                                  //       onPressed: (){
                                                  //         assignInstitution(indexValue, indexName);
                                                  //       },
                                                  //       style: TextButton.styleFrom(
                                                  //           foregroundColor: Colors.white,
                                                  //           backgroundColor: backgroundColor
                                                  //       ),
                                                  //       child: const Text('Institution',style: TextStyle(fontSize: 11),),
                                                  //     )
                                                  // ),
                                                  // SizedBox(
                                                  //     height: 30,
                                                  //     width: 75,
                                                  //     child: TextButton(
                                                  //       onPressed: (){
                                                  //         assignCircular(indexValue, indexName);
                                                  //       },
                                                  //       style: TextButton.styleFrom(
                                                  //           foregroundColor: Colors.white,
                                                  //           backgroundColor: backgroundColor
                                                  //       ),
                                                  //       child: const Text('Circular',style: TextStyle(fontSize: 11),),
                                                  //     )
                                                  // ),
                                                  // SizedBox(
                                                  //     height: 30,
                                                  //     width: 75,
                                                  //     child: TextButton(
                                                  //       onPressed: (){
                                                  //         assignCalendar(indexValue, indexName);
                                                  //       },
                                                  //       style: TextButton.styleFrom(
                                                  //           foregroundColor: Colors.white,
                                                  //           backgroundColor: backgroundColor
                                                  //       ),
                                                  //       child: const Text('Calendar',style: TextStyle(fontSize: 11),),
                                                  //     )
                                                  // ),
                                                ],
                                              ),
                                              // const SizedBox(height: 8,),
                                              // Row(
                                              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              //   children: [
                                              //     SizedBox(
                                              //         height: 30,
                                              //         width: 90,
                                              //         child: TextButton(
                                              //           onPressed: (){
                                              //             assignBirthday(indexValue, indexName);
                                              //           },
                                              //           style: TextButton.styleFrom(
                                              //               foregroundColor: Colors.white,
                                              //               backgroundColor: backgroundColor
                                              //           ),
                                              //           child: const Text('Birthday',style: TextStyle(fontSize: 11),),
                                              //         )
                                              //     ),
                                              //     SizedBox(
                                              //         height: 30,
                                              //         width: 90,
                                              //         child: TextButton(
                                              //           onPressed: (){
                                              //             assignOrdination(indexValue, indexName);
                                              //           },
                                              //           style: TextButton.styleFrom(
                                              //               foregroundColor: Colors.white,
                                              //               backgroundColor: backgroundColor
                                              //           ),
                                              //           child: const Text('Ordination',style: TextStyle(fontSize: 11),),
                                              //         )
                                              //     ),
                                              //     SizedBox(
                                              //         height: 30,
                                              //         width: 90,
                                              //         child: TextButton(
                                              //           onPressed: (){
                                              //             assignDeath(indexValue, indexName);
                                              //           },
                                              //           style: TextButton.styleFrom(
                                              //               foregroundColor: Colors.white,
                                              //               backgroundColor: backgroundColor
                                              //           ),
                                              //           child: const Text('Death',style: TextStyle(fontSize: 11),),
                                              //         )
                                              //     ),
                                              //   ],
                                              // ),
                                              SizedBox(height: size.height * 0.01,),
                                              Row(
                                                children: [
                                                  const Icon(Icons.person, color: Color(0xFF2661FA)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  houseData[index]['superior_id'] != null
                                                      && houseData[index]['superior_id'] != ''
                                                      && houseData[index]['superior_id'].isNotEmpty?
                                                  Text("${houseData[index]['superior_id'][1]}", style: const TextStyle(fontSize: 14),)
                                                      : const Text("NA"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.email, color: Color(0xFF2661FA)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  houseData[index]['email'] != null
                                                      && houseData[index]['email'] != '' ?
                                                  Flexible(child: Text("${houseData[index]['email']}"))
                                                      : const Text("NA"),
                                                  houseData[index]['email'] != null
                                                      && houseData[index]['email'] != '' ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.email_outlined),
                                                        color: Colors.red,
                                                        onPressed: () {
                                                          emailAction(houseData[index]['email']);
                                                        },
                                                      ),
                                                    ],
                                                  ) : Container()
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone_android, color: Color(0xFF2661FA)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  houseData[index]['mobile'] != null
                                                      && houseData[index]['mobile'] != '' ?
                                                  Flexible(child: Text("${houseData[index]['mobile']}"))
                                                      : const Text("NA"),
                                                  SizedBox(width: size.width * 0.1,),
                                                  houseData[index]['mobile'] != null
                                                      && houseData[index]['mobile'] != '' ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.phone),
                                                        color: Colors.blue,
                                                        onPressed: () {
                                                          callAction(houseData[index]['mobile']);
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.message),
                                                        color: Colors.orangeAccent,
                                                        onPressed: () {
                                                          smsAction(houseData[index]['mobile']);
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(LineAwesomeIcons.what_s_app),
                                                        color: Colors.green,
                                                        onPressed: () {
                                                          whatsappAction(houseData[index]['mobile']);
                                                          // whatsAppOpen(houseData[index]['mobile']);
                                                        },
                                                      )
                                                    ],
                                                  ) : Container()
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.settings_phone, color: Color(0xFF2661FA)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  houseData[index]['phone'] != null
                                                      && houseData[index]['phone'] != '' ?
                                                  Flexible(child: Text("${houseData[index]['phone']}"))
                                                      : const Text("NA"),
                                                  SizedBox(width: size.width * 0.08,),
                                                  houseData[index]['phone'] != null
                                                      && houseData[index]['phone'] != '' ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.phone),
                                                        color: Colors.blue,
                                                        onPressed: () {
                                                          callAction(houseData[index]['phone']);
                                                        },
                                                      ),
                                                    ],
                                                  ) : Container()
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
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
                        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                        child: SizedBox(
                          height: 45,
                          width: 150,
                          child: textButton,
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
