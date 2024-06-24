import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

class NotificationViewScreen extends StatefulWidget {
  const NotificationViewScreen({Key? key}) : super(key: key);

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  final bool _canPop = false;
  bool _isLoading  = true;
  List data = [];
  List notificationData = [];
  int selected = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getNotificationData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/search_read/push.notification/$notificationId'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      notificationData = data;
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
    // TODO: implement initState
    super.initState();
    getNotificationData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          Navigator.pop(context, 'refresh');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: Text(notificationName),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A3F85),
                      Color(0xFFFA761E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
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
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  notificationData.isNotEmpty ? Expanded(
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: notificationData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
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
                                        title: Container(padding: const EdgeInsets.only(top: 5, bottom: 5),child: Text("${notificationData[index]['name']}", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),)),
                                        subtitle: Column(
                                          children: [
                                            const SizedBox(height: 3,),
                                            Row(
                                              children: [
                                                Flexible(child: Text("${notificationData[index]['description']}", style: TextStyle(fontSize: size.height * 0.018, color: Colors.grey),)),
                                              ],
                                            ),
                                            const SizedBox(height: 5,),
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  const Icon(Icons.access_time_rounded, color: Colors.indigo,),
                                                  const SizedBox(width: 3,),
                                                  Text(DateFormat("hh:mm a").format(DateFormat("dd-MM-yyyy HH:mm:ss").parse(notificationData[index]['date']).add(const Duration(hours: 5, minutes: 30))), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.indigo, fontStyle: FontStyle.italic),),
                                                  // Text(DateFormat('h:mm:ss').format(DateFormat('dd-MM-yyyy HH:mm:ss').parse(notificationData[index]['date'])), style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.indigo, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        // trailing: Text(notificationData[index]['date'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
