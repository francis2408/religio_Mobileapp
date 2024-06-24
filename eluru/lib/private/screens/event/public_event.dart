// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:nagpur/widget/common/common.dart';
// import 'package:nagpur/widget/common/internet_connection_checker.dart';
// import 'package:nagpur/widget/theme_color/theme_color.dart';
// import 'package:nagpur/widget/widget.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
//
// class PublicEventScreen extends StatefulWidget {
//   const PublicEventScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PublicEventScreen> createState() => _PublicEventScreenState();
// }
//
// class _PublicEventScreenState extends State<PublicEventScreen> {
//   final formKey = GlobalKey<FormState>();
//   bool _isLoading = true;
//   var selectDate;
//   String startDate = '';
//   String endDate = '';
//   var startDateController = TextEditingController();
//   var endDateController = TextEditingController();
//
//   final format = DateFormat("dd-MM-yyyy");
//   final reverse = DateFormat("yyyy-MM-dd");
//
//   // View event screen values
//   String eventName = '';
//   String eventStartDate = '';
//   String eventEndDate = '';
//   String eventLocation = '';
//
//   final List<Color> _colorCollection=<Color>[];
//   final List<Meeting> events = [];
//
//   var headers = {
//     'Authorization': 'Bearer $authToken',
//   };
//
//   internetCheck() {
//     CheckInternetConnection.checkInternet().then((value) {
//       if(value) {
//         return null;
//       } else {
//         showDialogBox();
//       }
//     });
//   }
//
//   showDialogBox() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return WarningAlertDialog(
//           message: 'Please check your internet connection.',
//           onOkPressed: () {
//             Navigator.pop(context);
//             CheckInternetConnection.checkInternet().then((value) {
//               if (value) {
//                 return null;
//               } else {
//                 showDialogBox();
//               }
//             });
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   void initState() {
//     // Check the internet connection
//     internetCheck();
//     super.initState();
//     _initializeEventColor();
//     _isLoading = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: screenBackgroundColor,
//       appBar: AppBar(
//         title: const Text('Calendar Event'),
//         backgroundColor: backgroundColor,
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
//           child: _isLoading
//               ? Center(
//             child: Container(
//                 height: size.height * 0.1,
//                 width: size.width * 0.2,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage( "assets/alert/spinner_1.gif"),
//                   ),
//                 )),
//           ) : Container(
//             color: Colors.white,
//             padding: const EdgeInsets.all(10),
//             child: FutureBuilder(
//               future: getDataFromWeb(),
//               builder: (BuildContext context, AsyncSnapshot snapshot) {
//                 return SfCalendar(
//                   view: CalendarView.month,
//                   headerStyle: CalendarHeaderStyle(
//                       textAlign: TextAlign.left,
//                       textStyle: GoogleFonts.secularOne(
//                         letterSpacing: 1.5,
//                         fontSize: size.height * 0.023,
//                         color: valueColor,
//                       )
//                   ),
//                   selectionDecoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: backgroundColor,
//                         width: 1,
//                       )
//                   ),
//                   viewHeaderStyle: ViewHeaderStyle(
//                     dayTextStyle: TextStyle(
//                         fontSize: size.height * 0.02,
//                         color: emptyColor,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   monthCellBuilder: monthCellBuilder,
//                   todayHighlightColor: backgroundColor,
//                   todayTextStyle: GoogleFonts.fjallaOne(
//                     fontSize: size.height * 0.015,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   allowViewNavigation: true,
//                   showNavigationArrow: true,
//                   showDatePickerButton: false,
//                   initialSelectedDate: DateTime.now(),
//                   initialDisplayDate: DateTime.now(),
//                   dataSource: MeetingDataSource(snapshot.data),
//                   monthViewSettings: MonthViewSettings(
//                     dayFormat: 'EEE',
//                     showAgenda: true,
//                     agendaViewHeight: size.height * 0.4,
//                     agendaItemHeight: size.height * 0.06,
//                     agendaStyle: AgendaStyle(
//                       backgroundColor: screenBackgroundColor,
//                       appointmentTextStyle: TextStyle(
//                           fontSize: size.height * 0.018,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white
//                       ),
//                       dateTextStyle: GoogleFonts.fjallaOne(
//                         fontSize: size.height * 0.018,
//                         fontWeight: FontWeight.bold,
//                         color: valueColor,
//                       ),
//                       dayTextStyle: TextStyle(
//                           fontSize: size.height * 0.018,
//                           fontWeight: FontWeight.w700,
//                           color: backgroundColor
//                       ),
//                     ),
//                     // appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
//                   ),
//                   onTap:calendarTapped,
//                   onSelectionChanged: (CalendarSelectionDetails details){
//                     selectDate = details.date;
//                     startDate = reverse.format(selectDate);
//                     startDateController.text = format.format(selectDate);
//                     endDate = reverse.format(selectDate);
//                     endDateController.text = format.format(selectDate);
//                   },
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
//       eventID = meeting.eventId;
//       eventName = meeting.eventName!;
//       eventLocation = meeting.location!;
//       eventStartDate = format.format(meeting.from as DateTime);
//       eventEndDate = format.format(meeting.to as DateTime);
//
//       Size size = MediaQuery.of(context).size;
//       showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
//         ),
//         builder: (BuildContext context) => SizedBox(
//           height: size.height * 0.3,
//           child: Center(
//             child: _isLoading
//                 ? const CircularProgressIndicator(color: iconColor,)
//                 : SingleChildScrollView(
//               // controller: ModalScrollController.of(context),
//               child: Container(
//                 padding: const EdgeInsets.only(left: 10, right: 10),
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('View Event', style: TextStyle(color: textColor, fontSize: MediaQuery.of(context).size.height * 0.02, fontWeight: FontWeight.bold),),
//                           IconButton(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.cancel, color: Colors.red,))
//                         ],
//                       ),
//                       SizedBox(height: size.height * 0.02,),
//                       Container(
//                         padding: const EdgeInsets.all(15),
//                         child: Stack(
//                           children: [
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
//                                     SizedBox(width: size.width * 0.02,),
//                                     eventName.isNotEmpty && eventName != '' ? Text(eventName, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.015,),
//                                 Row(
//                                   children: [
//                                     Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
//                                     SizedBox(width: size.width * 0.02,),
//                                     startDate.isNotEmpty && startDate != '' ? Text(DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(startDate)), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : const Text(""),
//                                     SizedBox(width: size.width * 0.05,),
//                                     Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),),
//                                     SizedBox(width: size.width * 0.05,),
//                                     endDate.isNotEmpty && endDate != '' ? Text(
//                                       DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(endDate)), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
//                                     ) : Text(
//                                       "Till Now", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.015,),
//                                 Row(
//                                   children: [
//                                     Container(width: size.width * 0.25, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
//                                     SizedBox(width: size.width * 0.02,),
//                                     eventLocation.isNotEmpty && eventLocation != '' ? Text(eventLocation, style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       )
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
//     var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/calendar.event?fields=['name','start_datetime','duration','location','start_date','stop_date','category','calendar_config_type_id','allday']&domain=[('type','=','public'),('category','=','calendar')]&order=start_date asc"""));
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//
//     if(response.statusCode == 200) {
//       List jsonData = json.decode(await response.stream.bytesToString())['data'];
//       final Random random = Random();
//       for (var data in jsonData) {
//         Meeting meetingData = Meeting(
//           eventId: data['id'],
//           eventName: data['name'],
//           from: _convertDateFromString(data['start_date']),
//           to: _convertDateFromString(data['stop_date']),
//           background: _colorCollection[random.nextInt(10)],
//           location: data['location'],
//         );
//         events.add(meetingData);
//       }
//       return events;
//     } else {
//       var message = json.decode(await response.stream.bytesToString())['message'];
//       setState(() {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return ErrorAlertDialog(
//               message: message,
//               onOkPressed: () async {
//                 Navigator.pop(context);
//               },
//             );
//           },
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
//                     Color(0xFF1D976C),
//                     Color(0xFF93F9B9),
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
//     return DateFormat("yyyy-MM-dd").parse(date);
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
// }
//
// class Meeting {
//   Meeting({
//     this.eventId,
//     this.eventName,
//     this.from,
//     this.to,
//     this.background,
//     this.location,
//     this.allDay = false
//   });
//
//   int? eventId;
//   String? eventName;
//   String? location;
//   DateTime? from;
//   DateTime? to;
//   Color? background;
//   bool? allDay;
// }