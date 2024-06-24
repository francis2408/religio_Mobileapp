import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({Key? key}) : super(key: key);

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  DateTime currentDateTime = DateTime.now();
  bool _isLoading = true;
  bool _isData = true;
  bool _isMember = true;

  List administration = ['Committees','Association','Councils','Diocesan Society'];
  List adminCategory = [];
  List adminSubCategory = [];
  String name = '';

  int selected = -1;
  int selected2 = -1;
  int selected3 = -1;
  bool isCategoryExpanded = false;
  bool isSubCategoryExpanded = false;

  getAdministrationData() async {
    String url = '$baseUrl/member.commission';
    Map datas = {
      "params": {
        "filter": "[['category','=','Committee']]",
        "query": "{id,name,commission_member_ids{member_id{id,image_512,member_name,mobile},role_id,status}}"
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

    if(response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isData = false;
      });
      adminCategory = data;
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isData = false;
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

  getAssociationData() async {
    String url = '$baseUrl/member.association';
    Map datas = {
      "params": {
        "order": "name asc",
        "query": "{id,name,association_member_ids{member_id{id,image_512,member_name,mobile},role_id,status}}"
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

    if(response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isData = false;
      });
      adminCategory = data;
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isData = false;
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

  getCouncilsData() async {
    String url = '$baseUrl/member.council';
    Map datas = {
      "params": {
        "order": "name asc",
        "query": "{id,name,council_member_ids{member_id{id,image_512,member_name,mobile},role_id,status}}"
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

    if(response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isData = false;
      });
      adminCategory = data;
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isData = false;
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

  getLegalEntityData() async {
    String url = '$baseUrl/res.legal.entity';
    Map datas = {
      "params": {
        "filter":"[['diocese_id','=',$userDiocese]]",
        "order": "name asc",
        "query": "{id,image_512,name,entity_type,registration_no,incharge_id{id,image_512,member_name,mobile,role_ids},street,street2,city,district_id,state_id,country_id,zip,office_bearers_ids{member_id{id,image_512,member_name,mobile},role_id,status}}"
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

    if(response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isData = false;
      });
      adminCategory = data;
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isData = false;
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

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  getSubCategory() {
    if(adminSubCategory.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isMember = false;
        });
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isMember = false;
        });
      });
    }
  }

  Future<void> smsAction(String number) async {
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
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

  Future<void> whatsappAction(String whatsapp) async {
    if (Platform.isAndroid) {
      var whatsappUrl ="whatsapp://send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
    } else {
      var whatsappUrl ="https://api.whatsapp.com/send?phone=$whatsapp";
      await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
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

  _authTokenExpire() {
    AnimatedSnackBar.material(
        'Your session was expired; please login again.',
        type: AnimatedSnackBarType.info,
        duration: const Duration(seconds: 10)
    ).show(context);
  }

  clearSharedPreferenceData() async {
    // Deleting shared-preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAuthTokenKey');
    await prefs.remove('userTokenExpires');
    await prefs.remove('userIdKey');
    await prefs.remove('userNameKey');
    await prefs.remove('userEmailKey');
    await prefs.remove('userImageKey');
    await prefs.remove('userDioceseKey');
    await prefs.remove('userMemberKey');
    await HelperFunctions.setUserLoginSF(false);
    authToken = '';
    tokenExpire = '';
    userID = '';
    userName = '';
    userEmail = '';
    userImage = '';
    userLevel = '';
    userDiocese = '';
    userMember = '';
    await Future.delayed(const Duration(seconds: 1));

    Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
    _authTokenExpire();
  }

  @override
  void initState() {
    // Check Internet connection
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
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _isLoading = false;
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
        title: const Text('Administration'),
        centerTitle: true,
        backgroundColor: backgroundColor,
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                selected = -1;
                selected2 = -1;
                selected3 = -1;
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _isLoading = false;
                  });
                });
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
      ),
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
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(20),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: administration.length, // Update the itemCount to 2 for two expansion tiles
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
                                                  selected2 = -1;
                                                  selected3 = -1;
                                                  name = administration[index];
                                                  if(name == 'Committees') {
                                                    _isData = true;
                                                    getAdministrationData();
                                                    isCategoryExpanded = true;
                                                  } else if(name == 'Association') {
                                                    _isData = true;
                                                    getAssociationData();
                                                    isCategoryExpanded = true;
                                                  } else if(name == 'Councils') {
                                                    _isData = true;
                                                    getCouncilsData();
                                                    isCategoryExpanded = true;
                                                  } else {
                                                    _isData = true;
                                                    getLegalEntityData();
                                                    isCategoryExpanded = true;
                                                  }
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
                                                '${administration[index]}',
                                                style: GoogleFonts.signika(
                                                  fontSize: size.height * 0.022,
                                                  color: textExpandColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            children: [
                                              _isData ? Center(
                                                child: SizedBox(
                                                  height: size.height * 0.06,
                                                  child: const LoadingIndicator(
                                                    indicatorType: Indicator.ballPulse,
                                                    colors: [Colors.red,Colors.orange,Colors.yellow],
                                                  ),
                                                ),
                                              ) : adminCategory.isNotEmpty ? ListView.builder(
                                                key: Key('builder ${selected2.toString()}'),
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: isCategoryExpanded ? adminCategory.length : 0, // Update the itemCount to 2 for two expansion tiles
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
                                                          if(newState) {
                                                            setState(() {
                                                              selected2 = indexs;
                                                              selected3 = -1;
                                                              if(name == 'Committees') {
                                                                _isMember = true;
                                                                adminSubCategory = adminCategory[indexs]['commission_member_ids'];
                                                                getSubCategory();
                                                                isSubCategoryExpanded = true;
                                                              } else if(name == 'Association') {
                                                                _isMember = true;
                                                                adminSubCategory = adminCategory[indexs]['association_member_ids'];
                                                                getSubCategory();
                                                                isSubCategoryExpanded = true;
                                                              } else if(name == 'Councils') {
                                                                _isMember = true;
                                                                adminSubCategory = adminCategory[indexs]['council_member_ids'];
                                                                getSubCategory();
                                                                isSubCategoryExpanded = true;
                                                              } else {
                                                                _isMember = true;
                                                                adminSubCategory = adminCategory[indexs]['office_bearers_ids'];
                                                                getSubCategory();
                                                                isSubCategoryExpanded = true;
                                                              }
                                                            });
                                                          } else {
                                                            setState(() {
                                                              selected2 = -1;
                                                              _isMember = false;
                                                            });
                                                          }
                                                        },
                                                        title: Container(
                                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                          child: Text(
                                                            "${adminCategory[indexs]['name']}",
                                                            style: GoogleFonts.signika(
                                                              fontSize: size.height * 0.022,
                                                              color: subTextExpandColor,
                                                            ),
                                                          ),
                                                        ),
                                                        children: name != 'Diocesan Society' ? [
                                                          _isMember ? Center(
                                                            child: SizedBox(
                                                              height: size.height * 0.06,
                                                              child: const LoadingIndicator(
                                                                indicatorType: Indicator.ballPulse,
                                                                colors: [Colors.red,Colors.orange,Colors.yellow],
                                                              ),
                                                            ),
                                                          ) : adminSubCategory.isNotEmpty ? ListView.builder(
                                                            key: Key('builder ${selected3.toString()}'),
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemCount: isSubCategoryExpanded ? adminSubCategory.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                            itemBuilder: (BuildContext context, int indexValue) {
                                                              return Column(
                                                                children: [
                                                                  if(adminSubCategory[indexValue]['status'] == 'Active' || adminSubCategory[indexValue]['status'] == 'active') Container(
                                                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height: size.height * 0.11,
                                                                          width: size.width * 0.18,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            boxShadow: const <BoxShadow>[
                                                                              BoxShadow(
                                                                                color: Colors.grey,
                                                                                spreadRadius: -1,
                                                                                blurRadius: 5 ,
                                                                                offset: Offset(0, 1),
                                                                              ),
                                                                            ],
                                                                            shape: BoxShape.rectangle,
                                                                            image: DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: adminSubCategory[indexValue]['member_id']['image_512'] != null && adminSubCategory[indexValue]['member_id']['image_512'] != '' ? NetworkImage(adminSubCategory[indexValue]['member_id']['image_512'])
                                                                                  : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: Container(
                                                                            padding: const EdgeInsets.only(left: 15, right: 10),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        adminSubCategory[indexValue]['member_id']['member_name'],
                                                                                        style: GoogleFonts.secularOne(
                                                                                          fontSize: size.height * 0.021,
                                                                                          color: textColor,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(
                                                                                  height: size.height * 0.005,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      adminSubCategory[indexValue]['role_id']['name'],
                                                                                      style: GoogleFonts.reemKufi(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: size.height * 0.02,
                                                                                          color: Colors.black54,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                      style: TextStyle(
                                                                                          fontSize: size.height * 0.02,
                                                                                          color: Colors.blue,
                                                                                      ),
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        if (adminSubCategory[indexValue]['member_id']['mobile'] != null && adminSubCategory[indexValue]['member_id']['mobile'] != '') IconButton(
                                                                                          onPressed: () {
                                                                                            (adminSubCategory[indexValue]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                              (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              callAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                          const Divider(),
                                                                                                          ListTile(
                                                                                                            title: Text(
                                                                                                              (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              callAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ) : callAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                          },
                                                                                          icon: const Icon(Icons.phone),
                                                                                          color: Colors.blueAccent,
                                                                                        ),
                                                                                        if (adminSubCategory[indexValue]['member_id']['mobile'] != null && adminSubCategory[indexValue]['member_id']['mobile'] != '') IconButton(
                                                                                          onPressed: () {
                                                                                            (adminSubCategory[indexValue]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                              (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              smsAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                          const Divider(),
                                                                                                          ListTile(
                                                                                                            title: Text(
                                                                                                              (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              smsAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ) : smsAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                          },
                                                                                          icon: const Icon(Icons.message),
                                                                                          color: Colors.orange,
                                                                                        ),
                                                                                        if (adminSubCategory[indexValue]['member_id']['mobile'] != null && adminSubCategory[indexValue]['member_id']['mobile'] != '') IconButton(
                                                                                          onPressed: () {
                                                                                            (adminSubCategory[indexValue]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                              (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              whatsappAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                          const Divider(),
                                                                                                          ListTile(
                                                                                                            title: Text(
                                                                                                              (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                              style: const TextStyle(color: Colors.blueAccent),
                                                                                                            ),
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context); // Close the dialog
                                                                                                              whatsappAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim());
                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                            ) : whatsappAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                          },
                                                                                          icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                                          color: Colors.green,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  if(adminSubCategory[indexValue]['status'] == 'Active' || adminSubCategory[indexValue]['status'] == 'active') if(index < adminSubCategory.length - 1) const Divider(
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
                                                        ] : [
                                                          _isMember ? Center(
                                                            child: SizedBox(
                                                              height: size.height * 0.06,
                                                              child: const LoadingIndicator(
                                                                indicatorType: Indicator.ballPulse,
                                                                colors: [Colors.red,Colors.orange,Colors.yellow],
                                                              ),
                                                            ),
                                                          ) : adminCategory.isNotEmpty ? Padding(
                                                            padding: const EdgeInsets.all(10),
                                                            child: Column(
                                                              children: [
                                                                adminCategory[indexs]['image_512'] != null && adminCategory[indexs]['image_512'] != '' ? Container(
                                                                  height: size.height * 0.12,
                                                                  width: size.width * 0.5,
                                                                  alignment: Alignment.topCenter,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    boxShadow: const <BoxShadow>[
                                                                      BoxShadow(
                                                                        color: Colors.grey,
                                                                        spreadRadius: -1,
                                                                        blurRadius: 5 ,
                                                                        offset: Offset(0, 1),
                                                                      ),
                                                                    ],
                                                                    shape: BoxShape.rectangle,
                                                                    image: DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: NetworkImage(adminCategory[indexs]['image_512']),
                                                                    ),
                                                                  ),
                                                                ) : Container(),
                                                                adminCategory[indexs]['image_512'] != null && adminCategory[indexs]['image_512'] != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                                                Container(
                                                                  alignment: Alignment.topLeft,
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(width: size.width * 0.22, alignment: Alignment.topLeft, child: Text('Chairperson', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                                          SizedBox(width: size.width * 0.01,),
                                                                          adminCategory[indexs]['incharge_id']['member_name'] != '' && adminCategory[indexs]['incharge_id']['member_name'] != null ? Flexible(child: Text(adminCategory[indexs]['incharge_id']['member_name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: size.height * 0.01,),
                                                                      Row(
                                                                        children: [
                                                                          Container(width: size.width * 0.22, alignment: Alignment.topLeft, child: Text('Reg. No', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                                          SizedBox(width: size.width * 0.01,),
                                                                          adminCategory[indexs]['registration_no'] != '' && adminCategory[indexs]['registration_no'] != null ? Text(adminCategory[indexs]['registration_no'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: size.height * 0.01,),
                                                                      Row(
                                                                        children: [
                                                                          Container(width: size.width * 0.22, alignment: Alignment.topLeft, child: Text('Type', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                                          SizedBox(width: size.width * 0.01,),
                                                                          adminCategory[indexs]['entity_type'] != '' && adminCategory[indexs]['entity_type'] != null ? Text(capitalizeFirstLetter(adminCategory[indexs]['entity_type']), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: size.height * 0.01,),
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(width: size.width * 0.22, alignment: Alignment.topLeft, child: Text('Address', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                                          SizedBox(width: size.width * 0.01,),
                                                                          adminCategory[indexs]['street'] == '' && adminCategory[indexs]['street2'] == '' && adminCategory[indexs]['city'] == '' && adminCategory[indexs]['district_id']['name'] == '' && adminCategory[indexs]['state_id']['name'] == '' && adminCategory[indexs]['country_id']['name'] == '' && adminCategory[indexs]['zip'] == '' ? Container() : Flexible(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                adminCategory[indexs]['street'].trim() != '' && adminCategory[indexs]['street'] != null ? Text("${adminCategory[indexs]['street']},", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                adminCategory[indexs]['street2'].trim() != '' && adminCategory[indexs]['street2'] != null ? Text("${adminCategory[indexs]['street2']},", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                adminCategory[indexs]['city'].trim() != '' && adminCategory[indexs]['city'] != null ? Text("${adminCategory[indexs]['city']},", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                adminCategory[indexs]['district_id']['name'].trim() != '' && adminCategory[indexs]['district_id']['name'] != null ? Text("${adminCategory[indexs]['district_id']['name']},", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                adminCategory[indexs]['state_id']['name'].trim() != '' && adminCategory[indexs]['state_id']['name'] != null ? Text("${adminCategory[indexs]['state_id']['name']},", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                adminCategory[indexs]['country_id']['name'].trim() != '' && adminCategory[indexs]['country_id']['name'] != null ? Row(
                                                                                  children: [
                                                                                    adminCategory[indexs]['country_id']['name'].trim() != '' && adminCategory[indexs]['country_id']['name'] != null ? Text("${adminCategory[indexs]['country_id']['name']}", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                    adminCategory[indexs]['zip'].trim() != '' && adminCategory[indexs]['zip'] != null ? Text("-", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container(),
                                                                                    adminCategory[indexs]['zip'].trim() != '' && adminCategory[indexs]['zip'] != null ? Text("${adminCategory[indexs]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black87, fontSize: size.height * 0.02),) : Container()
                                                                                  ],
                                                                                ) : Container(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: size.height * 0.01,),
                                                                      adminSubCategory.isNotEmpty ? GestureDetector(
                                                                        onTap: () {
                                                                          // Bottom sheet
                                                                          Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                                                            return Container(
                                                                                height: size.height * 0.8,
                                                                                decoration: const BoxDecoration(
                                                                                  borderRadius: BorderRadius.only(
                                                                                      topRight: Radius.circular(25),
                                                                                      topLeft: Radius.circular(25)
                                                                                  ),
                                                                                  color: Colors.black12,
                                                                                ),
                                                                                child: _isMember ? Center(
                                                                                  child: SizedBox(
                                                                                    height: size.height * 0.06,
                                                                                    child: const LoadingIndicator(
                                                                                      indicatorType: Indicator.ballPulse,
                                                                                      colors: [Colors.red,Colors.orange,Colors.yellow],
                                                                                    ),
                                                                                  ),
                                                                                ) : adminSubCategory.isNotEmpty ? Padding(
                                                                                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Flexible(
                                                                                              child: RichText(
                                                                                                text: TextSpan(
                                                                                                    text: adminCategory[indexs]['name'],
                                                                                                    style: GoogleFonts.secularOne(fontSize: size.height * 0.022, color: Colors.black54),
                                                                                                    children: <InlineSpan>[
                                                                                                      TextSpan(
                                                                                                        text: " Member's",
                                                                                                        style: GoogleFonts.secularOne(fontSize: size.height * 0.022, color: Colors.black54),
                                                                                                      )
                                                                                                    ]
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            GestureDetector(
                                                                                              onTap: () {
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: const Icon(Icons.close, color: Colors.black54,),
                                                                                            )
                                                                                          ]
                                                                                      ),
                                                                                      SizedBox(height: size.height * 0.02,),
                                                                                      Text(
                                                                                        'Chairperson',
                                                                                        style: GoogleFonts.secularOne(fontSize: size.height * 0.022, color: Colors.black54),
                                                                                      ),
                                                                                      Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(15)
                                                                                        ),
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                height: size.height * 0.11,
                                                                                                width: size.width * 0.18,
                                                                                                decoration: BoxDecoration(
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  boxShadow: const <BoxShadow>[
                                                                                                    BoxShadow(
                                                                                                      color: Colors.grey,
                                                                                                      spreadRadius: -1,
                                                                                                      blurRadius: 5 ,
                                                                                                      offset: Offset(0, 1),
                                                                                                    ),
                                                                                                  ],
                                                                                                  shape: BoxShape.rectangle,
                                                                                                  image: DecorationImage(
                                                                                                    fit: BoxFit.cover,
                                                                                                    image: adminCategory[indexs]['incharge_id']['image_512'] != null && adminCategory[indexs]['incharge_id']['image_512'] != '' ? NetworkImage(adminCategory[indexs]['incharge_id']['image_512'])
                                                                                                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                child: Container(
                                                                                                  padding: const EdgeInsets.only(left: 15, right: 10),
                                                                                                  child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Flexible(
                                                                                                            child: Text(
                                                                                                              adminCategory[indexs]['incharge_id']['member_name'],
                                                                                                              style: GoogleFonts.secularOne(
                                                                                                                fontSize: size.height * 0.021,
                                                                                                                color: textColor,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: size.height * 0.005,
                                                                                                      ),
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            adminCategory[indexs]['incharge_id']['role_ids_view'],
                                                                                                            style: GoogleFonts.reemKufi(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontSize: size.height * 0.02,
                                                                                                              color: Colors.black54,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            (adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim(),
                                                                                                            style: TextStyle(
                                                                                                              fontSize: size.height * 0.02,
                                                                                                              color: Colors.blue,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Row(
                                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                                            children: [
                                                                                                              if(adminCategory[indexs]['incharge_id']['mobile'] != null && adminCategory[indexs]['incharge_id']['mobile'] != '') IconButton(
                                                                                                                onPressed: () {
                                                                                                                  (adminCategory[indexs]['incharge_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                                                    (adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim(),
                                                                                                                                    style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                  ),
                                                                                                                                  onTap: () {
                                                                                                                                    Navigator.pop(context); // Close the dialog
                                                                                                                                    callAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim());
                                                                                                                                  },
                                                                                                                                ),
                                                                                                                                const Divider(),
                                                                                                                                ListTile(
                                                                                                                                  title: Text(
                                                                                                                                    (adminCategory[indexs]['incharge_id']['mobile']).split(',')[1].trim(),
                                                                                                                                    style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                  ),
                                                                                                                                  onTap: () {
                                                                                                                                    Navigator.pop(context); // Close the dialog
                                                                                                                                    callAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[1].trim());
                                                                                                                                  },
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    },
                                                                                                                  ) : callAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim());
                                                                                                                },
                                                                                                                icon: const Icon(Icons.phone),
                                                                                                                color: Colors.blueAccent,
                                                                                                              ),
                                                                                                              if(adminCategory[indexs]['incharge_id']['mobile'] != null && adminCategory[indexs]['incharge_id']['mobile'] != '') IconButton(
                                                                                                                onPressed: () {
                                                                                                                  (adminCategory[indexs]['incharge_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                                                    (adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim(),
                                                                                                                                    style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                  ),
                                                                                                                                  onTap: () {
                                                                                                                                    Navigator.pop(context); // Close the dialog
                                                                                                                                    smsAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim());
                                                                                                                                  },
                                                                                                                                ),
                                                                                                                                const Divider(),
                                                                                                                                ListTile(
                                                                                                                                  title: Text(
                                                                                                                                    (adminCategory[indexs]['incharge_id']['mobile']).split(',')[1].trim(),
                                                                                                                                    style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                  ),
                                                                                                                                  onTap: () {
                                                                                                                                    Navigator.pop(context); // Close the dialog
                                                                                                                                    smsAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[1].trim());
                                                                                                                                  },
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    },
                                                                                                                  ) : smsAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim());
                                                                                                                },
                                                                                                                icon: const Icon(Icons.message),
                                                                                                                color: Colors.orange,
                                                                                                              ),
                                                                                                              if(adminCategory[indexs]['incharge_id']['mobile'] != null && adminCategory[indexs]['incharge_id']['mobile'] != '') IconButton(
                                                                                                                onPressed: () {
                                                                                                                  (adminCategory[indexs]['incharge_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                                                    (adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim(),
                                                                                                                                    style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                  ),
                                                                                                                                  onTap: () {
                                                                                                                                    Navigator.pop(context); // Close the dialog
                                                                                                                                    whatsappAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim());
                                                                                                                                  },
                                                                                                                                ),
                                                                                                                                const Divider(),
                                                                                                                                ListTile(
                                                                                                                                  title: Text(
                                                                                                                                    (adminCategory[indexs]['incharge_id']['mobile']).split(',')[1].trim(),
                                                                                                                                    style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                  ),
                                                                                                                                  onTap: () {
                                                                                                                                    Navigator.pop(context); // Close the dialog
                                                                                                                                    whatsappAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[1].trim());
                                                                                                                                  },
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      );
                                                                                                                    },
                                                                                                                  ) : whatsappAction((adminCategory[indexs]['incharge_id']['mobile']).split(',')[0].trim());
                                                                                                                },
                                                                                                                icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                                                                color: Colors.green,
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: size.height * 0.02,),
                                                                                      Text(
                                                                                        'Members',
                                                                                        style: GoogleFonts.secularOne(fontSize: size.height * 0.022, color: Colors.black54),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: Scrollbar(
                                                                                          thumbVisibility: true,
                                                                                          interactive: true,
                                                                                          radius: const Radius.circular(15),
                                                                                          thickness: 8,
                                                                                          child: AnimationLimiter(
                                                                                            child: ListView.builder(
                                                                                              shrinkWrap: true,
                                                                                              scrollDirection: Axis.vertical,
                                                                                              itemCount: isSubCategoryExpanded ? adminSubCategory.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                                                              itemBuilder: (BuildContext context, int indexValue) {
                                                                                                return Column(
                                                                                                  children: [
                                                                                                    if(adminSubCategory[indexValue]['status'] == 'Active' || adminSubCategory[indexValue]['status'] == 'active') Card(
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                          borderRadius: BorderRadius.circular(15)
                                                                                                      ),
                                                                                                      child: Container(
                                                                                                        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                                                                                        child: Row(
                                                                                                          children: [
                                                                                                            Container(
                                                                                                              height: size.height * 0.11,
                                                                                                              width: size.width * 0.18,
                                                                                                              decoration: BoxDecoration(
                                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                                boxShadow: const <BoxShadow>[
                                                                                                                  BoxShadow(
                                                                                                                    color: Colors.grey,
                                                                                                                    spreadRadius: -1,
                                                                                                                    blurRadius: 5 ,
                                                                                                                    offset: Offset(0, 1),
                                                                                                                  ),
                                                                                                                ],
                                                                                                                shape: BoxShape.rectangle,
                                                                                                                image: DecorationImage(
                                                                                                                  fit: BoxFit.cover,
                                                                                                                  image: adminSubCategory[indexValue]['member_id']['image_512'] != null && adminSubCategory[indexValue]['member_id']['image_512'] != '' ? NetworkImage(adminSubCategory[indexValue]['member_id']['image_512'])
                                                                                                                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            Expanded(
                                                                                                              child: Container(
                                                                                                                padding: const EdgeInsets.only(left: 15, right: 10),
                                                                                                                child: Column(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Row(
                                                                                                                      children: [
                                                                                                                        Flexible(
                                                                                                                          child: Text(
                                                                                                                            adminSubCategory[indexValue]['member_id']['member_name'],
                                                                                                                            style: GoogleFonts.secularOne(
                                                                                                                              fontSize: size.height * 0.021,
                                                                                                                              color: textColor,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                    SizedBox(
                                                                                                                      height: size.height * 0.005,
                                                                                                                    ),
                                                                                                                    Row(
                                                                                                                      children: [
                                                                                                                        Text(
                                                                                                                          adminSubCategory[indexValue]['role_id']['name'],
                                                                                                                          style: GoogleFonts.reemKufi(
                                                                                                                            fontWeight: FontWeight.bold,
                                                                                                                            fontSize: size.height * 0.02,
                                                                                                                            color: Colors.black54,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                    Row(
                                                                                                                      children: [
                                                                                                                        Text(
                                                                                                                          (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                                          style: TextStyle(
                                                                                                                            fontSize: size.height * 0.02,
                                                                                                                            color: Colors.blue,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        Row(
                                                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                                                          children: [
                                                                                                                            if(adminSubCategory[indexValue]['member_id']['mobile'] != null && adminSubCategory[indexValue]['member_id']['mobile'] != '') IconButton(
                                                                                                                              onPressed: () {
                                                                                                                                (adminSubCategory[indexValue]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                                                                  (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                                ),
                                                                                                                                                onTap: () {
                                                                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                                                                  callAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                                                                },
                                                                                                                                              ),
                                                                                                                                              const Divider(),
                                                                                                                                              ListTile(
                                                                                                                                                title: Text(
                                                                                                                                                  (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                                ),
                                                                                                                                                onTap: () {
                                                                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                                                                  callAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim());
                                                                                                                                                },
                                                                                                                                              ),
                                                                                                                                            ],
                                                                                                                                          ),
                                                                                                                                        ],
                                                                                                                                      ),
                                                                                                                                    );
                                                                                                                                  },
                                                                                                                                ) : callAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                                              },
                                                                                                                              icon: const Icon(Icons.phone),
                                                                                                                              color: Colors.blueAccent,
                                                                                                                            ),
                                                                                                                            if(adminSubCategory[indexValue]['member_id']['mobile'] != null && adminSubCategory[indexValue]['member_id']['mobile'] != '') IconButton(
                                                                                                                              onPressed: () {
                                                                                                                                (adminSubCategory[indexValue]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                                                                  (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                                ),
                                                                                                                                                onTap: () {
                                                                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                                                                  smsAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                                                                },
                                                                                                                                              ),
                                                                                                                                              const Divider(),
                                                                                                                                              ListTile(
                                                                                                                                                title: Text(
                                                                                                                                                  (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                                ),
                                                                                                                                                onTap: () {
                                                                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                                                                  smsAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim());
                                                                                                                                                },
                                                                                                                                              ),
                                                                                                                                            ],
                                                                                                                                          ),
                                                                                                                                        ],
                                                                                                                                      ),
                                                                                                                                    );
                                                                                                                                  },
                                                                                                                                ) : smsAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                                              },
                                                                                                                              icon: const Icon(Icons.message),
                                                                                                                              color: Colors.orange,
                                                                                                                            ),
                                                                                                                            if(adminSubCategory[indexValue]['member_id']['mobile'] != null && adminSubCategory[indexValue]['member_id']['mobile'] != '') IconButton(
                                                                                                                              onPressed: () {
                                                                                                                                (adminSubCategory[indexValue]['member_id']['mobile']).split(',').length != 1 ? showDialog(
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
                                                                                                                                                  (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim(),
                                                                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                                ),
                                                                                                                                                onTap: () {
                                                                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                                                                  whatsappAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                                                                },
                                                                                                                                              ),
                                                                                                                                              const Divider(),
                                                                                                                                              ListTile(
                                                                                                                                                title: Text(
                                                                                                                                                  (adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim(),
                                                                                                                                                  style: const TextStyle(color: Colors.blueAccent),
                                                                                                                                                ),
                                                                                                                                                onTap: () {
                                                                                                                                                  Navigator.pop(context); // Close the dialog
                                                                                                                                                  whatsappAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[1].trim());
                                                                                                                                                },
                                                                                                                                              ),
                                                                                                                                            ],
                                                                                                                                          ),
                                                                                                                                        ],
                                                                                                                                      ),
                                                                                                                                    );
                                                                                                                                  },
                                                                                                                                ) : whatsappAction((adminSubCategory[indexValue]['member_id']['mobile']).split(',')[0].trim());
                                                                                                                              },
                                                                                                                              icon: const Icon(LineAwesomeIcons.what_s_app),
                                                                                                                              color: Colors.green,
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
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
                                                                            );
                                                                          });
                                                                        },
                                                                        child: Container(
                                                                          alignment: Alignment.center,
                                                                          height: size.height * 0.05,
                                                                          width: size.width * 0.5,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            color: Colors.blueAccent,
                                                                          ),
                                                                          child: Text(
                                                                            'Members',
                                                                            style: GoogleFonts.secularOne(
                                                                              color: Colors.white,
                                                                              fontSize: size.height * 0.021,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ) : Container(),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
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
