import 'dart:convert';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationViewScreen extends StatefulWidget {
  const NotificationViewScreen({Key? key}) : super(key: key);

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final bool _canPop = false;
  bool _isLoading  = true;
  List data = [];
  List notificationData = [];
  int selected = -1;
  int index = 0;

  getNotificationData() async {
    String url = '$baseUrl/push.notification';
    Map datas = {
      "params": {
        "filter": "[['id','=',$notificationId]]",
        "query":"{id,name,image_1920,send_by,diocese_id,user_ids,date,description}"
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
      data = json.decode(response.body)['result']['data']['result'];
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      notificationData = data;

    } else {
      var message = json.decode(response.body)['result'];
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

  void _webLaunchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getNotificationData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getNotificationData();
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
    // return WillPopScope(
    //   onWillPop: () async {
    //     if (_canPop) {
    //       return true;
    //     } else {
    //       Navigator.pop(context, 'refresh');
    //       return false;
    //     }
    //   },
    //   child: Scaffold(
    //     backgroundColor: screenBackgroundColor,
    //     appBar: AppBar(
    //       title: Text(notificationName),
    //       flexibleSpace: Container(
    //         decoration: const BoxDecoration(
    //             gradient: LinearGradient(
    //                 colors: [
    //                   Color(0xFFFF512F),
    //                   Color(0xFFF09819)
    //                 ],
    //                 begin: Alignment.topLeft,
    //                 end: Alignment.bottomRight
    //             )
    //         ),
    //       ),
    //     ),
    //     body: SafeArea(
    //       child: Center(
    //         child: _isLoading
    //             ? SizedBox(
    //           height: size.height * 0.06,
    //           child: const LoadingIndicator(
    //             indicatorType: Indicator.ballSpinFadeLoader,
    //             colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
    //           ),
    //         ) : Container(
    //           padding: const EdgeInsets.only(left: 10, right: 10),
    //           child: Column(
    //             children: [
    //               SizedBox(
    //                 height: size.height * 0.02,
    //               ),
    //               notificationData.isNotEmpty ? Expanded(
    //                 child: AnimationLimiter(
    //                   child: SingleChildScrollView(
    //                     child: ListView.builder(
    //                         key: Key('builder ${selected.toString()}'),
    //                         shrinkWrap: true,
    //                         // scrollDirection: Axis.vertical,
    //                         physics: const NeverScrollableScrollPhysics(),
    //                         itemCount: notificationData.length,
    //                         itemBuilder: (BuildContext context, int index) {
    //                           return AnimationConfiguration.staggeredList(
    //                               position: index,
    //                               duration: const Duration(milliseconds: 380),
    //                               child: SlideAnimation(
    //                                   verticalOffset: 50.0,
    //                                   child: FadeInAnimation(
    //                                     child: Column(
    //                                       children: [
    //                                         Container(
    //                                           decoration: BoxDecoration(
    //                                             borderRadius: BorderRadius.circular(15.0),
    //                                           ),
    //                                           child: Card(
    //                                             shape: RoundedRectangleBorder(
    //                                               borderRadius: BorderRadius.circular(15.0),
    //                                             ),
    //                                             child: ListTile(
    //                                               title: Container(padding: const EdgeInsets.only(top: 5, bottom: 5),child: Text("${notificationData[index]['name']}", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),)),
    //                                               subtitle: Column(
    //                                                 children: [
    //                                                   const SizedBox(height: 3,),
    //                                                   Row(
    //                                                     children: [
    //                                                       Flexible(child: Text("${notificationData[index]['description']}", style: TextStyle(fontSize: size.height * 0.018, color: Colors.grey),)),
    //                                                     ],
    //                                                   ),
    //                                                   const SizedBox(height: 5,),
    //                                                   Container(
    //                                                     alignment: Alignment.topRight,
    //                                                     child: Row(
    //                                                       mainAxisAlignment: MainAxisAlignment.end,
    //                                                       children: [
    //                                                         const Icon(Icons.access_time_rounded, color: Colors.indigo,),
    //                                                         const SizedBox(width: 3,),
    //                                                         Text(notificationData[index]['date'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.indigo, fontStyle: FontStyle.italic),),
    //                                                       ],
    //                                                     ),
    //                                                   )
    //                                                 ],
    //                                               ),
    //                                               // trailing: Text(notificationData[index]['date'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
    //                                             ),
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   )
    //                               )
    //                           );
    //                         }
    //                     ),
    //                   ),
    //                 ),
    //               ) : Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Container(
    //                     padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
    //                     child: SizedBox(
    //                       height: 45,
    //                       width: 150,
    //                       child: textButton,
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
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
        body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballPulse,
                colors: [Colors.red,Colors.orange,Colors.yellow],
              ),
            ),
          ) : CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFF512F),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                automaticallyImplyLeading: false,
                expandedHeight: size.height * 0.3,
                pinned: true,
                floating: true,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context, 'refresh');
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: size.width * 0.1, end: size.width * 0.1, bottom: 5.0),
                  centerTitle: true,
                  title: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFFF512F),
                    ),
                    child: Text(
                        'Notification',
                        textScaleFactor: 1.0,
                        style: GoogleFonts.kavoon(
                            letterSpacing: 1,
                            color: Colors.white,
                            fontSize: size.height * 0.02
                        )
                    ),
                  ),
                  expandedTitleScale: 1,
                  // ClipRRect added here for rounded corners
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    child: notificationData[index]['image_1920'] != null && notificationData[index]['image_1920'] != '' ? Image.network(
                        notificationData[index]['image_1920'],
                        fit: BoxFit.fill
                    ) : Image.asset('assets/others/notification.jpg',
                        fit: BoxFit.fill
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: SingleChildScrollView(
                  child: AnimationLimiter(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notificationData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 380),
                                child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Column(
                                        children: [
                                          SizedBox(height: size.height * 0.02,),
                                          Container(
                                            alignment: Alignment.topRight,
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                const Icon(Icons.access_time_rounded, color: Colors.indigo,),
                                                const SizedBox(width: 3,),
                                                Text(notificationData[index]['date'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.indigo, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01,),
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
                                                        // Flexible(child: Text("${notificationData[index]['description']}", style: TextStyle(fontSize: size.height * 0.018, color: Colors.grey),)),
                                                        Flexible(child: buildRichTextWithLink(notificationData[index]['description'])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                  ],
                                                ),
                                                // trailing: Text(notificationData[index]['date'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.height * 0.016, color: Colors.black87),),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                            );
                          }
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRichTextWithLink(String apiResponse) {
    Size size = MediaQuery.of(context).size;
    String description = apiResponse;
    // Regular expression to find website links in the description
    RegExp urlRegex = RegExp(r'https?://(?:www\.)?[^\s]+');

    List<InlineSpan> textSpans = [];
    int startIndex = 0;
    for (RegExpMatch match in urlRegex.allMatches(description)) {
      // Add the non-link text
      textSpans.add(TextSpan(text: description.substring(startIndex, match.start)));
      // Add the link text
      String? url = match.group(0);
      textSpans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _webLaunchURL(url!);
            },
        ),
      );
      startIndex = match.end;
    }
    // Add the remaining non-link text
    textSpans.add(TextSpan(text: description.substring(startIndex)));
    return RichText(
      text: TextSpan(children: textSpans, style: TextStyle(fontSize: size.height * 0.018, color: Colors.grey),),
    );
  }
}
