import 'dart:convert';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class BishopEventScreen extends StatefulWidget {
  const BishopEventScreen({Key? key}) : super(key: key);

  @override
  State<BishopEventScreen> createState() => _BishopEventScreenState();
}

class _BishopEventScreenState extends State<BishopEventScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  DateTime currentDateTime = DateTime.now();
  bool _isLoading = true;
  bool isExpand = false;
  List bishopEvent = [];
  int selected = -1;
  String nowDate = '';
  String dateValue = '';
  String day = '';
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getBishopEventData() async {
    String url = '$baseUrl/calendar.event';
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map data = {
      "params": {
        "order": "start asc, start_date asc",
        "filter": "[['type','=','public'],['calendar_type','=','Bishop Calendar'],['start_date','>=','$today']]",
        "query":"{id,name,start,duration,start_date,stop_date,allday,location,description_html,session}"
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
      List jsonData = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      bishopEvent = jsonData;
    } else {
      var message = json.decode(response.body)['message'];
      setState(() {
        _isLoading = false;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: message,
          confirmBtnColor: greenColor,
          width: 100.0,
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
      getBishopEventData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getBishopEventData();
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
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ) : bishopEvent.isNotEmpty ? Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bishopEvent.length,
                          itemBuilder: (BuildContext context, int index) {
                            DateTime currentDate;
                            DateTime parsedDate;
                            if(bishopEvent[index]['allday'] != true) {
                              final String dateString = bishopEvent[index]['start'];
                              final DateTime date = DateFormat('dd-MM-yyyy hh:mm a').parse(dateString);
                              DateTime today = DateTime.now();
                              final DateFormat formatter = DateFormat('dd-MM-yyyy');
                              dateValue = formatter.format(date);
                              nowDate = formatter.format(today);
                              currentDate = today;
                              parsedDate = DateFormat('dd-MM-yyyy').parse(dateValue);
                              final DateFormat dayFormat = DateFormat('EEEE');
                              day = dayFormat.format(date);
                            } else {
                              final String dateString = bishopEvent[index]['start_date'];
                              final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                              DateTime today = DateTime.now();
                              nowDate = DateFormat('dd-MM-yyyy').format(today);
                              final DateFormat formatter = DateFormat('dd-MM-yyyy');
                              dateValue = formatter.format(date);
                              currentDate = today;
                              parsedDate = DateFormat('dd-MM-yyyy').parse(dateValue);
                            }
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: ScaleAnimation(
                                  child: bishopEvent[index]['allday'] != true ? Column(
                                    children: [
                                      if(nowDate == dateValue) Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${bishopEvent[index]['name']}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.calendar_month, color: Colors.orange,),
                                                      SizedBox(width: size.width * 0.01,),
                                                      RichText(
                                                        textAlign: TextAlign.left,
                                                        text: TextSpan(
                                                            text: DateFormat('dd MMMM, yyyy').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                            style: GoogleFonts.signika(
                                                              color: textColor,
                                                              fontSize: size.height * 0.021,
                                                            ),
                                                            children: bishopEvent[index]['session'] != null && bishopEvent[index]['session'] != '' ? [
                                                              const TextSpan(
                                                                text: '  ',
                                                              ),
                                                              TextSpan(
                                                                text: bishopEvent[index]['session'],
                                                                style: GoogleFonts.signika(
                                                                  color: textColor,
                                                                  fontSize: size.height * 0.021,
                                                                ),
                                                              ),
                                                            ] : []
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                    style: GoogleFonts.signika(
                                                      color: Colors.orange,
                                                      fontSize: size.height * 0.021,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.location_on, color: Colors.redAccent,),
                                                  SizedBox(width: size.width * 0.01,),
                                                  bishopEvent[index]['location'] != '' && bishopEvent[index]['location'] != null ? Flexible(child: Text('${bishopEvent[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      bishopEvent[index]['description_html'].replaceAll(exp, ''),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: size.height * 0.018),
                                                    ),
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15)
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: size.height * 0.01,
                                                                  ),
                                                                  Expanded(
                                                                    child: SingleChildScrollView(
                                                                      child: Html(
                                                                        data: bishopEvent[index]['description_html'],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                        alignment: Alignment.topRight,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            const Text('More', style: TextStyle(
                                                                color: Colors.indigoAccent
                                                            ),),
                                                            SizedBox(width: size.width * 0.018,),
                                                            const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                          ],
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ) : Container(),
                                            ],
                                          ),
                                        ),
                                      ) else if(currentDate.isBefore(parsedDate)) Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${bishopEvent[index]['name']}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.calendar_month, color: Colors.orange,),
                                                      SizedBox(width: size.width * 0.01,),
                                                      RichText(
                                                        textAlign: TextAlign.left,
                                                        text: TextSpan(
                                                            text: DateFormat('dd MMMM, yyyy').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                            style: GoogleFonts.signika(
                                                              color: textColor,
                                                              fontSize: size.height * 0.021,
                                                            ),
                                                            children: bishopEvent[index]['session'] != null && bishopEvent[index]['session'] != '' ? [
                                                              const TextSpan(
                                                                text: '  ',
                                                              ),
                                                              TextSpan(
                                                                text: bishopEvent[index]['session'],
                                                                style: GoogleFonts.signika(
                                                                  color: textColor,
                                                                  fontSize: size.height * 0.021,
                                                                ),
                                                              ),
                                                            ] : []
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                    style: GoogleFonts.signika(
                                                      color: Colors.orange,
                                                      fontSize: size.height * 0.021,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.location_on, color: Colors.redAccent,),
                                                  SizedBox(width: size.width * 0.01,),
                                                  bishopEvent[index]['location'] != '' && bishopEvent[index]['location'] != null ? Flexible(child: Text('${bishopEvent[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      bishopEvent[index]['description_html'].replaceAll(exp, ''),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: size.height * 0.018),
                                                    ),
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15)
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: size.height * 0.01,
                                                                  ),
                                                                  Expanded(
                                                                    child: SingleChildScrollView(
                                                                      child: Html(
                                                                        data: bishopEvent[index]['description_html'],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                        alignment: Alignment.topRight,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            const Text('More', style: TextStyle(
                                                                color: Colors.indigoAccent
                                                            ),),
                                                            SizedBox(width: size.width * 0.018,),
                                                            const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                          ],
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ) : Container(),
                                            ],
                                          ),
                                        ),
                                      ) else Container(),
                                    ],
                                  ) : Column(
                                    children: [
                                      if(nowDate == dateValue) Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${bishopEvent[index]['name']}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.calendar_month, color: Colors.orange,),
                                                      SizedBox(width: size.width * 0.01,),
                                                      RichText(
                                                        textAlign: TextAlign.left,
                                                        text: TextSpan(
                                                            text: DateFormat('dd MMMM, yyyy').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                            style: GoogleFonts.signika(
                                                              color: textColor,
                                                              fontSize: size.height * 0.021,
                                                            ),
                                                            children: bishopEvent[index]['session'] != null && bishopEvent[index]['session'] != '' ? [
                                                              const TextSpan(
                                                                text: '  ',
                                                              ),
                                                              TextSpan(
                                                                text: bishopEvent[index]['session'],
                                                                style: GoogleFonts.signika(
                                                                  color: textColor,
                                                                  fontSize: size.height * 0.021,
                                                                ),
                                                              ),
                                                            ] : []
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                    style: GoogleFonts.signika(
                                                      color: Colors.orange,
                                                      fontSize: size.height * 0.021,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.location_on, color: Colors.redAccent,),),
                                                  bishopEvent[index]['location'] != '' && bishopEvent[index]['location'] != null ? Text(bishopEvent[index]['location'], style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Text("-", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      bishopEvent[index]['description_html'].replaceAll(exp, ''),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15)
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: size.height * 0.01,
                                                                  ),
                                                                  Expanded(
                                                                    child: SingleChildScrollView(
                                                                      child: Html(
                                                                        data: bishopEvent[index]['description_html'],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                        alignment: Alignment.topRight,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            const Text('More', style: TextStyle(
                                                                color: Colors.indigoAccent
                                                            ),),
                                                            SizedBox(width: size.width * 0.018,),
                                                            const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                          ],
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ) : Container(),
                                            ],
                                          ),
                                        ),
                                      ) else if(currentDate.isBefore(parsedDate)) Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${bishopEvent[index]['name']}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.calendar_month, color: Colors.orange,),
                                                      SizedBox(width: size.width * 0.01,),
                                                      RichText(
                                                        textAlign: TextAlign.left,
                                                        text: TextSpan(
                                                            text: DateFormat('dd MMMM, yyyy').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                            style: GoogleFonts.signika(
                                                              color: textColor,
                                                              fontSize: size.height * 0.021,
                                                            ),
                                                            children: bishopEvent[index]['session'] != null && bishopEvent[index]['session'] != '' ? [
                                                              const TextSpan(
                                                                text: '  ',
                                                              ),
                                                              TextSpan(
                                                                text: bishopEvent[index]['session'],
                                                                style: GoogleFonts.signika(
                                                                  color: textColor,
                                                                  fontSize: size.height * 0.021,
                                                                ),
                                                              ),
                                                            ] : []
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat('EEEE').format(DateFormat('dd-MM-yyyy hh:mm a').parse(bishopEvent[index]['start'])),
                                                    style: GoogleFonts.signika(
                                                      color: Colors.orange,
                                                      fontSize: size.height * 0.021,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                              Row(
                                                children: [
                                                  Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.location_on, color: Colors.redAccent,),),
                                                  bishopEvent[index]['location'] != '' && bishopEvent[index]['location'] != null ? Text(bishopEvent[index]['location'], style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Text("-", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                ],
                                              ),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                              bishopEvent[index]['description_html'].replaceAll(exp, '') != null && bishopEvent[index]['description_html'].replaceAll(exp, '') != '' ? Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      bishopEvent[index]['description_html'].replaceAll(exp, ''),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: size.width * 0.01,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15)
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: size.height * 0.01,
                                                                  ),
                                                                  Expanded(
                                                                    child: SingleChildScrollView(
                                                                      child: Html(
                                                                        data: bishopEvent[index]['description_html'],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                        alignment: Alignment.topRight,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            const Text('More', style: TextStyle(
                                                                color: Colors.indigoAccent
                                                            ),),
                                                            SizedBox(width: size.width * 0.018,),
                                                            const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                          ],
                                                        )
                                                    ),
                                                  )
                                                ],
                                              ) : Container(),
                                            ],
                                          ),
                                        ),
                                      ) else Container(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) : Center(
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
              child: SizedBox(
                height: 50,
                width: 180,
                child: textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
