import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:scb/private/screens/account/about.dart';
import 'package:scb/private/screens/authentication/change_password.dart';
import 'package:scb/private/screens/celebration/celebration_tab.dart';
import 'package:scb/private/screens/circular&news_letter/circular_and_newsletter_tab.dart';
import 'package:scb/private/screens/commission/commission.dart';
import 'package:scb/private/screens/event/event.dart';
import 'package:scb/private/screens/house/house.dart';
import 'package:scb/private/screens/house/house_institution_list.dart';
import 'package:scb/private/screens/institution/institution.dart';
import 'package:scb/private/screens/institution/institution_members_list.dart';
import 'package:scb/private/screens/member/member_tab.dart';
import 'package:scb/private/screens/member/members_details.dart';
import 'package:scb/private/screens/member/profile/member_profile_details.dart';
import 'package:scb/private/screens/news/news.dart';
import 'package:scb/private/screens/news/news_detail.dart';
import 'package:scb/private/screens/notification/notification_list.dart';
import 'package:scb/private/screens/obituary/obituary_tab.dart';
import 'package:scb/private/screens/province/province_details.dart';
import 'package:scb/private/screens/province/province_house_list.dart';
import 'package:scb/private/screens/province/province_institution_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scb/private/screens/authentication/login.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/snackbar.dart';
import 'package:scb/widget/helper_function/helper_function.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  final ProvinceBannerImage provinceBannerImage = ProvinceBannerImage();
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
  List todayFeastday = [];
  List todayDeath = [];
  List member = [];
  var headers;
  int total = 0;

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
    "Welcome to Eastern province of the sisters of st. charles borromeo.",
  ];

  getData() async {
    var pref = await SharedPreferences.getInstance();
    if(pref.containsKey('setName')) {
      loginName = (pref.getString('setName'))!;
    }

    if(pref.containsKey('setPassword')) {
      loginPassword = (pref.getString('setPassword'))!;
    }

    if(pref.containsKey('userRememberKey')) {
      remember = (pref.getBool('userRememberKey'))!;
    }

    if(pref.containsKey('userTokenExpires')) {
      tokenExpire = (pref.getString('userTokenExpires'))!;
    }

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

    expiryDateTime = DateTime.parse(tokenExpire);

    headers = {
      'Authorization': 'Bearer $authToken',
    };

    if(expiryDateTime!.isAfter(currentDateTime)) {
      provinceBannerImage.runby(context);
      if(userRole == 'Religious Province') {
        url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('rel_province_id','=',$userProvinceId)]";
      } else if(userRole == 'House/Community') {
        url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('house_id','=',$userCommunityId)]";
      } else if(userRole == 'Institution') {
        url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('institution_id','=',$userInstituteId)]";
      } else {
        url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('rel_province_id','=',$userProvinceId)]";
      }
      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List data = json.decode(await response.stream.bytesToString())['data'];
        image = data;

        getNewsAndBirthdayData();
        getTodayBirthdayData();
        getTodayFeastData();
        getDeathMembersData();
        getUnreadNotificationCount();
        getMemberDetail();
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
    } else {
      if(remember == true) {
        setState(() {
          loginService.login(context, loginName, loginPassword, databaseName, callback: () {
            setState(() {
              getData();
            });
          });
        });
      } else {
        setState(() {
          shared.clearSharedPreferenceData(context);
        });
      }
    }
  }

  userDeviceTokenDelete() async {
    String url = '$baseUrl/device/delete/token';
    Map data = {
      "params": {
        "token": deviceToken,
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
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['full_name','name','middle_name','image_512','last_name','membership_type','display_roles','member_type','place_of_birth','unique_code','gender','dob','physical_status_id','diocese_id','parish_id','personal_mobile','personal_email','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','community_id','role_ids']&context={"bypass":1}"""));
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
        memberImage = member[i]['image_512'];
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

  getNewsAndBirthdayData() async {
    var sharedNewsUrl = "$baseUrl/call/res.member/api_get_news_birthday_data";
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
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_birthday_details_v1?args=['$userProvinceId']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      String today = result['data']['today'];
      List data = result['data']['next_30days'];
      for(int i = 0; i < data.length; i++) {
        var formattedDate = data[i]['birthday'];
        if(today == formattedDate) {
          todayBirthday.add(data[i]);
        }
      }
      setState(() {
        birthdayCount = todayBirthday.length.toString();
        if(birthdayCount != null && birthdayCount != '') {
          total += int.parse(birthdayCount);
        }
      });
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

  getTodayFeastData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_feast_list_v1?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      var today = DateFormat('dd - MMMM').format(DateTime.now());
      if(result['data'][0]['upcoming_feast_list'] != []) {
        List data = result['data'][0]['upcoming_feast_list'];
        for(int i = 0; i < data.length; i++) {
          var formattedDate = data[i]['feastday'];
          if(today == formattedDate) {
            todayFeastday.add(data[i]);
          }
        }
        setState(() {
          feastdayCount = todayFeastday.length.toString();
          if(feastdayCount != null && feastdayCount != '') {
            total += int.parse(feastdayCount);
          }
        });
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

  getDeathMembersData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_death_members?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      String today = result['data']['today'];
      List data = result['data']['obituary_results'];
      for(int i = 0; i < data.length; i++) {
        DateTime date = DateFormat("dd-MM-yyyy").parse(data[i]['death_date']);
        var formattedDate = DateFormat('dd - MMMM').format(date);
        if(today == formattedDate) {
          todayDeath.add(data[i]);
          obituaryCount = todayDeath.length.toString();
        }
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

  getUnreadNotificationCount() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/push.notification/get_unread_notification_count?args=[$userId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      for(int i = 0; i < data.length; i++) {
        unReadNotificationCount = data[i]['all_notification'];
        unReadEventCount = data[i]['cal_meet_notification'];
        unReadCircularCount = data[i]['cir_notification'];
        unReadNewsCount = data[i]['news_notification'];
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

  _flush() {
    AnimatedSnackBar.show(
        context,
        'Logout successfully',
        Colors.green
    );
  }

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
    }
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      userMember = '';
      todayDeath = [];
      todayBirthday = [];
      todayFeastday = [];
      total = 0;
      unReadNotificationCount = 0;
      unReadEventCount = 0;
      unReadCircularCount = 0;
      unReadNewsCount = 0;
      getData();
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

  void showNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'your_channel_key',
        title: message.notification!.title ?? 'Notification Title',
        body: message.notification!.body ?? 'Notification Body',
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'action_key',
          label: 'Okay',
        ),
      ],
    );
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    super.initState();
    getData();
    // getReadNotificationData();
    // Request for permission to show notifications (required for iOS)
    _firebaseMessaging.requestPermission();
    // Subscribe to a topic (optional)
    _firebaseMessaging.subscribeToTopic(db);
    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notificationCount++;
      // Display the notification using awesome_notifications
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        notificationCount = 0;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationListScreen()),
      );
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    clearImageCache();
    super.dispose();
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
            backgroundColor: appBackgroundColor,
            leading: IconButton(
              icon: SvgPicture.asset("assets/icons/menu.svg", color: Colors.white,),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              notificationCount != 0 && notificationCount != null ? Stack(
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25, width: 25,),
                    onPressed: () async  {
                      notificationCount = 0;
                      String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationListScreen()));

                      if(refresh == 'refresh') {
                        changeData();
                      }
                    },
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
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
              ) : unReadNotificationCount != 0 ? Stack(
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25, width: 25,),
                    onPressed: () async {
                      String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationListScreen()));

                      if(refresh == 'refresh') {
                        changeData();
                      }
                    },
                  ),
                  Positioned(
                    top: 3,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
                ],
              ) : IconButton(
                icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25, width: 25,),
                onPressed: () async {
                  String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationListScreen()));

                  if(refresh == 'refresh') {
                    changeData();
                  }
                },
              )
            ],
          ),
          body: SafeArea(
            child: _isLoading ? Center(
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
                    height: size.height * 0.09,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/home.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome',
                                style: GoogleFonts.chelaOne(
                                  letterSpacing: 0.8,
                                  fontSize: size.height * 0.025,
                                  color: emailText,
                                ),
                              ),
                              SizedBox(height: size.height * 0.008,),
                              Container(
                                padding: EdgeInsets.only(left: size.width * 0.05),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberName,
                                      style: GoogleFonts.roboto(
                                          letterSpacing: 0.5,
                                          fontSize: size.height * 0.022,
                                          fontWeight: FontWeight.bold,
                                          color: textHeadColor
                                      ),
                                    ),
                                    memberRole != '' && memberRole.isNotEmpty ? SizedBox(height: size.height * 0.005,) : Container(),
                                    memberRole != '' && memberRole.isNotEmpty ? Text(
                                      memberRole,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: size.height * 0.015,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
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
                            height: size.height * 0.11,
                            width: size.width * 0.18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: <BoxShadow>[
                                if(memberImage != null && memberImage != '') const BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: -1,
                                  blurRadius: 5 ,
                                  offset: Offset(0, 1),
                                ),
                              ],
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: memberImage != null && memberImage != ''
                                    ? NetworkImage(memberImage)
                                    : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                            child: Image.network(urlImage, fit: BoxFit.cover, width: 1000.0),
                          );
                        },
                        options: CarouselOptions(
                          viewportFraction: 0.95,
                          aspectRatio: 2.0,
                          height: size.height * 0.2,
                          autoPlay: true,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: const Duration(seconds: 2),
                          enlargeCenterPage: true,
                          onPageChanged: ((index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          }),
                        ),
                      ) : bannerImage.isNotEmpty ? CarouselSlider.builder(
                        carouselController: controller,
                        itemCount: bannerImage.length,
                        itemBuilder: (context, index, realIndex) {
                          final urlImage = bannerImage[index]['image_1920'];
                          return ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                            child: Image.network(urlImage, fit: BoxFit.cover, width: 1000.0),
                          );
                        },
                        options: CarouselOptions(
                          viewportFraction: 0.95,
                          aspectRatio: 2.0,
                          height: size.height * 0.2,
                          autoPlay: true,
                          enableInfiniteScroll: true,
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
                            child: Image.asset(urlImage, fit: BoxFit.cover, width: 1000.0),
                          );
                        },
                        options: CarouselOptions(
                          viewportFraction: 0.95,
                          aspectRatio: 2.0,
                          height: size.height * 0.2,
                          autoPlay: true,
                          enableInfiniteScroll: true,
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
                              color: Colors.redAccent,
                            ),
                            child: Text('News',style: GoogleFonts.kanit(fontSize: size.height * 0.018, color: Colors.white),),
                          )
                      ),
                      newsData.isNotEmpty ? Flexible(
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE8F4FF),
                                  Color(0xFFE8F4FF)
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            child: CarouselSlider.builder(
                              carouselController: controller,
                              itemCount: newsData.length,
                              itemBuilder: (context, index, realIndex) {
                                final news = newsData[index]['name'];
                                return GestureDetector(
                                  onTap: () async {
                                    if(newsData[index]['type'] == 'news') {
                                      newsID = newsData[index]['id'];
                                      String refresh = await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const NewsDetailScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    } else if(newsData[index]['type'] == 'birthday') {
                                      id = newsData[index]['id'];
                                      if(memberId == id) {
                                        memberId = id;
                                        String refresh = await Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => const MemberProfileTabbarScreen()));
                                        if(refresh == 'refresh') {
                                          changeData();
                                        }
                                      } else {
                                        id = newsData[index]['id'];
                                        userMember = 'Member';
                                        String refresh = await Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => const MembersDetailsTabBarScreen()));
                                        if(refresh == 'refresh') {
                                          changeData();
                                        }
                                      }
                                    } else if(newsData[index]['type'] == 'feast') {
                                      id = newsData[index]['id'];
                                      if(memberId == id) {
                                        memberId = id;
                                        String refresh = await Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => const MemberProfileTabbarScreen()));
                                        if(refresh == 'refresh') {
                                          changeData();
                                        }
                                      } else {
                                        userMember = 'Member';
                                        id = newsData[index]['id'];
                                        String refresh = await Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => const MembersDetailsTabBarScreen()));
                                        if(refresh == 'refresh') {
                                          changeData();
                                        }
                                      }
                                    } else {
                                      String refresh = await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const ObituaryTabScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    alignment: Alignment.center,
                                    child: newsData[index]['type'] == 'birthday' ? Row(
                                      children: [
                                        Container(
                                          height: size.height * 0.06,
                                          width: size.width * 0.13,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/happy-birthday.gif"),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.03,),
                                        Flexible(
                                          child: Text(
                                            news,
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.maitree(
                                              textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                              fontSize: size.height * 0.017,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : newsData[index]['type'] == 'feast' ? Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "Happy Feast Day to $news",
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.maitree(
                                              textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                              fontSize: size.height * 0.017,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : newsData[index]['type'] == 'obituary' ? Row(
                                      children: [
                                        Container(
                                          height: size.height * 0.06,
                                          width: size.width * 0.13,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/celebration.png"),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.03,),
                                        Flexible(
                                          child: Text(
                                            news,
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.maitree(
                                              textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                              fontSize: size.height * 0.017,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : Text(
                                      news,
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.maitree(
                                        textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                        fontSize: size.height * 0.017,
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
                                autoPlay: newsData.length > 1 ? true : false,
                                enableInfiniteScroll: newsData.length > 1 ? true : false,
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
                      ) : Flexible(
                        child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE8F4FF),
                                  Color(0xFFE8F4FF)
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            child: CarouselSlider.builder(
                              carouselController: controller,
                              itemCount: newsList.length,
                              itemBuilder: (context, index, realIndex) {
                                final news = newsList[index];
                                return Container(
                                  padding: const EdgeInsets.only(left: 5),
                                  alignment: Alignment.center,
                                  child: Text(
                                    news,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                      fontSize: size.height * 0.017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                viewportFraction: 0.95,
                                aspectRatio: 2.0,
                                height: size.height * 0.06,
                                autoPlay: newsList.length > 1 ? true : false,
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const MemberProfileTabbarScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/profile.svg',
                            title: "My Profile",
                            homeIconSize: 35,
                          ),
                          HomeCard(
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const ProvinceDetailsScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/church.svg',
                            title: "Province",
                            homeIconSize: 40,
                          ),
                          userRole == 'Religious Province' ? HomeCard(
                            onPressed: () async {
                              house = 'House';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const ProvinceHouseListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/house.svg',
                            title: "House",
                            homeIconSize: 35,
                          ) : userCommunityId == '' ? HomeCard(
                            onPressed: () async {
                              house = 'House';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const ProvinceHouseListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/house.svg',
                            title: "House",
                            homeIconSize: 35,
                          ) : HomeCard(
                            onPressed: () async {
                              house = 'House';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const HouseScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/house.svg',
                            title: "House",
                            homeIconSize: 35,
                          ),
                          userRole == 'Religious Province' ? HomeCard(
                            onPressed: () async {
                              institution = 'Institution';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const ProvinceInstitutionListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconSize: 35,
                          ) : userRole == 'House/Community' ? HomeCard(
                            onPressed: () async {
                              institution = 'Institution';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const HouseInstitutionListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconSize: 35,
                          ) : userInstituteId == '' ? HomeCard(
                            onPressed: () async {
                              institution = 'Institution';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const ProvinceInstitutionListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconSize: 35,
                          ) : HomeCard(
                            onPressed: () async {
                              institution = 'Institution';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const InstitutionScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/institution.svg',
                            title: "Institution",
                            homeIconSize: 35,
                          ),
                          HomeCard(
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const CommissionScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/admin.svg',
                            title: "Commission",
                            homeIconSize: 35,
                          ),
                          userRole == 'Institution' ? HomeCard(
                            onPressed: () async {
                              userMember = 'Member';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const InstitutionMembersListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/members.svg',
                            title: "Members",
                            homeIconSize: 40,
                          ) : userRole == 'House/Community' ? HomeCard(
                            onPressed: () async {
                              userMember = 'Member';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const MemberTabScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/members.svg',
                            title: "Members",
                            homeIconSize: 40,
                          ) : HomeCard(
                            onPressed: () async {
                              userMember = 'Member';
                              String refresh = await Navigator.push(context, CustomRoute(widget: const MemberTabScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/members.svg',
                            title: "Members",
                            homeIconSize: 40,
                          ),
                          total != 0 ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const CelebrationTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/birthday.svg',
                                title: "Celebration",
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
                                    total.toString(),
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const CelebrationTabScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/birthday.svg',
                            title: "Celebration",
                            homeIconSize: 35,
                          ),
                          unReadNewsCount != 0 ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const NewsScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/news_paper.svg',
                                title: "News",
                                homeIconSize: 32,
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
                                    '$unReadNewsCount',
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const NewsScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/news_paper.svg',
                            title: "News",
                            homeIconSize: 32,
                          ),
                          unReadEventCount != 0 ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const EventScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/calendar.svg',
                                title: "Events",
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
                                    '$unReadEventCount',
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const EventScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/calendar.svg',
                            title: "Events",
                            homeIconSize: 35,
                          ),
                          unReadNotificationCount != 0 ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () async {
                                  notificationCount = 0;
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationListScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/notification.svg',
                                title: "Notification",
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
                                    "${unReadNotificationCount + notificationCount}",
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationListScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/notification.svg',
                            title: "Notification",
                            homeIconSize: 35,
                          ),
                          unReadCircularCount != 0 ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const CircularAndNewsLetterTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/info.svg',
                                title: "Circular / News Letter",
                                homeIconSize: 40,
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
                                    '$unReadCircularCount',
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const CircularAndNewsLetterTabScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/info.svg',
                            title: "Circular / News Letter",
                            homeIconSize: 40,
                          ),
                          obituaryCount != null && obituaryCount != 0 ? Stack(
                            children: [
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const ObituaryTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/rip.svg',
                                title: "Obituary",
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
                                    obituaryCount,
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
                            onPressed: () async {
                              String refresh = await Navigator.push(context, CustomRoute(widget: const ObituaryTabScreen()));

                              if(refresh == 'refresh') {
                                changeData();
                              }
                            },
                            icon: 'assets/icons/rip.svg',
                            title: "Obituary",
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
                          height: size.height * 0.1,
                          width: size.width * 0.2,
                          fit: BoxFit.cover
                      ) : Image.asset(
                        'assets/images/profile.png',
                        height: size.height * 0.1,
                        width: size.width * 0.2,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: navIconColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.of(context).push(CustomRoute(widget: const MemberProfileTabbarScreen()));
                      },
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: menuPrimaryColor,
                              ),
                              child: SvgPicture.asset('assets/icons/user.svg', color: buttonIconColor, height: 20, width: 20)
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(child: Text('Profile', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: navIconColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.of(context).push(CustomRoute(widget: const AboutScreen()));
                      },
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: menuPrimaryColor,
                              ),
                              child: SvgPicture.asset('assets/icons/info.svg', color: buttonIconColor, height: 20, width: 20)
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(child: Text('About', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: navIconColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
                        webAction('https://www.boscosofttech.com/about');
                      },
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: menuPrimaryColor,
                              ),
                              child: SvgPicture.asset('assets/icons/shield.svg', color: buttonIconColor, height: 20, width: 20)
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(child: Text('Privacy', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.015,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Account',
                        style: TextStyle(
                            fontSize: size.height * 0.02,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.015,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: navIconColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(CustomRoute(widget: const ChangePasswordScreen()));
                      },
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: menuPrimaryColor,
                              ),
                              child: SvgPicture.asset('assets/icons/key.svg', color: buttonIconColor, height: 20, width: 20)
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(child: Text('Change Password', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                          Icon(Icons.arrow_forward_ios, color: valueColor, size: size.height * 0.02,),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: navIconColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
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
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: menuPrimaryColor,
                              ),
                              child: Icon(Icons.cancel, size: size.height * 0.025, color: buttonIconColor,)
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(child: Text('Exit', style: TextStyle(fontSize: size.height * 0.019, color: valueColor, fontWeight: FontWeight.w600),)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: navIconColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
                        // userDeviceTokenDelete();
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
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: menuPrimaryColor,
                              ),
                              child: SvgPicture.asset('assets/icons/logout.svg', color: buttonIconColor, height: 20, width: 20)
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(child: Text('Logout', style: TextStyle(fontSize: size.height * 0.019, color: Colors.black, fontWeight: FontWeight.w600),)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.1,),
                Text(
                  "v$curentVersion",
                  style: GoogleFonts.robotoSlab(
                    fontSize: size.height * 0.018,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  "© Boscosoft Technologies Pvt. Ltd.",
                  style: GoogleFonts.robotoSlab(
                    fontSize: size.height * 0.018,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
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
      activeDotColor: menuPrimaryColor,
    ),
    activeIndex: activeIndex,
    count: image.isNotEmpty ? image.length : bannerImage.isNotEmpty ? bannerImage.length : imgList.length,
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
        required this. homeIconSize,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.07,
              width: size.width * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [menuPrimaryColor, menuPrimaryColor], // Add your gradient colors here
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Center(
                  child: IconButton(
                    icon: SvgPicture.asset(icon, color: menuIconColor,),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: menuTextColor,
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