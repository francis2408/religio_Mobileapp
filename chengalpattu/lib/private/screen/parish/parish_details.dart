import 'dart:convert';
import 'dart:io';

import 'package:chengai/private/screen/parish/basic.dart';
import 'package:chengai/private/screen/parish/priest_history.dart';
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

class ParishDetailsScreen extends StatefulWidget {
  const ParishDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ParishDetailsScreen> createState() => _ParishDetailsScreenState();
}

class _ParishDetailsScreenState extends State<ParishDetailsScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List parish = [];
  List assPriest = [];
  int index = 0;

  List<Widget> tabsContent = [
    const ParishBasicScreen(),
    const ParishPriestHistoryScreen(),
  ];

  getParishDetails() async {
    String url = '$baseUrl/res.parish';
    Map data = {
      "params": {
        "filter": "[['id','=',$parishId]]",
        "query": "{id,image_1920,name,diocese_id,vicariate_id,mobile,email,phone,establishment_date,street,street2,city,district_id,state_id,country_id,zip,priest_id{id,image_1920,member_name,email,mobile,role_ids},ass_priest_id{id,image_1920,member_name,email,mobile,role_ids},patron_id}"
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
      parish = data;
      for(int i = 0; i < parish.length; i++) {
        if(parish[i]['ass_priest_id'].isNotEmpty && parish[i]['ass_priest_id'] != []) {
          assPriest = parish[i]['ass_priest_id'];
        }
      }
    } else {
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
      getParishDetails();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getParishDetails();
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
        ) : DefaultTabController(
          length: 2,
          child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
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
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: backgroundColor,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
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
                            parish[index]['name'],
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
                        child: parish[index]['image_1920'] != null && parish[index]['image_1920'] != '' ? Image.network(
                            parish[index]['image_1920'],
                            fit: BoxFit.fill
                        ) : Image.asset('assets/others/parish.png',
                            fit: BoxFit.fill
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        indicator: BoxDecoration(
                            color: const Color(0xFFFF512F),
                            borderRadius:  BorderRadius.circular(25.0)
                        ) ,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black,
                        tabs: const [
                          Tab(text: 'Parish Profile',),
                          Tab(text: 'Parish Priest History',),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: tabsContent,
              )
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.005,),
        Container(
          padding: EdgeInsets.only(left: size.width * 0.03, right: size.width * 0.03,),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFFAE0C5),
                borderRadius: BorderRadius.circular(25.0)
            ),
            constraints: BoxConstraints.expand(height: size.height * 0.05),
            child: _tabBar,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}