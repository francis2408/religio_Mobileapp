import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class EditFormationScreen extends StatefulWidget {
  const EditFormationScreen({Key? key}) : super(key: key);

  @override
  State<EditFormationScreen> createState() => _EditFormationScreenState();
}

class _EditFormationScreenState extends State<EditFormationScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isStage = false;
  bool isStartYear = false;
  bool isState = false;
  String state = '';
  String startYear = '';
  String endYear = '';
  var institutionController = TextEditingController();
  var startYearController = TextEditingController();
  var endYearController = TextEditingController();

  List formationData = [];
  List stages = [];
  List<DropDownValueModel> stageDropDown = [];

  int? stageID;
  String stage = '';
  var formationStage;

  final format = DateFormat("yyyy");

  getFormationData() async {
    String url = '$baseUrl/member.formation';
    Map data = {
      "params": {
        "filter": "[['member_id','=',${userProfile == "Profile" ? userMember : memberId}],['id','=',$formationId]]",
        "query": "{id,member_id,start_year,end_year,study_info,formation_stage_id,state,institution_id}"
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

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      formationData = data;

      for(int i= 0; i < formationData.length; i++) {
        if(formationData[i]['formation_stage_id']['id'] != '' && formationData[i]['formation_stage_id']['name'] != '') {
          stageID = formationData[i]['formation_stage_id']['id'];
          stage = formationData[i]['formation_stage_id']['name'];
        } else {
          stage = '';
        }

        institutionController.text = formationData[i]['institution_id']['name'];
        startYearController.text = formationData[i]['start_year'];
        startYear = formationData[i]['start_year'];
        endYearController.text = formationData[i]['end_year'];
        endYear = formationData[i]['end_year'];
        state = formationData[i]['state'];
      }
    }
    else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isLoading = false;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: message['message'],
          confirmBtnColor: greenColor,
          width: 100.0,
        );
      });
    }
  }

  getStageData() async {
    String url = '$baseUrl/res.formation.stage';
    Map data = {
      "params": {
        "query": "{id,name,code}"
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

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      stages = data;
      if(stages.isNotEmpty) {
        for(int i = 1; i < stages.length; i++) {
          stageDropDown.add(DropDownValueModel(name: stages[i]['name'], value: stages[i]['id']));
        }
        return stageDropDown;
      }
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isLoading = false;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: message['message'],
          confirmBtnColor: greenColor,
          width: 100.0,
        );
      });
    }
  }

  update(String stage, startYear, state) async {
    if(stage != null && stage != '' &&
        startYear != null && startYear != '' &&
        state != null && state != '') {
      String institute = institutionController.text.toString();
      String url = '$baseUrl/edit/member.formation/$formationId';
      Map data = {
        "params": {
          "data":{"member_id": userProfile == "Profile" ? userMember : memberId,"start_year": startYear,"end_year": endYear,"formation_stage_id": stageID,"state": state,"institution": institute}
        }
      };
      var body = jsonEncode(data);
      var response = await http.put(Uri.parse(url),
          headers: {
            'Authorization': authToken,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);
      if(response.statusCode == 200) {
        final message = json.decode(response.body)['result'];
        setState(() {
          _isLoading = false;
          AnimatedSnackBar.material(
              message['message'],
              type: AnimatedSnackBarType.success,
              duration: const Duration(seconds: 2)
          ).show(context);

          Navigator.pop(context);
          Navigator.pop(context, 'refresh');
        });
      } else {
        final message = json.decode(response.body)['result'];
        setState(() {
          _isLoading = false;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: message['message'],
            confirmBtnColor: greenColor,
            width: 100.0,
          );
        });
      }
    } else {
      setState(() {
        isStage = true;
        isStartYear = true;
        isState = true;
      });
      AnimatedSnackBar.material(
          'Please fill the required fields.',
          type: AnimatedSnackBarType.error,
          duration: const Duration(seconds: 2)
      ).show(context);
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
    // Check the internet connection
    internetCheck();

    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getFormationData();
      getStageData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getFormationData();
            getStageData();
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Edit Formation'),
          centerTitle: true,
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
            child: _isLoading
                ? SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
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
                        // controller: _stage,
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
                            // fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                        'Place',
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
                        controller: institutionController,
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter the place",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          hintStyle: GoogleFonts.breeSerif(
                            // fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                        keyboardType: TextInputType.none,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          hintText: "Select the beginning year",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
                          ),
                          hintStyle: GoogleFonts.breeSerif(
                            // fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                            isStartYear = true;
                          } else {
                            isStartYear = false;
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
                        keyboardType: TextInputType.none,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          hintText: "Select the end of the year",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
                          ),
                          hintStyle: GoogleFonts.breeSerif(
                            // fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                    SizedBox(height: size.height * 0.02,),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
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
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          update(stage, startYear, state);
                        } else if(stage.isEmpty && startYear.isNotEmpty && state.isNotEmpty) {
                          setState(() {
                            isStage = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(stage.isNotEmpty && startYear.isEmpty && state.isNotEmpty) {
                          setState(() {
                            isStartYear = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(stage.isNotEmpty && startYear.isNotEmpty && state.isEmpty) {
                          setState(() {
                            isState = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(stage.isEmpty && startYear.isEmpty && state.isNotEmpty) {
                          setState(() {
                            isStage = true;
                            isStartYear = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(stage.isNotEmpty && startYear.isEmpty && state.isEmpty) {
                          setState(() {
                            isStartYear = true;
                            isState = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(stage.isEmpty && startYear.isNotEmpty && state.isEmpty) {
                          setState(() {
                            isStage = true;
                            isState = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else {
                          setState(() {
                            isStage = true;
                            isStartYear = true;
                            isState = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
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
