import 'dart:convert';
import 'dart:io';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

const double expandedHeight = 300;
const double roundedContainerHeight = 50;

class VicariateDetailsScreen extends StatefulWidget {
  const VicariateDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VicariateDetailsScreen> createState() => _VicariateDetailsScreenState();
}

class _VicariateDetailsScreenState extends State<VicariateDetailsScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List vicariate = [];
  int index = 0;

  String image = '';
  String name = '';
  String email = '';
  String mobile = '';
  String phone = '';

  getVicariateDetailsData() async {
    String url = '$baseUrl/res.vicariate';
    Map data = {
      "params": {
        "filter": "[['id', '=', $vicariateId ]]",
        "query": "{id,image_1920,name,email,mobile,phone,street,street2,city,district_id,state_id,country_id,zip}"
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
      vicariate = data;
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getVicariateDetailsData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getVicariateDetailsData();
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
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ),
        ) : CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFFF512F),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              automaticallyImplyLeading: false,
              expandedHeight: size.height * 0.3,
              pinned: true,
              floating: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white,),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: size.width * 0.1, end: size.width * 0.1, bottom: 5.0),
                centerTitle: true,
                title: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFF512F),
                  ),
                  child: Text(
                      vicariate[index]['name'],
                      textScaleFactor: 1.0,
                      style: GoogleFonts.kavoon(
                          letterSpacing: 1,
                          color: Colors.white,
                          fontSize: size.height * 0.02
                      )
                  ),
                ),
                expandedTitleScale: 1,
                // ClipRRect added here for rounded corners
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  child: vicariate[index]['image_1920'] != null && vicariate[index]['image_1920'] != '' ? Image.network(
                      vicariate[index]['image_1920'],
                      fit: BoxFit.fill
                  ) : Image.asset('assets/images/vicariate.jpg',
                      fit: BoxFit.fill
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: SingleChildScrollView(
                child:  AnimationLimiter(
                  child: AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.05,),
                            vicariate[index]['email'] != null && vicariate[index]['email'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Flexible(
                                        child: Text(
                                          vicariate[index]['email'],
                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                        )
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.email_outlined),
                                  color: Colors.red,
                                  onPressed: () {
                                    emailAction(vicariate[index]['email']);
                                  },
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            vicariate[index]['mobile'] != null && vicariate[index]['mobile'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                  title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        vicariate[index]['mobile'],
                                        style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.phone),
                                        color: Colors.blue,
                                        onPressed: () {
                                          callAction(vicariate[index]['mobile']);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.message),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          smsAction(vicariate[index]['mobile']);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(LineAwesomeIcons.what_s_app),
                                        color: Colors.green,
                                        onPressed: () {
                                          whatsappAction(vicariate[index]['mobile']);
                                        },
                                      )
                                    ],
                                  )
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            vicariate[index]['phone'] != null && vicariate[index]['phone'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      vicariate[index]['phone'],
                                      style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.phone),
                                      color: Colors.blue,
                                      onPressed: () {
                                        callAction(vicariate[index]['phone']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            (vicariate[index]['street'].isEmpty && vicariate[index]['street2'].isEmpty && vicariate[index]['city'].isEmpty && vicariate[index]['district_id']['name'].isEmpty && vicariate[index]['state_id']['name'].isEmpty && vicariate[index]['country_id']['name'].isEmpty && vicariate[index]['zip'].isEmpty) ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Address", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Address", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5,),
                                    vicariate[index]['street'] != null && vicariate[index]['street'] != '' ? Text(vicariate[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    vicariate[index]['street2'] != null && vicariate[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                                    vicariate[index]['street2'] != null && vicariate[index]['street2'] != '' ? Text(vicariate[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    vicariate[index]['city'] != null && vicariate[index]['city'] != '' ? Text(vicariate[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    vicariate[index]['district_id']['name'] != null && vicariate[index]['district_id']['name'] != '' ? Text(vicariate[index]['district_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    vicariate[index]['state_id']['name'] != null && vicariate[index]['state_id']['name'] != '' ? Text(vicariate[index]['state_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    (vicariate[index]['country_id']['name'] != null && vicariate[index]['country_id']['name'] != '' && vicariate[index]['zip'] != null && vicariate[index]['zip'] != '') ? Text("${vicariate[index]['country_id']['name']}  -  ${vicariate[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
