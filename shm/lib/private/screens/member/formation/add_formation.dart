import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/snackbar.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

class AddFormationScreen extends StatefulWidget {
  const AddFormationScreen({Key? key}) : super(key: key);

  @override
  State<AddFormationScreen> createState() => _AddFormationScreenState();
}

class _AddFormationScreenState extends State<AddFormationScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool load = true;
  bool isStage = false;
  bool isStartYear = false;
  bool isStartDate = false;
  bool isEndDate = false;
  bool isState = false;
  bool isEndYear = false;
  String state = 'Completed';
  String startYear = '';
  String endYear = '';
  var startYearController = TextEditingController();
  var endYearController = TextEditingController();
  var studyInfoController = TextEditingController();
  final SingleValueDropDownController _stage = SingleValueDropDownController();
  final SingleValueDropDownController _house = SingleValueDropDownController();

  List stages = [];
  List houses = [];
  List<DropDownValueModel> stageDropDown = [];
  List<DropDownValueModel> houseDropDown = [];

  var start;
  var end;
  int? stageID;
  String houseID = '';
  String stage = '';
  String house = '';

  final format = DateFormat("yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getStageData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.formation.stage?fields=['name']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      stages = data;
      for(int i = 0; i < stages.length; i++) {
        setState(() {
          stageDropDown.add(DropDownValueModel(name: stages[i]['name'], value: stages[i]['id']));
        });
      }
      return stageDropDown;
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

  getHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?fields=['name']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      houses = data;
      for(int i = 0; i < houses.length; i++) {
        setState(() {
          houseDropDown.add(DropDownValueModel(name: houses[i]['name'], value: houses[i]['id']));
        });
      }
      return houseDropDown;
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

  save(String stage, startYear, state) async {
    if(stage.isNotEmpty && stage != '' && startYear != null && startYear != '') {
      String studyInfo = studyInfoController.text.toString();
      String house = '';
      if(houseID == null) {
        house = '';
      } else {
        house = houseID.toString();
      }
      var request = http.MultipartRequest('POST',  Uri.parse('$baseUrl/create/res.formation'));
      userMember == 'Member' ? request.fields.addAll({
        'values': "{'formation_stage_id': $stageID,'member_id': $id,'house_id': ${houseID != '' ? houseID : []},'start_year': '$startYear','end_year': '$endYear','study_info': '$studyInfo','state': '$state'}"
      }) : request.fields.addAll({
        'values': "{'formation_stage_id': $stageID,'member_id': $memberId,'house_id': ${houseID != '' ? houseID : []},'start_year': '$startYear','end_year': '$endYear','study_info': '$studyInfo','state': '$state'}"
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if(response.statusCode == 200) {
        final message = json.decode(await response.stream.bytesToString())['message'];
        setState(() {
          _isLoading = false;
          load = false;
          AnimatedSnackBar.show(
              context,
              'Formation data created successfully.',
              Colors.green
          );
          Navigator.pop(context);
          Navigator.pop(context, 'refresh');
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
                  Navigator.pop(context);
                },
              );
            },
          );
        });
      }
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
      getStageData();
      getHouseData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getStageData();
            getHouseData();
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
          title: const Text('Add Formation'),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          toolbarHeight: 50,
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
                    SizedBox(height: size.height * 0.02,),
                    Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 10),
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Text(
                            'Stage',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02,),
                          Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: inputColor
                      ),
                      child: DropDownTextField(
                        controller: _stage,
                        listSpace: 20,
                        listPadding: ListPadding(top: 20),
                        searchShowCursor: true,
                        searchAutofocus: true,
                        enableSearch: true,
                        listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                        textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                        dropDownItemCount: 6,
                        dropDownList: stageDropDown,
                        textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Select the stage",
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
                            stage = val.name;
                            stageID = val.value;
                            if(stage.isNotEmpty && stage != '') {
                              isStage = false;
                            } else {

                            }
                          } else {
                            setState(() {
                              isStage = true;
                              stage = '';
                            });
                          }
                        },
                      ),
                    ),
                    isStage ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Stage is required",
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
                        'House',
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
                        controller: _house,
                        listSpace: 20,
                        listPadding: ListPadding(top: 20),
                        searchShowCursor: true,
                        searchAutofocus: true,
                        enableSearch: true,
                        listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                        textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                        dropDownItemCount: 6,
                        dropDownList: houseDropDown,
                        textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Select the house",
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
                            house = val.name;
                            houseID = val.value.toString();
                          } else {
                            setState(() {
                              house = '';
                              houseID = '';
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
                      child: Row(
                        children: [
                          Text(
                            'Start Year',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02,),
                          Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: inputColor
                      ),
                      child: TextFormField(
                        controller: startYearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: "Select the beginning year",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
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
                          if(isStartDate) {
                            if(start !> end || end !< startYear) {
                              isStartDate = false;
                              isEndDate = false;
                            } else {
                              isStartDate = true;
                              isEndDate = true;
                            }
                          } else {
                            if (val!.isEmpty && val == '') {
                              isStartYear = true;
                            } else {
                              isStartYear = false;
                            }
                          }
                          return null;
                        },
                        onFieldSubmitted: (val) {
                          if (val.isEmpty) {
                            startYearController.text = '';
                            startYear = '';
                          }
                        },
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Select Year", style: TextStyle(color: backgroundColor),),
                                content: SizedBox( // Need to use container to add size constraint.
                                  width: size.width * 0.03,
                                  height: size.height * 0.3,
                                  child: YearPicker(
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    initialDate: startYearController.text.isNotEmpty ? format.parse(startYearController.text) : DateTime( DateTime.now().year),
                                    selectedDate: startYearController.text.isNotEmpty ? format.parse(startYearController.text) : DateTime( DateTime.now().year),
                                    onChanged: (DateTime dateTime) {
                                      startYearController.text = format.format(dateTime);
                                      startYear = startYearController.text;
                                      start = int.tryParse(startYear);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    isStartYear ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Start year is required",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500
                          ),
                        )
                    ) : Container(),
                    isStartDate ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Please check the start year",
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
                        'End Year',
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
                        controller: endYearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: "Select the end of the year",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
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
                        onFieldSubmitted: (val) {
                          if(val.isNotEmpty) {
                            setState(() {
                              isEndYear = true;
                            });
                          } else {
                            setState(() {
                              endYearController.text = '';
                              endYear = '';
                              isEndYear = false;
                            });
                          }
                        },
                        // check tha validation
                        validator: (val) {
                          if(isEndDate) {
                            if(start !> end || end !< startYear) {
                              setState(() {
                                isStartDate = false;
                                isEndDate = false;
                              });
                            } else {
                              setState(() {
                                isStartDate = true;
                                isEndDate = true;
                              });
                            }
                          }
                          return null;
                        },
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Select Year"),
                                content: SizedBox( // Need to use container to add size constraint.
                                  width: size.width * 0.03,
                                  height: size.height * 0.3,
                                  child: YearPicker(
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    initialDate: endYearController.text.isNotEmpty ? format.parse(endYearController.text) : DateTime( DateTime.now().year),
                                    selectedDate: endYearController.text.isNotEmpty ? format.parse(endYearController.text) : DateTime( DateTime.now().year),
                                    onChanged: (DateTime dateTime) {
                                      endYearController.text = format.format(dateTime);
                                      endYear = endYearController.text;
                                      end = int.tryParse(endYear);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    isEndDate ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Please check the end year",
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
                        'Any Study Done',
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
                        controller: studyInfoController,
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(40), // Limit to 10 characters
                        ],
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter the study done information",
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
                      child: Row(
                        children: [
                          Text(
                            'Status',
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
                    Row(
                      children: [
                        Expanded(
                            child: RadioListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                dense: true,
                                tileColor: inputColor,
                                activeColor: enableColor,
                                value: 'Active',
                                groupValue: state,
                                title: Text('Active', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                onChanged: (String? value) {
                                  setState(() {
                                    if (value!.isEmpty && value == '') {
                                      isState = true;
                                    } else {
                                      isState = false;
                                      state = value;
                                    }
                                  });
                                }
                            )
                        ),
                        SizedBox(width: size.width * 0.05,),
                        Expanded(
                            child: RadioListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                dense: true,
                                tileColor: inputColor,
                                activeColor: enableColor,
                                value: 'Completed',
                                groupValue: state,
                                title: Text('Completed', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                onChanged: (String? value) {
                                  setState(() {
                                    if (value!.isEmpty && value == '') {
                                      isState = true;
                                    } else {
                                      isState = false;
                                      state = value;
                                    }
                                  });
                                }
                            )
                        ),
                      ],
                    ),
                    isState ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Status is required",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500
                          ),
                        )
                    ) : Container(),
                    SizedBox(height: size.height * 0.1,),
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
                        if(stage.isNotEmpty && startYear.isNotEmpty && state.isNotEmpty) {
                          if(isEndYear) {
                            if(startYear.isNotEmpty && endYear.isNotEmpty) {
                              if(start > end || end < start) {
                                setState(() {
                                  isStartDate = true;
                                  isEndDate = true;
                                });
                                AnimatedSnackBar.show(
                                    context,
                                    'Please check the start year and end year',
                                    Colors.red
                                );
                              } else {
                                setState(() {
                                  isStartDate = false;
                                  isEndDate = false;
                                  if(load) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const CustomLoadingDialog();
                                      },
                                    );
                                    save(stage, startYear, state);
                                  }
                                });
                              }
                            }
                          } else {
                            if(load) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              save(stage, startYear, state);
                            }
                          }
                        } else if(stage.isEmpty && startYear.isNotEmpty && state.isNotEmpty) {
                          setState(() {
                            isStage = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(stage.isNotEmpty && startYear.isEmpty && state.isNotEmpty) {
                          setState(() {
                            isStartYear = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(stage.isNotEmpty && startYear.isNotEmpty && state.isEmpty) {
                          setState(() {
                            isState = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(stage.isEmpty && startYear.isEmpty && state.isNotEmpty) {
                          setState(() {
                            isStage = true;
                            isStartYear = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(stage.isNotEmpty && startYear.isEmpty && state.isEmpty) {
                          setState(() {
                            isStartYear = true;
                            isState = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(stage.isEmpty && startYear.isNotEmpty && state.isEmpty) {
                          setState(() {
                            isStage = true;
                            isState = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else {
                          setState(() {
                            isStage = true;
                            isStartYear = true;
                            isState = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        }
                      },
                      child: Text('Save', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        )
    );
  }
}
