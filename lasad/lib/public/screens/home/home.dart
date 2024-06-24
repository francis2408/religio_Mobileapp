import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lasad/private/screens/authentication/login.dart';
import 'package:lasad/public/screens/celebration/celebration.dart';
import 'package:lasad/public/screens/calendar/event.dart';
import 'package:lasad/public/screens/circular/circular.dart';
import 'package:lasad/public/screens/death/death_tab.dart';
import 'package:lasad/public/screens/house/house_list.dart';
import 'package:lasad/public/screens/institution/institution_list.dart';
import 'package:lasad/public/screens/member/member.dart';
import 'package:lasad/public/screens/news/news.dart';
import 'package:lasad/public/screens/notification/notification.dart';
import 'package:lasad/public/screens/province/province.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:lasad/widget/widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({Key? key}) : super(key: key);

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  int activeIndex = 0;
  int activeNewsIndex = 0;
  final controller = CarouselController();
  bool _isNews = true;
  List image = [];
  String url = '';
  List congregationData = [];
  List newsData = [];
  List todayIndianBirthday = [];
  List todayIndianFeast = [];
  List todaySriLankaBirthday = [];
  List todaySriLankFeast = [];
  bool _isLoading = true;
  final bool _canPop = false;
  int total = 0;

  var today = Jiffy.parseFromDateTime(DateTime.now()).format(pattern: "dd - MMMM" );

  List imgList = [
    'assets/lasad/one.jpeg',
    'assets/lasad/two.jpeg',
    'assets/lasad/three.jpeg',
    'assets/lasad/four.jpeg',
    'assets/lasad/five.jpeg',
    'assets/lasad/six.jpeg',
  ];

  List newsList = [
    "Welcome to the DE LA SALLE BROTHER'S of LASAD.",
  ];

  getData() async {
    url = "$baseUrl/provinces/congregation/1";
    var request = http.Request('GET', Uri.parse(url));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      congregationData = data;
      setState(() {
        _isLoading = false;
      });
      for(int i = 0; i < congregationData.length; i++) {
        for(int i = 0; i < congregationData.length; i++) {
          if(congregationData[i]['id'] == 1) {
            indian_sector_id = congregationData[i]['id'];
          }
          if(congregationData[i]['id'] == 2) {
            sri_sector_id = congregationData[i]['id'];
          }
        }
        userProvinceId = indian_sector_id;
      }
      getNewsData();
      getTodayIndianBirthdayData();
      getTodayIndianFeastData();
      getTodaySriLankaBirthdayData();
      getTodaySriLankaFeastData();
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
  }

  getNewsData() async {
    String sharedNewsUrl = '';
    sharedNewsUrl = "$baseUrl/news/province/$userProvinceId";
    var request = http.Request('GET', Uri.parse(sharedNewsUrl));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString())['data'];
      if (mounted) {
        setState(() {
          _isNews = false;
        });
      }
      newsData = data;

      // for(int i = 0; i < newsData.length; i++){
      // var dates = Jiffy.parse(newsData[i]["date"], pattern: 'dd-MM-yyyy').dateTime;
      // newsData[i]["formattedDate"] = Jiffy.parseFromDateTime(dates).format(pattern: "dd" );
      // newsData[i]["formattedMonth"] = Jiffy.parseFromDateTime(dates).format(pattern: "MMMM" );
      // newsData[i]["formattedYear"] = Jiffy.parseFromDateTime(dates).format(pattern: "y" );
      // }

    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isNews = false;
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

  getTodayIndianBirthdayData() async {
    var todayRequest = http.Request('GET', Uri.parse("$baseUrl/province/member/birthday/$userProvinceId"));
    http.StreamedResponse response = await todayRequest.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['next_30days'];
      for(int i = 0; i < data.length; i++) {
        if(today == data[i]['birthday'].trim()) {
          todayIndianBirthday.add(data[i]);
        }
      }
      setState(() {
        total += todayIndianBirthday.length;
      });
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
  }

  getTodaySriLankaBirthdayData() async {
    var todayRequest = http.Request('GET', Uri.parse("$baseUrl/province/member/birthday/$sri_sector_id"));
    http.StreamedResponse response = await todayRequest.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['next_30days'];
      for(int i = 0; i < data.length; i++) {
        if(today == data[i]['birthday'].trim()) {
          todaySriLankaBirthday.add(data[i]);
        }
      }
      setState(() {
        total += todaySriLankaBirthday.length;
      });
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
  }

  getTodayIndianFeastData() async {
    var todayRequest = http.Request('GET', Uri.parse("$baseUrl/province/member/feast/$userProvinceId"));
    http.StreamedResponse response = await todayRequest.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['next_30'];
      for(int i = 0; i < data.length; i++) {
        if(today == data[i]['feastday'].trim()) {
          todayIndianFeast.add(data[i]);
        }
      }
      setState(() {
        total += todayIndianFeast.length;
      });
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
  }

  getTodaySriLankaFeastData() async {
    var todayRequest = http.Request('GET', Uri.parse("$baseUrl/province/member/feast/$sri_sector_id"));
    http.StreamedResponse response = await todayRequest.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['next_30'];
      for(int i = 0; i < data.length; i++) {
        if(today == data[i]['feastday'].trim()) {
          todaySriLankFeast.add(data[i]);
        }
      }
      setState(() {
        total += todaySriLankFeast.length;
      });
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
    // Check Internet connection
    internetCheck();
    super.initState();
    getData();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to the desired screen when the notification is clicked
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmAlertDialog(
                message: 'Are you sure want to exit.',
                onYesPressed: () {
                  exit(0);
                },
                onCancelPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          );
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenColor,
        key: _scaffoldKey,
        body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: size.height * 0.06,
                      decoration: ShapeDecoration(
                        shape: CustomShape(),
                      ),
                      child: ListTile(
                        leading: IconButton(
                          icon: SvgPicture.asset("assets/icons/menu.svg", color: Colors.white,),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset("assets/icons/notification.svg", color: Colors.white, height: 25, width: 25,),
                              onPressed: () {
                                setState(() {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return const NotificationScreen();
                                      }));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-3, -size.height / 29),
                      child: Container(
                        height: size.height * 0.07,
                        width: size.width * 0.20,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          shape: BoxShape.rectangle,
                          image: const DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/images/lasad_logo.png'),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -size.height / 40),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          'DE LA SALLE BROTHERS - LASAD',
                          style: TextStyle(
                            fontSize: size.height * 0.025,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-3, -size.height / 60),
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: controller,
                            itemCount: imgList.length,
                            itemBuilder: (context, index, realIndex) {
                              final urlImage = imgList[index];
                              return ClipRRect(
                                borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                                child: Image.asset(urlImage, fit: BoxFit.fill, width: 1000.0),
                              );
                            },
                            options: CarouselOptions(
                              viewportFraction: 0.95,
                              aspectRatio: 2.0,
                              height: size.height * 0.19,
                              autoPlay: true,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration: const Duration(seconds: 2),
                              enlargeCenterPage: true,
                              onPageChanged: ((index, reason) {
                                setState(() {
                                  activeIndex = index;
                                });
                              }),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Container(
                              alignment: Alignment.center,
                              child: buildIndicator()
                          ),
                        ],
                      ),
                    ),
                    _isNews ? Container(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: size.height * 0.06,
                        child: const LoadingIndicator(
                          indicatorType: Indicator.ballPulse,
                          colors: [Color(0xFFA5FECB), Color(0xFF20BDFF), Color(0xFF5433FF),],
                        ),
                      ),
                    ) : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: size.height * 0.06,
                            width: size.width * 0.15,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                              ),
                              child: Text('News',style: GoogleFonts.kanit(fontSize: size.height * 0.018, color: Colors.white),),
                            )
                        ),
                        Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE8F4FF),
                                    Color(0xFFE8F4FF)
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                              ),
                              child: newsData.isNotEmpty ? CarouselSlider.builder(
                                carouselController: controller,
                                itemCount: newsData.length,
                                itemBuilder: (context, index, realIndex) {
                                  final news = newsData[index]['name'];
                                  return Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    alignment: Alignment.center,
                                    child: Text(
                                      news,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.cantataOne(
                                        textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  viewportFraction: 0.95,
                                  aspectRatio: 2.0,
                                  height: size.height * 0.06,
                                  autoPlay: true,
                                  enableInfiniteScroll: newsData.length > 1 ? true : false,
                                  autoPlayAnimationDuration: const Duration(seconds: 2),
                                  enlargeCenterPage: true,
                                  onPageChanged: ((index, reason) {
                                    setState(() {
                                      activeNewsIndex = index;
                                    });
                                  }),
                                ),
                              ) : CarouselSlider.builder(
                                carouselController: controller,
                                itemCount: newsList.length,
                                itemBuilder: (context, index, realIndex) {
                                  final news = newsList[index];
                                  return Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    alignment: Alignment.center,
                                    child: Text(
                                      news,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.cantataOne(
                                        textStyle: const TextStyle(color: Color(0xFF0861B6)),
                                        fontSize: size.height * 0.018,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  viewportFraction: 0.95,
                                  aspectRatio: 2.0,
                                  height: size.height * 0.06,
                                  autoPlay: true,
                                  enableInfiniteScroll: newsList.length > 1 ? true : false,
                                  autoPlayAnimationDuration: const Duration(seconds: 2),
                                  enlargeCenterPage: true,
                                  onPageChanged: ((index, reason) {
                                    setState(() {
                                      activeNewsIndex = index;
                                    });
                                  }),
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const ProvinceScreen()));
                                });
                              },
                              icon: 'assets/icons/church.svg',
                              title: "Sector",
                              colorOne: const Color(0xFFb83dba),
                              colorTwo: const Color(0xFFe96feb),
                              homeIconColor: const Color(0xFFf6ddf7),
                              homeIconSize: 40,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const PublicHouseListScreen()));
                                });
                              },
                              icon: 'assets/icons/house.svg',
                              title: "House",
                              colorOne: const Color(0xFF0bb08e),
                              colorTwo: const Color(0xFF36dab8),
                              homeIconColor: const Color(0xFFe5f8f4),
                              homeIconSize: 35,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const PublicInstitutionListScreen()));
                                });
                              },
                              icon: 'assets/icons/institution.svg',
                              title: "Institution",
                              colorOne: const Color(0xFF0861B6),
                              colorTwo: const Color(0xFF20BDFF),
                              homeIconColor: const Color(0xFFE8F4FF),
                              homeIconSize: 35,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const MemberScreen()));
                                });
                              },
                              icon: 'assets/icons/members.svg',
                              title: "Members",
                              colorOne: const Color(0xFFb83dba),
                              colorTwo: const Color(0xFFe96feb),
                              homeIconColor: const Color(0xFFf6ddf7),
                              homeIconSize: 40,
                            ),
                            total != 0 ? Stack(
                              children: [
                                HomeCard(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).push(CustomRoute(widget: const PublicCelebrationScreen()));
                                    });
                                  },
                                  icon: 'assets/icons/birthday.svg',
                                  title: "Celebration",
                                  colorOne: const Color(0xFF0bb08e),
                                  colorTwo: const Color(0xFF36dab8),
                                  homeIconColor: const Color(0xFFe5f8f4),
                                  homeIconSize: 35,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      total.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ) : HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const PublicCelebrationScreen()));
                                });
                              },
                              icon: 'assets/icons/birthday.svg',
                              title: "Celebration",
                              colorOne: const Color(0xFF0bb08e),
                              colorTwo: const Color(0xFF36dab8),
                              homeIconColor: const Color(0xFFe5f8f4),
                              homeIconSize: 35,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const PublicEventScreen()));
                                });
                              },
                              icon: 'assets/icons/calendar_1.svg',
                              title: "Event",
                              colorOne: const Color(0xFF0861B6),
                              colorTwo: const Color(0xFF20BDFF),
                              homeIconColor: const Color(0xFFE8F4FF),
                              homeIconSize: 35,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(CustomRoute(widget: const NewsScreen()));
                                });
                              },
                              icon: 'assets/icons/news_paper_1.svg',
                              title: "News",
                              colorOne: const Color(0xFFb83dba),
                              colorTwo: const Color(0xFFe96feb),
                              homeIconColor: const Color(0xFFf6ddf7),
                              homeIconSize: 32,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return const CircularScreen();
                                      }));
                                });
                              },
                              icon: 'assets/icons/info.svg',
                              title: "Circular",
                              colorOne: const Color(0xFF0bb08e),
                              colorTwo: const Color(0xFF36dab8),
                              homeIconColor: const Color(0xFFe5f8f4),
                              homeIconSize: 32,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return const DeathScreen();
                                      }));
                                });
                              },
                              icon: 'assets/icons/rip.svg',
                              title: "Obituary",
                              colorOne: const Color(0xFF0861B6),
                              colorTwo: const Color(0xFF20BDFF),
                              homeIconColor: const Color(0xFFE8F4FF),
                              homeIconSize: 32,
                            ),
                            HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return const NotificationScreen();
                                      }));
                                });
                              },
                              icon: 'assets/icons/notification.svg',
                              title: "Notification",
                              colorOne: const Color(0xFFb83dba),
                              colorTwo: const Color(0xFFe96feb),
                              homeIconColor: const Color(0xFFf6ddf7),
                              homeIconSize: 32,
                            ),
                            login_status ? Container() : HomeCard(
                              onPressed: () {
                                setState(() {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return const LoginScreen();
                                      }));
                                });
                              },
                              icon: 'assets/icons/more.svg',
                              title: "More",
                              colorOne: const Color(0xFF0bb08e),
                              colorTwo: const Color(0xFF36dab8),
                              homeIconColor: const Color(0xFFe5f8f4),
                              homeIconSize: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: whiteColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('DE LA SALLE BROTHERS - LASAD', style: TextStyle(fontSize: size.height * 0.018, fontWeight: FontWeight.bold),),
                accountEmail: const Text(''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/lasad_logo.png',
                      height: size.height * 0.08,
                      width: size.width * 0.18,
                    ),
                  ),
                ),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/images/nav/nav.jpg',
                        ),
                        fit: BoxFit.cover
                    )
                ),
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmAlertDialog(
                            message: 'Are you sure want to exit.',
                            onYesPressed: () {
                              exit(0);
                            },
                            onCancelPressed: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: menuPrimaryColor,
                            ),
                            child: Icon(Icons.cancel, size: size.height * 0.025, color: whiteColor,)
                        ),
                        SizedBox(width: size.width * 0.05),
                        Expanded(child: Text('Exit', style: TextStyle(fontSize: size.height * 0.019, color: Colors.black, fontWeight: FontWeight.w600),)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animateToSlide,
    effect: const ExpandingDotsEffect(
      dotHeight: 9,
      dotWidth: 9,
      activeDotColor: Color(0xFF0AD69D),
      // activeDotColor: Color(0xFF24C6DC)
      // activeDotColor: iconColor
    ),
    activeIndex: activeIndex,
    count: imgList.length,
  );

  void animateToSlide(int index) => controller.animateToPage(index);

  Widget buildTextIndicator() => AnimatedSmoothIndicator(
    onDotClicked: animatedToSlide,
    effect: const ExpandingDotsEffect(
        dotHeight: 3,
        dotWidth: 3,
        activeDotColor: Colors.white
    ),
    activeIndex: activeNewsIndex,
    count: newsData.isNotEmpty ? newsData.length : newsList.length,
  );

  void animatedToSlide(int index) => controller.animateToPage(index);
}

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
        required this.onPressed,
        required this.icon,
        required this.title,
        required this.colorOne,
        required this.colorTwo,
        required this.homeIconColor,
        required this. homeIconSize,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String icon;
  final String title;
  final Color colorOne;
  final Color colorTwo;
  final Color homeIconColor;
  final double homeIconSize;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: size.height / 9,
        width: size.width / 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.07,
              width: size.width * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                color: homeIconColor,
              ),
              child: Center(
                  child: IconButton(
                    icon: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [colorOne, colorTwo], // Add your gradient colors here
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ).createShader(bounds);
                      },
                      child: SvgPicture.asset(icon, color: homeIconColor,),),
                    iconSize: homeIconSize,
                    onPressed: onPressed,
                  )
              ),
            ),
            SizedBox(height: size.height * 0.005,),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  letterSpacing: 1,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.017
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getInnerPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double curveX = rect.width / 7;
    Path rectPath = Path()
      ..addRRect(RRect.fromRectAndCorners(rect, bottomLeft: const Radius.circular(30), bottomRight: const Radius.circular(30)));
    // ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)));

    Path curvePath = Path()
      ..moveTo(rect.center.dx - curveX, rect.bottom)
      ..quadraticBezierTo(
        rect.center.dx,
        rect.center.dy - curveX + 15, //middle curve control
        rect.center.dx + curveX,
        rect.bottom,
      );

    return Path.combine(PathOperation.xor, rectPath, curvePath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
        getOuterPath(rect),
        Paint()
          ..color = appBackgroundColor
          ..style = PaintingStyle.fill);
  }

  @override
  ShapeBorder scale(double t) => this;
}
