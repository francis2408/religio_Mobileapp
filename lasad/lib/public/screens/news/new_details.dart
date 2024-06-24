import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PublicNewsDetailsScreen extends StatefulWidget {
  const PublicNewsDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PublicNewsDetailsScreen> createState() => _PublicNewsDetailsScreenState();
}

class _PublicNewsDetailsScreenState extends State<PublicNewsDetailsScreen> {
  bool _isLoading  = true;
  List data = [];
  List newsData = [];
  int index = 0;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getNewsData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/news/$newsID'));
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
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    getNewsData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View News'),
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
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Color(0xFFA5FECB), Color(0xFF20BDFF), Color(0xFF5433FF)],
            ),
          ),
        ) : SlideFadeAnimation(
          duration: const Duration(seconds: 1),
          child: Container(
            padding: EdgeInsets.only(left: size.width * 0.02, right: size.width * 0.02),
            child: ListView(
              children: [
                SizedBox(height: size.height * 0.02,),
                newsData[index]['name'] != null && newsData[index]['name'] != '' ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("Title", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Row(
                      children: [
                        Flexible(
                            child: Text(
                              newsData[index]['name'],
                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                            )
                        ),
                      ],
                    ),
                  ),
                ) : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("Title", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Row(
                      children: [
                        Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                      ],
                    ),
                  ),
                ),
                newsData[index]['date'] != null && newsData[index]['date'] != '' ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("Date", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Row(
                      children: [
                        Flexible(
                            child: Text(
                              newsData[index]['date'],
                              style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                            )
                        ),
                      ],
                    ),
                  ),
                ) : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("Date", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Row(
                      children: [
                        Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                      ],
                    ),
                  ),
                ),
                newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("Description", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Html(
                      data: newsData[index]['description'],
                    ),
                  ),
                ) : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text("Description", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                    subtitle: Row(
                      children: [
                        Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
