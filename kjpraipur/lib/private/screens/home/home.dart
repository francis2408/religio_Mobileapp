import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/private/screens/authentication/login.dart';
import 'package:kjpraipur/private/screens/birthday/birthday.dart';
import 'package:kjpraipur/private/screens/circular/circular.dart';
import 'package:kjpraipur/private/screens/event/public_event.dart';
import 'package:kjpraipur/private/screens/house/house.dart';
import 'package:kjpraipur/private/screens/house/house_institution_list.dart';
import 'package:kjpraipur/private/screens/house/house_members_list.dart';
import 'package:kjpraipur/private/screens/institution/institution.dart';
import 'package:kjpraipur/private/screens/institution/institution_members_list.dart';
import 'package:kjpraipur/private/screens/member/member_list.dart';
import 'package:kjpraipur/private/screens/member/profile/member_profile_details.dart';
import 'package:kjpraipur/private/screens/news/news.dart';
import 'package:kjpraipur/private/screens/news/news_detail.dart';
import 'package:kjpraipur/private/screens/notification/notification_list.dart';
import 'package:kjpraipur/private/screens/obituary/obituary.dart';
import 'package:kjpraipur/private/screens/province/province_details.dart';
import 'package:kjpraipur/private/screens/province/province_house_list.dart';
import 'package:kjpraipur/private/screens/province/province_institution_list.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/helper/helper_function.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  final bool _canPop = false;
  bool load = true;
  int activeIndex = 0;
  int activeNewsIndex = 0;
  int indexValue = 0;
  final controller = CarouselController();
  bool _isLoading = true;
  bool _isNews = true;
  List image = [];
  String url = '';
  List newsData = [];
  List todayBirthday = [];
  List member = [];
  var headers;

  // Member Detail
  String memberName = '';
  String memberRole = '';
  String memberImage = '';
  String memberEmail = '';

  List imgList = [
    'assets/church/one.jpg',
    'assets/church/two.jpg',
    'assets/church/three.jpg',
    'assets/church/four.jpg',
    'assets/church/five.jpg',
  ];

  List newsList = [
    "Welcome to Society of the Catholic Apostolate.",
  ];

  getData() async {
    var pref = await SharedPreferences.getInstance();
    if(pref.containsKey('userAuthTokenKey')) {
      authToken = (pref.getString('userAuthTokenKey'))!;
    }

    if(pref.containsKey('userCongregationIdKey')) {
      userCongregationId = (pref.getInt('userCongregationIdKey'))!;
    }

    if(pref.containsKey('userProvinceIdKey')) {
      userProvinceId = (pref.getInt('userProvinceIdKey'))!;
    }

    if(pref.containsKey('userIdKey')) {
      userId = (pref.getInt('userIdKey'))!;
    }

    if(pref.containsKey('userIdsKey')) {
      userId = (pref.getString('userIdsKey'))!;
    }

    if(pref.containsKey('userNameKey')) {
      userName = (pref.getString('userNameKey'))!;
    }

    if(pref.containsKey('userRoleKey')) {
      userRole = (pref.getString('userRoleKey'))!;
    }

    if(pref.containsKey('userCommunityIdKey')) {
      userCommunityId = (pref.getInt('userCommunityIdKey'))!;
    }

    if(pref.containsKey('userCommunityIdsKey')) {
      userCommunityId = (pref.getString('userCommunityIdsKey'))!;
    }

    if(pref.containsKey('userInstituteIdKey')) {
      userInstituteId = (pref.getInt('userInstituteIdKey'))!;
    }

    if(pref.containsKey('userInstituteIdsKey')) {
      userInstituteId = (pref.getString('userInstituteIdsKey'))!;
    }

    if(pref.containsKey('userMemberIdKey')) {
      memberId = (pref.getInt('userMemberIdKey'))!;
    }

    if(pref.containsKey('userMemberIdsKey')) {
      memberId = (pref.getString('userMemberIdsKey'))!;
    }

    headers = {
      'Authorization': 'Bearer $authToken',
    };
    if(userRole == 'Religious Province') {
      url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('rel_province_id','=',$userProvinceId)]";
    } else if(userRole == 'House/Community') {
      url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('house_id','=',$userCommunityId)]";
    } else if(userRole == 'Institution') {
      url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('institution_id','=',$userCommunityId)]";
    } else {
      url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('house_id','=',$userCommunityId)]";
    }
    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      image = data;

      getMemberDetail();
      getNewsData();
      getTodayBirthdayData();
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
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

  userDeviceTokenDelete() async {
    String url = '$baseUrl/device/delete/token';
    Map data = {
      "params": {
        "token": "",
        "user_id": userId
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
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

  getMemberDetail() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['full_name','name','middle_name','image_1920','last_name','membership_type','display_roles','member_type','place_of_birth','unique_code','gender','dob','physical_status_id','diocese_id','parish_id','personal_mobile','personal_email','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','community_id','role_ids']"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      member = data;
      for(int i = 0; i < member.length; i++) {
        memberName = member[i]['full_name'];
        memberRole = member[i]['role_ids_name'];
        memberImage = member[i]['image_1920'];
        memberEmail = member[i]['email'];
      }
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

  getNewsData() async {
    var sharedNewsUrl = "$baseUrl/search_read/res.news?domain=[('rel_province_id','=',$userProvinceId),('type','=','Province'),('state','=','publish')]&fields=['name','state','description','date']&order=date desc";
    var request = http.Request('GET', Uri.parse(sharedNewsUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString())['data'];
      if (mounted) {
        setState(() {
          _isNews = false;
        });
      }
      newsData = data;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isNews = false;
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

  getTodayBirthdayData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_new_birthday_list?args=['$userProvinceId','today']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      todayBirthday = data;
      birthdayCount = todayBirthday.length.toString();
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
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

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
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
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmAlertDialog(
                message: 'Are you sure want to exit.',
                onYesPressed: () {
                  exit(0);
                },
                onCancelPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          );
          return false;
        }
      },
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: screenColor,
          appBar: AppBar(
            title: const Text(
              'KJP Raipur',
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                  )
              ),
            ),
            leading: IconButton(
              icon: SvgPicture.asset("assets/icons/menu.svg", color: Colors.white,),
              onPressed: () {
                setState(() {
                  // Check Internet connection
                  internetCheck();
                  _scaffoldKey.currentState?.openDrawer();
                });
              },
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25, width: 25,),
                onPressed: () {
                  // Navigator.of(context).push(CustomRoute(widget: const NotificationListScreen()));
                },
              )
            ],
          ),
          body: SafeArea(
            child: _isLoading
                ? Center(
              child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage( "assets/alert/spinner_1.gif"),
                    ),
                  )),
            ) : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.15,
                    padding: const EdgeInsets.symmetric(horizontal: 10,),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: size.width * 0.01,
                          right: size.width * 0.01,
                          child: Container(
                            height: size.height * 0.13,
                            width: size.width,
                            padding: const EdgeInsets.only(left: 0, top: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ',
                                        style: GoogleFonts.lobster(
                                            letterSpacing: 1,
                                            fontSize: size.height * 0.02,
                                            color: Colors.black
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: size.height * 0.003, left: size.width * 0.04, right: size.width * 0.17),
                                        child: Text(
                                          memberName,
                                          style: GoogleFonts.roboto(
                                              letterSpacing: 0.5,
                                              fontSize: size.height * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: textColor
                                          ),
                                        ),
                                      ),
                                      memberRole != '' && memberRole.isNotEmpty ? Flexible(
                                        child: Container(
                                          padding: EdgeInsets.only(top: size.height * 0.005, left: size.width * 0.04, right: size.width * 0.15),
                                          child: Text(memberRole, style: TextStyle(color: Colors.black54, fontSize: size.height * 0.017, fontWeight: FontWeight.w600),),
                                        ),
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.02,
                          right: size.width * 0.02,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                memberImage != '' ? showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Image.network(memberImage, fit: BoxFit.cover,),
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
                                height: size.height * 0.1,
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
                                    image: memberImage != ''
                                        ? NetworkImage(memberImage)
                                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      image.isNotEmpty ? CarouselSlider.builder(
                        carouselController: controller,
                        itemCount: image.length,
                        itemBuilder: (context, index, realIndex) {
                          final urlImage = image[index]['image_1920'];
                          return ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                            child: Image.network(urlImage, fit: BoxFit.fill, width: 1000.0),
                          );
                        },
                        options: CarouselOptions(
                          viewportFraction: 0.95,
                          aspectRatio: 2.0,
                          height: size.height * 0.19,
                          autoPlay: image.length > 1 ? true : false,
                          enableInfiniteScroll: image.length > 1 ? true : false,
                          autoPlayAnimationDuration: const Duration(seconds: 2),
                          enlargeCenterPage: true,
                          onPageChanged: ((index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          }),
                        ),
                      ) : CarouselSlider.builder(
                        carouselController: controller,
                        itemCount: imgList.length,
                        itemBuilder: (context, index, realIndex) {
                          final urlImage = imgList[index];
                          return ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                            child: Image.asset(urlImage, fit: BoxFit.fill, width: 1000.0),
                          );
                        },
                        options: CarouselOptions(
                          viewportFraction: 0.95,
                          aspectRatio: 2.0,
                          height: size.height * 0.19,
                          autoPlay: imgList.length > 1 ? true : false,
                          enableInfiniteScroll: imgList.length > 1 ? true : false,
                          autoPlayAnimationDuration: const Duration(seconds: 2),
                          enlargeCenterPage: true,
                          onPageChanged: ((index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          }),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: buildIndicator()
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  _isNews ? Container(
                      height: size.height * 0.1,
                      width: size.width * 0.2,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage( "assets/alert/spinner_1.gif"),
                        ),
                      )) : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: size.height * 0.06,
                          width: size.width * 0.15,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: Text('News',style: GoogleFonts.cantataOne(fontSize: size.height * 0.018, color: Colors.white),),
                          )
                      ),
                      Flexible(
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF3B4371),
                                  Color(0xFFF3904F),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: newsData.isNotEmpty ? CarouselSlider.builder(
                              carouselController: controller,
                              itemCount: newsData.length,
                              itemBuilder: (context, index, realIndex) {
                                final news = newsData[index]['name'];
                                return GestureDetector(
                                  onTap: () {
                                    newsID = newsData[index]['id'];
                                    Navigator.of(context).push(CustomRoute(widget: const NewsDetailScreen()));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    alignment: Alignment.center,
                                    child: Text(
                                      news,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.cantataOne(
                                        textStyle: const TextStyle(color: Colors.white),
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                viewportFraction: 0.95,
                                aspectRatio: 2.0,
                                height: size.height * 0.06,
                                autoPlay: true,
                                enableInfiniteScroll: newsData.length > 1 ? true : false,
                                autoPlayAnimationDuration: const Duration(seconds: 2),
                                enlargeCenterPage: true,
                                onPageChanged: ((index, reason) {
                                  setState(() {
                                    activeNewsIndex = index;
                                  });
                                }),
                              ),
                            ) : CarouselSlider.builder(
                              carouselController: controller,
                              itemCount: newsList.length,
                              itemBuilder: (context, index, realIndex) {
                                final news = newsList[index];
                                return Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  alignment: Alignment.center,
                                  child: Text(
                                    news,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.cantataOne(
                                      textStyle: const TextStyle(color: Colors.white),
                                      fontSize: size.height * 0.018,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                viewportFraction: 0.95,
                                aspectRatio: 2.0,
                                height: size.height * 0.06,
                                autoPlay: true,
                                enableInfiniteScroll: newsList.length > 1 ? true : false,
                                autoPlayAnimationDuration: const Duration(seconds: 2),
                                enlargeCenterPage: true,
                                onPageChanged: ((index, reason) {
                                  setState(() {
                                    activeNewsIndex = index;
                                  });
                                }),
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const MemberProfileTabbarScreen()));
                              });
                            },
                            icon: 'assets/icons/profile.svg',
                            title: "Profile",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const ProvinceDetailsScreen()));
                              });
                            },
                            icon: 'assets/icons/church.svg',
                            title: "Province",
                            homeIconColor: Colors.white,
                            homeIconSize: 40,
                          ),
                          userRole == 'Religious Province' ? HomeCard(
                            onPressed: () {
                              house = 'House';
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const ProvinceHouseListScreen()));
                              });
                            },
                            icon: 'assets/icons/house.svg',
                            title: "House",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ) : HomeCard(
                            onPressed: () {
                              house = 'House';
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const HouseScreen()));
                              });
                            },
                            icon: 'assets/icons/house.svg',
                            title: "House",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          userRole == 'Religious Province' ? HomeCard(
                            onPressed: () {
                              institution = 'Institution';
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const ProvinceInstitutionListScreen()));
                              });
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ) : userRole == 'House/Community' ? HomeCard(
                            onPressed: () {
                              institution = 'Institution';
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const HouseInstitutionListScreen()));
                              });
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ) : HomeCard(
                            onPressed: () {
                              institution = 'Institution';
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const InstitutionScreen()));
                              });
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          userRole == 'Institution' ? HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const InstitutionMembersListScreen()));
                              });
                            },
                            icon: 'assets/icons/members.svg',
                            title: "Members",
                            homeIconColor: Colors.white,
                            homeIconSize: 40,
                          ) : userRole == 'House/Community' ? HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const HouseMembersListScreen()));
                              });
                            },
                            icon: 'assets/icons/members.svg',
                            title: "Members",
                            homeIconColor: Colors.white,
                            homeIconSize: 40,
                          ) : HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const MembersListScreen()));
                              });
                            },
                            icon: 'assets/icons/members.svg',
                            title: "Members",
                            homeIconColor: Colors.white,
                            homeIconSize: 40,
                          ),
                          birthdayCount != '0' && birthdayCount != '' ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () {
                                  setState(() {
                                    Navigator.of(context).push(CustomRoute(widget: const BirthdayScreen()));
                                  });
                                },
                                icon: 'assets/icons/birthday.svg',
                                title: "Birthday",
                                homeIconColor: Colors.white,
                                homeIconSize: 35,
                              ),
                              Positioned(
                                top: 0,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    birthdayCount,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ) : HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const BirthdayScreen()));
                              });
                            },
                            icon: 'assets/icons/birthday.svg',
                            title: "Birthday",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const PublicEventScreen()));
                              });
                            },
                            icon: 'assets/icons/calendar.svg',
                            title: "Event",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const NewsScreen()));
                              });
                            },
                            icon: 'assets/icons/news_paper.svg',
                            title: "News",
                            homeIconColor: Colors.white,
                            homeIconSize: 32,
                          ),
                          HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const ObituaryScreen()));
                              });
                            },
                            icon: 'assets/icons/rip.svg',
                            title: "Obituary",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          notificationCount != 0 && notificationCount != null ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () {
                                  setState(() {
                                    Navigator.of(context).push(CustomRoute(widget: const NotificationListScreen()));
                                  });
                                },
                                icon: 'assets/icons/notification.svg',
                                title: "Notification",
                                homeIconColor: Colors.white,
                                homeIconSize: 35,
                              ),
                              Positioned(
                                top: 0,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    notificationCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ) : HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const NotificationListScreen()));
                              });
                            },
                            icon: 'assets/icons/notification.svg',
                            title: "Notification",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                          HomeCard(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(CustomRoute(widget: const CircularScreen()));
                              });
                            },
                            icon: 'assets/icons/info.svg',
                            title: "Circular",
                            homeIconColor: Colors.white,
                            homeIconSize: 35,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(memberName, style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                  accountEmail: Text(memberEmail, style: TextStyle(fontSize: size.height * 0.016, fontWeight: FontWeight.bold),),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: memberImage.isNotEmpty ? Image.network(
                          memberImage,
                          height: size.height * 0.08,
                          width: size.width * 0.18,
                          fit: BoxFit.cover
                      ) : Image.asset(
                        'assets/images/profile.png',
                        height: size.height * 0.08,
                        width: size.width * 0.18,
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/nav.jpg',
                          ),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, size: size.height * 0.03, color: Colors.red,),
                  title: Text('Exit', style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmAlertDialog(
                          message: 'Are you sure want to exit.',
                          onYesPressed: () {
                            exit(0);
                          },
                          onCancelPressed: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.power_settings_new, size: size.height * 0.03, color: Colors.red,),
                  title: Text('Logout', style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmAlertDialog(
                          message: 'Are you sure you want to logout?',
                          onCancelPressed: () {
                            // Cancel button logic
                            Navigator.of(context).pop();
                          },
                          onYesPressed: () async {
                            if(load) {
                              userDeviceTokenDelete();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.remove('userLoggedInkey');
                              await prefs.remove('userAuthTokenKey');
                              await prefs.remove('userIdKey');
                              await prefs.remove('userIdsKey');
                              await prefs.remove('userCongregationIdKey');
                              await prefs.remove('userProvinceIdKey');
                              await prefs.remove('userNameKey');
                              await prefs.remove('userRoleKey');
                              await prefs.remove('userCommunityIdKey');
                              await prefs.remove('userCommunityIdsKey');
                              await prefs.remove('userInstituteIdKey');
                              await prefs.remove('userInstituteIdsKey');
                              await prefs.remove('userMemberIdKey');
                              await prefs.remove('userMemberIdsKey');
                              await HelperFunctions.setUserLoginSF(false);
                              await Future.delayed(const Duration(seconds: 1));
                              setState(() {
                                load = false; // Set loading flag to false
                              });
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                              _flush();
                            }
                          },
                        );
                      },
                    );
                  },
                )
              ],
            ),
          )
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animateToSlide,
    effect: const ExpandingDotsEffect(
      dotHeight: 5,
      dotWidth: 5,
      activeDotColor: backgroundColor,
    ),
    activeIndex: activeIndex,
    count: image.isNotEmpty ? image.length : imgList.length,
  );

  void animateToSlide(int index) => controller.animateToPage(index);

  Widget buildTextIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animatedToSlide,
    effect: const ExpandingDotsEffect(
        dotHeight: 3,
        dotWidth: 3,
        activeDotColor: Colors.white
    ),
    activeIndex: activeNewsIndex,
    count: newsData.isNotEmpty ? newsData.length : newsList.length,
  );

  void animatedToSlide(int index) => controller.animateToPage(index);
}

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
        required this.onPressed,
        required this.icon,
        required this.title,
        required this.homeIconColor,
        required this.homeIconSize,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
  final Color homeIconColor;
  final double homeIconSize;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: size.height / 9,
        width: size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.07,
              width: size.width * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    menuPrimaryColor,
                    menuPrimaryColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),),
              child: Center(
                  child: IconButton(
                    icon: SvgPicture.asset(icon, color: Color(0xFFD7DBE4),),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            // SizedBox(height: size.height * 0.005,),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                // letterSpacing: 1,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.017
              ),
            ),
          ],
        ),
      ),
    );
  }
}