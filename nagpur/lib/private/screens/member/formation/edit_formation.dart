import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/common/internet_connection_checker.dart';
import 'package:nagpur/widget/common/snackbar.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

class EditFormationScreen extends StatefulWidget {
  const EditFormationScreen({Key? key}) : super(key: key);

  @override
  State<EditFormationScreen> createState() => _EditFormationScreenState();
}

class _EditFormationScreenState extends State<EditFormationScreen> {
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

  List formationData = [];
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

  getFormationData() async {
    String formationUrl = '';

    formationUrl = "$baseUrl/search_read/res.formation/$formationId";

    var request = http.Request('GET', Uri.parse(formationUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      formationData = data;
      for(int i = 0; i < formationData.length; i++) {
        if(formationData[i]['formation_stage_id'] != '' && formationData[i]['formation_stage_id'] != null && formationData[i]['formation_stage_id'] != []) {
          stageID = formationData[i]['formation_stage_id'][0];
          stage = formationData[i]['formation_stage_id'][1];
        } else {
          stage = '';
        }
        if(formationData[i]['house_id'] != '' && formationData[i]['house_id'] != null && formationData[i]['formation_stage_id'] != []) {
          houseID = formationData[i]['house_id'][0].toString();
          house = formationData[i]['house_id'][1];
        } else {
          house = '';
        }
        startYearController.text = formationData[i]['start_year'];
        startYear = formationData[i]['start_year'];
        start = int.tryParse(startYear);
        endYearController.text = formationData[i]['end_year'];
        endYear = formationData[i]['end_year'];
        end = int.tryParse(endYear);
        studyInfoController.text = formationData[i]['study_info'];
        state = formationData[i]['state'];
      }
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

  update(String stage, startYear, state) async {
    if(stage != null && stage != '' && startYear != null && startYear != '') {
      String studyInfo = studyInfoController.text.toString();
      var request = http.MultipartRequest('PUT',  Uri.parse('$baseUrl/write/res.formation?ids=[$formationId]'));
      userMember == 'Member' ? request.fields.addAll({
        'values': "{'formation_stage_id': $stageID,'member_id': $id,'house_id': ${houses != '' ? houseID : []},'start_year': '$startYear','end_year': '$endYear','study_info': '$studyInfo','state': '$state'}"
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
              'Formation data updated successfully.',
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

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      getFormationData();
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getStageData();
      getHouseData();
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getStageData();
            getHouseData();
            loadDataWithDelay();
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
          title: const Text('Edit Formation'),
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
                        initialValue: stage,
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
                          hintText: stage != '' ? stage : "Select the stage",
                          hintStyle: GoogleFonts.breeSerif(
                            color: stage != '' ? Colors.black87 : labelColor2,
                            fontStyle: stage != '' ? FontStyle.normal : FontStyle.italic,
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
                        initialValue: house,
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
                          hintText: house != '' ? house : "Select the house",
                          hintStyle: GoogleFonts.breeSerif(
                            color: house != '' ? Colors.black87 : labelColor2,
                            fontStyle: house != '' ? FontStyle.normal : FontStyle.italic,
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
                            setState(() {
                              startYearController.text = '';
                              startYear = '';
                            });
                          }
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
                                endYearController.text = '';
                                endYear = '';
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
                                title: const Text("Select Year", style: TextStyle(color: backgroundColor),),
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
                          hintText: "Enter the study information",
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
                                    update(stage, startYear, state);
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
                              update(stage, startYear, state);
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
                      child: Text('Update', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        )
    );
  }
}
