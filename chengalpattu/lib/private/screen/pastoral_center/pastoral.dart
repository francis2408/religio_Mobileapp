import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PastoralCenterScreen extends StatefulWidget {
  const PastoralCenterScreen({Key? key}) : super(key: key);

  @override
  State<PastoralCenterScreen> createState() => _PastoralCenterScreenState();
}

class _PastoralCenterScreenState extends State<PastoralCenterScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  DateTime currentDateTime = DateTime.now();
  bool _isLoading = true;
  bool _isMember = false;

  List pastoral = ['Commissions'];
  List pastoralCategory = [];
  List pastoralSubCategory = [];

  int selected = -1;
  int selected2 = -1;
  int selected3 = -1;
  bool isCategoryExpanded = false;
  bool isSubCategoryExpanded = false;

  getPastoralData() async {
    String url = '$baseUrl/member.commission';
    Map datas = {
      "params": {
        "order": "sequence, name asc",
        "filter": "[['category','=','Commission'],['commission_member_ids.status','=','Active']]",
        "query": "{id,name,commission_member_ids{member_id{id,image_512,member_name,mobile},role_id,status}}"
      }
    };
    var body = jsonEncode(datas);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      pastoralCategory = data;
    } else {
      final message = json.decode(response.body)['result'];
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
  }

  getSubCategory() {
    if(pastoralCategory.isNotEmpty) {
      setState(() {
        _isMember = false;
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
          if (value) {
            return null;
          } else {
            showDialogBox();
          }
        });
      },
      width: 100.0,
    );
  }

  _authTokenExpire() {
    AnimatedSnackBar.material(
        'Your session was expired; please login again.',
        type: AnimatedSnackBarType.info,
        duration: const Duration(seconds: 10)
    ).show(context);
  }

  clearSharedPreferenceData() async {
    // Deleting shared-preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAuthTokenKey');
    await prefs.remove('userTokenExpires');
    await prefs.remove('userIdKey');
    await prefs.remove('userNameKey');
    await prefs.remove('userEmailKey');
    await prefs.remove('userImageKey');
    await prefs.remove('userDioceseKey');
    await prefs.remove('userMemberKey');
    await HelperFunctions.setUserLoginSF(false);
    authToken = '';
    tokenExpire = '';
    userID = '';
    userName = '';
    userEmail = '';
    userImage = '';
    userLevel = '';
    userDiocese = '';
    userMember = '';
    await Future.delayed(const Duration(seconds: 1));

    Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
    _authTokenExpire();
  }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getPastoralData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getPastoralData();
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
        title: const Text('Pastoral Center'),
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
              setState(() {
                selected = -1;
                selected2 = -1;
                selected3 = -1;
                _isLoading = true;
                getPastoralData();
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading ? SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pastoral.length, // Update the itemCount to 2 for two expansion tiles
                          itemBuilder: (BuildContext context, int index) {
                            final isTileExpanded = index == selected;
                            final textExpandColor = isTileExpanded ? textColor : Colors.white;
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: ScaleAnimation(
                                  child: Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 10),
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Dialog(
                                                            child: Image.asset('assets/others/image.jpg', fit: BoxFit.cover,),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      height: size.height * 0.15,
                                                      width: size.width * 0.25,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: const <BoxShadow>[
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            spreadRadius: -1,
                                                            blurRadius: 5 ,
                                                            offset: Offset(0, 1),
                                                          ),
                                                        ],
                                                        shape: BoxShape.rectangle,
                                                        image: const DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage('assets/images/image.jpg'),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  Flexible(
                                                    child: Text.rich(
                                                      textAlign: TextAlign.left,
                                                      TextSpan(
                                                          text: 'Rev.Fr.I.Yesu Antony',
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.018,
                                                            color: Colors.black87,
                                                          ),
                                                          children: [
                                                            const TextSpan(
                                                              text: '  ',
                                                            ),
                                                            TextSpan(
                                                                text: '(Director, Pastoral Center)',
                                                              style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.018,
                                                                  color: Colors.black45,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Phone', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                  contentPadding: const EdgeInsets.all(10),
                                                                  content: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed: () {
                                                                          showDialog(
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
                                                                                          title: const Text(
                                                                                            '044 – 274 93 341',
                                                                                            style: TextStyle(color: Colors.blueAccent),
                                                                                          ),
                                                                                          onTap: () {
                                                                                            Navigator.pop(context); // Close the dialog
                                                                                            callAction('044 – 274 93 341');
                                                                                          },
                                                                                        ),
                                                                                        const Divider(),
                                                                                        ListTile(
                                                                                          title: const Text(
                                                                                            '044 – 274 28 233',
                                                                                            style: TextStyle(color: Colors.blueAccent),
                                                                                          ),
                                                                                          onTap: () {
                                                                                            Navigator.pop(context); // Close the dialog
                                                                                            callAction('044 – 274 28 233');
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                        icon: const Icon(Icons.phone),
                                                                        color: Colors.blueAccent,
                                                                      ),
                                                                    ],
                                                                  )
                                                              );
                                                            }
                                                        );
                                                      },
                                                      child: Text('044 – 274 93 341', style: GoogleFonts.secularOne(color: Colors.blueAccent, fontSize: size.height * 0.02),)
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Email', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                  contentPadding: const EdgeInsets.all(10),
                                                                  content: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed: () {
                                                                          showDialog(
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
                                                                                          title: const Text(
                                                                                            'pastoralsolidarity@gmail.com',
                                                                                            style: TextStyle(color: Colors.redAccent),
                                                                                          ),
                                                                                          onTap: () {
                                                                                            Navigator.pop(context); // Close the dialog
                                                                                            emailAction('pastoralsolidarity@gmail.com');
                                                                                          },
                                                                                        ),
                                                                                        const Divider(),
                                                                                        ListTile(
                                                                                          title: const Text(
                                                                                            'letsserveourpeople@gmail.com',
                                                                                            style: TextStyle(color: Colors.redAccent),
                                                                                          ),
                                                                                          onTap: () {
                                                                                            Navigator.pop(context); // Close the dialog
                                                                                            emailAction('letsserveourpeople@gmail.com');
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                        icon: const Icon(Icons.email),
                                                                        color: Colors.redAccent,
                                                                      ),
                                                                    ],
                                                                  )
                                                              );
                                                            }
                                                        );
                                                      },
                                                      child: Text('pastoralsolidarity@gmail.com', style: GoogleFonts.secularOne(color: Colors.redAccent, fontSize: size.height * 0.02),)
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.015,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                  SizedBox(width: size.width * 0.02,),
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Pastoral Centre,", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                        Text("Bishop's House Campus,", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                        Text("Chingleput,", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                        Text("Tamil Nadu,", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                        Row(
                                                          children: [
                                                            Text("India", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                            Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                            Text(" 603 101.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFED8F03), Color(0xFFFFB75E),],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(15.0)
                                          ),
                                          child: ExpansionTile(
                                            key: Key(index.toString()),// Use the generated GlobalKey for each expansion tile
                                            initiallyExpanded: index == selected,
                                            backgroundColor: Colors.white,
                                            iconColor: iconColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            onExpansionChanged: (newState) {
                                              if (newState) {
                                                setState(() {
                                                  selected = index;
                                                  selected2 = -1;
                                                  selected3 = -1;
                                                  isCategoryExpanded = true;
                                                });
                                              } else {
                                                setState(() {
                                                  selected = -1;
                                                  isCategoryExpanded = false;
                                                });
                                              }
                                            },
                                            title: Container(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text(
                                                '${pastoral[index]}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.022,
                                                  color: textExpandColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            children: [
                                              pastoralCategory.isNotEmpty ? ListView.builder(
                                                key: Key('builder ${selected2.toString()}'),
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: isCategoryExpanded ? pastoralCategory.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                itemBuilder: (BuildContext context, int indexs) {
                                                  final isTileExpanded = indexs == selected2;
                                                  final subTextExpandColor = isTileExpanded ? noDataColor : Colors.blueAccent;
                                                  return Column(
                                                    children: [
                                                      ExpansionTile(
                                                        key: Key(indexs.toString()),// Use the generated GlobalKey for each expansion tile
                                                        initiallyExpanded: indexs == selected2,
                                                        iconColor: noDataColor,
                                                        onExpansionChanged: (newState) {
                                                          if (newState) {
                                                            setState(() {
                                                              selected2 = indexs;
                                                              selected3 = -1;
                                                              pastoralSubCategory = pastoralCategory[indexs]['commission_member_ids'];
                                                              isSubCategoryExpanded = true;
                                                              _isMember = true;
                                                              getSubCategory();
                                                            });
                                                          } else {
                                                            setState(() {
                                                              selected2 = -1;
                                                              _isMember = true;
                                                            });
                                                          }
                                                        },
                                                        title: Container(
                                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Text(
                                                            "${pastoralCategory[indexs]['name']}",
                                                            style: GoogleFonts.signika(
                                                              fontSize: size.height * 0.02,
                                                              color: subTextExpandColor,
                                                            ),
                                                          ),
                                                        ),
                                                        children: [
                                                          _isMember ? Center(
                                                            child: SizedBox(
                                                              height: size.height * 0.06,
                                                              child: const LoadingIndicator(
                                                                indicatorType: Indicator.ballPulse,
                                                                colors: [Colors.red,Colors.orange,Colors.yellow],
                                                              ),
                                                            ),
                                                          ) : pastoralSubCategory.isNotEmpty ? ListView.builder(
                                                            key: Key('builder ${selected3.toString()}'),
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemCount: isSubCategoryExpanded ? pastoralSubCategory.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Column(
                                                                children: [
                                                                  if(pastoralSubCategory[index]['status'] == 'Active') Container(
                                                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height: size.height * 0.11,
                                                                          width: size.width * 0.18,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            boxShadow: const <BoxShadow>[
                                                                              BoxShadow(
                                                                                color: Colors.grey,
                                                                                spreadRadius: -1,
                                                                                blurRadius: 5 ,
                                                                                offset: Offset(0, 1),
                                                                              ),
                                                                            ],
                                                                            shape: BoxShape.rectangle,
                                                                            image: DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: pastoralSubCategory[index]['member_id']['image_512'] != null && pastoralSubCategory[index]['member_id']['image_512'] != '' ? NetworkImage(pastoralSubCategory[index]['member_id']['image_512'])
                                                                                  : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: Container(
                                                                            padding: const EdgeInsets.only(left: 15, right: 10),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        pastoralSubCategory[index]['member_id']['member_name'],
                                                                                        style: GoogleFonts.secularOne(
                                                                                          fontSize: size.height * 0.022,
                                                                                          color: textColor,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      pastoralSubCategory[index]['role_id']['name'],
                                                                                      style: GoogleFonts.reemKufi(
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: size.height * 0.02,
                                                                                        color: Colors.black54,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      (pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                      style: TextStyle(
                                                                                        fontSize: size.height * 0.02,
                                                                                        color: Colors.blue,
                                                                                      ),
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        if (pastoralSubCategory[index]['member_id']['mobile'] != null && pastoralSubCategory[index]['member_id']['mobile'] != '') IconButton(
                                                                                          onPressed: () {
                                                                                            (pastoralSubCategory[index]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                              (pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              callAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                          const Divider(),
                                                                                                          ListTile(
                                                                                                            title: Text(
                                                                                                              (pastoralSubCategory[index]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              callAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[1].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ) : callAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                          },
                                                                                          icon: const Icon(Icons.phone),
                                                                                          color: Colors.blueAccent,
                                                                                        ),
                                                                                        if (pastoralSubCategory[index]['member_id']['mobile'] != null && pastoralSubCategory[index]['member_id']['mobile'] != '') IconButton(
                                                                                          onPressed: () {
                                                                                            (pastoralSubCategory[index]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                              (pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              smsAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                          const Divider(),
                                                                                                          ListTile(
                                                                                                            title: Text(
                                                                                                              (pastoralSubCategory[index]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              smsAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[1].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ) : smsAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                          },
                                                                                          icon: const Icon(Icons.message),
                                                                                          color: Colors.orange,
                                                                                        ),
                                                                                        if (pastoralSubCategory[index]['member_id']['mobile'] != null && pastoralSubCategory[index]['member_id']['mobile'] != '') IconButton(
                                                                                          onPressed: () {
                                                                                            (pastoralSubCategory[index]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                              (pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              whatsappAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                          const Divider(),
                                                                                                          ListTile(
                                                                                                            title: Text(
                                                                                                              (pastoralSubCategory[index]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              whatsappAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[1].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ) : whatsappAction((pastoralSubCategory[index]['member_id']['mobile']).split(',')[0].trim());
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
                                                                  if(pastoralSubCategory[index]['status'] == 'Active') if(index < pastoralSubCategory.length - 1) const Divider(
                                                                    thickness: 2,
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ) : Center(
                                                            child: Container(
                                                              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                                                              child: SizedBox(
                                                                height: 50,
                                                                width: 180,
                                                                child: textButton,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ) : Center(
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                                                  child: SizedBox(
                                                    height: 50,
                                                    width: 180,
                                                    child: textButton,
                                                  ),
                                                ),
                                              )
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
