import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/snackbar.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AddStatutoryRenewalsScreen extends StatefulWidget {
  const AddStatutoryRenewalsScreen({Key? key}) : super(key: key);

  @override
  State<AddStatutoryRenewalsScreen> createState() => _AddStatutoryRenewalsScreenState();
}

class _AddStatutoryRenewalsScreenState extends State<AddStatutoryRenewalsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  final bool _canPop = false;
  bool load = true;
  bool _isLoading = true;
  bool isDocumentType = false;
  bool isDocumentNumber = false;
  bool isFile = false;

  String documentName = '';
  String documentID = '';
  String validFrom = '';
  String validTo = '';
  String nextRenewal = '';

  var documentNumberController = TextEditingController();
  var agencyController = TextEditingController();
  var validFromController = TextEditingController();
  var validToController = TextEditingController();
  var nextRenewalController = TextEditingController();
  final SingleValueDropDownController _documentType = SingleValueDropDownController();

  List documentTypeData = [];
  List<DropDownValueModel> documentTypeDropDown = [];

  var _attacFile;
  var _attachFileName;
  var baseFile;
  var path;

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

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
        if(sizeInMb <= 2) {
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
          isFile = true;
          _attacFile = '';
          _attachFileName = '';
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

  getDocumentTypeData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/renewal.doc.type?domain=[('is_member','=','True')]&fields=['name','document_number']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      documentTypeData = data;
      for(int i = 0; i < documentTypeData.length; i++) {
        setState(() {
          documentTypeDropDown.add(DropDownValueModel(name: documentTypeData[i]['name'], value: documentTypeData[i]['id']));
        });
      }
      return documentTypeDropDown;
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

  save(String documentType, documentNumber) async {
    if(documentType.isNotEmpty && documentType != '' && documentNumber != null && documentNumber != '') {
      String agency = agencyController.text.toString();

      if(isFile != true) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/create/member.statutory.renewals'));
        userMember == 'Member' ? _attacFile != null && _attacFile != '' ? request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$id,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal'}"
        }) : request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$id,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal','proof': ''}"
        }) : _attacFile != null && _attacFile != '' ? request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$memberId,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal'}"
        }) : request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$memberId,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal','proof': ''}"
        });
        if (_attacFile != null && _attacFile != '' && _attacFile.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath('proof', _attacFile));
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
                'Statutory renewals data created successfully.',
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
        isDocumentType = true;
        isDocumentNumber = true;
      });
      AnimatedSnackBar.show(
          context,
          'Please fill the required fields.',
          Colors.red
      );
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
      getDocumentTypeData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDocumentTypeData();
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
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          Navigator.pop(context, 'refresh');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Add Statutory Renewals'),
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
                      primaryColor,
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
                            'Document Type',
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
                        controller: _documentType,
                        listSpace: 20,
                        listPadding: ListPadding(top: 20),
                        searchShowCursor: true,
                        searchAutofocus: true,
                        enableSearch: true,
                        listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                        textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                        dropDownItemCount: 6,
                        dropDownList: documentTypeDropDown,
                        textFieldDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Select document type",
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
                            documentName = val.name;
                            documentID = val.value.toString();
                            isDocumentType = false;
                          } else {
                            setState(() {
                              isDocumentType = true;
                              documentName = '';
                              documentID = '';
                            });
                          }
                        },
                      ),
                    ),
                    isDocumentType ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Document type is required",
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
                            'Document Number',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(width: size.width * 0.01,),
                          Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),),
                          // SizedBox(width: size.width * 0.01,),
                          documentName == 'Passport' ? Text(
                            '(Eg: A1234567)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : documentName == 'Driving License' ? Text(
                            '(Eg: TN2420200000000)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : documentName == 'Fire Extinguisher' ? Text(
                            '(Eg: AB-123456)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : documentName == 'Visa' ? Text(
                            '(Eg: AB1234567 or AB12345678)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : documentName == 'Debit Card' ? Text(
                            '(Eg: 4539567890123456)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : documentName == 'Vehicle Registration' ? Text(
                            '(Eg: TN-01-AA-1234)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : documentName == 'Vehicle Insurance' ? Text(
                            '(Eg: AB12CD3456EF7890123)',
                            style: GoogleFonts.poppins(
                              fontSize: size.height * 0.016,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: inputColor
                      ),
                      child: TextFormField(
                        controller: documentNumberController,
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20), // Limit to 10 characters
                        ],
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          hintText: "Your document number",
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
                            isDocumentNumber = true;
                          } else {
                            isDocumentNumber = false;
                          }
                          return null;
                        },
                      ),
                    ),
                    isDocumentNumber ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Document number is required",
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
                        'Agency',
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
                        controller: agencyController,
                        autocorrect: true,
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30), // Limit to 10 characters
                        ],
                        style: GoogleFonts.breeSerif(
                            color: Colors.black,
                            letterSpacing: 0.2
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter statutory renewals agency",
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
                        'Valid From',
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
                        controller: validFromController,
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
                        onFieldSubmitted: (_) {
                          setState(() {
                            validFromController.text = '';
                            validFrom = '';
                          });
                        },
                        onTap: () async {
                          DateTime? datePick = await showDatePicker(
                            context: context,
                            initialDate: validFromController.text.isNotEmpty ? format.parse(validFromController.text) :DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.red,
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
                              validFromController.text = format.format(datePick);
                              validFrom = reverse.format(datePick);
                            });
                          } else {
                            validFromController.text = '';
                            validFrom = '';
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
                        'Valid To',
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
                        controller: validToController,
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
                        onFieldSubmitted: (_) {
                          setState(() {
                            validToController.text = '';
                            validTo = '';
                          });
                        },
                        onTap: () async {
                          DateTime? datePick = await showDatePicker(
                            context: context,
                            initialDate: validToController.text.isNotEmpty ? format.parse(validToController.text) :DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.red,
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
                              validToController.text = format.format(datePick);
                              validTo = reverse.format(datePick);
                              DateTime fromDate = DateTime.parse(validFrom);
                              DateTime toDate = DateTime.parse(validTo);
                              if(toDate.isBefore(fromDate)) {
                                validToController.text = '';
                                validTo = '';
                                validFromController.text = '';
                                validFrom = '';
                                AnimatedSnackBar.show(
                                    context,
                                    'To date should not be lesser than from date.',
                                    Colors.red
                                );
                              }
                            });
                          } else {
                            validToController.text = '';
                            validTo = '';
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
                        'Next Renewal Date',
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
                        controller: nextRenewalController,
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
                        onFieldSubmitted: (_) {
                          setState(() {
                            nextRenewalController.text = '';
                            nextRenewal = '';
                          });
                        },
                        onTap: () async {
                          DateTime? datePick = await showDatePicker(
                            context: context,
                            initialDate: nextRenewalController.text.isNotEmpty ? format.parse(nextRenewalController.text) :DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.red,
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
                              nextRenewalController.text = format.format(datePick);
                              nextRenewal = reverse.format(datePick);
                            });
                          } else {
                            nextRenewalController.text = '';
                            nextRenewal = '';
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
                        'Proof',
                        style: GoogleFonts.poppins(
                          fontSize: size.height * 0.018,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                              "Attach Proof",
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
                              _attachFileName != null && _attachFileName != '' ? Flexible(child: Text('$_attachFileName')) : const Text(''),
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
                              _attachFileName != null && _attachFileName != '' ? IconButton(
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
                    SizedBox(height: size.height * 0.1,)
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
                        if(documentName.isNotEmpty && documentNumberController.text.isNotEmpty) {
                          if(load) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const CustomLoadingDialog();
                              },
                            );
                            save(documentName, documentNumberController.text.toString());
                          }
                        } else {
                          setState(() {
                            isDocumentType = true;
                            isDocumentNumber = true;
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
        ),
      ),
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
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SfPdfViewer.file(File(url)),
    );
  }
}