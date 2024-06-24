import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:msscc/private/screens/institution/other_institution_details.dart';
import 'package:msscc/private/screens/institution/other_institution_members_list.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

class OtherHouseInstitutionListScreen extends StatefulWidget {
  const OtherHouseInstitutionListScreen({Key? key}) : super(key: key);

  @override
  State<OtherHouseInstitutionListScreen> createState() => _OtherHouseInstitutionListScreenState();
}

class _OtherHouseInstitutionListScreenState extends State<OtherHouseInstitutionListScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List institutionData = [];
  List data = [];
  int selected = -1;
  int? indexValue;
  String indexName = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getOtherHouseInstitutionData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution?fields=['name','image_512','superior_id','ministry_category_id','members_count']&domain=[('community_id','=',$houseID)]&limit=40&offset=0&order=name asc&context={"bypass":1}"""));
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

  void changeData() {
    setState(() {
      _isLoading = true;
      getOtherHouseInstitutionData();
    });
  }

  assignValues(indexValue, indexName) async {
    instituteID = indexValue;
    name = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherInstitutionDetailsScreen()));
    if(refresh == 'refresh') {
      changeData();
    }
  }

  institutionMembers(indexValue, indexName) async {
    instituteID = indexValue;
    name = indexName;
    institution = 'Institution';

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherInstitutionMembersListScreen()));
    if(refresh == 'refresh') {
      changeData();
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
      getOtherHouseInstitutionData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getOtherHouseInstitutionData();
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
      appBar: house == 'House' ? AppBar(
        title: const Text('Institution'),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              ),
              gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ) : null,
      body: SafeArea(
        child: Center(
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
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                SizedBox(
                  width: size.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: tabBackColor,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Institutions of $houseName',
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
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Institutions :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${institutionData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
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
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: institutionData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                indexValue = institutionData[index]['id'];
                                indexName = institutionData[index]['name'];
                                assignValues(indexValue,indexName);
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
                                          institutionData[index]['image_512'] != '' ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Image.network(institutionData[index]['image_512'], fit: BoxFit.cover,),
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
                                          height: size.height * 0.11,
                                          width: size.width * 0.20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            shape: BoxShape.rectangle,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: institutionData[index]['image_512'] != null && institutionData[index]['image_512'] != ''
                                                  ? NetworkImage(institutionData[index]['image_512'])
                                                  : const AssetImage('assets/images/institution.png') as ImageProvider,
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
                                                      institutionData[index]['name'],
                                                      style: GoogleFonts.secularOne(
                                                        fontSize: size.height * 0.02,
                                                        color: textHeadColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              institutionData[index]['ministry_category_id'].isNotEmpty && institutionData[index]['ministry_category_id'] != [] ? SizedBox(
                                                height: size.height * 0.01,
                                              ) : Container(),
                                              Row(
                                                children: [
                                                  institutionData[index]['ministry_category_id'].isNotEmpty && institutionData[index]['ministry_category_id'] != [] ? Flexible(
                                                    child: Text(
                                                      institutionData[index]['ministry_category_id'][1],
                                                      style: GoogleFonts.secularOne(
                                                        fontSize: size.height * 0.017,
                                                        color: valueColor,
                                                      ),
                                                    ),
                                                  ) : Container(),
                                                ],
                                              ),
                                              institutionData[index]['superior_id'].isNotEmpty && institutionData[index]['superior_id'] != [] ? SizedBox(
                                                height: size.height * 0.01,
                                              ) : Container(),
                                              Row(
                                                children: [
                                                  institutionData[index]['superior_id'].isNotEmpty && institutionData[index]['superior_id'] != [] ? Flexible(
                                                    child: Text(
                                                      institutionData[index]['superior_id'][1],
                                                      style: GoogleFonts.secularOne(
                                                        fontSize: size.height * 0.017,
                                                        color: emptyColor,
                                                      ),
                                                    ),
                                                  ) : Container(),
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
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
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: customBackgroundColor2,
                                                      ),
                                                      child: RichText(
                                                        text: TextSpan(
                                                            text: institutionData[index]['members_count'].toString(),
                                                            style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.014,
                                                                fontWeight: FontWeight.bold,
                                                                color: customTextColor2,
                                                                fontStyle: FontStyle.italic
                                                            ),
                                                            children: <InlineSpan>[
                                                              institutionData[index]['members_count'] == 1 ? TextSpan(
                                                                text: ' Member',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.014,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: customTextColor2,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                              ) : TextSpan(
                                                                text: ' Members',
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.014,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: customTextColor2,
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
