import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

import 'basic.dart';
import 'council.dart';

const double expandedHeight = 300;
const double roundedContainerHeight = 50;

class ProvinceDetailsScreen extends StatefulWidget {
  const ProvinceDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceDetailsScreen> createState() => _ProvinceDetailsScreenState();
}

class _ProvinceDetailsScreenState extends State<ProvinceDetailsScreen> {
  bool _isLoading = true;
  List province = [];

  String provinceName = '';
  String provinceImage = '';

  List<Widget> tabsContent = [
    const ProvinceBasicDetailsScreen(),
    const ProvinceCouncilDetailsScreen()
  ];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getProvinceData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.religious.province?domain=[('id','=',$userProvinceId)]&fields=['name','code','image_1920','establishment_year','email','mobile','phone','history','website']"));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      province = data;

      for(int i = 0; i < province.length; i++) {
        provinceName = province[i]['name'];
        provinceImage = province[i]['image_1920'];
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
    getProvinceData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: _isLoading
          ? Center(
        child: Container(
            height: size.height * 0.1,
            width: size.width * 0.2,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage( "assets/alert/spinner_1.gif"),
              ),
            )
        ),
      ) : DefaultTabController(
        length: 3,
        child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: backgroundColor,
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
                        color: backgroundColor,
                      ),
                      child: Text(
                        provinceName,
                        style: GoogleFonts.secularOne(
                            color: Colors.white,
                            fontSize: size.height * 0.02
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    expandedTitleScale: 1,
                    // ClipRRect added here for rounded corners
                    background: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                      child: provinceImage.isNotEmpty && provinceImage != '' ? Image.network(
                          provinceImage,
                          // fit: BoxFit.cover
                      ) : Image.asset('assets/images/province.jpg',
                          fit: BoxFit.fill
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicator: BoxDecoration(
                        color: appBackgroundColor,
                        borderRadius:  BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: appBackgroundColor.withOpacity(0.8),
                            blurRadius: 10,
                            offset: const Offset(0, 5), // changes position of shadow
                          ),
                        ],
                      ) ,
                      labelColor: tabLabelColor,
                      unselectedLabelColor: unselectColor,
                      tabs: const [
                        Tab(text: 'Province Profile',),
                        Tab(text: 'Province Council',),
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
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: size.width * 0.03, right: size.width * 0.03,),
          child: Container(
            padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            constraints: BoxConstraints.expand(height: size.height * 0.05),
            child: _tabBar
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