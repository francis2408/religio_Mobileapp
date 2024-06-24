import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

class AddFamilyInfoScreen extends StatefulWidget {
  const AddFamilyInfoScreen({Key? key}) : super(key: key);

  @override
  State<AddFamilyInfoScreen> createState() => _AddFamilyInfoScreenState();
}

class _AddFamilyInfoScreenState extends State<AddFamilyInfoScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool load = true;
  bool isName = false;
  bool isGender = false;
  bool isRelation = false;
  bool isValid = false;
  String gender = 'Male';
  String relation = '';
  String dateOfBirth = '';
  var nameController = TextEditingController();
  var dateOfBirthController = TextEditingController();
  var contactController = TextEditingController();
  var occupationController = TextEditingController();

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  save(String name, gender, relation) async {
    if(name.isNotEmpty && name != '' &&
        gender != null && gender != '' &&
        relation != null && relation != '') {

      String occupation = occupationController.text.toString();
      String contact = contactController.text.toString();

      var request = http.MultipartRequest('POST',  Uri.parse('$baseUrl/create/res.religious.family'));
      userMember == 'Member' ? request.fields.addAll({
        'values': "{'member_id': '$id','name': '$name','gender': '$gender','birth_date': '$dateOfBirth','occupation': '$occupation','contact_number': '$contact','relationship': '$relation'}"
      }) : request.fields.addAll({
        'values': "{'member_id': '$memberId','name': '$name','gender': '$gender','birth_date': '$dateOfBirth','occupation': '$occupation','contact_number': '$contact','relationship': '$relation'}"
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
              'Family data created successfully.',
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
      setState(() {
        isGender = true;
        isGender = true;
        isRelation = true;
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
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Family Info'),
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
                              'Name',
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
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            hintText: "Your parent's or sibling's name",
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
                          // check tha validation
                          validator: (val) {
                            if (val!.isEmpty && val == '') {
                              isName = true;
                            } else {
                              isName = false;
                            }
                          },
                        ),
                      ),
                      isName ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Name is required",
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
                              'Gender',
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
                                  value: 'Male',
                                  groupValue: gender,
                                  title: Text('Male', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (value!.isEmpty && value == '') {
                                        isGender = true;
                                      } else {
                                        isGender = false;
                                        gender = value;
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
                                  value: 'Female',
                                  groupValue: gender,
                                  title: Text('Female', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (value!.isEmpty && value == '') {
                                        isGender = true;
                                      } else {
                                        isGender = false;
                                        gender = value;
                                      }
                                    });
                                  }
                              )
                          ),
                        ],
                      ),
                      isGender ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Gender is required",
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
                              'Relationship',
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
                                  value: 'Parent',
                                  groupValue: relation,
                                  title: Text('Parent', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (value!.isEmpty && value == '') {
                                        isRelation = true;
                                      } else {
                                        isRelation = false;
                                        relation = value;
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
                                  value: 'Siblings',
                                  groupValue: relation,
                                  title: Text('Siblings', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (value!.isEmpty && value == '') {
                                        isRelation = true;
                                      } else {
                                        isRelation = false;
                                        relation = value;
                                      }
                                    });
                                  }
                              )
                          ),
                        ],
                      ),
                      isRelation ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Relationship is required",
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
                          'Date of Birth',
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
                          controller: dateOfBirthController,
                          autocorrect: true,
                          keyboardType: TextInputType.datetime,
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
                            hintText: "Your parent's or sibling's birthday",
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
                              initialDate: dateOfBirthController.text.isNotEmpty ? format.parse(dateOfBirthController.text) :DateTime.now(),
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
                                dateOfBirthController.text = format.format(datePick);
                                dateOfBirth = reverse.format(datePick);
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
                          'Contact Number',
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
                          controller: contactController,
                          keyboardType: TextInputType.number,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            hintText: "Your parent's or sibling's contact number",
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
                          // check tha validationValidator
                          validator: (val) {
                            if(val!.isNotEmpty) {
                              var reg = RegExp(r"(^(?:[+0]9)?[0-9]{10,12}$)");
                              if(reg.hasMatch(val)) {
                                isValid = false;
                              } else {
                                isValid = true;
                              }
                            }
                          },
                        ),
                      ),
                      isValid ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Please enter the valid mobile number",
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
                          'Occupation',
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
                          controller: occupationController,
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.breeSerif(
                              color: Colors.black,
                              letterSpacing: 0.2
                          ),
                          decoration: InputDecoration(
                            hintText: "Your parent's or sibling's occupation",
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
                        if(nameController.text.toString().isNotEmpty && gender.isNotEmpty && relation.isNotEmpty) {
                          if(isValid == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid mobile number.',
                                Colors.red
                            );
                          } else {
                            if(load) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              save(nameController.text.toString(), gender, relation);
                            }
                          }
                        } else if(nameController.text.toString().isEmpty && gender.isNotEmpty && relation.isNotEmpty) {
                          setState(() {
                            isName = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(nameController.text.toString().isNotEmpty && gender.isEmpty && relation.isNotEmpty) {
                          setState(() {
                            isGender = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(nameController.text.toString().isNotEmpty && gender.isNotEmpty && relation.isEmpty) {
                          setState(() {
                            isRelation = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(nameController.text.toString().isEmpty && gender.isEmpty && relation.isNotEmpty) {
                          setState(() {
                            isName = true;
                            isGender = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(nameController.text.toString().isNotEmpty && gender.isEmpty && relation.isEmpty) {
                          setState(() {
                            isGender = true;
                            isRelation = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(nameController.text.toString().isEmpty && gender.isNotEmpty && relation.isEmpty) {
                          setState(() {
                            isRelation = true;
                            isName = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else {
                          setState(() {
                            isName = true;
                            isGender = true;
                            isRelation = true;
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
