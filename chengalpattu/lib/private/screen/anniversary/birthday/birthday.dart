import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  List data = [];
  List birthday = [];
  String today = '';
  var searchController = TextEditingController();

  getBirthdayData() async {
    String url = '$baseUrl/res.member/get_birthday_list';
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
      if(birthdayTab == 'Upcoming') {
        data = result['b_result'];
      } else {
        data = result['all_birthdays'];
      }
      setState(() {
        _isLoading = false;
      });
      birthday = data;
    }
    else {
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
      birthday = results;
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
      getBirthdayData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getBirthdayData();
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
                birthday.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 3,),
                    Text('${birthday.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 5,),
                  ],
                ) : Container(),
                birthday.isNotEmpty ? SizedBox(
                  height: size.height * 0.01,
                ) : Container(),
                birthdayTab == 'Upcoming' ? birthday.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: birthday.length,
                          itemBuilder: (BuildContext context, int index) {
                            if(today == birthday[index]['birthday']) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Container(
                                      padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: size.height * 0.13,
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double innerHeight = constraints.maxHeight;
                                                double innerWidth = constraints.maxWidth;
                                                return Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Container(
                                                        padding: const EdgeInsets.only(left: 5, right: 5,),
                                                        height: innerHeight * 0.95,
                                                        width: innerWidth,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15),
                                                          color: Colors.white,
                                                        ),
                                                        child: Container(
                                                          padding: EdgeInsets.only(left: size.width * 0.25,),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                birthday[index]['name'],
                                                                style: TextStyle(
                                                                    fontSize: size.height * 0.019,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.indigo
                                                                ),
                                                                textAlign: TextAlign.left,
                                                              ),
                                                              const SizedBox(height: 2,),
                                                              Text(
                                                                birthday[index]['birthday'],
                                                                style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.grey),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      birthday[index]['mobile'],
                                                                      style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.blue),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      birthday[index]['mobile'] != null && birthday[index]['mobile'] != '' ? IconButton(
                                                                        onPressed: () {
                                                                          callAction(birthday[index]['mobile']);
                                                                        },
                                                                        icon: const Icon(Icons.phone),
                                                                        color: Colors.blueAccent,
                                                                      ) : Container(),
                                                                      birthday[index]['mobile'] != null && birthday[index]['mobile'] != '' ? IconButton(
                                                                        onPressed: () {
                                                                          smsAction(birthday[index]['mobile']);
                                                                        },
                                                                        icon: const Icon(Icons.message),
                                                                        color: Colors.orange,
                                                                      ) : Container(),
                                                                      birthday[index]['mobile'] != null && birthday[index]['mobile'] != '' ? IconButton(
                                                                        onPressed: () {
                                                                          whatsappAction(birthday[index]['mobile']);
                                                                        },
                                                                        icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                        color: Colors.green,
                                                                      ) : Container(),
                                                                    ],
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: size.height * 0.018,
                                                      right: size.width * 0.04,
                                                      child: Center(
                                                        child: Container(
                                                          height: size.height * 0.08,
                                                          width: size.width * 0.18,
                                                          decoration: const BoxDecoration(
                                                            image: DecorationImage(
                                                              image: AssetImage( "assets/images/happy-birthday.gif"),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: size.height * 0.02,
                                                      left: size.width * 0.03,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          birthday[index]['img_data'] != '' ? showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return Dialog(
                                                                child: Image.network(birthday[index]['img_data'], fit: BoxFit.cover,),
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
                                                        child: SizedBox(
                                                          height: size.height * 0.1,
                                                          width: size.width * 0.2,
                                                          child: CircleAvatar(
                                                            child: ClipOval(
                                                              child: birthday[index]['img_data'] != null && birthday[index]['img_data'] != '' ? Image.network(
                                                                  birthday[index]['img_data'],
                                                                  height: size.height * 0.1,
                                                                  width: size.width * 0.2,
                                                                  fit: BoxFit.cover
                                                              ) : Image.asset(
                                                                'assets/images/profile.png',
                                                                height: size.height * 0.15,
                                                                width: size.width * 0.32,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10,)
                                        ],
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
                                        height: 80,
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
                                                    child: birthday[index]['img_data'] != null && birthday[index]['img_data'] != '' ? Image.network(
                                                        birthday[index]['img_data'],
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
                                                            birthday[index]['name'],
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
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "${birthday[index]['birthday']}",
                                                            style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.018, color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
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
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                      child: SizedBox(
                        height: 50,
                        width: 180,
                        child: textButton,
                      ),
                    ),
                  ),
                ) : birthday.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: birthday.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: SizedBox(
                                      height: 80,
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
                                                      child: birthday[index]['img_data'] != null && birthday[index]['img_data'] != '' ? Image.network(
                                                          birthday[index]['img_data'],
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
                                                              birthday[index]['name'],
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
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "${birthday[index]['birthday']}",
                                                              style: GoogleFonts.reemKufi(fontWeight: FontWeight.bold, fontSize: size.height * 0.018, color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
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
                                          if(today == birthday[index]['birthday']) Positioned(
                                            bottom: size.height * 0.01,
                                            right: size.width * 0.01,
                                            child: Center(
                                              child: Container(
                                                height: size.height * 0.05,
                                                width: size.width * 0.1,
                                                decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage( "assets/images/celebration.png"),
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
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                      child: SizedBox(
                        height: 50,
                        width: 180,
                        child: textButton,
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
