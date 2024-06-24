import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/snackbar.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

class EditEmergencyContactScreen extends StatefulWidget {
  const EditEmergencyContactScreen({Key? key}) : super(key: key);

  @override
  State<EditEmergencyContactScreen> createState() => _EditEmergencyContactScreenState();
}

class _EditEmergencyContactScreenState extends State<EditEmergencyContactScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  final bool _canPop = false;
  bool load = true;
  bool _isLoading = true;
  bool isName = false;
  bool isMobile = false;
  bool isPin = false;

  var nameController = TextEditingController();
  var mobileController = TextEditingController();
  var streetController = TextEditingController();
  var street2Controller = TextEditingController();
  var placeController = TextEditingController();
  var cityController = TextEditingController();
  var zipCodeController = TextEditingController();
  final SingleValueDropDownController _relation = SingleValueDropDownController();
  final SingleValueDropDownController _district = SingleValueDropDownController();
  final SingleValueDropDownController _state = SingleValueDropDownController();
  final SingleValueDropDownController _country = SingleValueDropDownController();

  String district = '';
  String districtID = '';
  String state = '';
  String stateID = '';
  String country = '';
  String countryID = '';
  String relationShip = '';
  String relationShipID = '';

  List emergencyData = [];
  List relationShipData = [];
  List districtData = [];
  List districtBasedData = [];
  List stateData = [];
  List stateBasedData = [];
  List countryData = [];

  List<DropDownValueModel> relationShipDropDown = [];
  List<DropDownValueModel> districtDropDown = [];
  List<DropDownValueModel> stateDropDown = [];
  List<DropDownValueModel> countryDropDown = [];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getEmergencyContactData() async {
    setState(() {
      _isLoading = true;
    });
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/emergency.contact.info/$emergencyId"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      emergencyData = data;
      for(int i = 0; i < emergencyData.length; i++) {
        nameController.text = emergencyData[i]['emer_name'];
        mobileController.text = emergencyData[i]['emer_phone'];
        if(emergencyData[i]['emer_relationship_id'] != '' && emergencyData[i]['emer_relationship_id'] != null && emergencyData[i]['emer_relationship_id'] != []) {
          relationShipID = emergencyData[i]['emer_relationship_id'][0].toString();
          relationShip = emergencyData[i]['emer_relationship_id'][1];
        }
        streetController.text = emergencyData[i]['emer_street'];
        street2Controller.text = emergencyData[i]['emer_street2'];
        placeController.text = emergencyData[i]['emer_place'];
        cityController.text = emergencyData[i]['emer_city'];
        if(emergencyData[i]['emer_district_id'] != '' && emergencyData[i]['emer_district_id'] != null && emergencyData[i]['emer_district_id'] != []) {
          districtID = emergencyData[i]['emer_district_id'][0].toString();
          district = emergencyData[i]['emer_district_id'][1];
          setState(() {
            stateDropDown.clear();
            getDistrictDetail();
          });
        } else {
          district = '';
        }
        if(emergencyData[i]['emer_state_id'] != '' && emergencyData[i]['emer_state_id'] != null && emergencyData[i]['emer_state_id'] != []) {
          stateID = emergencyData[i]['emer_state_id'][0].toString();
          state = emergencyData[i]['emer_state_id'][1];
          setState(() {
            countryDropDown.clear();
            getStateDetail();
          });
        } else {
          state = '';
        }
        if(emergencyData[i]['emer_country_id'] != '' && emergencyData[i]['emer_country_id'] != null && emergencyData[i]['emer_country_id'] != []) {
          countryID = emergencyData[i]['emer_country_id'][0].toString();
          country = emergencyData[i]['emer_country_id'][1];
        } else {
          country = '';
        }
        zipCodeController.text = emergencyData[i]['emer_zip'];
      }
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
    setState(() {
      _isLoading = false;
    });
  }

  getRealtionshipData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.member.relationship?fields=['name','gender']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      relationShipData = data;
      for(int i = 0; i < relationShipData.length; i++) {
        setState(() {
          relationShipDropDown.add(DropDownValueModel(name: relationShipData[i]['name'], value: relationShipData[i]['id']));
        });
      }
      return relationShipDropDown;
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

  getDistrictData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.state.district?fields=['name','state_id']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      districtData = data;
      for(int i = 0; i < districtData.length; i++) {
        setState(() {
          districtDropDown.add(DropDownValueModel(name: districtData[i]['name'], value: districtData[i]['id']));
        });
      }
      return districtDropDown;
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

  getStateData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country.state?fields=['name','country_id']&limit=2000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      stateData = data;
      for(int i = 0; i < stateData.length; i++) {
        setState(() {
          stateDropDown.add(DropDownValueModel(name: stateData[i]['name'], value: stateData[i]['id']));
        });
      }
      return stateDropDown;
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

  getCountryData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country?fields=['name']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      countryData = data;
      for(int i = 0; i < countryData.length; i++) {
        setState(() {
          countryDropDown.add(DropDownValueModel(name: countryData[i]['name'], value: countryData[i]['id']));
        });
      }
      return countryDropDown;
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

  getDistrictDetail() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.state.district?id=$districtID&fields=['name','state_id']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];

      for(int i = 0; i < data.length; i++) {
        if(data[i]['state_id'] != '' && data[i]['state_id'] != []) {
          int id = data[i]['state_id'][0];
          stateID = id.toString();
        } else {
          stateID = '';
        }
      }
      getDistrictBased(stateID);
    }
    else {
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
  }

  getStateDetail() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country.state?id=$stateID&fields=['name','country_id']&limit=2000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];

      for(int i = 0; i < data.length; i++) {
        if(data[i]['country_id'] != '' && data[i]['country_id'] != []) {
          int id = data[i]['country_id'][0];
          countryID = id.toString();
        } else {
          countryID = '';
        }
      }
      getStateBased(countryID);
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
  }

  getDistrictBased(stateID) async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country.state?id=$stateID&fields=['name','country_id']&limit=2000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      districtBasedData = data;

      if(districtBasedData.isNotEmpty){
        for(int i = 0; i < districtBasedData.length; i++) {
          setState(() {
            stateDropDown.add(DropDownValueModel(name: districtBasedData[i]['name'], value: districtBasedData[i]['id']));
          });
        }
        return stateDropDown;
      } else {
        for(int i = 0; i <= districtBasedData.length; i++) {
          setState(() {
            stateDropDown.add(DropDownValueModel(name: "No data found", value: i));
          });
        }
        return stateDropDown;
      }
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
  }

  getStateBased(countryID) async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country?id=$countryID&fields=['name']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      stateBasedData = data;

      if(stateBasedData.isNotEmpty){
        for(int i = 0; i < stateBasedData.length; i++) {
          setState(() {
            countryDropDown.add(DropDownValueModel(name: stateBasedData[i]['name'], value: stateBasedData[i]['id']));
          });
        }
        return countryDropDown;
      } else {
        for(int i = 0; i <= stateBasedData.length; i++) {
          setState(() {
            countryDropDown.add(DropDownValueModel(name: "No data found", value: i));
          });
        }
        return countryDropDown;
      }
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
  }

  update(String name) async {
    var relation;
    var district;
    var state;
    var country;
    if(name != null && name != '') {
      String mobile = mobileController.text.toString();
      String street = streetController.text.toString();
      String street2 = street2Controller.text.toString();
      String place = placeController.text.toString();
      String city = cityController.text.toString();
      String zip = zipCodeController.text.toString();
      if(relationShipID != '' && relationShipID != null) {
        relation = relationShipID;
      } else {
        relation = [];
      }
      if(districtID != '' && districtID != null) {
        district = districtID;
      } else {
        district = [];
      }
      if(stateID != '' && stateID != null) {
        state = stateID;
      } else {
        state = [];
      }
      if(countryID != '' && countryID != null) {
        country = countryID;
      } else {
        country = [];
      }

      var request = http.MultipartRequest('PUT',  Uri.parse('$baseUrl/write/emergency.contact.info?ids=[$emergencyId]'));
      userMember == 'Member' ? request.fields.addAll({
        'values': "{'member_id': $id,'emer_name': '$name','emer_phone': '$mobile','emer_relationship_id': $relation,'emer_street': '$street','emer_street2': '$street2','emer_place': '$place','emer_city': '$city','emer_district_id': $district,'emer_state_id': $state,'emer_country_id': $country,'emer_zip': '$zip'}"
      }) : request.fields.addAll({
        'values': "{'member_id': $memberId,'emer_name': '$name','emer_phone': '$mobile','emer_relationship_id': $relation,'emer_street': '$street','emer_street2': '$street2','emer_place': '$place','emer_city': '$city','emer_district_id': $district,'emer_state_id': $state,'emer_country_id': $country,'emer_zip': '$zip'}"
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
              'Emergency data updated successfully.',
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
      setState(() {
        isName = true;
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
      getEmergencyContactData();
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
      getDistrictData();
      getStateData();
      getCountryData();
      getRealtionshipData();
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getDistrictData();
            getStateData();
            getCountryData();
            getRealtionshipData();
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
          title: const Text('Edit Emergency Contact'),
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
              padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
              alignment: Alignment.topLeft,
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    SizedBox(height: size.height * 0.02,),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      color: const Color(0xFFF0F0F0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
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
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20), // Limit to 10 characters
                                ],
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
                                    isName = true;
                                  } else {
                                    isName = false;
                                  }
                                  return null;
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
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                initialValue: relationShip,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: relationShipDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: relationShip != '' ? relationShip : "Select Relationship",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: relationShip != '' ? Colors.black87 : labelColor2,
                                    fontStyle: relationShip != '' ? FontStyle.normal : FontStyle.italic,
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
                                    relationShip = val.name;
                                    relationShipID = val.value.toString();
                                  } else {
                                    setState(() {
                                      relationShip = '';
                                      relationShipID = '';
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
                                'Mobile Number',
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
                                controller: mobileController,
                                keyboardType: TextInputType.number,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(12), // Limit to 10 characters
                                ],
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Your parent's or sibling's mobile number",
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
                                // check tha validationValidator
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                                    if(reg.hasMatch(val)) {
                                      isMobile = false;
                                    } else {
                                      isMobile = true;
                                    }
                                  } else {
                                    isMobile = false;
                                  }
                                },
                              ),
                            ),
                            isMobile ? Container(
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02,),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      color: const Color(0xFFF0F0F0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Address',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Street',
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
                                controller: streetController,
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
                                  hintText: "Enter your street name",
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
                                'Street 2',
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
                                controller: street2Controller,
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
                                  hintText: "Enter your second street name",
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
                                  hintText: "Enter your place name",
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
                                'City',
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
                                controller: cityController,
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
                                  hintText: "Enter your city name",
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
                                'District',
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
                                initialValue: district,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: districtDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: district != '' ? district : "Select the district",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: district != '' ? Colors.black87 : labelColor2,
                                    fontStyle: district != '' ? FontStyle.normal : FontStyle.italic,
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
                                    setState(() {
                                      district = val.name;
                                      districtID = val.value.toString();
                                      if(district.isNotEmpty && district != '') {
                                        stateDropDown.clear();
                                        if(_isLoading == false) {
                                          _isLoading = true;
                                          getDistrictDetail();
                                          _isLoading = false;
                                        } else {
                                          _isLoading = false;
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      district = '';
                                      districtID = '';
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
                                'State',
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
                                initialValue: state,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: stateDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: state != '' ? state : "Select the state",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: state != '' ? Colors.black87 : labelColor2,
                                    fontStyle: state != '' ? FontStyle.normal : FontStyle.italic,
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
                                    setState(() {
                                      state = val.name;
                                      stateID = val.value.toString();
                                      if(state.isNotEmpty && state != '') {
                                        countryDropDown.clear();
                                        if(_isLoading == false) {
                                          _isLoading = true;
                                          getStateDetail();
                                          _isLoading = false;
                                        } else {
                                          _isLoading = false;
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      state = '';
                                      stateID = '';
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
                                'Country',
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
                                initialValue: country,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: countryDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: country != '' ? country : "Select the country",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: country != '' ? Colors.black87 : labelColor2,
                                    fontStyle: country != '' ? FontStyle.normal : FontStyle.italic,
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
                                    setState(() {
                                      country = val.name;
                                      countryID = val.value.toString();
                                    });
                                  } else {
                                    setState(() {
                                      country = '';
                                      countryID = '';
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
                                'PIN code',
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
                                controller: zipCodeController,
                                keyboardType: TextInputType.number,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(8), // Limit to 10 characters
                                ],
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your pin code number",
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
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^[1-9][0-9]{5}$");
                                    if(reg.hasMatch(val)) {
                                      isPin = false;
                                    } else {
                                      isPin = true;
                                    }
                                  } else {
                                    isPin = false;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            isPin ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid PIN code",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                          ],
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
                        if(nameController.text.toString().isNotEmpty) {
                          if(isMobile == true && isPin == false) {
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the valid mobile number.',
                                Colors.red
                            );
                          } else if(isMobile == false && isPin == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the valid zip code.',
                                Colors.red
                            );
                          } else if(isMobile == true && isPin == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please fill the valid mobile number and zip code.',
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
                              update(nameController.text.toString());
                            }
                          }
                        } else{
                          setState(() {
                            isName = true;
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
