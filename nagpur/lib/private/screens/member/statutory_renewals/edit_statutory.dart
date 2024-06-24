import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/common/internet_connection_checker.dart';
import 'package:nagpur/widget/common/snackbar.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditStatutoryRenewalsScreen extends StatefulWidget {
  const EditStatutoryRenewalsScreen({Key? key}) : super(key: key);

  @override
  State<EditStatutoryRenewalsScreen> createState() => _EditStatutoryRenewalsScreenState();
}

class _EditStatutoryRenewalsScreenState extends State<EditStatutoryRenewalsScreen> {
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
  String proofName = '';

  var documentNumberController = TextEditingController();
  var agencyController = TextEditingController();
  var validFromController = TextEditingController();
  var validToController = TextEditingController();
  var nextRenewalController = TextEditingController();

  List statutoryData = [];
  List documentTypeData = [];
  List<DropDownValueModel> documentTypeDropDown = [];

  var _attacFile;
  var _netAttacFile;
  var _attachFileName;
  var baseFile;
  var path;
  var netPath;
  var netFileName;

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
        proofName = file.name;

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
            proofName = '';
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

  getDocumentTypeData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/renewal.doc.type?domain=[('is_member','=','True')]&fields=['name','document_number']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
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

  getStatutoryData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/member.statutory.renewals/$statutoryId"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      statutoryData = data;

      for(int i = 0; i < statutoryData.length; i++) {
        if(statutoryData[i]['document_type_id'] != '' && statutoryData[i]['document_type_id'] != null && statutoryData[i]['document_type_id'] != []) {
          documentID = statutoryData[i]['document_type_id'][0].toString();
          documentName = statutoryData[i]['document_type_id'][1];
        } else {
          documentName = '';
        }
        documentNumberController.text = statutoryData[i]['no'];
        agencyController.text = statutoryData[i]['agency'];
        if(statutoryData[i]['valid_from'].isNotEmpty && statutoryData[i]['valid_from'] != '') {
          DateTime inputDate = DateTime.parse(statutoryData[i]['valid_from']);
          String inputDateString = DateFormat('dd-MM-yyyy').format(inputDate);
          validFromController.text = inputDateString;
          validFrom = statutoryData[i]['valid_from'];
        }
        if(statutoryData[i]['valid_to'].isNotEmpty && statutoryData[i]['valid_to'] != '') {
          DateTime outputDate = DateTime.parse(statutoryData[i]['valid_to']);
          String outputDateString = DateFormat('dd-MM-yyyy').format(outputDate);
          validToController.text = outputDateString;
          validTo = statutoryData[i]['valid_to'];
        }
        if(statutoryData[i]['next_renewal'].isNotEmpty && statutoryData[i]['next_renewal'] != '') {
          DateTime nextDate = DateTime.parse(statutoryData[i]['next_renewal']);
          String nextDateString = DateFormat('dd-MM-yyyy').format(nextDate);
          nextRenewalController.text = nextDateString;
          nextRenewal = statutoryData[i]['next_renewal'];
        }
        if(statutoryData[i]['proof'] != '') {
          _netAttacFile = statutoryData[i]['proof'];
          proofName = statutoryData[i]['proof_name'];
          var attach = statutoryData[i]['proof'];
          File file = File(attach);
          var path = file.path;
          _attachFileName = path.split("/").last;
        } else {
          _attacFile = '';
          _attachFileName = '';
          _netAttacFile = '';
          proofName = '';
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

  update(String documentType, documentNumber) async {
    if(documentType.isNotEmpty && documentType != '' && documentNumber != null && documentNumber != '') {
      String agency = agencyController.text.toString();

      if(isFile != true) {
        var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/write/member.statutory.renewals?ids=[$statutoryId]'));
        userMember == 'Member' ? _netAttacFile == '' && _attacFile == '' ? request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$id,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal','proof': ''}"
        }) : request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$id,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal'}"
        }) : _netAttacFile == '' && _attacFile == '' ? request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$memberId,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal','proof': ''}"
        }) : request.fields.addAll({
          'values': "{'document_type_id':$documentID,'member_id':$memberId,'no':'$documentNumber','agency':'$agency','valid_from':'$validFrom','valid_to':'$validTo','next_renewal':'$nextRenewal'}"
        });
        if (_attacFile != null && _attacFile != '') {
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
                'Statutory renewals data updated successfully.',
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

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      getStatutoryData();
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
      getDocumentTypeData();
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDocumentTypeData();
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
          title: const Text('Edit Statutory Renewals'),
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
                        initialValue: documentName,
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
                          hintText: documentName != '' ? documentName : "Select document type",
                          hintStyle: GoogleFonts.breeSerif(
                            color: documentName != '' ? Colors.black87 : labelColor2,
                            fontStyle: documentName != '' ? FontStyle.normal : FontStyle.italic,
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
                          // SizedBox(width: size.width * 0.02,),
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
                        onFieldSubmitted: (val) {
                          if (val.isEmpty) {
                            setState(() {
                              validFromController.text = '';
                              validFrom = '';
                            });
                          }
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
                        onFieldSubmitted: (val) {
                          if (val.isEmpty) {
                            setState(() {
                              validToController.text = '';
                              validTo = '';
                            });
                          }
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
                        onFieldSubmitted: (val) {
                          if (val.isEmpty) {
                            setState(() {
                              nextRenewalController.text = '';
                              nextRenewal = '';
                            });
                          }
                        },
                        onTap: () async {
                          DateTime? datePick = await showDatePicker(
                            context: context,
                            initialDate: nextRenewalController.text.isNotEmpty ? format.parse(nextRenewalController.text) : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
                              _attachFileName != null && _attachFileName != '' ? Flexible(child: Text(proofName)) : const Text(''),
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
                                            proofName = '';
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

                                  Map<String, String> queryParams = Uri.parse(fileName).queryParameters;
                                  // Extract the 'field' parameter
                                  field = queryParams['field'] ?? '';

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
                    _attachFileName != null && _attachFileName != '' ? Container() : isFile ? Container() : Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "File size must be 2 MB or below",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500
                          ),
                        )
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
                            update(documentName, documentNumberController.text.toString());
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
                      child: Text('Update', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
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
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
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