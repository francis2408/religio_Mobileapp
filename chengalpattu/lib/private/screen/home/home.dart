import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/administration/administration.dart';
import 'package:chengai/private/screen/anniversary/birthday/birthday_tab.dart';
import 'package:chengai/private/screen/anniversary/ordination/ordination_tab.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/private/screen/bishop_speaks/bishop_speaks.dart';
import 'package:chengai/private/screen/calendar/event.dart';
import 'package:chengai/private/screen/circular/circular.dart';
import 'package:chengai/private/screen/curia/diocese_curia.dart';
import 'package:chengai/private/screen/institution/institution.dart';
import 'package:chengai/private/screen/member/members_tabs.dart';
import 'package:chengai/private/screen/member/profile_details.dart';
import 'package:chengai/private/screen/news/new_details.dart';
import 'package:chengai/private/screen/news/news.dart';
import 'package:chengai/private/screen/notification/notification_list.dart';
import 'package:chengai/private/screen/obituary/obituary_tab.dart';
import 'package:chengai/private/screen/parish/parish_tab.dart';
import 'package:chengai/private/screen/pastoral_center/pastoral.dart';
import 'package:chengai/private/screen/retired/retired.dart';
import 'package:chengai/private/screen/seminarian/seminarian.dart';
import 'package:chengai/private/screen/seminarian/seminarian_tab.dart';
import 'package:chengai/private/screen/vicariate/vicariate_list.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../diocese/diocese_details.dart';

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
  final controller = CarouselController();
  int activeIndex = 0;
  int activeNewsIndex = 0;
  List image = [];
  String url = '';
  List member = [];
  List newsData = [];
  List birthdayData = [];
  List ordinationData = [];
  List obituaryData = [];

  String userRole = '';
  String todayBirthday = '';
  String todayOrdination = '';
  String todayObituary = '';
  int birthdayCount = 0;
  String ordinationCount = '';
  String obituaryCount = '';
  String newsText = '';
  String title = '';
  String message = '';

  List imgList = [
    'assets/church/one.jpg',
    'assets/church/two.jpg',
    'assets/church/three.jpg',
    'assets/church/four.jpg',
    'assets/church/five.jpg',
  ];
  final bool _canPop = false;
  bool _isLoading = true;
  bool _isNews = true;
  bool _isImage = true;

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  userDeviceTokenDelete() async {
    String url = '$baseUrl/device/delete/token';
    Map data = {
      "params": {
        "token": "",
        "user_id": userID
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

  getBannerImageData() async {
    var pref = await SharedPreferences.getInstance();
    if(pref.containsKey('setName')) {
      loginName = (pref.getString('setName'))!;
    }

    if(pref.containsKey('setDatabaseName')) {
      databaseName = (pref.getString('setDatabaseName'));
    }

    if(pref.containsKey('setPassword')) {
      loginPassword = (pref.getString('setPassword'))!;
    }

    if(pref.containsKey('userRememberKey')) {
      remember = (pref.getBool('userRememberKey'))!;
    }

    if(pref.containsKey('userAuthTokenKey')) {
      authToken = (pref.getString('userAuthTokenKey'))!;
    }

    if(pref.containsKey('userTokenExpires')) {
      tokenExpire = (pref.getString('userTokenExpires'))!;
    }

    if(pref.containsKey('userNameKey')) {
      userName = (pref.getString('userNameKey'))!;
    }

    if(pref.containsKey('userEmailKey')) {
      userEmail = (pref.getString('userEmailKey'))!;
    }

    if(pref.containsKey('userImageKey')) {
      userImage = (pref.getString('userImageKey'))!;
    }

    if(pref.containsKey('userDioceseKey')) {
      userDiocese = (pref.getInt('userDioceseKey'))!;
    }

    if(pref.containsKey('userDiocesesKey')) {
      userDioceses = (pref.getString('userDiocesesKey'))!;
    }

    if(pref.containsKey('userMemberKey')) {
      userMember = (pref.getInt('userMemberKey'))!;
    }

    if(pref.containsKey('userMembersKey')) {
      userMembers = (pref.getString('userMembersKey'))!;
    }

    expiryDateTime = DateTime.parse(tokenExpire);
    DateTime currentDateTime = DateTime.now();

    if(expiryDateTime!.isAfter(currentDateTime)) {

      if(userDiocese != '') {
        String url = '$baseUrl/slider.image';
        Map data = {
          "params": {
            "filter": "[['diocese_id','=',$userDiocese]]",
            "query": "{id,image_1920}"
          }
        };
        var body = jsonEncode(data);
        var response = await http.post(Uri.parse(url),
            headers: {
              'Authorization': authToken,
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: body);

        if(response.statusCode == 200) {
          List data = json.decode(response.body)['result']['data']['result'];
          if (mounted) {
            setState(() {
              _isImage = false;
            });
          }
          image = data;

          if(userMember != '') {
            // Getting Member Data
            getMemberData();
          } else {
            _isLoading = false;
            // BirthdayData
            getBirthdayData();
            // OrdinationData
            getOrdinationData();
            // ObituaryData
            getObituaryData();
            // News Data
            getNewsData();
          }
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
      } else {
        if(userMember != '') {
          // Getting Member Data
          getMemberData();
        } else {
          // Unread Notification
          getUnReadNotification();
          // BirthdayData
          getBirthdayData();
          // OrdinationData
          getOrdinationData();
          // ObituaryData
          getObituaryData();
          // News Data
          getNewsData();
        }
      }
    } else {
      if(remember == true) {
        setState(() {
          loginService.login(context, loginName, loginPassword, databaseName, callback: () {
            setState(() {
              getBannerImageData();
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

  getMemberData() async {
    String url = '$baseUrl/res.member';
    Map data = {
      "params": {
        "filter": "[['id','=',$userMember]]",
        "query": "{id,member_name,image_1920,email,role_ids,membership_type}"
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      List data = jsonDecode(response.body)['result']['data']['result'];
      setState(() {
        userName = '';
        userEmail = '';
        userImage = '';
        _isLoading = false;
      });
      member = data;

      for(int i = 0; i < member.length; i++) {
        userImage = member[i]['image_1920'];
        userName = member[i]['member_name'];
        userEmail = member[i]['email'];
        userRole = member[i]['role_ids_view'];
        membershipType = member[i]['membership_type'];
      }
      // Unread Notification
      getUnReadNotification();
      // BirthdayData
      getBirthdayData();
      // OrdinationData
      getOrdinationData();
      // ObituaryData
      getObituaryData();
      // News Data
      getNewsData();
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
  }

  getBirthdayData() async {
    String url = '$baseUrl/res.member/get_birthday_list';
    Map data = {
      "params": {}
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      todayBirthday = json.decode(response.body)['result']['result']['today'];
      List data = json.decode(response.body)['result']['result']['b_result'];
      for(int i = 0; i < data.length; i++) {
        if(todayBirthday == data[i]['birthday']) {
          birthdayData.add(data[i]);
          birthdayCount = birthdayData.length;
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

  getOrdinationData() async {
    String url = '$baseUrl/res.member/get_anniversary_list';
    Map data = {
      "params": {}
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      todayOrdination = json.decode(response.body)['result']['result']['today'];
      List data = json.decode(response.body)['result']['result']['anniversary_results'];
      for(int j = 0; j < data.length; j++) {
        if(todayOrdination == data[j]['ordination_date']) {
          ordinationData.add(data[j]);
          ordinationCount = ordinationData.length.toString();
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

  getObituaryData() async {
    String url = '$baseUrl/res.member/get_obituary_list';
    Map data = {
      "params": {}
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if (response.statusCode == 200) {
      String today = json.decode(response.body)['result']['result']['today'];
      List data = json.decode(response.body)['result']['result']['obituary_results'];
      setState(() {
        _isLoading = false;
      });
      for(int k = 0; k < data.length; k++) {
        DateTime dateTime = DateTime.parse(data[k]['death_date']);
        String formattedDate = DateFormat('d - MMMM').format(dateTime);
        if(today == formattedDate) {
          obituaryData.add(data[k]);
          obituaryCount = obituaryData.length.toString();
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

  getNewsData() async {
    String url = '$baseUrl/res.news';
    Map data = {
      "params": {
        "filter": "[['state','=','publish']]",
        "order": "date desc",
        "query":"{id,name,date}"
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['result']['data']['result'];
      if (mounted) {
        setState(() {
          _isNews = false;
        });
      }
      newsData = data;

      newsText = newsData.map((item) => item["name"]!).join("   ");

      for(int i = 0; i < newsData.length; i++){
        final date = format.parse(newsData[i]['date']);
        var newsDate = reverse.format(date);
        DateTime dateTime = DateTime.parse(newsDate);
        newsData[i]["formattedDate"] = DateFormat('MMMM ').format(dateTime);
        newsData[i]["formattedMonth"] = DateFormat('dd').format(dateTime);
        newsData[i]["formattedYear"] = DateFormat('yyyy').format(dateTime);
      }

    } else {
      var message = json.decode(response.body)['result'];
      setState(() {
        _isNews = false;
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

  getUnReadNotification() async {
    String url = '$baseUrl/push.notification/get_unread_notification_count';
    Map datas = {
      "params": {
        "args": [userID]
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
    if(response.statusCode == 200) {
      List data = jsonDecode(response.body)['result']['result'];
      for(int i = 0; i < data.length; i++) {
        unReadNotificationCount = data[i]['all_notification'];
        unReadEventCount = data[i]['cal_meet_notification'];
        unReadCircularCount = data[i]['cir_notification'];
        unReadNewsCount = data[i]['news_notification'];
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

  void changeData() {
    setState(() {
      _isLoading = true;
      birthdayData = [];
      birthdayCount = 0;
      unReadNotificationCount = 0;
      unReadEventCount = 0;
      unReadCircularCount = 0;
      unReadNewsCount = 0;
      getBannerImageData();
    });
  }

  _flush() {
    AnimatedSnackBar.material(
        'Logout successfully',
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 2)
    ).show(context);
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
          label: 'Action Button',
        ),
      ],
    );

    AwesomeNotifications().actionStream.listen((receivedNotification) {
      if (receivedNotification.channelKey == 'your_channel_key' &&
          receivedNotification.buttonKeyPressed == 'action_key') {
        setState(() {
          notificationCount = 0;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationListScreen()),
        );
      }
    });
  }

  // void showNotification(RemoteMessage message, BuildContext context) async {
  //   title = message.notification!.title.toString();
  //   message = message.notification!.body as RemoteMessage;
  //   await AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: 0,
  //       channelKey: 'your_channel_key',
  //       title: message.notification!.title ?? 'Notification Title',
  //       body: message.notification!.body ?? 'Notification Body',
  //     ),
  //     actionButtons: [
  //       NotificationActionButton(
  //         key: 'action_key',
  //         label: 'Action Button',
  //       ),
  //     ],
  //   );
  //
  //   AwesomeNotifications().actionStream.listen((receivedNotification) {
  //     if (receivedNotification.channelKey == 'your_channel_key' &&
  //         receivedNotification.buttonKeyPressed == 'action_key') {
  //       // Handle the action button press
  //       _handleNotificationAction(context);
  //     }
  //   });
  // }
  //
  // void _handleNotificationAction(BuildContext context) {
  //   Fluttertoast.showToast(
  //     msg: '$title\n$message',
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: Colors.grey,
  //     textColor: Colors.white,
  //   );
  //
  //   // Navigate to the notification screen
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const NotificationListScreen()),
  //   );
  // }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    getBannerImageData();
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: 'Info',
            text: 'Are you sure want to exit.',
            confirmBtnColor: greenColor,
            onConfirmBtnTap: () {
              exit(0);
            },
            width: 100.0,
          );
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Diocese of Chingleput',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
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
            notificationCount != 0 && notificationCount != null ? Stack(
              children: [
                IconButton(
                  icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25, width: 25,),
                  onPressed: () async {
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
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dear, ',
                              style: GoogleFonts.lobster(
                                  letterSpacing: 1,
                                  fontSize: size.height * 0.02,
                                  color: Colors.black
                              ),
                            ),
                            SizedBox(height: size.height * 0.008,),
                            Container(
                              padding: EdgeInsets.only(left: size.width * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: GoogleFonts.kavoon(
                                        letterSpacing: 0.5,
                                        fontSize: size.height * 0.02,
                                        color: textColor
                                    ),
                                  ),
                                  userRole != '' && userRole.isNotEmpty ? SizedBox(height: size.height * 0.005,) : Container(),
                                  userRole != '' && userRole.isNotEmpty ? Text(
                                    userRole,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: size.height * 0.017,
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
                          userImage != '' ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Image.network(userImage, fit: BoxFit.cover,),
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
                              if(userImage != null && userImage != '') const BoxShadow(
                                color: Colors.grey,
                                spreadRadius: -1,
                                blurRadius: 5 ,
                                offset: Offset(0, 1),
                              ),
                            ],
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: userImage != null && userImage != ''
                                  ? NetworkImage(userImage)
                                  : const AssetImage('assets/images/profile.png') as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _isImage ? Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height * 0.06,
                    child: const LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.red,Colors.orange,Colors.yellow],
                    ),
                  ),
                ) : image.isNotEmpty ? CarouselSlider.builder(
                  carouselController: controller,
                  itemCount: image.length,
                  itemBuilder: (context, index, realIndex) {
                    final urlImage = image[index]['image_1920'];
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      child: buildImage(urlImage, index),
                    );
                  },
                  options: CarouselOptions(
                    viewportFraction: 0.95,
                    aspectRatio: 2.0,
                    height: size.height * 0.19,
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
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      child: Image.asset(urlImage, fit: BoxFit.fill, width: 1000.0),
                    );
                  },
                  options: CarouselOptions(
                    viewportFraction: 0.95,
                    aspectRatio: 2.0,
                    height: size.height * 0.19,
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
                SizedBox(height: size.height * 0.015,),
                Container(
                    alignment: Alignment.center,
                    child: buildIndicator()
                ),
                SizedBox(height: size.height * 0.015,),
                _isNews ? Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height * 0.06,
                    child: const LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.red,Colors.orange,Colors.yellow],
                    ),
                  ),
                ) : Row(
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
                          child: CarouselSlider.builder(
                            carouselController: controller,
                            itemCount: newsData.length,
                            itemBuilder: (context, index, realIndex) {
                              final news = newsData[index]['name'];
                              return GestureDetector(
                                onTap: () async {
                                  newsID = newsData[index]['id'];
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const NewsDetailsScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
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
                          )
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.03,
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
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const BishopSpeechScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/speech.svg',
                                title: "Bishop Speaks",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 40,
                              ),
                              if(userMember != '') HomeCard(
                                onPressed: () async {
                                  userProfile = "Profile";
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const MemberProfileScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/profile.svg',
                                title: "My Profile",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              if(userDiocese != '') HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const DioceseDetailsScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/diocese.svg',
                                title: "Diocese",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 35,
                              ),
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const DioceseCurioScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/curia.svg',
                                title: "Diocesian Curia",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 35,
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
                                    title: "Calendar",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 30,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
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
                                title: "Calendar",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const AdministrationScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/admin.svg',
                                title: "Administration",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const PastoralCenterScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/pastoral.svg',
                                title: "Pastoral Center",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              if(userDiocese != '') HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const VicariateListScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/vicariate.svg',
                                title: "Vicariate",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 40,
                              ),
                              if(userDiocese != '') HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const ParishTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/church.svg',
                                title: "Parish & Shrines",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 40,
                              ),
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const InstitutionScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/institution.svg',
                                title: "Institution",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              if(userDiocese != '') HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const MemberTabsScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/members.svg',
                                title: "Members",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 40,
                              ),
                              HomeCard(
                                onPressed: () async {
                                  selectMenu = 'Seminarian';
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const SeminarianTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/seminarian.svg',
                                title: "Seminarian",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              HomeCard(
                                onPressed: () async {
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const RetiredScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/retired.svg',
                                title: "Senior Priest Home",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              birthdayCount != null && birthdayCount != 0 && birthdayCount != '' ? Stack(
                                children: [
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const BirthdayTabScreen()));

                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: 'assets/icons/birthday.svg',
                                    title: "Birthday",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 30,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        birthdayCount.toString(),
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
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const BirthdayTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/birthday.svg',
                                title: "Birthday",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              ordinationCount != null && ordinationCount != 0 && ordinationCount != '' ? Stack(
                                children: [
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const OrdinationTabScreen()));

                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: 'assets/icons/ordination.svg',
                                    title: "Ordination",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 30,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        ordinationCount,
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
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const OrdinationTabScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/ordination.svg',
                                title: "Ordination",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              unReadCircularCount != 0 ? Stack(
                                children: [
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const CircularScreen()));

                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: 'assets/icons/circular.svg',
                                    title: "Circular",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 35,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
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
                                  String refresh = await Navigator.push(context, CustomRoute(widget: const CircularScreen()));

                                  if(refresh == 'refresh') {
                                    changeData();
                                  }
                                },
                                icon: 'assets/icons/circular.svg',
                                title: "Circular",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
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
                                    icon: 'assets/icons/news.svg',
                                    title: "News",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 40,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
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
                                icon: 'assets/icons/news.svg',
                                title: "News",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 40,
                              ),
                              unReadNotificationCount != 0 ? Stack(
                                children: [
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationListScreen()));

                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: 'assets/icons/notification.svg',
                                    title: "Notification",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 30,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
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
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                              obituaryCount != null && obituaryCount != 0 && obituaryCount != '' ? Stack(
                                children: [
                                  HomeCard(
                                    onPressed: () async {
                                      String refresh = await Navigator.push(context, CustomRoute(widget: const ObituaryTabScreen()));

                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                    icon: 'assets/icons/death.svg',
                                    title: "Obituary",
                                    colorOne: const Color(0xFFFF512F),
                                    colorTwo: const Color(0xFFF09819),
                                    homeIconColor: Colors.white,
                                    homeIconSize: 30,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: greenColor,
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
                                icon: 'assets/icons/death.svg',
                                title: "Obituary",
                                colorOne: const Color(0xFFFF512F),
                                colorTwo: const Color(0xFFF09819),
                                homeIconColor: Colors.white,
                                homeIconSize: 30,
                              ),
                            ],
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
        drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName, style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
              accountEmail: Text(userEmail, style: TextStyle(fontSize: size.height * 0.018,)),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: userImage.isNotEmpty ? Image.network(
                      userImage,
                      height: size.height * 0.08,
                      width: size.width * 0.18,
                      fit: BoxFit.cover
                  ) : Image.asset(
                    'assets/others/member.png',
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
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.info,
                  title: 'Info',
                  text: 'Are you sure want to exit.',
                  confirmBtnColor: greenColor,
                  onConfirmBtnTap: () {
                    exit(0);
                  },
                  width: 100.0,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new, size: size.height * 0.03, color: Colors.red,),
              title: Text('Logout', style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
              onTap: () {
                Navigator.pop(context);
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.info,
                  title: 'Info',
                  text: 'Are you sure you want to log out?',
                  confirmBtnColor: greenColor,
                  onConfirmBtnTap: () async {
                    // Deleting user device token
                    userDeviceTokenDelete();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const CustomLoadingDialog();
                      },
                    );
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
                    _flush();
                  },
                  onCancelBtnTap: () {
                    Navigator.pop(context);
                  },
                  confirmBtnText: 'Yes',
                  cancelBtnText: 'No',
                  showCancelBtn: true,
                  width: 100.0,
                );
                },
            ),
            SizedBox(height: size.height * 0.45,),
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
      )
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animateToSlide,
    effect: const ExpandingDotsEffect(
        dotHeight: 9,
        dotWidth: 9,
        activeDotColor: Color(0xFFE13A06)
    ),
    activeIndex: activeIndex,
    count: image.isNotEmpty ? image.length : imgList.length,
  );

  void animateToSlide(int index) => controller.animateToPage(index);

  Widget buildTextIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animatedToSlide,
    effect: const ExpandingDotsEffect(
        dotHeight: 6,
        dotWidth: 6,
        activeDotColor: Color(0xFFE13A06)
    ),
    activeIndex: activeNewsIndex,
    count: newsData.isNotEmpty ? newsData.length : 0,
  );

  void animatedToSlide(int index) => controller.animateToPage(index);
}

Widget buildImage(String urlImage, int index) =>
    CachedNetworkImage(fit: BoxFit.fill, imageUrl: urlImage, width: 1000.0);

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
        required this.onPressed,
        required this.icon,
        required this.title,
        required this.colorOne,
        required this.colorTwo,
        required this.homeIconColor,
        required this. homeIconSize,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
  final Color colorOne;
  final Color colorTwo;
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  colorOne,
                  colorTwo
                ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              ),),
              child: Center(
                  child: IconButton(
                    icon: SvgPicture.asset(icon, color: homeIconColor,),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
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