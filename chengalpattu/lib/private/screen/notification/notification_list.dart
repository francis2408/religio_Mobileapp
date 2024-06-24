import 'dart:convert';

import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/notification/view_notification.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  bool read;
  bool isRead;

  Notifications({required this.id, required this.title, required this.body, required this.timestamp, this.isRead = false, this.read = false});
}

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading  = true;
  bool isReadAll = false;
  bool isNotRead = false;
  List notificationData = [];
  List readIds = [];
  List allReadIds = [];
  late List<Notifications> notificationsData;
  int selected = -1;
  bool isSelectItem = false;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final readNotificationIds = prefs.getStringList('read_notification_ids') ?? [];

    // Load the notifications from your API or database
    final newNotifications = await _fetchNotifications();

    // Set the background color of each notification item based on whether it has been read
    notificationsData = newNotifications.map((notificationData) {
      final isRead = readNotificationIds.contains(notificationData.id);
      return Notifications(id: notificationData.id, title: notificationData.title, body: notificationData.body, timestamp: notificationData.timestamp, isRead: notificationData.isRead, read: isRead);
    }).toList();

    setState(() {});
  }

  Future<List<Notifications>> _fetchNotifications() async {
    String url = '$baseUrl/push.notification/get_notification';
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
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['result']['result'];
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      notificationData = data;
      for(int i = 0; i < notificationData.length; i++) {
        if(notificationData[i]['msg_read'] == false) {
          readIds.add(notificationData[i]['id']);
        } else {
          allReadIds.add(notificationData[i]['id']);
        }
      }
      if(readIds.isEmpty) {
        setState(() {
          isNotRead = false;
          HelperFunctions.setNotificationReadSF(true);
        });
      } else {
        setState(() {
          isNotRead = true;
          HelperFunctions.setNotificationReadSF(false);
        });
      }
      return notificationData.map((notification) => Notifications(
        id: notification['id'].toString(),
        title: notification['title'],
        body: notification['description'],
        timestamp: notification['date'],
        isRead: notification['msg_read'],
      )).toList();
    } else {
      var message = json.decode(response.body)['result'];
      _isLoading = false;
      throw QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: message['message'],
        confirmBtnColor: greenColor,
        width: 100.0,
      );
    }
  }

  Future<void> _markNotificationAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final readNotificationIds = prefs.getStringList('read_notification_ids') ?? [];
    readNotificationIds.add(id);
    prefs.setStringList('read_notification_ids', readNotificationIds);
    if(readNotificationIds.length == notificationsData.length) {
      if(allReadIds.length == notificationsData.length) {
        HelperFunctions.setNotificationReadSF(true);
      } else {
        HelperFunctions.setNotificationReadSF(false);
      }
    } else {
      HelperFunctions.setNotificationReadSF(false);
    }
  }

  readNotification() async {
    String url = '$baseUrl/push.notification/read_notification';
    Map datas = isReadAll ? {
      "params": {
        "args": [readIds]
      }
    } : {
      "params": {
        "args": [[notificationId]]
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
      var result = jsonDecode(response.body)['result'];
      readIds.clear();
      if(isReadAll == true) {
        HelperFunctions.setNotificationReadSF(true);
        changeData();
      } else {
        if(result['status'] == true) {
          String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationViewScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
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

  void changeData() {
    setState(() {
      _isLoading = true;
      _loadNotifications();
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

  @override
  void initState() {
    // Check internet connection
    internetCheck();
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      _loadNotifications();
      notificationCount = 0;
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            _loadNotifications();
            notificationCount = 0;
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
        title: const Text('Notification'),
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
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading ? SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
            ),
          ) : Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: notificationsData.isNotEmpty ? Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                if(isNotRead != false) Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      isReadAll = true;
                      if(isReadAll == true) {
                        readNotification();
                      } else {
                        isReadAll  = false;
                      }
                    },
                    child: Container(
                        height: size.height * 0.03,
                        width: size.width * 0.23,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: tabBackColor,
                          boxShadow: [
                            BoxShadow(
                              color: tabBackColor.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Text(
                          'Read All',
                          style: TextStyle(
                              fontSize: size.height * 0.018,
                              color: Colors.white
                          ),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: AnimationLimiter(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notificationsData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final notification = notificationsData[index];
                            bool isSameDate = true;
                            final String dateString = notificationsData[index].timestamp;
                            final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                            if (index == 0) {
                              isSameDate = false;
                            } else {
                              final String prevDateString = notificationsData[index - 1].timestamp;
                              final DateTime prevDate = DateFormat('dd-MM-yyyy').parse(prevDateString);
                              isSameDate = date.isSameDate(prevDate);
                            }
                            if (!(isSameDate)) {
                              return Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      date.formatDate(),
                                      style: GoogleFonts.roboto(
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.height * 0.018
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.005,),
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: ListTile(
                                            leading: const CircleAvatar(
                                              backgroundColor: backgroundColor,
                                              child: Icon(Icons.notifications, color: Colors.white,),
                                            ),
                                            title: Text(notificationsData[index].title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),),
                                            subtitle: Text(notificationsData[index].body,maxLines: 1, overflow: TextOverflow.ellipsis,),
                                            trailing: Text(DateFormat("hh:mm a").format(DateFormat("dd-MM-yyyy HH:mm:ss").parse(notificationsData[index].timestamp).add(const Duration(hours: 5, minutes: 30))), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
                                            onLongPress: () {},
                                            onTap: () async {
                                              if (!notification.read) {
                                                await _markNotificationAsRead(notification.id);
                                                notification.read = true;
                                              }
                                              notificationId = int.tryParse(notificationsData[index].id);
                                              notificationName = notificationsData[index].title;
                                              readNotification();
                                            },
                                          ),
                                        ),
                                      ),
                                      notificationsData[index].isRead == true ? Container() : Positioned(
                                        top: 35,
                                        left: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF512F),
                                                    Color(0xFFF09819)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight
                                              )
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 13,
                                            minHeight: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.005,),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(height: size.height * 0.005,),
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: ListTile(
                                            leading: const CircleAvatar(
                                              backgroundColor: backgroundColor,
                                              child: Icon(Icons.notifications, color: Colors.white,),
                                            ),
                                            title: Text(notificationsData[index].title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),),
                                            subtitle: Text(notificationsData[index].body,maxLines: 1, overflow: TextOverflow.ellipsis,),
                                            trailing: Text(DateFormat("hh:mm a").format(DateFormat("dd-MM-yyyy HH:mm:ss").parse(notificationsData[index].timestamp).add(const Duration(hours: 5, minutes: 30))), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
                                            onTap: () async {
                                              if (!notification.read) {
                                                await _markNotificationAsRead(notification.id);
                                                notification.read = true;
                                              }
                                              notificationId = int.tryParse(notificationsData[index].id);
                                              notificationName = notificationsData[index].title;
                                              readNotification();
                                            },
                                          ),
                                        ),
                                      ),
                                      notificationsData[index].isRead == true ? Container() : Positioned(
                                        top: 35,
                                        left: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF512F),
                                                    Color(0xFFF09819)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight
                                              )
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 13,
                                            minHeight: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.005,),
                                ],
                              );
                            }
                          }
                      ),
                    ),
                  ),
                ),
              ],
            ) : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                  child: SizedBox(
                    height: 45,
                    width: 150,
                    child: textButton,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(CustomRoute(widget: const AddNotificationScreen()));
      //   },
      //   backgroundColor: const Color(0xFFFF512F),
      //   child: const Icon(Icons.notification_add),
      // ),
    );
  }
}

const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {

  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }
  bool isSameDate(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}