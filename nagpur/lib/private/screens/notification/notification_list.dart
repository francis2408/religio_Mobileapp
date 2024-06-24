import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nagpur/widget/helper_function/helper_function.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nagpur/private/screens/notification/view_notification.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/common/internet_connection_checker.dart';
import 'package:nagpur/widget/common/slide_animations.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

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
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading  = true;
  bool isReadAll = false;
  bool isNotRead = false;
  List data = [];
  List notificationData = [];
  List readIds = [];
  List allReadIds = [];
  late List<Notifications> notificationsData;
  int selected = -1;
  bool isSelectItem = false;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

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
    var request = http.Request('GET', Uri.parse("$baseUrl/call/push.notification/get_notification?args=[$userId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
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
    return [];
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
    var request = isReadAll ? http.MultipartRequest('POST',  Uri.parse('$baseUrl/call/push.notification/read_notification?args=[$readIds]')) : http.MultipartRequest('POST',  Uri.parse('$baseUrl/call/push.notification/read_notification?args=[[$notificationId]]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      readIds.clear();
      if(isReadAll == true) {
        HelperFunctions.setNotificationReadSF(true);
        changeData();
      } else {
        if(result['status'] == 'success') {
          String refresh = await Navigator.push(context, CustomRoute(widget: const NotificationViewScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
        }
      }
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
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

  // String convertToIndianDateTime(String utcDateTime) {
  //   // Parse the UTC datetime string
  //   DateTime dateTime = DateFormat("dd-MM-yyyy HH:mm:ss").parse(utcDateTime);
  //
  //   // Add 5 hours and 30 minutes to the datetime
  //   dateTime = dateTime.add(const Duration(hours: 5, minutes: 30));
  //
  //   // Format the datetime in Indian date and time format
  //   String formattedDateTime = DateFormat("dd-MM-yyyy hh:mm a").format(dateTime);
  //   print('formattedDateTime $formattedDateTime');
  //
  //   return formattedDateTime;
  // }

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Notifications'),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          toolbarHeight: 50,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, 'refresh');
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              )
          ),
        ),
        body: SafeArea(
          child: Center(
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
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
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
                                            color: hiLightColor,
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
                                                backgroundColor: iconBackColor,
                                                child: Icon(Icons.notifications, color: Colors.white,),
                                              ),
                                              title: Text(notificationsData[index].title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
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
                                                      menuPrimaryColor,
                                                      menuPrimaryColor,
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
                                                backgroundColor: iconBackColor,
                                                child: Icon(Icons.notifications, color: Colors.white,),
                                              ),
                                              title: Text(notificationsData[index].title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: labelColor),),
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
                                                      menuPrimaryColor,
                                                      menuPrimaryColor
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
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: NoResult(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    text: 'No Data available',
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
      ),
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