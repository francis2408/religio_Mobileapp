import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/snackbar.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool load = true;
  bool _allDay = false;
  bool isTitle = false;
  bool isType = false;
  bool isStartAt = false;
  bool isStart = false;
  bool isEnd = false;
  String allDay = 'False';
  String startAt = '';
  String startDate = '';
  String endDate = '';
  String type = 'private';

  var eventNameController  = TextEditingController();
  var startAtDateController = TextEditingController();
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var placeController = TextEditingController();
  var descriptionController = TextEditingController();

  final SingleValueDropDownController _calendarType = SingleValueDropDownController();
  List calendarTypeData = [];
  List<DropDownValueModel> calendarTypeDropDown = [];

  String calendarID = '';
  String calendar = '';

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getEventTypeData() async {
    var request;
    if(userRole == "Religious Province") {
      request = http.Request('GET', Uri.parse("$baseUrl/search_read/calendar.config.type?domain=[('code','in',['RP','PRC'])]&fields=['name','code']&limit=1000"));
    } else if(userRole == "House/Community") {
      request = http.Request('GET', Uri.parse("$baseUrl/search_read/calendar.config.type?domain=[('code','=','RH')]&fields=['name','code']&limit=1000"));
    } else if(userRole == "Institution") {
      request = http.Request('GET', Uri.parse("$baseUrl/search_read/calendar.config.type?domain=[('code','=','RI')]&fields=['name','code']&limit=1000"));
    } else {
      request = http.Request('GET', Uri.parse("$baseUrl/search_read/calendar.config.type?domain=[('code','=','PC')]&fields=['name','code']&limit=1000"));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      calendarTypeData = data;
      for(int i = 0; i < calendarTypeData.length; i++) {
        setState(() {
          calendarTypeDropDown.add(DropDownValueModel(name: calendarTypeData[i]['name'], value: calendarTypeData[i]['id']));
        });
      }
      return calendarTypeDropDown;
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
  }

  save(String eventName) async {
    String name = eventName;
    String location = placeController.text.toString();
    String description = descriptionController.text.toString();
    var request = http.MultipartRequest('POST',  Uri.parse('$baseUrl/create/calendar.event'));
    _allDay ? request.fields.addAll({
      'values': "{'name': '$name','allday': $allDay,'start': '$startAt','stop': '$startAt','start_date': '$startDate','stop_date': '$endDate','type': '$type','user_id': $userId,'calendar_config_type_id': $calendarID,'location': '$location','description_html': '$description','category': 'calendar'}"
    }) : request.fields.addAll({
      'values': "{'name': '$name','allday': $allDay,'start': '$startAt','stop': '$startAt','type': '$type','user_id': $userId,'calendar_config_type_id': $calendarID,'location': '$location','description_html': '$description','category': 'calendar'}"
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      final message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        load = false;
        _isLoading = false;
        AnimatedSnackBar.show(
            context,
            'Event data created successfully.',
            Colors.green
        );
        Navigator.pop(context);
        Navigator.pop(context, 'refresh');
      });
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
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
      getEventTypeData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getEventTypeData();
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
        title: const Text('Add Event'),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              ),
              gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
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
            child: Container(
                height: size.height * 0.1,
                width: size.width * 0.2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage( "assets/alert/spinner_1.gif"),
                  ),
                )
            ),
          ) : Container(
            padding: EdgeInsets.only(left: size.width * 0.03, right: size.width * 0.03),
            alignment: Alignment.topLeft,
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Title',
                          style: GoogleFonts.poppins(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02,),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: size.height * 0.02),),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: TextFormField(
                      controller: eventNameController,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30), // Limit to 10 characters
                      ],
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter the event title",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      // check tha validation
                      validator: (val) {
                        if (val!.isEmpty && val == '') {
                          isTitle = true;
                        } else {
                          isTitle = false;
                        }
                      },
                    ),
                  ),
                  isTitle ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Title is required",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      )
                  ) : Container(),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'All Day',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Checkbox(
                              value: _allDay,
                              activeColor: enableColor,
                              onChanged: (value) {
                                setState(() {
                                  _allDay = value!;
                                  if(_allDay == true) {
                                    isStartAt = false;
                                    allDay = 'True';
                                  } else {
                                    isStart = false;
                                    isEnd = false;
                                    allDay = 'False';
                                  }
                                });
                              },
                          ),
                        ),
                        SizedBox(width: size.width * 0.03,),
                        Text('All Day', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  if(_allDay != true) Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Start At',
                          style: GoogleFonts.poppins(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02,),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: size.height * 0.02),),
                      ],
                    ),
                  ),
                  if(_allDay != true) Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: inputColor,
                    ),
                    child: TextFormField(
                      controller: startAtDateController,
                      readOnly: true,
                      style: const TextStyle(
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.calendar_month,
                          color: Colors.indigo,
                        ),
                        hintText: "Choose date and time",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      // check tha validation
                      validator: (val) {
                        if (val!.isEmpty && val == '') {
                          isStartAt = true;
                        } else {
                          isStartAt = false;
                        }
                      },
                      onFieldSubmitted: (_) {
                        setState(() {
                          startAtDateController.text = '';
                          startAt = '';
                          startDate = '';
                          endDate = '';
                        });
                      },
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 1)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: enableColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: backgroundColor,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (selectedDate != null) {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: enableColor,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: backgroundColor,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (selectedTime != null) {
                            DateTime selectedDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            setState(() {
                              startAtDateController.text = DateFormat("dd-MM-yyyy hh:mm a").format(selectedDateTime);
                              startAt = DateFormat("yyyy-MM-dd hh:mm:ss").format(selectedDateTime);
                              startDate = DateFormat("yyyy-MM-dd").format(selectedDateTime);
                              endDate = DateFormat("yyyy-MM-dd").format(selectedDateTime);
                            });
                          }
                        }
                      },
                    ),
                  ),
                  if(_allDay != true) isStartAt ? Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: const Text(
                      "Start date and time are required",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ) : Container(),
                  if(_allDay != true) SizedBox(
                    height: size.height * 0.01,
                  ),
                  if(_allDay) Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Start Date',
                          style: GoogleFonts.poppins(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02,),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: size.height * 0.02),)
                      ],
                    ),
                  ),
                  if(_allDay) Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: TextFormField(
                      controller: startDateController,
                      autocorrect: true,
                      keyboardType: TextInputType.datetime,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10), // Limit to 10 characters
                      ],
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.calendar_month,
                          color: Colors.indigo,
                        ),
                        hintText: "Choose the date",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      // check tha validation
                      validator: (val) {
                        if (val!.isEmpty && val == '') {
                          isStart = true;
                        } else {
                          isStart = false;
                        }
                      },
                      onFieldSubmitted: (_) {
                        setState(() {
                          startAtDateController.text = '';
                          startAt = '';
                          startDate = '';
                        });
                      },
                      onTap: () async {
                        DateTime? datePick = await showDatePicker(
                          context: context,
                          initialDate: startDateController.text.isNotEmpty ? format.parse(startDateController.text) : DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 1)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: enableColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: backgroundColor,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (datePick != null) {
                          setState(() {
                            var dateNow = DateTime.now();
                            var diff = dateNow.difference(datePick);
                            var year = ((diff.inDays)/365).round();
                            startDateController.text = format.format(datePick);
                            startDate = reverse.format(datePick);
                            startAt = DateFormat("yyyy-MM-dd hh:mm:ss").format(datePick);
                          });
                        }
                      },
                    ),
                  ),
                  if(_allDay) isStart ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Start date is required",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      )
                  ) : Container(),
                  if(_allDay) SizedBox(
                    height: size.height * 0.01,
                  ),
                  if(_allDay) Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'End Date',
                          style: GoogleFonts.poppins(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: size.width * 0.02,),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: size.height * 0.02),)
                      ],
                    ),
                  ),
                  if(_allDay) Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: TextFormField(
                      controller: endDateController,
                      autocorrect: true,
                      keyboardType: TextInputType.datetime,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10), // Limit to 10 characters
                      ],
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.calendar_month,
                          color: Colors.indigo,
                        ),
                        hintText: "Choose the date",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      // check tha validation
                      validator: (val) {
                        if (val!.isEmpty && val == '') {
                          isEnd = true;
                        } else {
                          isEnd = false;
                        }
                      },
                      onFieldSubmitted: (_) {
                        setState(() {
                          endDateController.text = '';
                          endDate = '';
                        });
                      },
                      onTap: () async {
                        DateTime? datePick = await showDatePicker(
                          context: context,
                          initialDate: endDateController.text.isNotEmpty ? format.parse(endDateController.text) :DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 1)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: enableColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: backgroundColor,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (datePick != null) {
                          setState(() {
                            var dateNow = DateTime.now();
                            var diff = dateNow.difference(datePick);
                            var year = ((diff.inDays)/365).round();
                            endDateController.text = format.format(datePick);
                            endDate = reverse.format(datePick);
                          });
                        }
                      },
                    ),
                  ),
                  if(_allDay) isEnd ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "End date is required",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      )
                  ) : Container(),
                  if(_allDay) SizedBox(
                    height: size.height * 0.01,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Type',
                          style: GoogleFonts.poppins(
                            fontSize: size.height * 0.018,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RadioListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      dense: true,
                      tileColor: inputColor,
                      activeColor: enableColor,
                      value: 'private',
                      groupValue: type,
                      title: Text('Private', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          type = value!;
                        });
                      }
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  RadioListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      dense: true,
                      tileColor: inputColor,
                      activeColor: enableColor,
                      value: 'public',
                      groupValue: type,
                      title: Text('Public', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          type = value!;
                        });
                      }
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Calendar Type',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: DropDownTextField(
                      controller: _calendarType,
                      listSpace: 20,
                      listPadding: ListPadding(top: 20),
                      searchShowCursor: true,
                      searchAutofocus: true,
                      enableSearch: true,
                      listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                      textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                      dropDownItemCount: 6,
                      dropDownList: calendarTypeDropDown,
                      textFieldDecoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Select calendar type",
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null && val != "") {
                          setState(() {
                            calendar = val.name;
                            calendarID = val.value.toString();
                          });
                        } else {
                          setState(() {
                            calendar = '';
                            calendarID = '';
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: TextFormField(
                      controller: placeController,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30), // Limit to 10 characters
                      ],
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter the location",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2000), // Limit to 10 characters
                      ],
                      maxLines: 15,
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter the description",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintStyle: GoogleFonts.breeSerif(
                          color: labelColor2,
                          fontStyle: FontStyle.italic,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: disableColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: enableColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        decoration: const BoxDecoration(
            color: screenBackgroundColor,
            border: Border(
                top: BorderSide(
                    color: Colors.grey,
                    width: 1.0
                )
            )
        ),
        padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: size.width * 0.4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.red
              ),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context, 'refresh');
                    });
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
              ),
            ),
            Container(
                width: size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: greenColor,
                ),
                child: TextButton(
                    onPressed: () {
                      if(_allDay) {
                        if(eventNameController.text.isNotEmpty && startDateController.text.isNotEmpty && endDateController.text.isNotEmpty) {
                          if(load) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomLoadingDialog();
                              },
                            );
                            save(eventNameController.text.toString());
                          }
                        } else {
                          setState(() {
                            if(eventNameController.text.isEmpty) isTitle = true;
                            if(startDateController.text.isEmpty) isStart = true;
                            if(endDateController.text.isEmpty) isEnd = true;
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the required fields.',
                                Colors.red
                            );
                          });
                        }
                      } else {
                        if(eventNameController.text.isNotEmpty && startAtDateController.text.isNotEmpty) {
                          if(load) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomLoadingDialog();
                              },
                            );
                            save(eventNameController.text.toString());
                          }
                        } else {
                          setState(() {
                            if(eventNameController.text.isEmpty) isTitle = true;
                            if(startAtDateController.text.isEmpty) isStartAt = true;
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the required fields.',
                                Colors.red
                            );
                          });
                        }
                      }
                    },
                    child: Text('Save', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                )
            ),
          ],
        ),
      ),
    );
  }
}
