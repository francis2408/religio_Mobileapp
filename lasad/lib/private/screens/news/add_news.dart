import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({Key? key}) : super(key: key);

  @override
  State<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool load = true;
  bool isTitle = false;
  bool isDate = false;
  String date = '';
  String type = '';
  String status = 'publish';

  var nameController  = TextEditingController();
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  save(String name) async {
    String description = descriptionController.text.toString();
    var request = http.MultipartRequest('POST',  Uri.parse('$baseUrl/create/res.news'));
    request.fields.addAll({
      'values': "{'name': '$name','date': '$date','type': '$type','description': '$description','state': '$status'}"
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
            'News data created successfully.',
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
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _isLoading = false;
              });
            });
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
        title: const Text('Add News'),
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
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
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
                      controller: nameController,
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
                        hintText: "Enter the title",
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
                    child: Row(
                      children: [
                        Text(
                          'Date',
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
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: TextFormField(
                      controller: dateController,
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
                          isDate = true;
                        } else {
                          isDate = false;
                        }
                      },
                      onTap: () async {
                        DateTime? datePick = await showDatePicker(
                          context: context,
                          initialDate: dateController.text.isNotEmpty ? format.parse(dateController.text) : DateTime.now(),
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
                            dateController.text = format.format(datePick);
                            date = reverse.format(datePick);
                          });
                        }
                      },
                    ),
                  ),
                  isDate ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Date is required",
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
                      value: 'Congregation',
                      groupValue: type,
                      title: Text('Congregation', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
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
                      value: 'Province',
                      groupValue: type,
                      title: Text('Province', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
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
                      value: 'Community',
                      groupValue: type,
                      title: Text('Community', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
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
                              value: 'publish',
                              groupValue: status,
                              title: Text('Publish', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
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
                              value: 'unpublished',
                              groupValue: status,
                              title: Text('Un Published', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
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
                    height: size.height * 0.3,
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
                      if(nameController.text.isNotEmpty && dateController.text.isNotEmpty) {
                        if(load) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          save(nameController.text.toString());
                        }
                      } else {
                        setState(() {
                          if(nameController.text.isEmpty) isTitle = true;
                          if(dateController.text.isEmpty) isDate = true;
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        });
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
