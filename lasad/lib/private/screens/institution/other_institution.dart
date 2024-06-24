import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/private/screens/circular&news_letter/circular/circular.dart';
import 'package:lasad/private/screens/institution/institution_members.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherInstitutionScreen extends StatefulWidget {
  const OtherInstitutionScreen({Key? key}) : super(key: key);

  @override
  State<OtherInstitutionScreen> createState() => _OtherInstitutionScreenState();
}

class _OtherInstitutionScreenState extends State<OtherInstitutionScreen> {
  late List<GlobalKey> expansionTile;
  bool _isLoading = true;
  List institutionData = [];
  List data = [];
  int selected = -1;
  int? indexValue;
  String indexName = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  housesInstitutionList() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution?fields=['name','image_1920','community_id','superior_name','diocese_id','parish_id','medium','ministry_ids','institution_category_id','ministry_category_id','phone','mobile','email','street','street2','place','city','district_id','state_id','zip','country_id']&domain=[('id','!=',$userInstituteId)]&order=name asc&context={"bypass":1}"""));
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

  assignHouseInstitution(indexValue, indexName) {
    house_institution_id = indexValue;
    house_institution_name = indexName;
  }

  assignValues(indexValue, indexName) {
    institution_id = indexValue;
    institution_name = indexName;

    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const InstitutionMembersScreen();
          }));
    });
  }

  assignCircular(indexValue, indexName) {
    institution_id = indexValue;
    institution_name = indexName;

    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return const CircularScreen();
          }));
    });
  }

  assignCalendar(indexValue, indexName) {
    institution_id = indexValue;
    institution_name = indexName;

    setState(() {
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) {
      //       return const CalendarScreen();
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
    housesInstitutionList();

    expansionTile = List<GlobalKey<_OtherInstitutionScreenState>>
        .generate(institutionData.length, (index) => GlobalKey());
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
                            child: Container(
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
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
                                        indexValue = institutionData[index]['id'];
                                        indexName = institutionData[index]['name'];

                                        house == 'House' ? houseInstitution = 'HouseInstitution' : houseInstitution = '';
                                        house == 'House' ? assignHouseInstitution(indexValue, indexName) : null;
                                      });
                                    } else {
                                      setState(() {
                                        selected = -1;
                                      });
                                    }
                                  },
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                image: institutionData[index]['image_1920'] != null && institutionData[index]['image_1920'] != ''
                                                    ? NetworkImage(institutionData[index]['image_1920'])
                                                    : const AssetImage('assets/images/institution.png') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.03,),
                                          Flexible(
                                            child: Text(
                                              "${institutionData[index]['name']}",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 5, right: 20, bottom: 10),
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
                                                  // SizedBox(
                                                  //     height: 30,
                                                  //     width: 90,
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
                                                  // SizedBox(
                                                  //     height: 30,
                                                  //     width: 90,
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
                                                  //     width: 90,
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
                                              SizedBox(height: size.height * 0.01,),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.church, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    institutionData[index]['diocese_id'] != null && institutionData[index]['diocese_id'] != '' && institutionData[index]['diocese_id'].isNotEmpty ?
                                                    Flexible(child: Text("${institutionData[index]['diocese_id'][1]}", style: const TextStyle(fontSize: 14),)) : const Text('NA'),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.temple_buddhist, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    institutionData[index]['parish_id'] != null && institutionData[index]['parish_id'] != '' && institutionData[index]['parish_id'].isNotEmpty ?
                                                    Flexible(child: Text("${institutionData[index]['parish_id'][1]}", style: const TextStyle(fontSize: 14),)) : const Text('NA'),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.person, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    institutionData[index]['superior_id'] != null && institutionData[index]['superior_id'] != '' ?
                                                    Flexible(child: Text("${institutionData[index]['superior_id'][1]}", style: const TextStyle(fontSize: 14),)) : const Text('NA'),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.category, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    institutionData[index]['institution_category_id'] != null && institutionData[index]['institution_category_id'] != '' && institutionData[index]['institution_category_id'].isNotEmpty ?
                                                    Flexible(child: Text("${institutionData[index]['institution_category_id'][1]}", style: const TextStyle(fontSize: 14),)) : const Text('NA'),
                                                  ],
                                                ),
                                              ),
                                              institutionData[index]['email'].isEmpty ? SizedBox(height: size.height * 0.01,) : Container(),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.email, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    institutionData[index]['email'] != null && institutionData[index]['email'] != '' ?
                                                    Flexible(child: Text("${institutionData[index]['email']}", style: const TextStyle(fontSize: 14),)) : const Text('NA'),
                                                    if(institutionData[index]['email'] != null && institutionData[index]['email'] != '')
                                                      SizedBox(width: size.width * 0.06,),
                                                    if(institutionData[index]['email'] != null && institutionData[index]['email'] != '')
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons.email_outlined),
                                                            iconSize: 25,
                                                            color: Colors.red,
                                                            onPressed: () {
                                                              emailAction(institutionData[index]['email']);
                                                            },
                                                          )
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              ),
                                              institutionData[index]['mobile'].isEmpty ? SizedBox(height: size.height * 0.01,) : Container(),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.phone_android, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    institutionData[index]['mobile'] != null && institutionData[index]['mobile'] != '' ?
                                                    Flexible(child: Text("${institutionData[index]['mobile']}", style: const TextStyle(fontSize: 14),)) : const Text('NA'),
                                                    if(institutionData[index]['mobile'] != null && institutionData[index]['mobile'] != '')
                                                      SizedBox(width: size.width * 0.06,),
                                                    if(institutionData[index]['mobile'] != null && institutionData[index]['mobile'] != '')
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons.phone),
                                                            iconSize: 25,
                                                            color: Colors.blue,
                                                            onPressed: () {
                                                              callAction(institutionData[index]['mobile']);
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.message),
                                                            iconSize: 25,
                                                            color: Colors.orangeAccent,
                                                            onPressed: () {
                                                              smsAction(institutionData[index]['mobile']);
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(LineAwesomeIcons.what_s_app),
                                                            iconSize: 25,
                                                            color: Colors.green,
                                                            onPressed: () {
                                                              whatsappAction(institutionData[index]['mobile']);
                                                            },
                                                          )
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.location_on, color: Color(0xFF2661FA)),
                                                    SizedBox(width: size.width * 0.03,),
                                                    (institutionData[index]['street'].isEmpty &&
                                                        institutionData[index]['street2'].isEmpty &&
                                                        institutionData[index]['place'].isEmpty &&
                                                        institutionData[index]['city'].isEmpty &&
                                                        institutionData[index]['district_id'].isEmpty &&
                                                        institutionData[index]['state_id'].isEmpty &&
                                                        institutionData[index]['country_id'].isEmpty &&
                                                        institutionData[index]['zip'].isEmpty) ? const Text('NA')
                                                        : Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        institutionData[index]['street'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                                        institutionData[index]['street'].isNotEmpty ? Text("${institutionData[index]['street']},") : Container(),
                                                        institutionData[index]['street2'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                                        institutionData[index]['street2'].isNotEmpty ? Text("${institutionData[index]['street2']},") : Container(),
                                                        institutionData[index]['place'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                                        institutionData[index]['place'].isNotEmpty ? Text("${institutionData[index]['place']},") : Container(),
                                                        institutionData[index]['city'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                                        institutionData[index]['city'].isNotEmpty ? Text("${institutionData[index]['city']},") : Container(),
                                                        institutionData[index]['district_id'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                                        institutionData[index]['district_id'].isNotEmpty ? Text("${institutionData[index]['district_id'][1]},") : Container(),
                                                        institutionData[index]['state_id'].isNotEmpty ? const SizedBox(height: 3,) : Container(),
                                                        institutionData[index]['state_id'].isNotEmpty ? Text("${institutionData[index]['state_id'][1]},") : Container(),
                                                        (institutionData[index]['country_id'].isNotEmpty && institutionData[index]['zip'].isNotEmpty) ? const SizedBox(height: 3,) : Container(),
                                                        (institutionData[index]['country_id'].isNotEmpty && institutionData[index]['zip'].isNotEmpty) ? Text("${institutionData[index]['country_id'][1]}  -  ${institutionData[index]['zip']}.") : Container(),
                                                      ],
                                                    )
                                                  ],
                                                ),
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
