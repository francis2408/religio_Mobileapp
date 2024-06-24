// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:lasad/widget/common/common.dart';
// import 'package:lasad/widget/theme_color/color.dart';
// import 'package:lasad/widget/internet_checker.dart';
// import 'package:lasad/widget/widget.dart';
// import 'package:loading_indicator/loading_indicator.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:quickalert/quickalert.dart';
// import 'package:switcher/core/switcher_size.dart';
// import 'package:switcher/switcher.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
//
// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreen> {
//   final formKey = GlobalKey<FormState>();
//   FocusNode searchFocusNode = FocusNode();
//   FocusNode textFieldFocusNode = FocusNode();
//   bool _isLoading = true;
//   bool isChecked = false;
//   var isAllDay;
//   List event = [];
//
//   List calendarType = [];
//
//   var selectDate;
//   String startDate = '';
//   String endDate = '';
//   String category = 'calendar';
//   String eventType = 'private';
//   var calendarTypeId;
//   var calendarTypeName;
//   var eventNameController = TextEditingController();
//   var durationController = TextEditingController();
//   var startDateController = TextEditingController();
//   var endDateController = TextEditingController();
//   var locationController = TextEditingController();
//
//   final format = DateFormat("dd-MM-yyyy");
//   final reverse = DateFormat("yyyy-MM-dd");
//
//   // View event screen values
//   String eventName = '';
//   String duration = '';
//   String eventStartDate = '';
//   String eventEndDate = '';
//   String cType = '';
//   String ppType = '';
//   String eventLocation = '';
//   bool boolAllDay = false;
//
//   final List<Color> _colorCollection=<Color>[];
//   final List<Meeting> events = [];
//
//   @override
//   void initState() {
//     // Check Internet connection
//     CheckInternetConnection.checkInternet().then((value) {
//       if(value) {
//         return null;
//       } else {
//         showDialogBox();
//       }
//     });
//     super.initState();
//     _initializeEventColor();
//     _isLoading = false;
//   }
//
//   showDialogBox() {
//     QuickAlert.show(
//       context: context,
//       type: QuickAlertType.warning,
//       title: 'Warning',
//       text: 'Please check your internet connection',
//       confirmBtnColor: buttonColor,
//       onConfirmBtnTap: () {
//         Navigator.pop(context);
//         CheckInternetConnection.checkInternet().then((value) {
//           if (value) {
//             return null;
//           } else {
//             showDialogBox();
//           }
//         });
//       },
//       width: 100.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: screenBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         title: const Text('Calendar Event'),
//         toolbarHeight: 50,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(25),
//                 bottomRight: Radius.circular(25)
//             )
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: _isLoading ? SizedBox(
//             height: size.height * 0.06,
//             child: const LoadingIndicator(
//               indicatorType: Indicator.ballSpinFadeLoader,
//               colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
//             ),
//           ) : Container(
//             color: Colors.white,
//             padding: const EdgeInsets.all(10),
//             child: FutureBuilder(
//               future: getDataFromWeb(),
//               builder: (BuildContext context, AsyncSnapshot snapshot) {
//                 return SafeArea(
//                   child: SfCalendar(
//                     view: CalendarView.month,
//                     headerStyle: CalendarHeaderStyle(
//                         textAlign: TextAlign.left,
//                         // backgroundColor: const Color(0xFFF09819),
//                         textStyle: GoogleFonts.secularOne(
//                           letterSpacing: 1.5,
//                           fontSize: size.height * 0.023,
//                           color: Colors.black,
//                         )
//                     ),
//                     selectionDecoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: const Color(0xFF39E8BC),
//                           width: 1,
//                         )
//                     ),
//                     viewHeaderStyle: ViewHeaderStyle(
//                       // backgroundColor: const Color(0xFFC9C6C6),
//                       dayTextStyle: TextStyle(
//                           fontSize: size.height * 0.02,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     monthCellBuilder: monthCellBuilder,
//                     todayHighlightColor: const Color(0xFF39E8BC),
//                     todayTextStyle: GoogleFonts.fjallaOne(
//                       fontSize: size.height * 0.015,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     allowViewNavigation: true,
//                     showNavigationArrow: true,
//                     showDatePickerButton: false,
//                     initialSelectedDate: DateTime.now(),
//                     initialDisplayDate: DateTime.now(),
//                     dataSource: MeetingDataSource(snapshot.data),
//                     monthViewSettings: MonthViewSettings(
//                       dayFormat: 'EEE',
//                       showAgenda: true,
//                       agendaViewHeight: size.height * 0.4,
//                       agendaItemHeight: size.height * 0.06,
//                       agendaStyle: AgendaStyle(
//                         backgroundColor: screenBackgroundColor,
//                         appointmentTextStyle: TextStyle(
//                             fontSize: size.height * 0.018,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white
//                         ),
//                         dateTextStyle: GoogleFonts.fjallaOne(
//                           fontSize: size.height * 0.018,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                         dayTextStyle: TextStyle(
//                             fontSize: size.height * 0.018,
//                             fontWeight: FontWeight.w700,
//                             color: const Color(0xFF39E8BC)
//                         ),
//                       ),
//                       // appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
//                     ),
//                     onTap:calendarTapped,
//                     onSelectionChanged: (CalendarSelectionDetails details){
//                       selectDate = details.date;
//                       startDate = reverse.format(selectDate);
//                       startDateController.text = format.format(selectDate);
//                       endDate = reverse.format(selectDate);
//                       endDateController.text = format.format(selectDate);
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   calendarTapped(CalendarTapDetails details) {
//     if (details.targetElement == CalendarElement.appointment ||
//         details.targetElement == CalendarElement.agenda) {
//       Meeting meeting = details.appointments![0];
//       event_id = meeting.eventId;
//       eventName = meeting.eventName!;
//       eventLocation = meeting.location!;
//       ppType = meeting.privatePublic!;
//       eventStartDate = format.format(meeting.from as DateTime);
//       eventEndDate = format.format(meeting.to as DateTime);
//       boolAllDay = meeting.allDay!;
//       showMaterialModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
//         ),
//         bounce: true,
//         builder: (context) => SizedBox(
//           height: MediaQuery.of(context).size.height * 0.58,
//           child: Center(
//             child: _isLoading
//                 ? const CircularProgressIndicator(color: iconColor,)
//                 : SingleChildScrollView(
//               controller: ModalScrollController.of(context),
//               child: Container(
//                 padding: const EdgeInsets.only(left: 10, right: 5),
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
//                             IconButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               icon: Icon(Icons.cancel, color: Colors.red, size: MediaQuery.of(context).size.height * 0.03,),
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: TextFormField(
//                           initialValue: eventName,
//                           readOnly: true,
//                           decoration: const InputDecoration(
//                             icon: Icon(
//                               Icons.event,
//                               color: Color(0xFF2661FA),
//                             ),
//                             labelText: "Event Name",
//                             labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: TextFormField(
//                           initialValue: eventStartDate,
//                           readOnly: true,
//                           decoration: const InputDecoration(
//                             icon: Icon(
//                               Icons.date_range,
//                               color: Color(0xFF2661FA),
//                             ),
//                             labelText: "Start Date",
//                             labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: TextFormField(
//                           initialValue: eventEndDate,
//                           readOnly: true,
//                           decoration: const InputDecoration(
//                             icon: Icon(
//                               Icons.date_range,
//                               color: Color(0xFF2661FA),
//                             ),
//                             labelText: "End Date",
//                             labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: TextFormField(
//                           initialValue: ppType,
//                           readOnly: true,
//                           decoration: const InputDecoration(
//                             icon: Icon(
//                               Icons.perm_identity,
//                               color: Color(0xFF2661FA),
//                             ),
//                             labelText: "Type",
//                             labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: TextFormField(
//                           initialValue: eventLocation != null && eventLocation != '' ? eventLocation : 'NA',
//                           readOnly: true,
//                           decoration: const InputDecoration(
//                             icon: Icon(
//                               Icons.location_on,
//                               color: Color(0xFF2661FA),
//                             ),
//                             labelText: "Location",
//                             labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: Row(
//                           children: <Widget>[
//                             const Icon(
//                               Icons.access_time,
//                               color: Color(0xFF2661FA),
//                             ),
//                             SizedBox(width: MediaQuery.of(context).size.width * 0.035,),
//                             const Text('All Day', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//                             SizedBox(width: MediaQuery.of(context).size.width * 0.035,),
//                             IgnorePointer(
//                               ignoring: true,
//                               child: Switcher(
//                                 value: boolAllDay,
//                                 colorOff: Colors.red.withOpacity(0.5),
//                                 colorOn: Colors.green,
//                                 size: SwitcherSize.small,
//                                 onChanged: (bool value) {},
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//   }
//
//   Future getDataFromWeb() async {
//     var request;
//     if(house == 'House' && houseInstitution == 'HouseInstitution') {
//       request = http.Request('GET', Uri.parse("$baseUrl/events/calendar/institution/$house_institution_id"));
//     } else if(house == 'House') {
//       request = http.Request('GET', Uri.parse('$baseUrl/events/calendar/house/$house_id'));
//     } else if(institution == 'Institution') {
//       request = http.Request('GET', Uri.parse('$baseUrl/events/calendar/institution/$institution_id'));
//     } else {
//       request = http.Request('GET', Uri.parse('$baseUrl/events/calendar/province/$userProvinceId'));
//     }
//
//     http.StreamedResponse response = await request.send();
//
//     if(response.statusCode == 200) {
//       List jsonData = json.decode(await response.stream.bytesToString())['data'];
//       final Random random = Random();
//       for (var data in jsonData) {
//         Meeting meetingData = Meeting(
//             eventId: data['id'],
//             eventName: data['name'],
//             from: _convertDateFromString(data['start_date']),
//             to: _convertDateFromString(data['stop_date']),
//             background: _colorCollection[random.nextInt(10)],
//             privatePublic: data['type'],
//             location: data['location'],
//             allDay: data['allday']);
//         events.add(meetingData);
//       }
//       return events;
//     } else {
//       var message = json.decode(await response.stream.bytesToString())['message'];
//       setState(() {
//         QuickAlert.show(
//           context: context,
//           type: QuickAlertType.error,
//           title: 'Error',
//           text: message,
//           confirmBtnColor: buttonColor,
//           width: 100.0,
//         );
//       });
//     }
//   }
//
//   Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
//     Size size = MediaQuery.of(context).size;
//     if (details.date.month == DateTime.now().month) {
//       if (details.date.day == DateTime.now().day) {
//         return Padding(
//           padding: const EdgeInsets.all(5.0),
//           child: Container(
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [
//                     Color(0xFF39E8BC),
//                     Color(0xFF39E8BC)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               details.date.day.toString(),
//               style: GoogleFonts.fjallaOne(
//                   fontSize: size.height * 0.018,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white
//               ),),
//           ),
//         );
//       }
//     }
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: Container(
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           // color: const Color(0xFFFACBC0)
//         ),
//         child: Text(
//           details.date.day.toString(),
//           style: GoogleFonts.secularOne(
//             fontSize: size.height * 0.018,
//           ),
//         ),
//       ),
//     );
//   }
//
//   DateTime _convertDateFromString(String date) {
//     return DateFormat("dd-MM-yyyy").parse(date);
//   }
//
//   void _initializeEventColor() {
//     _colorCollection.add(const Color(0xFF0F8644));
//     _colorCollection.add(const Color(0xFF8B1FA9));
//     _colorCollection.add(const Color(0xFFD20100));
//     _colorCollection.add(const Color(0xFFFC571D));
//     _colorCollection.add(const Color(0xFF36B37B));
//     _colorCollection.add(const Color(0xFF01A1EF));
//     _colorCollection.add(const Color(0xFF3D4FB5));
//     _colorCollection.add(const Color(0xFFE47C73));
//     _colorCollection.add(const Color(0xFF636363));
//     _colorCollection.add(const Color(0xFF0A8043));
//   }
// }
//
// class MeetingDataSource extends CalendarDataSource {
//   MeetingDataSource(List<Meeting>? source) {
//     appointments = source;
//   }
//
//   @override
//   int getId(int index) {
//     return appointments![index].eventId;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     return appointments![index].from;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     return appointments![index].to;
//   }
//
//   @override
//   String getSubject(int index) {
//     return appointments![index].eventName;
//   }
//
//   @override
//   Color getColor(int index) {
//     return appointments![index].background;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return appointments![index].allDay;
//   }
//
//   @override
//   String getLocation(int index) {
//     return appointments![index].location;
//   }
//
//   String getPrivatePublic(int index) {
//     return appointments![index].privatePublic;
//   }
// }
//
// class Meeting {
//   Meeting({
//         this.eventId,
//         this.eventName,
//         this.from,
//         this.to,
//         this.background,
//         this.location,
//         this.privatePublic,
//         this.allDay = false
//       });
//
//   int? eventId;
//   String? eventName;
//   String? location;
//   String? privatePublic;
//   DateTime? from;
//   DateTime? to;
//   Color? background;
//   bool? allDay;
// }
