import 'dart:convert';
import 'dart:io';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class ReligiousInstitutionList extends StatefulWidget {
  const ReligiousInstitutionList({Key? key}) : super(key: key);

  @override
  State<ReligiousInstitutionList> createState() => _ReligiousInstitutionListState();
}

class _ReligiousInstitutionListState extends State<ReligiousInstitutionList> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final InstitutionRunBy institutionRunBy = InstitutionRunBy();
  final InstitutionCategoryRunBy institutionCategoryRunBy = InstitutionCategoryRunBy();
  bool _isLoading = true;
  bool _isCategory = true;
  bool _isEducation = true;
  var categoryId;
  var subCategoryId;
  List category = [];
  List<DropDownValueModel> categoryDropDown = [];

  List religiousInstitutionCategory = [];
  List institutionData = [];
  int selected = -1;
  int selected2 = -1;
  int selected3 = -1;
  bool isCategoryTypeExpanded = true;
  bool isSubCategoryTypeExpanded = false;
  bool isCategoryExpanded = false;
  bool isSubCategoryExpanded = false;

  var mediumId;
  List<DropDownValueModel> mediumDropDown = [];

  getSubCategory(indexValue, indexName) {
    categoryId = indexValue;
    categoryTypeName = indexName;
    for(int i = 0; i < religiousInstitution.length; i++) {
      if(categoryId == religiousInstitution[i]['ministry_id'] && categoryTypeName == religiousInstitution[i]['ministry']) {
        religiousInstitutionCategory = religiousInstitution[i]['institutions'];
      }
    }
  }

  getInstitutionData() async {
    String url = '$baseUrl/res.institution';
    Map datas = mediumName == 'All' ? {
      "params": {
        "filter": "[['sub_category_id','=',$subCategoryId],['run_by','=','Religious']]",
        "order": "vicariate_id asc",
        "query":"{id,image_1920,name,phone,mobile,email,diocese_id,vicariate_id,parish_id,institution_category_id,street,street2,city,district_id,state_id,country_id,zip,medium_id}"
      }
    } : {
      "params": {
        "filter": "[['sub_category_id','=',$subCategoryId],['run_by','=','Religious'],['medium_id.name','=','$mediumName']]",
        "order": "vicariate_id asc",
        "query":"{id,image_1920,name,phone,mobile,email,diocese_id,vicariate_id,parish_id,institution_category_id,street,street2,city,district_id,state_id,country_id,zip,medium_id}"
      }
    };
    var body = jsonEncode(datas);
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
        _isEducation = false;
      });
      institutionData = data;
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        _isEducation = false;
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

  getCategoryValue() {
    for(int i = 0; i < categoryTab.length; i++) {
      categoryDropDown.add(DropDownValueModel(name: categoryTab[i]['name'], value: categoryTab[i]['id']));
    }
    return categoryDropDown;
  }

  getCategoryTypeValue() {
    for(int i = 0; i < mediumTab.length; i++) {
      mediumDropDown.add(DropDownValueModel(name: mediumTab[i]['name'], value: mediumTab[i]['id']));
    }
    return mediumDropDown;
  }

  getCategoryBasedData(categoryId) async {
    String url = '$baseUrl/res.institution/get_institution_data_runby';
    Map data = {
      "params": {
        "kwargs": {
          "institution_category_id": categoryId
        }
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
      var result = json.decode(response.body)['result'];
      List data = result['result'][0]['religious'];
      for(int i = 0; i < data.length; i++) {
        if (categoryId == data[i]['ministry_id'] && categoryName == data[i]['ministry']) {
          if (categoryName == 'All') {
            category.addAll(data[i]['institutions']);
          } else if (mediumName == 'Tamil Medium') {
            List tamil = data[i]['institutions'];
            for (int t = 0; t < tamil.length; t++) {
              if (tamil[t]['mediums'] != null && tamil[t]['mediums'].isNotEmpty) {
                List tamilMedium = tamil[t]['mediums'];
                for (int m = 0; m < tamilMedium.length; m++) {
                  if (tamilMedium[m]['medium_name'] == mediumName && (tamilMedium[m]['medium_count'] != 0 && tamilMedium[m]['medium_count'] != '')) {
                    category.add(tamil[t]);
                    break;
                  }
                }
              }
            }
          } else if (mediumName == 'English Medium') {
            List english = data[i]['institutions'];
            for (int e = 0; e < english.length; e++) {
              if (english[e]['mediums'] != null && english[e]['mediums'].isNotEmpty) {
                List englishMedium = english[e]['mediums'];
                for (int m = 0; m < englishMedium.length; m++) {
                  if (englishMedium[m]['medium_name'] == mediumName && (englishMedium[m]['medium_count'] != 0 && englishMedium[m]['medium_count'] != '')) {
                    category.add(english[e]);
                    break;
                  }
                }
              }
            }
          } else {
            category.addAll(data[i]['institutions']);
          }
        }
      }
      setState(() {
        _isCategory = false;
      });
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isCategory = false;
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

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> emailAction(String email) async {
    final Uri uri = Uri(scheme: "mailto", path: email);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    mediumName = 'All';
    categoryName = 'All';
    if(expiryDateTime!.isAfter(currentDateTime)) {
      institutionCategoryRunBy.runby(context, callback: () {
        getCategoryValue();
        getCategoryTypeValue();
      });
      institutionRunBy.runby(context, callback: () {
        setState(() {
          _isLoading = false;
          _isCategory = false;
        });
      });
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            institutionCategoryRunBy.runby(context, callback: () {
              getCategoryValue();
              getCategoryTypeValue();
            });
            institutionRunBy.runby(context, callback: () {
              setState(() {
                _isLoading = false;
                _isCategory = false;
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
      body: SafeArea(
        child: Center(
          child: _isLoading ? SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
            ),
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white
                          ),
                          child: DropDownTextField(
                            initialValue: categoryName,
                            listSpace: 20,
                            listPadding: ListPadding(top: 20),
                            listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                            textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                            dropDownItemCount: 6,
                            dropDownList: categoryDropDown,
                            clearOption: true,
                            textFieldDecoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: categoryName != '' && categoryName != null ? categoryName : "Select the category",
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
                                setState(() {
                                  categoryName = val.name;
                                  categoryId = val.value;
                                  if(categoryName.isNotEmpty && categoryName != '') {
                                    _isCategory = true;
                                    category.clear();
                                    getCategoryBasedData(categoryId);
                                  }
                                });
                              } else {
                                setState(() {
                                  category = [];
                                  categoryName = '';
                                  categoryId = '';
                                  _isCategory = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      categoryName == 'Education' ? SizedBox(
                        width: size.width * 0.02,
                      ) : Container(),
                      // categoryName == 'Education' ? Container(
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10),
                      //       color: Colors.white
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(5.0),
                      //     child: DropdownButton(
                      //       value: medium,
                      //       icon: const Icon(Icons.arrow_drop_down),
                      //       onChanged: (String? newValue) {
                      //         setState(() {
                      //           medium = newValue!;
                      //         });
                      //       },
                      //       items: const [
                      //         DropdownMenuItem(
                      //           value: 'All',
                      //           child: Text('All'),
                      //         ),
                      //         DropdownMenuItem(
                      //           value: 'Tamil Medium',
                      //           child: Text('Tamil'),
                      //         ),
                      //         DropdownMenuItem(
                      //           value: 'English Medium',
                      //           child: Text('English'),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ) : Container(),
                      categoryName == 'Education' ? Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white
                          ),
                          child: DropDownTextField(
                            initialValue: mediumName,
                            listSpace: 20,
                            listPadding: ListPadding(top: 20),
                            listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                            textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                            dropDownItemCount: 6,
                            dropDownList: mediumDropDown,
                            clearOption: true,
                            textFieldDecoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: mediumName != '' && mediumName != null ? mediumName : "Select the medium",
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
                              if (val != null && val != "") {
                                setState(() {
                                  mediumName = val.name;
                                  mediumId = val.value;
                                  if(mediumName.isNotEmpty && mediumName != '') {
                                    _isCategory = true;
                                    category.clear();
                                    getCategoryBasedData(categoryId);
                                  }
                                });
                              } else {
                                setState(() {
                                  mediumName = '';
                                  mediumId = '';
                                  _isCategory = false;
                                });
                              }
                            },
                          ),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                categoryName == 'All' ? religiousInstitution.isNotEmpty ? Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: religiousInstitution.length, // Update the itemCount to 2 for two expansion tiles
                          itemBuilder: (BuildContext context, int index) {
                            final isTileExpanded = index == selected;
                            final textExpandColor = isTileExpanded ? textColor : Colors.white;
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: ScaleAnimation(
                                  child: Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFED8F03), Color(0xFFFFB75E),],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(15.0)
                                          ),
                                          child: ExpansionTile(
                                            key: Key(index.toString()),// Use the generated GlobalKey for each expansion tile
                                            initiallyExpanded: index == selected,
                                            backgroundColor: Colors.white,
                                            iconColor: iconColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            onExpansionChanged: (newState) {
                                              if (newState) {
                                                setState(() {
                                                  selected = index;
                                                  int indexValue;
                                                  String indexName;
                                                  indexValue = religiousInstitution[index]['ministry_id'];
                                                  indexName = religiousInstitution[index]['ministry'];
                                                  getSubCategory(indexValue, indexName);
                                                  selected2 = -1;
                                                  selected3 = -1;
                                                  isCategoryExpanded = true;
                                                });
                                              } else {
                                                setState(() {
                                                  selected = -1;
                                                  isCategoryExpanded = false;
                                                });
                                              }
                                            },
                                            title: Container(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text(
                                                '${religiousInstitution[index]['ministry']}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.023,
                                                  color: textExpandColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            children: [
                                              religiousInstitutionCategory.isNotEmpty ? ListView.builder(
                                                key: Key('builder ${selected2.toString()}'),
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: isCategoryExpanded ? religiousInstitutionCategory.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                itemBuilder: (BuildContext context, int indexs) {
                                                  final isTileExpanded = indexs == selected2;
                                                  final subTextExpandColor = isTileExpanded ? noDataColor : Colors.blueAccent;
                                                  return Column(
                                                    children: [
                                                      ExpansionTile(
                                                        key: Key(indexs.toString()),// Use the generated GlobalKey for each expansion tile
                                                        initiallyExpanded: indexs == selected2,
                                                        iconColor: noDataColor,
                                                        onExpansionChanged: (newState) {
                                                          if (newState) {
                                                            setState(() {
                                                              selected2 = indexs;
                                                              int indexValue;
                                                              indexValue = religiousInstitutionCategory[indexs]['category_id'];
                                                              subCategoryId = indexValue;
                                                              selected3 = -1;
                                                              isSubCategoryExpanded = true;
                                                              _isEducation = true;
                                                              getInstitutionData();
                                                            });
                                                          } else {
                                                            setState(() {
                                                              selected2 = -1;
                                                              _isEducation = true;
                                                            });
                                                          }
                                                        },
                                                        title: Container(
                                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Text(
                                                            "${religiousInstitutionCategory[indexs]['category_name']} (${religiousInstitutionCategory[indexs]['institution_count']})",
                                                            style: GoogleFonts.signika(
                                                              fontSize: size.height * 0.022,
                                                              color: subTextExpandColor,
                                                            ),
                                                          ),
                                                        ),
                                                        children: [
                                                          _isEducation
                                                              ? Center(
                                                            child: SizedBox(
                                                              height: size.height * 0.06,
                                                              child: const LoadingIndicator(
                                                                indicatorType: Indicator.ballPulse,
                                                                colors: [Colors.red,Colors.orange,Colors.yellow],
                                                              ),
                                                            ),
                                                          ) : institutionData.isNotEmpty ? ListView.builder(
                                                            key: Key('builder ${selected3.toString()}'),
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemCount: isSubCategoryExpanded ? institutionData.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Column(
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.only(left: 15, right: 5, top: 5, bottom: 5),
                                                                    child: Column(
                                                                      children: [
                                                                        Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Flexible(
                                                                              child: RichText(
                                                                                text: TextSpan(
                                                                                    text: '${institutionData[index]['name']}',
                                                                                    style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.02),
                                                                                    children: [
                                                                                      institutionData[index]['parish_id']['name'] != '' && institutionData[index]['parish_id']['name'] != null ? TextSpan(
                                                                                        text: " - ${institutionData[index]['parish_id']['name']}",
                                                                                        style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.black),
                                                                                      ) : const TextSpan(),
                                                                                    ]
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(height: size.height * 0.01,),
                                                                        Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            institutionData[index]['street'] == '' && institutionData[index]['street2'] == '' && institutionData[index]['city'] == '' && institutionData[index]['district_id']['name'] == '' && institutionData[index]['state_id']['name'] == '' && institutionData[index]['country_id']['name'] == '' && institutionData[index]['zip'] == '' ? Container() : Flexible(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  institutionData[index]['street'].trim() != '' && institutionData[index]['street'] != null ? Text("${institutionData[index]['street']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                  institutionData[index]['street2'].trim() != '' && institutionData[index]['street2'] != null ? Text("${institutionData[index]['street2']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                  institutionData[index]['city'].trim() != '' && institutionData[index]['city'] != null ? Text("${institutionData[index]['city']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                  institutionData[index]['district_id']['name'].trim() != '' && institutionData[index]['district_id']['name'] != null ? Text("${institutionData[index]['district_id']['name']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                  institutionData[index]['state_id']['name'].trim() != '' && institutionData[index]['state_id']['name'] != null ? Text("${institutionData[index]['state_id']['name']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                  institutionData[index]['country_id']['name'].trim() != '' && institutionData[index]['country_id']['name'] != null ? Row(
                                                                                    children: [
                                                                                      institutionData[index]['country_id']['name'].trim() != '' && institutionData[index]['country_id']['name'] != null ? Text("${institutionData[index]['country_id']['name']}", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                      institutionData[index]['zip'].trim() != '' && institutionData[index]['zip'] != null ? Text("-", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                      institutionData[index]['zip'].trim() != '' && institutionData[index]['zip'] != null ? Text("${institutionData[index]['zip']}.", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container()
                                                                                    ],
                                                                                  ) : Container(),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        institutionData[index]['phone'] != '' && institutionData[index]['phone'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                                                        institutionData[index]['phone'] != '' && institutionData[index]['phone'] != null ? Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text('Phone: ',
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: size.height * 0.02,
                                                                              ),
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                (institutionData[index]['phone']).split(',').length != 1 ? showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      contentPadding: const EdgeInsets.all(10),
                                                                                      content: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          Column(
                                                                                            children: [
                                                                                              ListTile(
                                                                                                title: Text(
                                                                                                  (institutionData[index]['phone']).split(',')[0].trim(),
                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                ),
                                                                                                onTap: () {
                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                  callAction((institutionData[index]['phone']).split(',')[0].trim());
                                                                                                },
                                                                                              ),
                                                                                              const Divider(),
                                                                                              ListTile(
                                                                                                title: Text(
                                                                                                  (institutionData[index]['phone']).split(',')[1].trim(),
                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                ),
                                                                                                onTap: () {
                                                                                                  Navigator.pop(context);
                                                                                                  callAction((institutionData[index]['phone']).split(',')[1].trim());
                                                                                                },
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ) : callAction((institutionData[index]['phone']).split(',')[0].trim());
                                                                              },
                                                                              child: Text(
                                                                                (institutionData[index]['phone'])
                                                                                    .split(',')[0]
                                                                                    .trim(),
                                                                                style: TextStyle(
                                                                                  color: Colors.blueAccent,
                                                                                  fontSize: size.height * 0.02,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ) : Container(),
                                                                        institutionData[index]['email'] != '' && institutionData[index]['email'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                                                        institutionData[index]['email'] != '' && institutionData[index]['email'] != null ? Row(
                                                                          children: [
                                                                            Text('Email: ',
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: size.height * 0.02,
                                                                              ),
                                                                            ),
                                                                            GestureDetector(
                                                                                onTap: () {
                                                                                  emailAction(institutionData[index]['email']);
                                                                                },
                                                                                child: Text(
                                                                                  '${institutionData[index]['email']}',
                                                                                  style: GoogleFonts.signika(color: Colors.blueAccent,
                                                                                      fontSize: size.height * 0.02),
                                                                                )
                                                                            ),
                                                                          ],
                                                                        ) : Container(),
                                                                        institutionData[index]['medium_id']['name'] != '' && institutionData[index]['medium_id']['name'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                                                        institutionData[index]['medium_id']['name'] != '' && institutionData[index]['medium_id']['name'] != null ? Row(
                                                                          children: [
                                                                            Text(
                                                                              'Medium: ',
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: size.height * 0.02,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              institutionData[index]['medium_id']['name'],
                                                                              style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.02),
                                                                            )
                                                                          ],
                                                                        ) : Container(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  if(index < institutionData.length - 1) const Divider(
                                                                    thickness: 2,
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ) : Center(
                                                            child: Container(
                                                              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                                                              child: SizedBox(
                                                                height: 50,
                                                                width: 180,
                                                                child: textButton,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ) : Center(
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                                                  child: SizedBox(
                                                    height: 50,
                                                    width: 180,
                                                    child: textButton,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                      child: SizedBox(
                        height: 50,
                        width: 180,
                        child: textButton,
                      ),
                    ),
                  ),
                ) : _isCategory ? Expanded(
                  child: Center(
                    child: SizedBox(
                      height: size.height * 0.06,
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballSpinFadeLoader,
                        colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                      ),
                    ),
                  ),
                ) : category.isNotEmpty ? Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          key: Key('builder ${selected2.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isCategoryTypeExpanded ? category.length : 0, // Update the itemCount to 2 for two expansion tiles
                          itemBuilder: (BuildContext context, int indexs) {
                            final isTileExpanded = indexs == selected2;
                            final subTextExpandColor = isTileExpanded ? noDataColor : Colors.blueAccent;
                            return Column(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0)
                                    ),
                                    child: ExpansionTile(
                                      key: Key(indexs.toString()),// Use the generated GlobalKey for each expansion tile
                                      initiallyExpanded: indexs == selected2,
                                      iconColor: noDataColor,
                                      onExpansionChanged: (newState) {
                                        if (newState) {
                                          setState(() {
                                            selected2 = indexs;
                                            int indexValue;
                                            indexValue = category[indexs]['category_id'];
                                            subCategoryId = indexValue;
                                            selected3 = -1;
                                            isSubCategoryTypeExpanded = true;
                                            _isEducation = true;
                                            getInstitutionData();
                                          });
                                        } else {
                                          setState(() {
                                            selected2 = -1;
                                            _isEducation = true;
                                          });
                                        }
                                      },
                                      title: Container(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: mediumName == 'Tamil Medium' ? category[indexs]['mediums'] != [] && category[indexs]['mediums'].isNotEmpty ? category[indexs]['mediums'][0]['medium_count'] != 0 ? Text(
                                          "${category[indexs]['category_name']} (${category[indexs]['mediums'][0]['medium_count']})",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ) : Text(
                                          "${category[indexs]['category_name']}",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ) : Text(
                                          "${category[indexs]['category_name']}",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ) : mediumName == 'English Medium' ? category[indexs]['mediums'] != [] && category[indexs]['mediums'].isNotEmpty ? category[indexs]['mediums'][1]['medium_count'] != 0 ? Text(
                                          "${category[indexs]['category_name']} (${category[indexs]['mediums'][1]['medium_count']})",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ) : Text(
                                          "${category[indexs]['category_name']}",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ) : Text(
                                          "${category[indexs]['category_name']}",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ) : Text(
                                          "${category[indexs]['category_name']} (${category[indexs]['institution_count']})",
                                          style: GoogleFonts.signika(
                                            fontSize: size.height * 0.022,
                                            color: subTextExpandColor,
                                          ),
                                        ),
                                      ),
                                      children: [
                                        _isEducation ? Center(
                                          child: SizedBox(
                                            height: size.height * 0.06,
                                            child: const LoadingIndicator(
                                              indicatorType: Indicator.ballPulse,
                                              colors: [Colors.red,Colors.orange,Colors.yellow],
                                            ),
                                          ),
                                        ) : institutionData.isNotEmpty ? SingleChildScrollView(
                                          child: ListView.builder(
                                            key: Key('builder ${selected3.toString()}'),
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: isSubCategoryTypeExpanded ? institutionData.length : 0, // Update the itemCount to 2 for two expansion tiles
                                            itemBuilder: (BuildContext context, int index) {
                                              return Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.only(left: 15, right: 5, top: 5, bottom: 5),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Flexible(
                                                              child: RichText(
                                                                text: TextSpan(
                                                                    text: '${institutionData[index]['name']}',
                                                                    style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.02),
                                                                    children: [
                                                                      institutionData[index]['parish_id']['name'] != '' && institutionData[index]['parish_id']['name'] != null ? TextSpan(
                                                                        text: " - ${institutionData[index]['parish_id']['name']}",
                                                                        style: GoogleFonts.signika(fontSize: size.height * 0.02, color: Colors.black),
                                                                      ) : const TextSpan(),
                                                                    ]
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: size.height * 0.01,),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            institutionData[index]['street'] == '' && institutionData[index]['street2'] == '' && institutionData[index]['city'] == '' && institutionData[index]['district_id']['name'] == '' && institutionData[index]['state_id']['name'] == '' && institutionData[index]['country_id']['name'] == '' && institutionData[index]['zip'] == '' ? Container() : Flexible(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  institutionData[index]['street'].trim() != '' && institutionData[index]['street'] != null ? Text("${institutionData[index]['street']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                  institutionData[index]['street2'].trim() != '' && institutionData[index]['street2'] != null ? Text("${institutionData[index]['street2']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                  institutionData[index]['city'].trim() != '' && institutionData[index]['city'] != null ? Text("${institutionData[index]['city']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                  institutionData[index]['district_id']['name'].trim() != '' && institutionData[index]['district_id']['name'] != null ? Text("${institutionData[index]['district_id']['name']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                  institutionData[index]['state_id']['name'].trim() != '' && institutionData[index]['state_id']['name'] != null ? Text("${institutionData[index]['state_id']['name']},", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                  institutionData[index]['country_id']['name'].trim() != '' && institutionData[index]['country_id']['name'] != null ? Row(
                                                                    children: [
                                                                      institutionData[index]['country_id']['name'].trim() != '' && institutionData[index]['country_id']['name'] != null ? Text("${institutionData[index]['country_id']['name']}", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                      institutionData[index]['zip'].trim() != '' && institutionData[index]['zip'] != null ? Text("-", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                      institutionData[index]['zip'].trim() != '' && institutionData[index]['zip'] != null ? Text("${institutionData[index]['zip']}.", style: GoogleFonts.signika(color: Colors.black87, fontSize: size.height * 0.02),) : Container()
                                                                    ],
                                                                  ) : Container(),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        institutionData[index]['phone'] != '' && institutionData[index]['phone'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                                        institutionData[index]['phone'] != '' && institutionData[index]['phone'] != null ? Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Phone: ',
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: size.height * 0.02,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                (institutionData[index]['phone']).split(',').length != 1 ? showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      contentPadding: const EdgeInsets.all(10),
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (institutionData[index]['phone']).split(',')[0].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context); // Close the dialog
                                                                                  callAction((institutionData[index]['phone']).split(',')[0].trim());
                                                                                },
                                                                              ),
                                                                              const Divider(),
                                                                              ListTile(
                                                                                title: Text(
                                                                                  (institutionData[index]['phone']).split(',')[1].trim(),
                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                ),
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                  callAction((institutionData[index]['phone']).split(',')[1].trim());
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ) : callAction((institutionData[index]['phone']).split(',')[0].trim());
                                                              },
                                                              child: Text(
                                                                (institutionData[index]['phone']).split(',')[0].trim(),
                                                                style: TextStyle(
                                                                  color: Colors.blueAccent,
                                                                  fontSize: size.height * 0.02,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ) : Container(),
                                                        institutionData[index]['email'] != '' && institutionData[index]['email'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                                        institutionData[index]['email'] != '' && institutionData[index]['email'] != null ? Row(
                                                          children: [
                                                            Text(
                                                              'Email: ',
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: size.height * 0.02,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                                onTap: () {
                                                                  emailAction(institutionData[index]['email']);
                                                                },
                                                                child: Text(
                                                                  '${institutionData[index]['email']}',
                                                                  style: GoogleFonts.signika(color: Colors.blueAccent,
                                                                      fontSize: size.height * 0.02),
                                                                )
                                                            ),
                                                          ],
                                                        ) : Container(),
                                                        institutionData[index]['medium_id']['name'] != '' && institutionData[index]['medium_id']['name'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                                        institutionData[index]['medium_id']['name'] != '' && institutionData[index]['medium_id']['name'] != null ? Row(
                                                          children: [
                                                            Text(
                                                              'Medium: ',
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: size.height * 0.02,
                                                              ),
                                                            ),
                                                            Text(
                                                              institutionData[index]['medium_id']['name'],
                                                              style: GoogleFonts.signika(color: textColor, fontSize: size.height * 0.02),
                                                            )
                                                          ],
                                                        ) : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  if(index < institutionData.length - 1) const Divider(
                                                    thickness: 2,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ) : Center(
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                                            child: SizedBox(
                                              height: 50,
                                              width: 180,
                                              child: textButton,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                      child: SizedBox(
                        height: 50,
                        width: 180,
                        child: textButton,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
