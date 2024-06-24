import 'dart:convert';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _controller = CalendarController();
  DateTime currentDateTime = DateTime.now();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isChecked = false;
  var isAllDay;

  var selectDate;
  String startDate = '';
  String endDate = '';
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  String eventName = '';
  String eventStartDate = '';
  String eventEndDate = '';
  String eventLocation = '';
  bool boolAllDay = false;

  final List<Color> _colorCollection=<Color>[];
  final List<Meeting> events = [];

  var headers = {
    'Authorization': authToken,
    'Content-Type': 'application/json',
  };

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

  _authTokenExpire() {
    AnimatedSnackBar.material(
        'Your session was expired; please login again.',
        type: AnimatedSnackBarType.info,
        duration: const Duration(seconds: 10)
    ).show(context);
  }

  clearSharedPreferenceData() async {
    // Deleting shared-preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAuthTokenKey');
    await prefs.remove('userTokenExpires');
    await prefs.remove('userIdKey');
    await prefs.remove('userNameKey');
    await prefs.remove('userEmailKey');
    await prefs.remove('userImageKey');
    await prefs.remove('userDioceseKey');
    await prefs.remove('userMemberKey');
    await HelperFunctions.setUserLoginSF(false);
    authToken = '';
    tokenExpire = '';
    userID = '';
    userName = '';
    userEmail = '';
    userImage = '';
    userLevel = '';
    userDiocese = '';
    userMember = '';
    await Future.delayed(const Duration(seconds: 1));

    Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
    _authTokenExpire();
  }

  @override
  void initState() {
    // Check Internet connection
    internetCheck();
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      _initializeEventColor();
      _isLoading = false;
    } else {
      clearSharedPreferenceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
        backgroundColor: backgroundColor,
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
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: FutureBuilder(
              future: expiryDateTime!.isAfter(currentDateTime) ? getDataFromWeb() : clearSharedPreferenceData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return SafeArea(
                  child: SfCalendar(
                    view: CalendarView.month,
                    headerStyle: CalendarHeaderStyle(
                        textAlign: TextAlign.left,
                        // backgroundColor: const Color(0xFFF09819),
                        textStyle: GoogleFonts.secularOne(
                          letterSpacing: 1.5,
                          fontSize: size.height * 0.023,
                          color: Colors.black,
                        )
                    ),
                    selectionDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF512F),
                          width: 1,
                        )
                    ),
                    viewHeaderStyle: ViewHeaderStyle(
                        // backgroundColor: const Color(0xFFC9C6C6),
                        dayTextStyle: TextStyle(
                            fontSize: size.height * 0.02,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                    ),
                    monthCellBuilder: monthCellBuilder,
                    todayHighlightColor: const Color(0xFFFF512F),
                    todayTextStyle: GoogleFonts.fjallaOne(
                      fontSize: size.height * 0.015,
                      fontWeight: FontWeight.bold,
                    ),
                    allowViewNavigation: true,
                    showNavigationArrow: true,
                    showDatePickerButton: false,
                    initialSelectedDate: DateTime.now(),
                    initialDisplayDate: DateTime.now(),
                    dataSource: MeetingDataSource(snapshot.data),
                    monthViewSettings: MonthViewSettings(
                      dayFormat: 'EEE',
                      showAgenda: true,
                      agendaViewHeight: size.height * 0.4,
                      agendaItemHeight: size.height * 0.06,
                      agendaStyle: AgendaStyle(
                        backgroundColor: screenBackgroundColor,
                        appointmentTextStyle: TextStyle(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        dateTextStyle: GoogleFonts.fjallaOne(
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        dayTextStyle: TextStyle(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF512F)
                        ),
                      ),
                      // appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                    ),
                    onTap: expiryDateTime!.isAfter(currentDateTime) ? calendarTapped : clearSharedPreferenceData(),
                    onSelectionChanged: (CalendarSelectionDetails details){
                      selectDate = details.date;
                      startDate = reverse.format(selectDate);
                      startDateController.text = format.format(selectDate);
                      endDate = reverse.format(selectDate);
                      endDateController.text = format.format(selectDate);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  calendarTapped(CalendarTapDetails details) {
    // Check Internet connection
    internetCheck();

    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      Meeting meeting = details.appointments![0];
      eventId = meeting.eventId;
      eventName = meeting.eventName!;
      eventLocation = meeting.location!;
      eventStartDate = format.format(meeting.from as DateTime);
      eventEndDate = format.format(meeting.to as DateTime);
      boolAllDay = meeting.allDay!;

      // Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewCalendarEventScreen()));

      // Bottom sheet
      Size size = MediaQuery.of(context).size;
      showMaterialModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        ),
        bounce: true,
        builder: (context) => SizedBox(
          height: size.height * 0.3,
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: iconColor,)
                : SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('View Event', style: TextStyle(color: Colors.indigo, fontSize: MediaQuery.of(context).size.height * 0.02, fontWeight: FontWeight.bold),),
                          IconButton(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.cancel, color: Colors.red,))
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    eventName != null && eventName != '' ? Text(eventName, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    startDate.isNotEmpty && startDate != null && startDate != '' ? Text(startDate, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : const Text(""),
                                    SizedBox(width: size.width * 0.05,),
                                    Text("-", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),),
                                    SizedBox(width: size.width * 0.05,),
                                    endDate.isNotEmpty && endDate != null && endDate != '' ? Text(
                                      endDate, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                    ) : Text(
                                      "Till Now", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02,),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015,),
                                Row(
                                  children: [
                                    Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                    SizedBox(width: size.width * 0.02,),
                                    eventLocation != '' && eventLocation != null ? Text(eventLocation, style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Future getDataFromWeb() async {
    // Check Internet connection
    internetCheck();

    String url = '$baseUrl/calendar.event';
    Map data = {
      "params": {
        "query": "{id,name,start_date,stop_date,allday,location,description}"
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
      final Random random = Random();
      for (var data in jsonData) {
        Meeting meetingData = Meeting(
          eventId: data['id'],
          eventName: data['name'],
          from: _convertDateFromString(data['start_date']),
          to: _convertDateFromString(data['stop_date']),
          background: _colorCollection[random.nextInt(10)],
          location: data['location'],
          allDay: data['allday'],
        );
        events.add(meetingData);
      }
      return events;
    } else {
      var message = json.decode(response.body)['message'];
      setState(() {
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

  Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
    Size size = MediaQuery.of(context).size;
    if (details.date.month == DateTime.now().month) {
      if (details.date.day == DateTime.now().day) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF512F),
                  Color(0xFFF09819)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              details.date.day.toString(),
              style: GoogleFonts.fjallaOne(
              fontSize: size.height * 0.018,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: const Color(0xFFFACBC0)
        ),
        child: Text(
          details.date.day.toString(),
          style: GoogleFonts.secularOne(
              fontSize: size.height * 0.018,
          ),
        ),
      ),
    );
  }

  DateTime _convertDateFromString(String date) {
    return DateFormat("dd-MM-yyyy").parse(date);
  }

  void _initializeEventColor() {
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting>? source) {
    appointments = source;
  }

  @override
  int getId(int index) {
    return appointments![index].eventId;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].allDay;
  }

  @override
  String getLocation(int index) {
    return appointments![index].location;
  }

}

class Meeting {
  Meeting({
    this.eventId,
    this.eventName,
    this.from,
    this.to,
    this.background,
    this.location,
    this.allDay = false
  });

  int? eventId;
  String? eventName;
  DateTime? from;
  DateTime? to;
  String? location;
  Color? background;
  bool? allDay;
}
