import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AddHealthScreen extends StatefulWidget {
  const AddHealthScreen({Key? key}) : super(key: key);

  @override
  State<AddHealthScreen> createState() => _AddHealthScreenState();
}

class _AddHealthScreenState extends State<AddHealthScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isDisease = false;
  String startDate = '';
  String endDate = '';
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var concernController = TextEditingController();
  var physicianController = TextEditingController();
  var descriptionController = TextEditingController();
  final SingleValueDropDownController _disease = SingleValueDropDownController();

  List diseaseData = [];
  List<DropDownValueModel> diseaseDropDown = [];

  int? diseaseID;
  String diseaseName = '';
  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var _attacFile;
  var _attachFileName;
  var baseFile;
  var path;

  getDiseaseData() async {
    String url = '$baseUrl/res.disease.disorder';
    Map data = {
      "params": {
        "query": "{id,name}"
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
      diseaseData = data;

      for(int i = 0; i < diseaseData.length; i++) {
        diseaseDropDown.add(DropDownValueModel(name: diseaseData[i]['name'], value: diseaseData[i]['id']));
      }
      return diseaseDropDown;
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

  getFiles() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['doc', 'pdf'],
    );

    if(resultFile != null) {
      setState(() {
        PlatformFile file = resultFile.files.first;
        _attacFile = file.path;
        _attachFileName = file.name;
        var attachFileType = _attacFile.split('.').last;

        File files = File(_attacFile);
        List<int> fileBytes = files.readAsBytesSync();
        var bFile = base64Encode(fileBytes);
        baseFile = 'data:@file/$attachFileType;base64,$bFile';

        final f = File(_attacFile);
        int sizeInBytes = f.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb <= 25){
          // This file is Longer the
        } else {

        }
      });
    }
  }

  save(String diseaseName) async {
    if(diseaseName != null && diseaseName != '') {

      String concern = concernController.text.toString();
      String physician = physicianController.text.toString();
      String description = descriptionController.text.toString();

      String url = '$baseUrl/create/member.health';
      Map data = {
        "params":{
          "data":{"member_id": userProfile == "Profile" ? userMember : memberId,"start_date": startDate != '' ? startDate : null,"end_date": endDate != '' ? endDate : null,"disease_disorder_id": diseaseID,"particulars": concern,"referred_physician": physician,"disease_description": description}
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
        final message = json.decode(response.body)['result'];
        setState(() {
          _isLoading = false;
          AnimatedSnackBar.material(
              'Health data crated successfully',
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
        isDisease = true;
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
      getDiseaseData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDiseaseData();
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
        title: const Text('Add Health'),
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
                              'Disease Type',
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
                          controller: _disease,
                          listSpace: 20,
                          listPadding: ListPadding(top: 20),
                          searchShowCursor: true,
                          searchAutofocus: true,
                          enableSearch: true,
                          clearOption: true,
                          listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          dropDownItemCount: 6,
                          dropDownList: diseaseDropDown,
                          onChanged: (val) {
                            if (val != null && val != "") {
                              diseaseName = val.name;
                              diseaseID = val.value;
                              if(diseaseName.isNotEmpty && diseaseName != '') {
                                setState(() {
                                  isDisease = false;
                                });
                              }
                            } else {
                              setState(() {
                                isDisease = true;
                                diseaseName = '';
                              });
                            }
                          },
                          textFieldDecoration: InputDecoration(
                            hintText: "Select disease type",
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
                      isDisease ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Disease is required",
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
                          'Start Date',
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
                          controller: startDateController,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.calendar_month,
                              color: Colors.indigo,
                            ),
                            hintText: "Choose start date",
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
                          onTap: () async {
                            DateTime? datePick = await showDatePicker(
                              context: context,
                              initialDate: startDateController.text.isNotEmpty ? format.parse(startDateController.text) :DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: const Color(0xFFFF512F),
                                    buttonTheme: const ButtonThemeData(
                                        textTheme: ButtonTextTheme.primary),
                                    colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFFF512F))
                                        .copyWith(
                                        secondary:
                                        const Color(0xFFFF512F)),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (datePick != null) {
                              setState(() {
                                // var dateNow = DateTime.now();
                                // var diff = dateNow.difference(datePick);
                                // var year = ((diff.inDays)/365).round();
                                startDateController.text = format.format(datePick);
                                startDate = reverse.format(datePick);
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
                          'End Date',
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
                          controller: endDateController,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.calendar_month,
                              color: Colors.indigo,
                            ),
                            hintText: "Choose end date",
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
                          onTap: () async {
                            DateTime? datePick = await showDatePicker(
                              context: context,
                              initialDate: endDateController.text.isNotEmpty ? format.parse(endDateController.text) :DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: const Color(0xFFFF512F),
                                    buttonTheme: const ButtonThemeData(
                                        textTheme: ButtonTextTheme.primary),
                                    colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFFF512F))
                                        .copyWith(
                                        secondary:
                                        const Color(0xFFFF512F)),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (datePick != null) {
                              setState(() {
                                // var dateNow = DateTime.now();
                                // var diff = dateNow.difference(datePick);
                                // var year = ((diff.inDays)/365).round();
                                endDateController.text = format.format(datePick);
                                endDate = reverse.format(datePick);
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
                          'Medical Concern',
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
                          controller: concernController,
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            hintText: "Your medical concern",
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
                          'Referred Physician',
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
                          controller: physicianController,
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            hintText: "You referred physician",
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
                          maxLength: 1000,
                          maxLines: 5,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            hintText: "Your description",
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
                      // SizedBox(height: size.height * 0.01,),
                      // Container(
                      //   padding: const EdgeInsets.only(top: 5, bottom: 10),
                      //   alignment: Alignment.topLeft,
                      //   child: Text(
                      //     'Attachment',
                      //     style: GoogleFonts.poppins(
                      //       fontSize: size.height * 0.02,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.black54,
                      //     ),
                      //   ),
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Container(
                      //       alignment: Alignment.center,
                      //       decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(20.0),
                      //           color: Colors.indigo
                      //       ),
                      //       child: TextButton.icon(
                      //         onPressed: () {
                      //           setState(() {
                      //             getFiles();
                      //           });
                      //         },
                      //         icon: const Icon(Icons.attachment, color: Colors.white,),
                      //         label: Text(
                      //           "Attach Proof",
                      //           textAlign: TextAlign.center,
                      //           style: GoogleFonts.breeSerif(
                      //             letterSpacing: 0.5,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: size.width * 0.02,),
                      //     Flexible(
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           _attachFileName != null && _attachFileName != '' ? Flexible(child: Text('$_attachFileName')) : const Text(''),
                      //           _attachFileName != null && _attachFileName != '' ? IconButton(
                      //             icon: const Icon(Icons.delete, color: Colors.red,),
                      //             onPressed: () {
                      //               setState(() {
                      //                 _attacFile = '';
                      //                 _attachFileName = '';
                      //                 localPath = '';
                      //                 filename = '';
                      //                 AnimatedSnackBar.material(
                      //                     'File is removed successfully',
                      //                     type: AnimatedSnackBarType.success,
                      //                     duration: const Duration(seconds: 2)
                      //                 ).show(context);
                      //               });
                      //             },
                      //           ) : Container(),
                      //           _attachFileName != null && _attachFileName != '' ? IconButton(
                      //             icon: const Icon(Icons.remove_red_eye),
                      //             color: Colors.orangeAccent,
                      //             onPressed: () {
                      //               // Check Internet connection
                      //               internetCheck();
                      //
                      //               localPath = _attacFile;
                      //               File file = File(localPath);
                      //               path = file.path;
                      //               filename = path.split("/").last;
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute<dynamic>(
                      //                   builder: (_) => PDFViewerCachedFromUrl(
                      //                     url: localPath,
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           ) : Container(),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: size.height * 0.1,),
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
                        if(diseaseName.isNotEmpty && diseaseName != '') {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          save(diseaseName);
                        } else {
                          setState(() {
                            isDisease = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
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

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text('$filename'),
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