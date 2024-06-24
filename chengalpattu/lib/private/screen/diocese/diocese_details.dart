import 'dart:convert';

import 'package:chengai/private/screen/diocese/basic.dart';
import 'package:chengai/private/screen/diocese/history.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

import 'bishop.dart';

const double expandedHeight = 300;
const double roundedContainerHeight = 50;

class DioceseDetailsScreen extends StatefulWidget {
  const DioceseDetailsScreen({Key? key}) : super(key: key);

  @override
  State<DioceseDetailsScreen> createState() => _DioceseDetailsScreenState();
}

class _DioceseDetailsScreenState extends State<DioceseDetailsScreen> {
  DateTime currentDateTime = DateTime.now();
  final ClearSharedPreference shared = ClearSharedPreference();
  final LoginService loginService = LoginService();
  bool _isLoading = true;
  List diocese = [];

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  String dioceseImage = '';
  String dioceseName = '';
  String dioceseEmail = '';
  String dioceseMobile = '';
  String diocesePhone = '';
  String dioceseHistory = '';
  String dioceseWebsite = '';

  List<Widget> tabsContent = [
    const DioceseBishopScreen(),
    const DioceseBasicScreen(),
    const DioceseHistoryScreen(),
  ];

  getDioceseData() async {
    String url = '$baseUrl/res.ecclesia.diocese';
    Map data = {
      "params": {
        "filter": "[['id', '=', $userDiocese]]",
        "query": "{id,image_1920,name,bishop_id,street,street2,city,district_id,state_id,country_id,zip,mobile,phone,email,website,history}"
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
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      diocese = data;
      for(int i = 0; i < diocese.length; i++) {
        dioceseImage = diocese[i]['image_1920'];
        dioceseName = diocese[i]['name'];
        bishopID = diocese[i]['bishop_id']['id'];
      }
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
    // checking Internet
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getDioceseData();
    } else {
      if(remember == true) {
        setState(() {
          loginService.login(context, loginName, loginPassword, databaseName, callback: () {
            setState(() {
              getDioceseData();
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
      body: _isLoading ? Center(
        child: SizedBox(
          height: size.height * 0.06,
          child: const LoadingIndicator(
            indicatorType: Indicator.ballSpinFadeLoader,
            colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
          ),
        ),
      ) : DefaultTabController(
        length: 3,
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
                      Navigator.pop(context, 'refresh');
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white,),
                  ),
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
                        dioceseName.toUpperCase(),
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
                    child: dioceseImage != null && dioceseImage != '' ? Image.network(
                        dioceseImage,
                        fit: BoxFit.fill
                    ) : Image.asset('assets/images/diocese.jpg',
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
                      Tab(text: 'Bishop Profile',),
                      Tab(text: 'Diocese Profile',),
                      Tab(text: 'History',),
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