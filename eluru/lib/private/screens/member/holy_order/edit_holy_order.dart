import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eluru/widget/common/common.dart';
import 'package:eluru/widget/common/internet_connection_checker.dart';
import 'package:eluru/widget/common/snackbar.dart';
import 'package:eluru/widget/theme_color/theme_color.dart';
import 'package:eluru/widget/widget.dart';

class EditHolyOrderScreen extends StatefulWidget {
  const EditHolyOrderScreen({Key? key}) : super(key: key);

  @override
  State<EditHolyOrderScreen> createState() => _EditHolyOrderScreenState();
}

class _EditHolyOrderScreenState extends State<EditHolyOrderScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool load = true;
  bool isOrder = false;
  bool isStatus = false;
  bool isDate = false;
  String status = 'Completed';
  String date = '';
  String order = '';
  var dateController = TextEditingController();
  var placeController = TextEditingController();
  var ministerController = TextEditingController();

  List holyOrder = [];

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getHolyOrderData() async {
    String holyOderUrl = "$baseUrl/search_read/res.holyorder/$holyOrderId";
    var request = http.Request('GET', Uri.parse(holyOderUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      holyOrder = data;
      for(int i = 0; i < holyOrder.length; i++) {
        order = holyOrder[i]['order'];
        dateController.text = DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(holyOrder[i]['date']));
        date = holyOrder[i]['date'];
        placeController.text = holyOrder[i]['place'];
        ministerController.text = holyOrder[i]['minister'];
        status = holyOrder[i]['state'];
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

  update(String order, date, status) async {
    if(order != null && order != '' &&
        date != null && date != '' &&
        status != null && status != '') {
      String place = placeController.text.toString();
      String minister = ministerController.text.toString();
      var request = http.MultipartRequest('PUT',  Uri.parse('$baseUrl/write/res.holyorder?ids=[$holyOrderId]'));
      userMember == 'Member' ? request.fields.addAll({
        'values': "{'member_id': $id,'date': '$date','place': '$place','order': '$order','minister': '$minister','state': '$status'}"
      }) : request.fields.addAll({
        'values': "{'member_id': $memberId,'date': '$date','place': '$place','order': '$order','minister': '$minister','state': '$status'}"
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
              'Holy order data updated successfully.',
              Colors.green
          );
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
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getHolyOrderData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getHolyOrderData();
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
          title: const Text('Edit Holy Order'),
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
                            'Order',
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
                    RadioListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      dense: true,
                      tileColor: inputColor,
                      activeColor: enableColor,
                      value: 'Lector',
                      groupValue: order,
                      title: Text('Lector', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                      onChanged: (String? value) {
                        setState(() {
                          if (value!.isEmpty && value == '') {
                            isOrder = true;
                          } else {
                            isOrder = false;
                            order = value;
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
                        value: 'Acolyte',
                        groupValue: order,
                        title: Text('Acolyte', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                        onChanged: (String? value) {
                          setState(() {
                            if (value!.isEmpty && value == '') {
                              isOrder = true;
                            } else {
                              isOrder = false;
                              order = value;
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
                        value: 'Deacon',
                        groupValue: order,
                        title: Text('Deacon', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                        onChanged: (String? value) {
                          setState(() {
                            if (value!.isEmpty && value == '') {
                              isOrder = true;
                            } else {
                              isOrder = false;
                              order = value;
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
                        value: 'Priest',
                        groupValue: order,
                        title: Text('Priest', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                        onChanged: (String? value) {
                          setState(() {
                            if (value!.isEmpty && value == '') {
                              isOrder = true;
                            } else {
                              isOrder = false;
                              order = value;
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
                        value: 'Bishop',
                        groupValue: order,
                        title: Text('Bishop', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                        onChanged: (String? value) {
                          setState(() {
                            if (value!.isEmpty && value == '') {
                              isOrder = true;
                            } else {
                              isOrder = false;
                              order = value;
                            }
                          });
                        }
                    ),
                    isOrder ? Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: const Text(
                          "Order is required",
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
                        keyboardType: TextInputType.datetime,
                        maxLength: 10,
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
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
                          ),
                          hintText: "Choose the date",
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
                            isDate = true;
                          } else {
                            isDate = false;
                          }
                        },
                        onFieldSubmitted: (_) {
                          setState(() {
                            dateController.text = '';
                            date = '';
                          });
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
                          } else {
                            dateController.text = '';
                            date = '';
                          }
                        },
                      ),
                    ),
                    isDate ? Container(
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
                          LengthLimitingTextInputFormatter(20), // Limit to 10 characters
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
                        'Minister',
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
                        controller: ministerController,
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
                          hintText: "Enter your minister",
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
                                groupValue: status,
                                title: Text('Active', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                onChanged: (String? value) {
                                  setState(() {
                                    if (value!.isEmpty && value == '') {
                                      isStatus = true;
                                    } else {
                                      isStatus = false;
                                      status = value;
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
                                groupValue: status,
                                title: Text('Completed', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                onChanged: (String? value) {
                                  setState(() {
                                    if (value!.isEmpty && value == '') {
                                      isStatus = true;
                                    } else {
                                      isStatus = false;
                                      status = value;
                                    }
                                  });
                                }
                            )
                        ),
                      ],
                    ),
                    isStatus ? Container(
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
                width: size.width * 0.3,
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
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: greenColor,
                  ),
                  child: TextButton(
                      onPressed: () {
                        if(order.isNotEmpty && date.isNotEmpty && status.isNotEmpty) {
                          update(order, date, status);
                        } else if(order.isEmpty && date.isNotEmpty && status.isNotEmpty) {
                          setState(() {
                            isOrder = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(order.isNotEmpty && date.isEmpty && status.isNotEmpty) {
                          setState(() {
                            isDate = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(order.isNotEmpty && date.isNotEmpty && status.isEmpty) {
                          setState(() {
                            isStatus = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(order.isEmpty && date.isEmpty && status.isNotEmpty) {
                          setState(() {
                            isOrder = true;
                            isDate = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(order.isNotEmpty && date.isEmpty && status.isEmpty) {
                          setState(() {
                            isDate = true;
                            isStatus = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else if(order.isEmpty && date.isNotEmpty && status.isEmpty) {
                          setState(() {
                            isOrder = true;
                            isStatus = true;
                          });
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields.',
                              Colors.red
                          );
                        } else {
                          setState(() {
                            isOrder = true;
                            isDate = true;
                            isStatus = true;
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
