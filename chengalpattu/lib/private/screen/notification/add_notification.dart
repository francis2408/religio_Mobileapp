import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool isTitle = false;
  bool isCommon = false;
  bool isUser = false;
  bool isDiocese = false;
  bool isUsers = false;

  var titleController = TextEditingController();
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();

  final SingleValueDropDownController _diocese = SingleValueDropDownController();
  final MultiValueDropDownController _users = MultiValueDropDownController();

  List dioceseData = [];
  List userData = [];
  List usersID = [];
  List usersName = [];
  List<DropDownValueModel> dioceseDropDown = [];
  List<DropDownValueModel> userDropDown = [];

  int? dioceseID;
  String dioceseName = '';
  String userName = '';

  String sendBy = 'Common';

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
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Notification'),
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
                          'Title',
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
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: GoogleFonts.breeSerif(
                          color: Colors.black,
                          letterSpacing: 0.2
                      ),
                      decoration: InputDecoration(
                        hintText: "Your notification title name",
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
                  SizedBox(height: size.height * 0.01,),
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Send By',
                      style: GoogleFonts.poppins(
                        fontSize: size.height * 0.02,
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
                              value: 'Common',
                              groupValue: sendBy,
                              title: Text('Common', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  sendBy = value!;
                                  isCommon = true;
                                  isUser = false;
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
                              value: 'Users',
                              groupValue: sendBy,
                              title: Text('Users', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  sendBy = value!;
                                  isUser = true;
                                  isCommon = false;
                                });
                              }
                          )
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01,),
                  isCommon ? Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Diocese',
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
                  ) : Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Diocese',
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
                  isCommon ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: DropDownTextField(
                      controller: _diocese,
                      listSpace: 20,
                      listPadding: ListPadding(top: 20),
                      searchShowCursor: true,
                      searchAutofocus: true,
                      enableSearch: true,
                      clearOption: true,
                      listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                      textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                      dropDownItemCount: 6,
                      dropDownList: dioceseDropDown,
                      onChanged: (val) {
                        if (val != null && val != "") {
                          dioceseName = val.name;
                          dioceseID = val.value;
                          if(dioceseName.isNotEmpty && dioceseName != '') {
                            setState(() {
                              isDiocese = false;
                            });
                          }
                        } else {
                          setState(() {
                            isDiocese = true;
                            dioceseName = '';
                          });
                        }
                      },
                      textFieldDecoration: InputDecoration(
                        hintText: "Select diocese",
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
                  ) : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: DropDownTextField(
                      controller: _diocese,
                      listSpace: 20,
                      listPadding: ListPadding(top: 20),
                      searchShowCursor: true,
                      searchAutofocus: true,
                      enableSearch: true,
                      clearOption: true,
                      listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                      textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                      dropDownItemCount: 6,
                      dropDownList: dioceseDropDown,
                      onChanged: (val) {
                        if (val != null && val != "") {
                          dioceseName = val.name;
                          dioceseID = val.value;
                          if(dioceseName.isNotEmpty && dioceseName != '') {
                            setState(() {
                              isDiocese = false;
                            });
                          }
                        } else {
                          setState(() {
                            isDiocese = true;
                            dioceseName = '';
                          });
                        }
                      },
                      textFieldDecoration: InputDecoration(
                        hintText: "Select diocese",
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
                  isDiocese ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Diocese is required",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      )
                  ) : Container(),
                  isUser ? SizedBox(height: size.height * 0.01,) : Container(),
                  isUser ? Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          'Users',
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
                  ) : Container(),
                  isUser ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: inputColor
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropDownTextField.multiSelection(
                          controller: _users,
                          listSpace: 20,
                          listPadding: ListPadding(top: 20),
                          clearOption: true,
                          listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          dropDownItemCount: 6,
                          dropDownList: userDropDown,
                          onChanged: (val) {
                            if(val.isNotEmpty) {
                              for(int i = 0; i < val.length; i++) {
                                setState((){
                                  userName = val[i].name;
                                  usersID.add(val[i].value);
                                  usersName.add(userName);
                                  if(usersID.isNotEmpty && usersName.isNotEmpty &&
                                      usersID != null && usersName != null &&
                                      usersID != [] && usersName != []) {
                                    setState(() {
                                      isUsers = false;
                                    });
                                  }
                                });
                              }
                            } else {
                              isUsers = false;
                              usersID.clear();
                              usersName.clear();
                            }
                          },
                          textFieldDecoration: InputDecoration(
                            hintText: "Select users",
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
                      ],
                    ),
                  ) : Container(),
                  isUsers ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      child: const Text(
                        "Users/User is required",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      )
                  ) : Container(),
                  SizedBox(height: size.height * 0.01,),
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
                    onPressed: () {},
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
                      onPressed: () {},
                      child: Text('Save', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        )
    );
  }
}
