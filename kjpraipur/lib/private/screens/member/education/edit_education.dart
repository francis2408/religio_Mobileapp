import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditEducationScreen extends StatefulWidget {
  const EditEducationScreen({Key? key}) : super(key: key);

  @override
  State<EditEducationScreen> createState() => _EditEducationScreenState();
}

class _EditEducationScreenState extends State<EditEducationScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isLevel = false;
  bool isStudy = false;
  bool isMode = false;
  bool isFile = false;
  bool load = true;
  String status = '';
  String mode ='';
  String years = '';
  var instituteController = TextEditingController();
  var yearController = TextEditingController();
  var resultController = TextEditingController();

  List educationData = [];
  List levelData = [];
  List studyData = [];
  List studyBasedData = [];
  List<DropDownValueModel> levelDropDown = [];
  List<DropDownValueModel> studyDropDown = [];

  int? levelID;
  String level = '';
  int? studyID;
  String study = '';
  final format = DateFormat("yyyy");
  var _attacFile;
  var _netAttacFile;
  var _attachFileName;
  var baseFile;
  var path;
  var netPath;
  var netFileName;

  getFiles() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['docx', 'pdf'],
    );

    if(resultFile != null) {
      setState(() {
        PlatformFile file = resultFile.files.first;
        _attacFile = file.path;
        _attachFileName = file.name;

        final f = File(_attacFile);
        int sizeInBytes = f.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb <= 2) {
          isFile = false;
          var attachFileType = _attacFile.split('.').last;
          if(attachFileType != 'jpg') {
            File files = File(_attacFile);
            List<int> fileBytes = files.readAsBytesSync();
            var bFile = base64Encode(fileBytes);
            baseFile = 'data:@file/$attachFileType;base64,$bFile';
          } else {
            _attacFile = '';
            _attachFileName = '';
            AnimatedSnackBar.show(
                context,
                'Please select the PDF file or document file.',
                Colors.red
            );
          }
        } else {
          _attacFile = '';
          _attachFileName = '';
          isFile = true;
        }
      });
    }
  }

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getLevelData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.study.level?fields=['name']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      levelData = data;

      for(int i = 0; i < levelData.length; i++) {
        setState(() {
          levelDropDown.add(DropDownValueModel(name: levelData[i]['name'], value: levelData[i]['id']));
        });
      }
      return levelDropDown;
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  getStudyData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member.program?fields=['name','study_level_id']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      studyData = data;

      for(int i = 0; i < studyData.length; i++) {
        setState(() {
          studyDropDown.add(DropDownValueModel(name: studyData[i]['name'], value: studyData[i]['id']));
        });
      }
      return studyDropDown;
    }
    else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  getStudy(levelID) async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member.program?fields=['name','study_level_id']&domain=[('study_level_id','=',$levelID)]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      studyBasedData = data;
      if(studyBasedData.isNotEmpty){
        for(int i = 0; i < studyBasedData.length; i++) {
          setState(() {
            studyDropDown.add(DropDownValueModel(name: studyBasedData[i]['name'], value: studyBasedData[i]['id']));
          });
        }
        return studyDropDown;
      } else {
        for(int i = 0; i <= studyBasedData.length; i++) {
          setState(() {
            studyDropDown.add(DropDownValueModel(name: "No data found", value: i));
          });
        }
        return studyDropDown;
      }
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  getEducationalData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member.education/$educationId"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      educationData = data;
      for(int i = 0; i < educationData.length; i++) {
        if(educationData[i]['study_level_id'] != '' && educationData[i]['study_level_id'] != null && educationData[i]['study_level_id'] != []) {
          levelID = educationData[i]['study_level_id'][0];
          level = educationData[i]['study_level_id'][1];
          setState(() {
            studyDropDown.clear();
            getStudy(levelID);
          });
        } else {
          level = '';
        }

        if(educationData[i]['program_id'] != '' && educationData[i]['program_id'] != null && educationData[i]['study_level_id'] != []) {
          studyID = educationData[i]['program_id'][0];
          study = educationData[i]['program_id'][1];
        } else {
          study = '';
        }
        instituteController.text = educationData[i]['institution'];
        yearController.text = educationData[i]['year_of_passing'];
        years = educationData[i]['year_of_passing'];
        status = educationData[i]['state'];
        mode = educationData[i]['mode'];
        resultController.text = educationData[i]['result'];
        if(educationData[i]['attachment'] != '') {
          _netAttacFile = educationData[i]['attachment'];
          var attach = educationData[i]['attachment'];
          File file = File(attach);
          var path = file.path;
          _attachFileName = path.split("/").last;
        } else {
          _attacFile = '';
          _attachFileName = '';
        }
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

  update(level, study, mode) async {
    if(level != null && level != '' &&
        study != null && study != '' &&
        mode != null && mode != '') {

      if(isFile != true) {
        String institute = instituteController.text.toString();
        String result = resultController.text.toString();
        var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/write/res.member.education?ids=[$educationId]'));
        userMember == 'Member' ? request.fields.addAll({
          'values': "{'study_level_id': $levelID,'member_id': $id,'program_id': $studyID,'year_of_passing': '$years','institution': '$institute','mode': '$mode','result': '$result','state': '$status'}"
        }) : request.fields.addAll({
          'values': "{'study_level_id': $levelID,'member_id': $memberId,'program_id': $studyID,'year_of_passing': '$years','institution': '$institute','mode': '$mode','result': '$result','state': '$status'}"
        });
        if (_attacFile != null && _attacFile != '') {
          request.files.add(await http.MultipartFile.fromPath('attachment', _attacFile));
        }
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if(response.statusCode == 200) {
          final message = json.decode(await response.stream.bytesToString())['message'];
          setState(() {
            _isLoading = false;
            load = false;
            AnimatedSnackBar.show(
                context,
                'Education data updated successfully.',
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
                  },
                );
              },
            );
          });
        }
      } else {
        isFile = true;
        AnimatedSnackBar.show(
            context,
            'File size must be 2 MB or below.',
            Colors.red
        );
      }
    } else {
      setState(() {
        isLevel = true;
        isStudy = true;
        isMode = true;
      });
      AnimatedSnackBar.show(
          context,
          'Please fill the required fields.',
          Colors.red
      );
    }
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      getEducationalData();
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
    getLevelData();
    getStudyData();
    loadDataWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Education'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A3F85),
                    Color(0xFFFA761E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
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
                          'Level',
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
                      initialValue: level,
                      listSpace: 20,
                      listPadding: ListPadding(top: 20),
                      searchShowCursor: true,
                      searchAutofocus: true,
                      enableSearch: true,
                      listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                      textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                      dropDownItemCount: 6,
                      dropDownList: levelDropDown,
                      textFieldDecoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: level != '' ? level : "Select study level",
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
                          level = val.name;
                          levelID = val.value;
                          if(level.isNotEmpty && level != '') {
                            isLevel = false;
                            studyDropDown.clear();
                            if(_isLoading == false) {
                              _isLoading = true;
                              getStudy(levelID);
                              _isLoading = false;
                            } else {
                              _isLoading = false;
                            }
                          }
                        } else {
                          setState(() {
                            isLevel = true;
                            level = '';
                          });
                        }
                      },
                    ),
                  ),
                  isLevel ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Study level is required",
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
                    child: Row(
                      children: [
                        Text(
                          'Program of Study',
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
                      initialValue: study,
                      listSpace: 20,
                      listPadding: ListPadding(top: 20),
                      searchShowCursor: true,
                      searchAutofocus: true,
                      enableSearch: true,
                      clearOption: true,
                      listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                      textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                      dropDownItemCount: 6,
                      dropDownList: studyDropDown,
                      onChanged: (val) {
                        if (val != null && val != "") {
                          study = val.name;
                          studyID = val.value;
                          if(study.isNotEmpty && study != '') {
                            setState(() {
                              isStudy = false;
                            });
                          }
                        } else {
                          setState(() {
                            isStudy = true;
                            study = '';
                          });
                        }
                      },
                      textFieldDecoration: InputDecoration(
                        hintText: study != '' ? study : "Select program of study",
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
                  isStudy ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Program of study is required",
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
                      'Place and Institution',
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
                      controller: instituteController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your study place or institution.",
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
                    child: Text(
                      'Year of Passing',
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
                      controller: yearController,
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
                        hintText: "Choose year of passing",
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
                              title: const Text("Select Year", style: TextStyle(color: backgroundColor),),
                              content: SizedBox( // Need to use container to add size constraint.
                                width: size.width * 0.03,
                                height: size.height * 0.3,
                                child: YearPicker(
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  initialDate: yearController.text.isNotEmpty ? format.parse(yearController.text) : DateTime(DateTime.now().year),
                                  selectedDate: yearController.text.isNotEmpty ? format.parse(yearController.text) : DateTime(DateTime.now().year),
                                  onChanged: (DateTime dateTime) {
                                    yearController.text = format.format(dateTime);
                                    years = yearController.text;
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
                    child: Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
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
                              groupValue: status,
                              title: Text('Active', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  status = value!;
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
                              groupValue: status,
                              title: Text('Completed', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  status = value!;
                                });
                              }
                          )
                      ),
                    ],
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
                          'Mode',
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
                  RadioListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dense: true,
                    tileColor: inputColor,
                    activeColor: enableColor,
                    value: 'Regular',
                    groupValue: mode,
                    title: Text('Regular', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                    onChanged: (String? value) {
                      setState(() {
                        if (value!.isEmpty && value == '') {
                          isMode = true;
                        } else {
                          isMode = false;
                          mode = value;
                        }
                      });
                    },
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
                      value: 'Private',
                      groupValue: mode,
                      title: Text('Private', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          if (value!.isEmpty && value == '') {
                            isMode = true;
                          } else {
                            isMode = false;
                            mode = value;
                          }
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
                      value: 'Not Applicable',
                      groupValue: mode,
                      title: Text('Not Applicable', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          if (value!.isEmpty && value == '') {
                            isMode = true;
                          } else {
                            isMode = false;
                            mode = value;
                          }
                        });
                      }
                  ),
                  isMode ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Study mode is required",
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
                      'Result',
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
                      controller: resultController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter the study result",
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
                    child: Text(
                      'Attachment',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.indigo
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              getFiles();
                            });
                          },
                          icon: const Icon(Icons.attachment, color: Colors.white,),
                          label: Text(
                            "Attach File",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.breeSerif(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02,),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _attachFileName != null && _attachFileName != '' ? Text('$_attachFileName') : const Text(''),
                            _attachFileName != null && _attachFileName != '' ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red,),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmAlertDialog(
                                      message: 'Are you sure want to delete the file ?',
                                      onCancelPressed: () {
                                        cancel();
                                      },
                                      onYesPressed: () {
                                        setState(() {
                                          _attacFile = '';
                                          _attachFileName = '';
                                          _netAttacFile = '';
                                          localPath = '';
                                          fileName = '';
                                          AnimatedSnackBar.show(
                                              context,
                                              'File is removed successfully',
                                              Colors.green
                                          );
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              },
                            ) : Container(),
                            _attachFileName != null && _attachFileName != '' && _netAttacFile != '' ? IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              color: Colors.orangeAccent,
                              onPressed: () {
                                netPath = _netAttacFile;
                                File file = File(netPath);
                                path = file.path;
                                netFileName = path.split("/").last;
                                fileName = netFileName;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (_) => PDFViewerCachedFromNetworkUrl(
                                      netUrl: netPath,
                                    ),
                                  ),
                                );
                              },
                            ) : _attachFileName != null && _attachFileName != '' ? IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              color: Colors.orangeAccent,
                              onPressed: () {
                                localPath = _attacFile;
                                File file = File(localPath);
                                path = file.path;
                                fileName = path.split("/").last;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (_) => PDFViewerCachedFromUrl(
                                      url: localPath,
                                    ),
                                  ),
                                );
                              },
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  isFile ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "File size must be 2 MB or below",
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
                      if(level.isNotEmpty && study.isNotEmpty && mode.isNotEmpty) {
                        if(load) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          update(level, study, mode);
                        }
                      } else if(level.isEmpty && study.isNotEmpty && mode.isNotEmpty) {
                        setState(() {
                          isLevel = true;
                        });
                        AnimatedSnackBar.show(
                            context,
                            'Please fill the required fields.',
                            Colors.red
                        );
                      } else if(level.isNotEmpty && study.isEmpty && mode.isNotEmpty) {
                        setState(() {
                          isStudy = true;
                        });
                        AnimatedSnackBar.show(
                            context,
                            'Please fill the required fields.',
                            Colors.red
                        );
                      } else if(level.isNotEmpty && study.isNotEmpty && mode.isEmpty) {
                        setState(() {
                          isMode = true;
                        });
                        AnimatedSnackBar.show(
                            context,
                            'Please fill the required fields.',
                            Colors.red
                        );
                      } else if(level.isEmpty && study.isEmpty && mode.isNotEmpty) {
                        setState(() {
                          isLevel = true;
                          isStudy = true;
                        });
                        AnimatedSnackBar.show(
                            context,
                            'Please fill the required fields.',
                            Colors.red
                        );
                      } else if(level.isNotEmpty && study.isEmpty && mode.isEmpty) {
                        setState(() {
                          isStudy = true;
                          isMode = true;
                        });
                        AnimatedSnackBar.show(
                            context,
                            'Please fill the required fields.',
                            Colors.red
                        );
                      } else if(level.isEmpty && study.isNotEmpty && mode.isEmpty) {
                        setState(() {
                          isLevel = true;
                          isMode = true;
                        });
                        AnimatedSnackBar.show(
                            context,
                            'Please fill the required fields.',
                            Colors.red
                        );
                      } else {
                        setState(() {
                          isLevel = true;
                          isStudy = true;
                          isMode = true;
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
      ),
    );
  }
}

class PDFViewerCachedFromNetworkUrl extends StatelessWidget {
  const PDFViewerCachedFromNetworkUrl({Key? key, required this.netUrl}) : super(key: key);

  final String netUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
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
      body: SfPdfViewer.network(netUrl),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
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
      body: SfPdfViewer.file(File(url)),
    );
  }
}