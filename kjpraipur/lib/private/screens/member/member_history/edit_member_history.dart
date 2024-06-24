import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

class EditMemberHistoryScreen extends StatefulWidget {
  const EditMemberHistoryScreen({Key? key}) : super(key: key);

  @override
  State<EditMemberHistoryScreen> createState() => _EditMemberHistoryScreenState();
}

class _EditMemberHistoryScreenState extends State<EditMemberHistoryScreen> {
  final formKey = GlobalKey<FormState>();
  final bool _canPop = false;
  bool _isLoading = true;
  bool isState = false;
  bool isMember = false;
  bool isHouse = false;
  bool isRole = false;
  bool isStartYear = false;
  String state = '';
  String startYear = '';
  String endYear = '';
  String roleName = '';
  String houseID = '';
  String houseName = '';
  String memberID = '';
  String memberName = '';
  String institutionID = '';
  String institutionName = '';

  var startYearController = TextEditingController();
  var endYearController = TextEditingController();
  final SingleValueDropDownController _member = SingleValueDropDownController();
  final SingleValueDropDownController _institution = SingleValueDropDownController();
  final SingleValueDropDownController _house = SingleValueDropDownController();
  final MultiValueDropDownController _role = MultiValueDropDownController();

  List memberBasic = [];
  List members = [];
  List house = [];
  List roles = [];
  List institutionData = [];
  List roleIds = [];
  List roleNames = [];

  List<DropDownValueModel> memberDropDown = [];
  List<DropDownValueModel> houseDropDown = [];
  List<DropDownValueModel> rolesDropDown = [];
  List<DropDownValueModel> institutionDropDown = [];

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberBasicData() async {
    var request = userMember == 'Member' ? http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$id)]&fields=['member_name']")) : http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$memberID)]&fields=['member_name']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      memberBasic = data;
      for(int i = 0; i < memberBasic.length; i++) {
        memberName = memberBasic[i]['member_name'];
        memberID = memberBasic[i]['id'].toString();
      }
    }
    else {
      final message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.error,
        //   title: 'Error',
        //   text: message,
        //   confirmBtnColor: greenColor,
        //   width: 100.0,
        // );
      });
    }
  }

  getMembersData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.religious.province/api_get_member_name_list?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      members = data;
      for(int i = 1; i < members.length; i++) {
        memberDropDown.add(DropDownValueModel(name: members[i]['member_name'], value: members[i]['id']));
      }
      return memberDropDown;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.error,
        //   title: 'Error',
        //   text: message,
        //   confirmBtnColor: greenColor,
        //   width: 100.0,
        // );
      });
    }
  }

  getHouseData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.community?domain=[('is_other_province','=',False),('is_other_diocese','=',False)]&fields=['name']&limit=40&offset=0"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      house = data;
      for(int i = 1; i < house.length; i++) {
        houseDropDown.add(DropDownValueModel(name: house[i]['name'], value: house[i]['id']));
      }
      return houseDropDown;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.error,
        //   title: 'Error',
        //   text: message,
        //   confirmBtnColor: greenColor,
        //   width: 100.0,
        // );
      });
    }
  }

  getRoleData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member.role?fields=['name']&limit=500"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      List data = json.decode(responseData)['data'];
      roles = data;
      for(int i = 1; i < roles.length; i++) {
        rolesDropDown.add(DropDownValueModel(name: roles[i]['name'], value: roles[i]['id']));
      }
      return rolesDropDown;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.error,
        //   title: 'Error',
        //   text: message,
        //   confirmBtnColor: greenColor,
        //   width: 100.0,
        // );
      });
    }
  }

  getInstitutionData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution?fields=['name']&order=name asc&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      institutionData = data;
      for(int i = 1; i < institutionData.length; i++) {
        institutionDropDown.add(DropDownValueModel(name: institutionData[i]['name'], value: institutionData[i]['id']));
      }
      return institutionDropDown;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.error,
        //   title: 'Error',
        //   text: message,
        //   confirmBtnColor: greenColor,
        //   width: 100.0,
        // );
      });
    }
  }

  save(String member, house, startDate, state) async {
    if(memberName.isNotEmpty && houseName.isNotEmpty && startYear.isNotEmpty && state != null) {
      var request = http.MultipartRequest('POST',  Uri.parse("$baseUrl/call/house.member/api_create_member_history?args=[{'member_id':$memberID,'house_id':$houseID,'date_from':'$startYear','date_to':'$endYear','role_ids':$roleIds,'institution_id':$institutionID,'status':'$state'}]"));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if(response.statusCode == 200) {
        final message = json.decode(await response.stream.bytesToString())['message'];
        setState(() {
          _isLoading = false;
          AnimatedSnackBar.show(
              context,
              'Member history data created successfully.',
              Colors.green
          );
          Navigator.pop(context, 'refresh');
        });
      } else {
        final message = json.decode(await response.stream.bytesToString())['message'];
        setState(() {
          _isLoading = false;
          // QuickAlert.show(
          //   context: context,
          //   type: QuickAlertType.error,
          //   title: 'Error',
          //   text: message,
          //   confirmBtnColor: greenColor,
          //   width: 100.0,
          // );
        });
      }
    } else {
      setState(() {
        isMember = true;
        isHouse = true;
        isStartYear = true;
        isState = true;
      });
      AnimatedSnackBar.show(
          context,
          'Please fill the required fields.',
          Colors.red
      );
    }
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      memberID == null && memberID == '' ? getMembersData() : getMemberBasicData();
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
    getHouseData();
    getRoleData();
    getInstitutionData();
    loadDataWithDelay();
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
            title: const Text('Edit Member History'),
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
                      memberID == null && memberID == '' ? Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Text(
                              'Member',
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
                      memberID == null && memberID == '' ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: inputColor
                        ),
                        child: DropDownTextField(
                          controller: _member,
                          listSpace: 20,
                          listPadding: ListPadding(top: 20),
                          searchShowCursor: true,
                          searchAutofocus: true,
                          enableSearch: true,
                          listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          dropDownItemCount: 6,
                          dropDownList: memberDropDown,
                          textFieldDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Select the member",
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
                              memberName = val.name;
                              memberID = val.value.toString();
                              if(memberName.isNotEmpty && memberName != '') {
                                isMember = false;
                              }
                            } else {
                              setState(() {
                                isMember = true;
                                memberName = '';
                                memberID = '';
                              });
                            }
                          },
                        ),
                      ) : Container(),
                      memberID == null && memberID == '' ? isMember ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Member is required",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500
                            ),
                          )
                      ) : Container() : Container(),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Text(
                              'House',
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
                          controller: _house,
                          listSpace: 20,
                          listPadding: ListPadding(top: 20),
                          searchShowCursor: true,
                          searchAutofocus: true,
                          enableSearch: true,
                          listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          dropDownItemCount: 6,
                          dropDownList: houseDropDown,
                          textFieldDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Select the house",
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
                              houseName = val.name;
                              houseID = val.value.toString();
                              if(houseName.isNotEmpty && houseName != '') {
                                isHouse = false;
                              }
                            } else {
                              setState(() {
                                isHouse = true;
                                houseName = '';
                                houseID = '';
                              });
                            }
                          },
                        ),
                      ),
                      isHouse ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "House is required",
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
                              'Start Year',
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
                          controller: startYearController,
                          autocorrect: true,
                          keyboardType: TextInputType.none,
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
                            hintText: "Select the beginning year",
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
                              isStartYear = true;
                            } else {
                              isStartYear = false;
                            }
                          },
                          onTap: () async {
                            DateTime? datePick = await showDatePicker(
                              context: context,
                              initialDate: startYearController.text.isNotEmpty ? format.parse(startYearController.text) :DateTime.now(),
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
                                var dateNow = DateTime.now();
                                var diff = dateNow.difference(datePick);
                                var year = ((diff.inDays)/365).round();
                                startYearController.text = format.format(datePick);
                                startYear = reverse.format(datePick);
                              });
                            }
                          },
                        ),
                      ),
                      isStartYear ? Container(
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
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'End Year',
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
                          controller: endYearController,
                          autocorrect: true,
                          keyboardType: TextInputType.none,
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
                            hintText: "Select the end of the year",
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
                              initialDate: endYearController.text.isNotEmpty ? format.parse(endYearController.text) :DateTime.now(),
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
                                var dateNow = DateTime.now();
                                var diff = dateNow.difference(datePick);
                                var year = ((diff.inDays)/365).round();
                                endYearController.text = format.format(datePick);
                                endYear = reverse.format(datePick);
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
                          'Roles',
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
                        child: DropDownTextField.multiSelection(
                          controller: _role,
                          listSpace: 20,
                          listPadding: ListPadding(top: 20),
                          listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          dropDownItemCount: 6,
                          dropDownList: rolesDropDown,
                          textFieldDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Select the role",
                            hintStyle: GoogleFonts.breeSerif(
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
                            if(val.isNotEmpty) {
                              for(int i = 0; i < val.length; i++) {
                                setState((){
                                  isRole = false;
                                  roleName = val[i].name;
                                  roleIds.add(val[i].value);
                                  roleNames.add(roleName);
                                });
                              }
                            } else {
                              isRole = true;
                              roleIds.clear();
                              roleNames.clear();
                            }
                          },
                        ),
                      ),
                      isRole ? Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: const Text(
                            "Role is required",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500
                            ),
                          )
                      ) : Container(),
                      roleNames.isNotEmpty ? SizedBox(
                        height: size.height * 0.01,
                      ) : Container(),
                      roleNames.isNotEmpty ? Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        alignment: Alignment.topLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Values:   ',
                              style: GoogleFonts.poppins(
                                fontSize: size.height * 0.018,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Flexible(
                              child: Text(roleNames.join(", "), style: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),),
                            )
                          ],
                        ),
                      ) : Container(),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Institution',
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
                        child: DropDownTextField(
                          controller: _institution,
                          listSpace: 20,
                          listPadding: ListPadding(top: 20),
                          searchShowCursor: true,
                          searchAutofocus: true,
                          enableSearch: true,
                          listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                          textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                          dropDownItemCount: 6,
                          dropDownList: institutionDropDown,
                          textFieldDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Select the institution",
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
                              institutionName = val.name;
                              institutionID = val.value.toString();
                            } else {
                              setState(() {
                                institutionName = '';
                                institutionID = '';
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
                                  groupValue: state,
                                  title: Text('Active', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (value!.isEmpty && value == '') {
                                        isState = true;
                                      } else {
                                        isState = false;
                                        state = value;
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
                                  groupValue: state,
                                  title: Text('Completed', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (value!.isEmpty && value == '') {
                                        isState = true;
                                      } else {
                                        isState = false;
                                        state = value;
                                      }
                                    });
                                  }
                              )
                          ),
                        ],
                      ),
                      isState ? Container(
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
                          if(memberName.isNotEmpty && houseName.isNotEmpty && startYear.isNotEmpty && state.isNotEmpty) {
                            save(memberName, houseName, startYear, state);
                          } else {
                            setState(() {
                              memberName.isNotEmpty ? isMember = false : isMember = true;
                              houseName.isNotEmpty ? isHouse = false : isHouse = true;
                              startYear.isNotEmpty ? isStartYear = false : isStartYear = true;
                              state.isNotEmpty ? isState = false : isState = true;
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
      ),
    );
  }
}
