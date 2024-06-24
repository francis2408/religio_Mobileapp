import 'dart:convert';

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

class EditProfessionScreen extends StatefulWidget {
  const EditProfessionScreen({Key? key}) : super(key: key);

  @override
  State<EditProfessionScreen> createState() => _EditProfessionScreenState();
}

class _EditProfessionScreenState extends State<EditProfessionScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool load = true;
  bool isType = false;
  bool isDate = false;
  bool isStatus = false;
  String status = 'Completed';
  String type ='';
  String date = '';

  List profession = [];

  var dateController = TextEditingController();
  var placeController = TextEditingController();
  var yearController = TextEditingController();

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getProfessionData() async {
    String professionUrl = '';

    professionUrl = "$baseUrl/search_read/res.profession/$professionId";
    var request = http.Request('GET', Uri.parse(professionUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      profession = data;
      for(int i = 0; i < profession.length; i++) {
        type = profession[i]['type'];
        // Convert the input date string to DateTime
        DateTime inputDate = DateTime.parse(profession[i]['profession_date']);
        // Format the date in the desired format
        String outputDateString = DateFormat('dd-MM-yyyy').format(inputDate);
        dateController.text = outputDateString;
        date = profession[i]['profession_date'];
        placeController.text = profession[i]['place'];
        yearController.text = profession[i]['years'].toString();
        status = profession[i]['state'];
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

  update(String type, date) async {
    String place = placeController.text.toString();
    String years = yearController.text.toString().isNotEmpty ? yearController.text.toString() : 0.toString();
    if(type != null && type != '' && dateController.text.isNotEmpty) {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/write/res.profession?ids=[$professionId]'));
      userMember == 'Member' ? request.fields.addAll({
        'values': "{'type': '$type','member_id': $id,'profession_date': '$date','place': '$place','years': $years,'state': '$status'}"
      }) : request.fields.addAll({
        'values': "{'type': '$type','member_id': $memberId,'profession_date': '$date','place': '$place','years': $years,'state': '$status'}"
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
              'Profession data updated successfully.',
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
      getProfessionData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getProfessionData();
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
        title: const Text('Edit Profession'),
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
                          'Type',
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
                      value: 'First',
                      groupValue: type,
                      title: Text('First', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          if (value!.isEmpty && value == '') {
                            isType = true;
                          } else {
                            isType = false;
                            type = value;
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
                      value: 'Renewal',
                      groupValue: type,
                      title: Text('Renewal', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          if (value!.isEmpty && value == '') {
                            isType = true;
                          } else {
                            isType = false;
                            type = value;
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
                    value: 'Final',
                    groupValue: type,
                    title: Text('Final', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                    onChanged: (String? value) {
                      setState(() {
                        if (value!.isEmpty && value == '') {
                          isType = true;
                        } else {
                          isType = false;
                          type = value;
                        }
                      });
                    },
                  ),
                  isType ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Profession type is required",
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
                      onFieldSubmitted: (val) {
                        if (val.isEmpty) {
                          dateController.text = '';
                          date = '';
                        }
                      },
                      onTap: () async {
                        DateTime? datePick = await showDatePicker(
                          context: context,
                          initialDate: dateController.text.isNotEmpty ? format.parse(dateController.text) :DateTime.now(),
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
                        "Profession date is required",
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
                        hintText: "Enter your place",
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
                      'Years',
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
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10), // Limit to 10 characters
                      ],
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your profession years",
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
                      if(type.isNotEmpty && dateController.text.isNotEmpty) {
                        if(load) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          update(type, date);
                        }
                      } else {
                        if(type.isEmpty) {
                          setState(() {
                            isType = true;
                          });
                        } else if(dateController.text.isEmpty) {
                          setState(() {
                            isDate = true;
                          });
                        } else {
                          setState(() {
                            isType = true;
                            isDate = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        }
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
