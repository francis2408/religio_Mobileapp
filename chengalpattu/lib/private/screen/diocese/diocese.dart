import 'dart:convert';
import 'dart:io';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class DioceseScreen extends StatefulWidget {
  const DioceseScreen({Key? key}) : super(key: key);

  @override
  State<DioceseScreen> createState() => _DioceseScreenState();
}

class _DioceseScreenState extends State<DioceseScreen> {
  bool _isLoading = true;
  List diocese = [];
  int index = 0;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  getDioceseData() async {
    String url = '$baseUrl/res.ecclesia.diocese';
    Map data = {
      "params": {
        "filter": "[['id', '=', $userDiocese ]]",
        "query": "{id,image_1920,name,bishop_id,street,street2,city,district_id,state_id,country_id,zip,mobile,phone,email,website,history,org_image_ids,establishment_date,vision,mission}"
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
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      diocese = data;
    }
    else {
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

  Future<void> webAction(String web) async {
    try {
      await launch(
        web,
        forceWebView: false, // Set this to false for Android devices
        enableJavaScript: true, // Add this line to enable JavaScript if needed
      );
    } catch (e) {
      throw 'Could not launch $web: $e';
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
    getDioceseData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: _isLoading ? const Center(
          child: CircularProgressIndicator(
            color: backgroundColor,
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
                // titlePadding: const EdgeInsetsDirectional.only(start: 16.0, bottom: 16.0),
                centerTitle: true,
                title: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFF512F),
                  ),
                  child: Text(
                      diocese[index]['name'].toUpperCase(),
                    textScaleFactor: 1.0,
                    style: GoogleFonts.kavoon(
                    letterSpacing: 1,
                    color: Colors.white,
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
                  child: diocese[index]['image_1920'] != null && diocese[index]['image_1920'] != '' ? Image.network(
                      diocese[index]['image_1920'],
                      fit: BoxFit.fill
                  ) : Image.asset('assets/images/diocese.jpg',
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
                            diocese[index]['establishment_date'] != null && diocese[index]['establishment_date'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Establishment Date", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Flexible(
                                        child: Text(
                                          diocese[index]['establishment_date'],
                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Establishment Date", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            diocese[index]['vision'] != null && diocese[index]['vision'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Vision", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Flexible(
                                        child: Text(
                                          diocese[index]['vision'],
                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Vision", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            diocese[index]['mission'] != null && diocese[index]['mission'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Mission", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Flexible(
                                        child: Text(
                                          diocese[index]['mission'],
                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Mission", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            diocese[index]['email'] != null && diocese[index]['email'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Email", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Flexible(
                                        child: Text(
                                          diocese[index]['email'],
                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                        )
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.email_outlined),
                                  color: Colors.red,
                                  onPressed: () {
                                    emailAction(diocese[index]['email']);
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
                            diocese[index]['mobile'] != null && diocese[index]['mobile'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                  title: Text("Mobile Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        diocese[index]['mobile'],
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
                                          callAction(diocese[index]['mobile']);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.message),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          smsAction(diocese[index]['mobile']);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(LineAwesomeIcons.what_s_app),
                                        color: Colors.green,
                                        onPressed: () {
                                          whatsappAction(diocese[index]['mobile']);
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
                            diocese[index]['phone'] != null && diocese[index]['phone'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Phone Number", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      diocese[index]['phone'],
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
                                        callAction(diocese[index]['phone']);
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
                            diocese[index]['website'] != null && diocese[index]['website'] != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("Website", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        diocese[index]['website'],
                                        style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.language),
                                      color: Colors.blue,
                                      onPressed: () async {
                                        webAction(diocese[index]['website']);
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
                                title: Text("Website", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                  ],
                                ),
                              ),
                            ),
                            (diocese[index]['street'].isEmpty && diocese[index]['street2'].isEmpty && diocese[index]['city'].isEmpty && diocese[index]['district_id']['name'].isEmpty && diocese[index]['state_id']['name'].isEmpty && diocese[index]['country_id']['name'].isEmpty && diocese[index]['zip'].isEmpty) ? Card(
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
                                    diocese[index]['street'] != null && diocese[index]['street'] != '' ? Text(diocese[index]['street'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    diocese[index]['street2'] != null && diocese[index]['street2'] != '' ? const SizedBox(height: 3,) : Container(),
                                    diocese[index]['street2'] != null && diocese[index]['street2'] != '' ? Text(diocese[index]['street2'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    diocese[index]['city'] != null && diocese[index]['city'] != '' ? Text(diocese[index]['city'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    diocese[index]['district_id']['name'] != null && diocese[index]['district_id']['name'] != '' ? Text(diocese[index]['district_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    diocese[index]['state_id']['name'] != null && diocese[index]['state_id']['name'] != '' ? Text(diocese[index]['state_id']['name'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                    const SizedBox(height: 3,),
                                    (diocese[index]['country_id']['name'] != null && diocese[index]['country_id']['name'] != '' && diocese[index]['zip'] != null && diocese[index]['zip'] != '') ? Text("${diocese[index]['country_id']['name']}  -  ${diocese[index]['zip']}.", style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Container(),
                                  ],
                                ),
                              ),
                            ),
                            diocese[index]['history'].replaceAll(exp, '') != null && diocese[index]['history'].replaceAll(exp, '') != '' ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Html(
                                  data: diocese[index]['history'],
                                ),
                              ),
                            ) : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text("History", style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),),
                                subtitle: Row(
                                  children: [
                                    Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
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
