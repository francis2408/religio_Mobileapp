import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({Key? key}) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading  = true;
  List data = [];
  List newsData = [];
  int index = 0;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getNewsData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/search_read/res.news/$newsID'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      newsData = data;
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getNewsData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getNewsData();
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
        title: const Text('News'),
        backgroundColor: backgroundColor,
        toolbarHeight: 50,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.lineScalePulseOutRapid,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : newsData.isNotEmpty ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SlideFadeAnimation(
              duration: const Duration(seconds: 1),
              child: ListView.builder(itemCount: newsData.length, itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15,),
                      child: Container(
                        width: size.width,
                        height: size.height * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: newsData[index]['upload_image'] != null && newsData[index]['upload_image'] != ''
                                ? NetworkImage(newsData[index]['upload_image'])
                                : const AssetImage('assets/images/no_image.jpg') as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: size.width,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: backgroundColor,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              newsData[index]['name'],
                              textScaleFactor: 1.0,
                              style: GoogleFonts.secularOne(
                                  letterSpacing: 1,
                                  color: Colors.white,
                                  fontSize: size.height * 0.02
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(width: size.width * 0.22, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                  SizedBox(width: size.width * 0.02,),
                                  newsData[index]['date'] != null && newsData[index]['date'] != '' ? Text(DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(newsData[index]['date'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                ],
                              ),
                              newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                              newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(alignment: Alignment.topLeft, child: Text('Description', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                  SizedBox(height: size.height * 0.01,),
                                  Container(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Html(
                                      data: newsData[index]['description'],
                                      style: {
                                        'p': Style(
                                          lineHeight: const LineHeight(1.5),
                                          textAlign: TextAlign.justify, // Adjust the value as needed
                                        ),
                                      },
                                    ),
                                  )
                                ],
                              ) : Container(),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }),
            ),
          ) : Center(
            child: Container(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: NoResult(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}