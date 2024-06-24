import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObituaryScreen extends StatefulWidget {
  const ObituaryScreen({Key? key}) : super(key: key);

  @override
  State<ObituaryScreen> createState() => _ObituaryScreenState();
}

class _ObituaryScreenState extends State<ObituaryScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  bool _isToday = false;
  List data = [];
  List deathData = [];
  List deathListData = [];
  String today = '';
  String formattedDate = '';
  var searchController = TextEditingController();

  getObituaryData() async {
    String url = '$baseUrl/res.member/get_obituary_list';
    Map datas = {
      "params": {}
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
      var result = json.decode(response.body)['result']['result'];
      today = result['today'];
      if(obituaryTab == 'Upcoming') {
        data = result['obituary_results'];
      } else {
        data = result['all_obituary'];
      }
      setState(() {
        _isLoading = false;
      });
      deathData = data;
      for(int i = 0; i < deathData.length; i++) {
        DateTime dateTime = DateTime.parse(deathData[i]['death_date']);
        formattedDate = DateFormat('d - MMMM').format(dateTime);
        if(today == formattedDate) {
          _isToday = true;
        }
      }
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

    setState(() {
      deathData = results;
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
      getObituaryData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getObituaryData();
          });
        });
      } else {
        clearSharedPreferenceData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Center(
            child: _isLoading ? SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ) : Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
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
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                deathData.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 3,),
                    Text('${deathData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 5,),
                  ],
                ) : Container(),
                obituaryTab == 'Upcoming' ? deathData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if(_isToday) Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  // decoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(20),
                                  // ),
                                  child: Text(
                                    'In Fond Memory',
                                    style: GoogleFonts.pacifico(
                                      color: Colors.indigo,
                                      fontSize: size.height * 0.026,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height:  size.height * 0.01,),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: deathData.length,
                              itemBuilder: (BuildContext context, int index) {
                                DateTime dateTime = DateTime.parse(deathData[index]['death_date']);
                                formattedDate = DateFormat('d - MMMM').format(dateTime);
                                if(today == formattedDate) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Container(
                                          padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          deathData[index]['img_data'] != '' ? showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return Dialog(
                                                                child: Image.network(deathData[index]['img_data'], fit: BoxFit.cover,),
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
                                                              if(deathData[index]['img_data'] != '')const BoxShadow(
                                                                color: Colors.grey,
                                                                spreadRadius: -1,
                                                                blurRadius: 5 ,
                                                                offset: Offset(0, 1),
                                                              ),
                                                            ],
                                                            shape: BoxShape.rectangle,
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: deathData[index]['img_data'] != null && deathData[index]['img_data'] != ''
                                                                  ? NetworkImage(deathData[index]['img_data'])
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
                                                                      deathData[index]['name'].toUpperCase(),
                                                                      style: GoogleFonts.secularOne(
                                                                        fontSize: size.height * 0.02,
                                                                        color: textColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: size.height * 0.01,
                                                              ),
                                                              deathData[index]['dob'] != null && deathData[index]['dob'] != '' ? Row(
                                                                children: [
                                                                  Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['dob'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                                  SizedBox(width: size.width * 0.02,),
                                                                  Text('-', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                                  SizedBox(width: size.width * 0.02,),
                                                                  Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['death_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                                ],
                                                              ) : Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['death_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: size.height * 0.001,
                                                  right: size.width * 0.001,
                                                  child: Center(
                                                    child: Container(
                                                      height: size.height * 0.08,
                                                      width: size.width * 0.15,
                                                      decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage( "assets/images/death.png"),
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
                                    ),
                                  );
                                } else {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: SizedBox(
                                            height: 90,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: size.width * 0.03,
                                                  ),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(20),
                                                    child: CircleAvatar(
                                                      child: ClipOval(
                                                        child: deathData[index]['img_data'] != null && deathData[index]['img_data'] != '' ? Image.network(
                                                            deathData[index]['img_data'],
                                                            height: size.height * 0.15,
                                                            width: size.width * 0.2,
                                                            fit: BoxFit.cover
                                                        ) : Image.asset(
                                                          'assets/images/profile.png',
                                                          height: size.height * 0.15,
                                                          width: size.width * 0.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 10, right: 5, left: 20),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                deathData[index]['name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.02,
                                                                  // fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          deathData[index]['dob'] != null && deathData[index]['dob'] != '' ? Row(
                                                            children: [
                                                              Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['dob'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                              SizedBox(width: size.width * 0.02,),
                                                              Text('-', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                              SizedBox(width: size.width * 0.02,),
                                                              Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['death_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                            ],
                                                          ) : Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['death_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
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
                ) : deathData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: deathData.length,
                              itemBuilder: (BuildContext context, int index) {
                                DateTime dateTime = DateTime.parse(deathData[index]['death_date']);
                                formattedDate = DateFormat('d - MMMM').format(dateTime);
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: SizedBox(
                                          height: 90,
                                          child: Stack(
                                            children: [
                                              Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.03,
                                                    ),
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(20),
                                                      child: CircleAvatar(
                                                        child: ClipOval(
                                                          child: deathData[index]['img_data'] != null && deathData[index]['img_data'] != '' ? Image.network(
                                                              deathData[index]['img_data'],
                                                              height: size.height * 0.15,
                                                              width: size.width * 0.2,
                                                              fit: BoxFit.cover
                                                          ) : Image.asset(
                                                            'assets/images/profile.png',
                                                            height: size.height * 0.15,
                                                            width: size.width * 0.2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.only(top: 10, right: 5, left: 20),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  deathData[index]['name'],
                                                                  style: GoogleFonts.secularOne(
                                                                    fontSize: size.height * 0.02,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            deathData[index]['dob'] != null && deathData[index]['dob'] != '' ? Row(
                                                              children: [
                                                                Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['dob'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                                SizedBox(width: size.width * 0.02,),
                                                                Text('-', style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                                SizedBox(width: size.width * 0.02,),
                                                                Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['death_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                              ],
                                                            ) : Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deathData[index]['death_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if(today == formattedDate) Positioned(
                                                bottom: size.height * 0.01,
                                                right: size.width * 0.01,
                                                child: Center(
                                                  child: Container(
                                                    height: size.height * 0.06,
                                                    width: size.width * 0.15,
                                                    decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage( "assets/images/death.png"),
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
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
        ),
      ),
    );
  }
}
