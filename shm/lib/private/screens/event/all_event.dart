import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shm/private/screens/event/add_event.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/slide_animations.dart';
import 'package:shm/widget/common/snackbar.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

import 'edit_event.dart';

class AllEventScreen extends StatefulWidget {
  const AllEventScreen({Key? key}) : super(key: key);

  @override
  State<AllEventScreen> createState() => _AllEventScreenState();
}

class _AllEventScreenState extends State<AllEventScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late ScrollController _controller;

  DateTime currentDateTime = DateTime.now();
  bool _showContainer = false;
  Timer? _containerTimer;
  bool _isLoading = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool load = true;
  bool isExpand = false;
  String limitCount = '';
  String eventCount = '';
  String nowDate = '';
  String dateValue = '';
  String day = '';

  List eventData = [];
  int selected = -1;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isLoading == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 500) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      // Cancel the previous timer if it exists
      _containerTimer?.cancel();
      eventPage += eventLimit;
      var request;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if(selectedTab == 'All') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
      } else if(selectedTab == 'Upcoming') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar'),('start_date','>=','$today')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
      } else if(selectedTab == 'Provincial') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar'),('calendar_config_type_id.name','=','Provincial Calendar')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
      } else if(selectedTab == 'Province') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar'),('calendar_config_type_id.name','=','Province Calendar')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
      } else {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('category','=','calendar'),('user_id','=',$userId)]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
      }
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var result = json.decode(await response.stream.bytesToString());
        final List fetchedPosts = result['data'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            eventData.addAll(fetchedPosts);
            limitCount = eventData.length.toString();
          });
        } else {
          setState(() {
            _hasNextPage = false;
            _showContainer = true;
          });
          // Start the timer to auto-close the container after 2 seconds
          _containerTimer = Timer(const Duration(seconds: 2), () {
            setState(() {
              _showContainer = false;
            });
          });
        }
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
        _isLoadMoreRunning = false;
      });
    }
  }

  void getAllEventData() async {
    setState(() {
      _isLoading = true;
    });
    var request;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if(selectedTab == 'All') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
    } else if(selectedTab == 'Upcoming') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar'),('start_date','>=','$today')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
    } else if(selectedTab == 'Provincial') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar'),('calendar_config_type_id.name','=','Provincial Calendar')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
    } else if(selectedTab == 'Province') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('type','=','public'),('category','=','calendar'),('calendar_config_type_id.name','=','Province Calendar')]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
    } else {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday','description_html','user_id','recurrency']&domain=[('category','=','calendar'),('user_id','=',$userId)]&limit=$eventLimit&offset=$eventPage&order=stop_date desc"""));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      eventCount = result['total_count'].toString();
      List data = result['data'];
      eventData = data;
      limitCount = eventData.length.toString();
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

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/calendar.event?ids=[$eventID]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
        load = false;
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Event data deleted successfully.',
            Colors.green
        );
      });
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getAllEventData();
    });
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getAllEventData();
      _controller = ScrollController()..addListener(_loadMore);
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
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            loadDataWithDelay();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _containerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
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
        ) : eventData.isNotEmpty ? Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Showing 1 - $limitCount of $eventCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
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
                        controller: _controller,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime currentDate;
                          DateTime parsedDate;
                          if(eventData[index]['allday'] != 'Yes') {
                            final String dateString = eventData[index]['start_datetime'];
                            final DateTime date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
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
                          return eventData[index]['allday'] != 'Yes' ? GestureDetector(
                            onTap: () {
                              eventID = eventData[index]['id'];
                              deleteID = eventData[index]['user_id'][0];
                              // Bottom sheet
                              if(selectedTab == 'My Calendar') {
                                Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                  return CustomBottomSheet(
                                    size: size, // Pass the 'size' variable
                                    onDeletePressed: () {
                                      setState(() {
                                        Navigator.pop(context);
                                        (userId == deleteID) ? showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmAlertDialog(
                                              message: 'Are you sure you want to delete the event data?',
                                              onCancelPressed: () {
                                                cancel();
                                              },
                                              onYesPressed: () {
                                                if(load) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      return const CustomLoadingDialog();
                                                    },
                                                  );
                                                  delete();
                                                }
                                              },
                                            );
                                          },
                                        ) : showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WarningAlertDialog(
                                                message: 'Sorry, you are not allowed to delete this.?',
                                                onOkPressed: () {
                                                  Navigator.pop(context);
                                                }
                                            );
                                          },
                                        );
                                      });
                                    },
                                    onEditPressed: () async {
                                      Navigator.pop(context);
                                      String refresh = await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const EditEventScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                  );
                                });
                              }
                            },
                            child: Card(
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
                                                const Icon(Icons.calendar_month, color: menuPrimaryColor,),
                                                SizedBox(width: size.width * 0.01,),
                                                eventData[index]['allday'] != 'Yes' ? Text(
                                                  DateFormat('dd MMMM, yyyy hh:mm a').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(eventData[index]['start_datetime'])),
                                                  style: GoogleFonts.signika(
                                                    color: hiLightColor,
                                                    fontSize: size.height * 0.021,
                                                  ),
                                                ) : eventData[index]['start_date'] == eventData[index]['stop_date'] ? Text(
                                                  DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['start_date'])),
                                                  style: GoogleFonts.signika(
                                                      color: hiLightColor,
                                                      fontSize: size.height * 0.021
                                                  ),
                                                ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Text(
                                                  DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['start_date'])),
                                                  style: GoogleFonts.signika(
                                                      color: hiLightColor,
                                                      fontSize: size.height * 0.021
                                                  ),
                                                ) : Text(
                                                  DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['start_date'])),
                                                  style: GoogleFonts.signika(
                                                    color: hiLightColor,
                                                    fontSize: size.height * 0.021,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            eventData[index]['allday'] != 'Yes' ? Text(
                                              day,
                                              style: GoogleFonts.signika(
                                                color: mobileText,
                                                fontSize: size.height * 0.021,
                                              ),
                                            ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Text(
                                              DateFormat('EEEE').format(DateTime.parse(eventData[index]['start_date'])),
                                              style: GoogleFonts.signika(
                                                color: mobileText,
                                                fontSize: size.height * 0.021,
                                              ),
                                            ) : eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' && eventData[index]['stop_date'] == '' ? Text(
                                              DateFormat('EEEE').format(DateTime.parse(eventData[index]['start_date'])),
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
                                            const Icon(Icons.location_on, color: menuPrimaryColor,),
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
                                                style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
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
                                        if(DateFormat('yyyy-MM-dd').format(currentDate) == eventData[index]['start_date']) Container(
                                          height: size.height * 0.04,
                                          width: size.width * 0.1,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/pin.png"),
                                            ),
                                          ),
                                        ) else if(DateFormat('yyyy-MM-dd').format(currentDate) == eventData[index]['stop_date']) Container(
                                          height: size.height * 0.04,
                                          width: size.width * 0.1,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/pin.png"),
                                            ),
                                          ),
                                        ),
                                        if(eventData[index]['recurrency'] == 'Yes') Container(
                                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: customBackgroundColor2,
                                          ),
                                          child: Text(
                                            'Recurrency',
                                            style: TextStyle(
                                                fontSize: size.height * 0.014,
                                                fontWeight: FontWeight.bold,
                                                color: customTextColor2,
                                                fontStyle: FontStyle.italic
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ) : GestureDetector(
                            onTap: () {
                              eventID = eventData[index]['id'];
                              deleteID = eventData[index]['user_id'][0];
                              // Bottom sheet
                              if(selectedTab == 'My Calendar') {
                                Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                  return CustomBottomSheet(
                                    size: size, // Pass the 'size' variable
                                    onDeletePressed: () {
                                      setState(() {
                                        Navigator.pop(context);
                                        (userId == deleteID) ? showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmAlertDialog(
                                              message: 'Are you sure you want to delete the event data?',
                                              onCancelPressed: () {
                                                cancel();
                                              },
                                              onYesPressed: () {
                                                if(load) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      return const CustomLoadingDialog();
                                                    },
                                                  );
                                                  delete();
                                                }
                                              },
                                            );
                                          },
                                        ) : showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WarningAlertDialog(
                                                message: 'Sorry, you are not allowed to delete this.',
                                                onOkPressed: () {
                                                  Navigator.pop(context);
                                                }
                                            );
                                          },
                                        );
                                      });
                                    },
                                    onEditPressed: () async {
                                      Navigator.pop(context);
                                      String refresh = await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const EditEventScreen()));
                                      if(refresh == 'refresh') {
                                        changeData();
                                      }
                                    },
                                  );
                                });
                              }
                            },
                            child: Card(
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
                                                Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.calendar_month, color: menuPrimaryColor,),),
                                                Text(DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['start_date'])), style: GoogleFonts.signika(color: hiLightColor, fontSize: size.height * 0.021),),
                                              ],
                                            ),
                                            Text(
                                              DateFormat('EEEE').format(DateTime.parse(eventData[index]['start_date'])),
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
                                                Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.calendar_month, color: menuPrimaryColor,),),
                                                Text(DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['start_date'])), style: GoogleFonts.signika(color: hiLightColor, fontSize: size.height * 0.021),),
                                              ],
                                            ),
                                            Text(
                                              DateFormat('EEEE').format(DateTime.parse(eventData[index]['start_date'])),
                                              style: GoogleFonts.signika(
                                                color: mobileText,
                                                fontSize: size.height * 0.021,
                                              ),
                                            )
                                          ],
                                        ) : Row(
                                          children: [
                                            Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.calendar_month, color: menuPrimaryColor,),),
                                            eventData[index]['start_date'] != null && eventData[index]['start_date'] != '' ? Text(DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['start_date'])), style: GoogleFonts.signika(color: hiLightColor, fontSize: size.height * 0.021),) : const Text(""),
                                            eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? SizedBox(width: size.width * 0.03,) : Container(),
                                            eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? Text("-", style: GoogleFonts.signika(color: hiLightColor, fontSize: size.height * 0.021,),) : Container(),
                                            eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? SizedBox(width: size.width * 0.03,) : Container(),
                                            eventData[index]['stop_date'] != null && eventData[index]['stop_date'] != '' ? Text(
                                              DateFormat("dd-MMM-yyyy").format(DateFormat("yyyy-MM-dd").parse(eventData[index]['stop_date'])), style: GoogleFonts.signika(color: hiLightColor, fontSize: size.height * 0.021,),
                                            ) : Container(),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.01,),
                                        Row(
                                          children: [
                                            Container(width: size.width * 0.08, alignment: Alignment.topLeft, child: const Icon(Icons.location_on, color: menuPrimaryColor,),),
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
                                                style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
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
                                        if(DateFormat('yyyy-MM-dd').format(currentDate) == eventData[index]['start_date']) Container(
                                          height: size.height * 0.04,
                                          width: size.width * 0.1,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/pin.png"),
                                            ),
                                          ),
                                        ) else if(DateFormat('yyyy-MM-dd').format(currentDate) == eventData[index]['stop_date']) Container(
                                          height: size.height * 0.04,
                                          width: size.width * 0.1,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/images/pin.png"),
                                            ),
                                          ),
                                        ),
                                        if(eventData[index]['recurrency'] == 'Yes') Container(
                                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: customBackgroundColor2,
                                          ),
                                          child: Text(
                                            'Recurrency',
                                            style: TextStyle(
                                                fontSize: size.height * 0.014,
                                                fontWeight: FontWeight.bold,
                                                color: customTextColor2,
                                                fontStyle: FontStyle.italic
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if(_isLoadMoreRunning == true)
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.width * 0.01),
                  child: Center(
                    child: Container(
                        height: size.height * 0.1,
                        width: size.width * 0.2,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage( "assets/alert/spinner_1.gif"),
                          ),
                        )
                    ),
                  ),
                ),
              if(_hasNextPage == false)
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: _showContainer ? 40 : 0,
                  color: Colors.grey,
                  child: const Center(
                    child: Text('You have fetched all of the data'),
                  ),
                ),
            ],
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
              text: 'No Data available',
            ),
          ),
        ),
      ),
      floatingActionButton: selectedTab == 'My Calendar' ? eventData.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor,
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEventScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,),
      ) : ConditionalFloatingActionButton(
        isEmpty: false,
        iconBackColor: iconBackColor,
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEventScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,),
      ) : Container(),
    );
  }
}
