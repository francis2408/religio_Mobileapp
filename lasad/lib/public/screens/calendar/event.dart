import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PublicEventScreen extends StatefulWidget {
  const PublicEventScreen({Key? key}) : super(key: key);

  @override
  State<PublicEventScreen> createState() => _PublicEventScreenState();
}

class _PublicEventScreenState extends State<PublicEventScreen> {
  DateTime currentDateTime = DateTime.now();
  bool load = true;
  bool isExpand = false;
  String limitCount = '';
  String eventCount = '';
  String nowDate = '';
  String dateValue = '';
  String day = '';

  bool _isLoading = true;
  List eventData = [];

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  void getEventData() async {
    setState(() {
      _isLoading = true;
    });
    var request = http.Request('GET', Uri.parse("$baseUrl/events/calendar/province/calendar/$userProvinceId"));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      eventData = data;
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
    setState(() {
      _isLoading = false;
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
    // TODO: implement initState
    super.initState();
    getEventData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: backgroundColor,
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
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
            ),
          ),
        ) : eventData.isNotEmpty ? Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Showing 1 - ${eventData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),),
                ],
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  interactive: true,
                  radius: const Radius.circular(20),
                  thickness: 8,
                  child: SlideFadeAnimation(
                    duration: const Duration(seconds: 1),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime currentDate;
                          DateTime parsedDate;
                          if(eventData[index]['allday'] != true) {
                            final String dateString = eventData[index]['start_datetime'];
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
                            final String dateString = eventData[index]['start_date'];
                            final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                            DateTime today = DateTime.now();
                            nowDate = DateFormat('dd-MM-yyyy').format(today);
                            final DateFormat formatter = DateFormat('dd-MM-yyyy');
                            dateValue = formatter.format(date);
                            currentDate = today;
                            parsedDate = DateFormat('dd-MM-yyyy').parse(dateValue);
                          }
                          return eventData[index]['allday'] != 'Yes' ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${eventData[index]['name']}',
                                        style: GoogleFonts.signika(
                                          fontSize: size.height * 0.022,
                                          color: textColor,
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
                                              const Icon(Icons.calendar_month, color: iconColor2,),
                                              SizedBox(width: size.width * 0.01,),
                                              eventData[index]['allday'] != true ? Text(
                                                eventData[index]['start_datetime'],
                                                style: GoogleFonts.signika(
                                                  color: textColor,
                                                  fontSize: size.height * 0.021,
                                                ),
                                              ) : eventData[index]['start_date'] == eventData[index]['stop_date'] ? Text(
                                                eventData[index]['start_date'],
                                                style: GoogleFonts.signika(
                                                    color: textColor,
                                                    fontSize: size.height * 0.021
                                                ),
                                              ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Text(
                                                eventData[index]['start_date'],
                                                style: GoogleFonts.signika(
                                                    color: textColor,
                                                    fontSize: size.height * 0.021
                                                ),
                                              ) : Row(
                                                children: [
                                                  eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' ? Text(eventData[index]['start_date'], style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021),) : const Text(""),
                                                  eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? SizedBox(width: size.width * 0.03,) : Container(),
                                                  eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? Text("-", style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021,),) : Container(),
                                                  eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? SizedBox(width: size.width * 0.03,) : Container(),
                                                  eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? Text(eventData[index]['stop_date'], style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021,),
                                                  ) : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                          eventData[index]['allday'] != true ? Text(
                                            day,
                                            style: GoogleFonts.signika(
                                              color: mobileText,
                                              fontSize: size.height * 0.021,
                                            ),
                                          ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Text(
                                            eventData[index]['start_date'],
                                            style: GoogleFonts.signika(
                                              color: mobileText,
                                              fontSize: size.height * 0.021,
                                            ),
                                          ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Text(
                                            eventData[index]['start_date'],
                                            style: GoogleFonts.signika(
                                              color: mobileText,
                                              fontSize: size.height * 0.021,
                                            ),
                                          ) : Container(),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on, color: iconColor2,),
                                          SizedBox(width: size.width * 0.01,),
                                          eventData[index]['location'] != '' && eventData[index]['location'] != null ? Flexible(child: Text('${eventData[index]['location']}', style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.021),)) : Text("-", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.01,),
                                      eventData[index]['description_html'].replaceAll(exp, '') != null && eventData[index]['description_html'].replaceAll(exp, '') != '' ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              eventData[index]['description_html'].replaceAll(exp, ''),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: size.height * 0.018,color: valueColor),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.01,),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                backgroundColor: screenBackgroundColor,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                ),
                                                builder: (BuildContext context) {
                                                  return CustomContentBottomSheet(
                                                      size: size,
                                                      title: "Content",
                                                      content: eventData[index]['description_html']
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
                                                        color: mobileText
                                                    ),),
                                                    SizedBox(width: size.width * 0.018,),
                                                    const Icon(Icons.arrow_forward_ios, color: mobileText, size: 11,)
                                                  ],
                                                )
                                            ),
                                          )
                                        ],
                                      ) : Text(
                                        'No description available',
                                        style: GoogleFonts.secularOne(
                                          letterSpacing: 0.5,
                                          fontSize: size.height * 0.017,
                                          color: emptyColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: size.height * 0.005,
                                  right: size.width * 0.01,
                                  child: Row(
                                    children: [
                                      if(DateFormat('dd-MM-yyyy').format(currentDate) == eventData[index]['start_date']) Container(
                                        height: size.height * 0.04,
                                        width: size.width * 0.1,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/images/pin.png"),
                                          ),
                                        ),
                                      ) else if(DateFormat('dd-MM-yyyy').format(currentDate) == eventData[index]['stop_date']) Container(
                                        height: size.height * 0.04,
                                        width: size.width * 0.1,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/images/pin.png"),
                                          ),
                                        ),
                                      ),
                                      if(eventData[index]['recurrency'] == true) Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: screenColor,
                                        ),
                                        child: Text(
                                          'Recurrency',
                                          style: TextStyle(
                                              fontSize: size.height * 0.014,
                                              fontWeight: FontWeight.bold,
                                              color: screenColor,
                                              fontStyle: FontStyle.italic
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ) : Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${eventData[index]['name']}',
                                        style: GoogleFonts.signika(
                                          fontSize: size.height * 0.022,
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.01,
                                      ),
                                      eventData[index]['start_date'] == eventData[index]['stop_date'] ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.calendar_month, color: iconColor2,),),
                                              Text(eventData[index]['start_date'], style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021),),
                                            ],
                                          ),
                                          Text(
                                            eventData[index]['start_date'],
                                            style: GoogleFonts.signika(
                                              color: mobileText,
                                              fontSize: size.height * 0.021,
                                            ),
                                          )
                                        ],
                                      ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.calendar_month, color: iconColor2,),),
                                              Text(eventData[index]['start_date'], style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021),),
                                            ],
                                          ),
                                          Text(
                                            eventData[index]['start_date'],
                                            style: GoogleFonts.signika(
                                              color: mobileText,
                                              fontSize: size.height * 0.021,
                                            ),
                                          )
                                        ],
                                      ) : Row(
                                        children: [
                                          Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.calendar_month, color: iconColor2,),),
                                          eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' ? Text(eventData[index]['start_date'], style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021),) : const Text(""),
                                          eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? SizedBox(width: size.width * 0.03,) : Container(),
                                          eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? Text("-", style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021,),) : Container(),
                                          eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? SizedBox(width: size.width * 0.03,) : Container(),
                                          eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? Text(eventData[index]['stop_date'], style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.021,),
                                          ) : Container(),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.01,),
                                      Row(
                                        children: [
                                          Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.location_on, color: iconColor2,),),
                                          eventData[index]['location'] != '' && eventData[index]['location'] != null ? Text(eventData[index]['location'], style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.021),) : Text("-", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.01,),
                                      eventData[index]['description_html'].replaceAll(exp, '') != null && eventData[index]['description_html'].replaceAll(exp, '') != '' ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              eventData[index]['description_html'].replaceAll(exp, ''),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: size.height * 0.018,color: valueColor),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.01,),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                backgroundColor: screenBackgroundColor,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                ),
                                                builder: (BuildContext context) {
                                                  return CustomContentBottomSheet(
                                                      size: size,
                                                      title: "Content",
                                                      content: eventData[index]['description_html']
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
                                                        color: mobileText
                                                    ),),
                                                    SizedBox(width: size.width * 0.018,),
                                                    const Icon(Icons.arrow_forward_ios, color: mobileText, size: 11,)
                                                  ],
                                                )
                                            ),
                                          )
                                        ],
                                      ) : Text(
                                        'No description available',
                                        style: GoogleFonts.secularOne(
                                          letterSpacing: 0.5,
                                          fontSize: size.height * 0.017,
                                          color: emptyColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: size.height * 0.005,
                                  right: size.width * 0.01,
                                  child: Row(
                                    children: [
                                      if(DateFormat('dd-MM-yyyy').format(currentDate) == eventData[index]['start_date']) Container(
                                        height: size.height * 0.04,
                                        width: size.width * 0.1,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/images/pin.png"),
                                          ),
                                        ),
                                      ) else if(DateFormat('yyyy-dd-MM-yyyy-dd').format(currentDate) == eventData[index]['stop_date']) Container(
                                        height: size.height * 0.04,
                                        width: size.width * 0.1,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/images/pin.png"),
                                          ),
                                        ),
                                      ),
                                      if(eventData[index]['recurrency'] == true) Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: screenColor,
                                        ),
                                        child: Text(
                                          'Recurrency',
                                          style: TextStyle(
                                              fontSize: size.height * 0.014,
                                              fontWeight: FontWeight.bold,
                                              color: screenColor,
                                              fontStyle: FontStyle.italic
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
        ) : Expanded(
          child: Center(
            child: Container(
              alignment: Alignment.center,
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
