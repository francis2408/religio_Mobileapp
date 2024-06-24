import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/slide_animations.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

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
          getNewsData();
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
      body: SafeArea(
        child: _isLoading ? Center(
          child: Container(
              height: size.height * 0.1,
              width: size.width * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage( "assets/alert/spinner_1.gif"),
                ),
              )
          ),
        ) : CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: backgroundColor,
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
              leading: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: backgroundColor,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: size.width * 0.1, end: size.width * 0.1, bottom: 5.0),
                centerTitle: true,
                title: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: backgroundColor,
                  ),
                  child: Text(
                    newsData[index]['name'],
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: size.height * 0.02
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                expandedTitleScale: 1,
                // ClipRRect added here for rounded corners
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  child: newsData[index]['upload_image'] != null && newsData[index]['upload_image'] != '' ? Image.network(
                      newsData[index]['upload_image'],
                      fit: BoxFit.fill
                  ) : Image.asset('assets/images/news.jpg',
                      fit: BoxFit.fill
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: SingleChildScrollView(
                child:  SlideFadeAnimation(
                  duration: const Duration(seconds: 1),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.05,),
                      Card(
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
                                        'html': Style(
                                          color: valueColor,
                                          textAlign: TextAlign.justify,
                                        ),
                                      },
                                    ),
                                  ),
                                ],
                              ) : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}