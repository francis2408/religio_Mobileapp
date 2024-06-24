import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class EditFamilyInfoScreen extends StatefulWidget {
  const EditFamilyInfoScreen({Key? key}) : super(key: key);

  @override
  State<EditFamilyInfoScreen> createState() => _EditFamilyInfoScreenState();
}

class _EditFamilyInfoScreenState extends State<EditFamilyInfoScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
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

  List family = [];

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  getFamilyInfoData() async {
    String url = '$baseUrl/member.family';
    Map data = {
      "params": {
        "filter": "[['member_id','=',${userProfile == "Profile" ? userMember : memberId}],['id','=',$familyId]]",
        "query": "{id,member_id,name,gender,relationship,birth_date,death_info,occupation,contact_number}"
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
      family = data;

      for(int i= 0; i < family.length; i++) {
        nameController.text = family[i]['name'];
        gender = family[i]['gender'];
        relation = family[i]['relationship'];
        dateOfBirthController.text = family[i]['birth_date'];
        occupationController.text = family[i]['occupation'];
        contactController.text = family[i]['contact_number'];
      }
    }
    else {
      final message = jsonDecode(response.body)['result'];
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

  update(String name, gender, relation) async {
    if(name != null && name != '' &&
        gender != null && gender != '' &&
        relation != null && relation != '') {

      String occupation = occupationController.text.toString();
      String contact = contactController.text.toString();

      String url = '$baseUrl/edit/member.family/$familyId';
      Map data = {
        "params":{
          "data":{"member_id": userProfile == "Profile" ? userMember : memberId,"name": name,"gender": gender,"birth_date": dateOfBirth != '' ? dateOfBirth : null,"occupation": occupation,"contact_number": contact,"relationship": relation}
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
        isGender = true;
        isGender = true;
        isRelation = true;
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
      getFamilyInfoData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getFamilyInfoData();
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
          title: const Text('Edit Family Info'),
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
                              dateOfBirthController.text = format.format(datePick);
                              dateOfBirth = reverse.format(datePick);

                              // if(year < 18) {
                              //   Flushbar(
                              //     message: "You are under 18, So please select valid date of birth",
                              //     icon: const Icon(
                              //       Icons.warning,
                              //       size: 28.0,
                              //       color: Colors.red,
                              //     ),
                              //     flushbarPosition: FlushbarPosition.TOP,
                              //     duration: const Duration(seconds: 2),
                              //     leftBarIndicatorColor: Colors.red,
                              //     margin: const EdgeInsets.all(8),
                              //     borderRadius: BorderRadius.circular(10),
                              //     borderColor: Colors.red,
                              //     borderWidth: 1.5,
                              //   ).show(context);
                              // }
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
                        keyboardType: TextInputType.text,
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
                            var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                            if(reg.hasMatch(val)) {
                              isValid = false;
                            } else {
                              isValid = true;
                            }
                          } else {
                            isValid = false;
                            contactController.text = '';
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
                        if(nameController.text.toString().isNotEmpty && gender.isNotEmpty && relation.isNotEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          update(nameController.text.toString(), gender, relation);
                        } else if(nameController.text.toString().isEmpty && gender.isNotEmpty && relation.isNotEmpty) {
                          setState(() {
                            isName = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(nameController.text.toString().isNotEmpty && gender.isEmpty && relation.isNotEmpty) {
                          setState(() {
                            isGender = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(nameController.text.toString().isNotEmpty && gender.isNotEmpty && relation.isEmpty) {
                          setState(() {
                            isRelation = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(nameController.text.toString().isEmpty && gender.isEmpty && relation.isNotEmpty) {
                          setState(() {
                            isName = true;
                            isGender = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(nameController.text.toString().isNotEmpty && gender.isEmpty && relation.isEmpty) {
                          setState(() {
                            isGender = true;
                            isRelation = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else if(nameController.text.toString().isEmpty && gender.isNotEmpty && relation.isEmpty) {
                          setState(() {
                            isRelation = true;
                            isName = true;
                          });
                          AnimatedSnackBar.material(
                              'Please fill the required fields.',
                              type: AnimatedSnackBarType.error,
                              duration: const Duration(seconds: 2)
                          ).show(context);
                        } else {
                          setState(() {
                            isName = true;
                            isGender = true;
                            isRelation = true;
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
