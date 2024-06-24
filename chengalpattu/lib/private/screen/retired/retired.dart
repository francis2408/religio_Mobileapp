import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chengai/private/screen/member/member_details.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class RetiredScreen extends StatefulWidget {
  const RetiredScreen({Key? key}) : super(key: key);

  @override
  State<RetiredScreen> createState() => _RetiredScreenState();
}

class _RetiredScreenState extends State<RetiredScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();

  bool _isLoading = true;

  List data = [];
  List members = [];
  var searchController = TextEditingController();

  void getMembersData() async {
    String url = '$baseUrl/res.member';
    Map datas = userMember != '' && selectedTab == 'All' ? {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['id','!=',$userMember],['role_ids.name','=','Retired']]",
        "order": "member_type_sequence, name asc",
        "query": "{id,name,member_name,image_1920,email,mobile,role_ids,parish_name,membership_type}"
      }
    } : {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['role_ids.name','=','Retired']]",
        "order": "member_type_sequence, name asc",
        "query": "{id,name,member_name,image_1920,email,mobile,role_ids,parish_name,membership_type}"
      }
    };
    var body = json.encode(datas);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if(response.statusCode == 200) {
      data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      members = data;
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        _isLoading = false;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: message['message'],
          confirmBtnColor: greenColor,
          width: 100.0,
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

  assignValues(indexValue, indexEmail, indexMobile) async {
    memberId = indexValue;
    memberEmail = indexEmail;
    memberMobile= indexMobile;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MemberDetailsScreen()));

    if(refresh == 'refresh') {
      changeData();
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
    if(Platform.isAndroid) {
      var whatsappUrl ="whatsapp://send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    } else {
      var whatsappUrl ="https://api.whatsapp.com/send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    }
  }

  searchData(String searchWord) {
    List results = [];
    if(searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = data
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
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
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Warning',
      text: 'Please check your internet connection',
      confirmBtnColor: greenColor,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        CheckInternetConnection.checkInternet().then((value) {
          if(value) {
            return null;
          } else {
            showDialogBox();
          }
        });
      },
      width: 100.0,
    );
  }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    super.initState();
    if (expiryDateTime!.isAfter(currentDateTime)) {
      getMembersData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMembersData();
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
      appBar: AppBar(
        title: const Text('Senior Priest Home'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF512F),
                    Color(0xFFF09819)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _isLoading = true;
              setState(() {
                if(_isLoading) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    setState(() {
                      getMembersData();
                    });
                  });
                }
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
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
                          color: backgroundColor,
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
                                  ? const Icon(Icons.clear, color: backgroundColor)
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
                                height: size.height * 0.055,
                                width: size.width * 0.11,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                  color: Color(0xFFd9f1fc),
                                ),
                                child: const Icon(Icons.search, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(width: 1, color: Colors.transparent),
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
                      Text('${members.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  members.isNotEmpty ? Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      radius: const Radius.circular(15),
                      thickness: 8,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: size.height * 0.005,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          int indexValue;
                                          String indexEmail = '';
                                          String indexMobile = '';
                                          indexValue = members[index]['id'];
                                          indexEmail = members[index]['email'];
                                          indexMobile = members[index]['mobile'];
                                          assignValues(indexValue, indexEmail, indexMobile);
                                        },
                                        child: Stack(
                                          children: [
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Container(
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
                                                        height: size.height * 0.11,
                                                        width: size.width * 0.18,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          boxShadow: <BoxShadow>[
                                                            if(members[index]['image_1920'] != '') const BoxShadow(
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
                                                                    members[index]['member_name'].toUpperCase(),
                                                                    style: GoogleFonts.secularOne(
                                                                      fontSize: size.height * 0.02,
                                                                      color: textColor,
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
                                                                members[index]['parish_name'] != null && members[index]['parish_name'] != '' ? Flexible(
                                                                  child: RichText(
                                                                    textAlign: TextAlign.left,
                                                                    text: TextSpan(
                                                                        text: members[index]['parish_name'],
                                                                        style: TextStyle(
                                                                          fontSize: size.height * 0.017,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.black87,
                                                                        ),
                                                                        children: members[index]['role_ids_view'] != null && members[index]['role_ids_view'] != '' ? [
                                                                          const TextSpan(
                                                                            text: '  ',
                                                                          ),
                                                                          TextSpan(
                                                                            text: '(${members[index]['role_ids_view']})',
                                                                            style: TextStyle(
                                                                                fontSize: size.height * 0.017,
                                                                                color: Colors.black45,
                                                                                fontStyle: FontStyle.italic
                                                                            ),
                                                                          ),
                                                                        ] : []
                                                                    ),
                                                                  ),
                                                                ) : members[index]['role_ids_view'] != null && members[index]['role_ids_view'] != '' ? Flexible(
                                                                  child: Text(
                                                                    members[index]['role_ids_view'],
                                                                    style: TextStyle(
                                                                      letterSpacing: 0.5,
                                                                      fontSize: size.height * 0.018,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.black54,
                                                                    ),
                                                                  ),
                                                                ) : Container(),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  (members[index]['mobile']).split(',')[0].trim(),
                                                                  style: TextStyle(
                                                                    fontSize: size.height * 0.018,
                                                                    color: Colors.blue,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                                      onPressed: () {
                                                                        (members[index]['mobile']).split(',').length != 1 ? showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              contentPadding: const EdgeInsets.all(10),
                                                                              content: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Column(
                                                                                    children: [
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (members[index]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          callAction((members[index]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (members[index]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          callAction((members[index]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : callAction((members[index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.phone),
                                                                      color: Colors.blueAccent,
                                                                    ),
                                                                    if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                                      onPressed: () {
                                                                        (members[index]['mobile']).split(',').length != 1 ? showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              contentPadding: const EdgeInsets.all(10),
                                                                              content: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Column(
                                                                                    children: [
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (members[index]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          smsAction((members[index]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (members[index]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          smsAction((members[index]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : smsAction((members[index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(Icons.message),
                                                                      color: Colors.orange,
                                                                    ),
                                                                    if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                                      onPressed: () {
                                                                        (members[index]['mobile']).split(',').length != 1 ? showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              contentPadding: const EdgeInsets.all(10),
                                                                              content: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Column(
                                                                                    children: [
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (members[index]['mobile']).split(',')[0].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                                                        },
                                                                                      ),
                                                                                      const Divider(),
                                                                                      ListTile(
                                                                                        title: Text(
                                                                                          (members[index]['mobile']).split(',')[1].trim(),
                                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                                        ),
                                                                                        onTap: () {
                                                                                          Navigator.pop(context); // Close the dialog
                                                                                          whatsappAction((members[index]['mobile']).split(',')[1].trim());
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ) : whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                                      },
                                                                      icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                      color: Colors.green,
                                                                    ),
                                                                  ],
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
                                            ),
                                            Positioned(
                                              bottom: size.height * 0.01,
                                              right: size.width * 0.025,
                                              child: Container(
                                                height: size.height * 0.03,
                                                width: size.width * 0.07,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: members[index]['membership_type_label'] == 'Diocesan' ? Colors.green : members[index]['membership_type_label'] == 'Lay Person' ? Colors.pinkAccent : Colors.indigo,
                                                ),
                                                child: members[index]['membership_type_label'] == 'Diocesan' ? Text('D',
                                                  style: GoogleFonts.heebo(
                                                      fontSize: size.height * 0.022,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ) : members[index]['membership_type_label'] == 'Lay Person' ? Text('L',
                                                  style: GoogleFonts.heebo(
                                                      fontSize: size.height * 0.022,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ) : Text('R',
                                                  style: GoogleFonts.heebo(
                                                      fontSize: size.height * 0.022,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ),
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
                    ),
                  ) : Expanded(
                    child: Column(
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
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
