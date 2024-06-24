import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/slide_animations.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

class FeastScreen extends StatefulWidget {
  const FeastScreen({Key? key}) : super(key: key);

  @override
  State<FeastScreen> createState() => _FeastScreenState();
}

class _FeastScreenState extends State<FeastScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  List feast = [];
  String today = '';

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getFeastData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/res.member/api_get_feast_list_v1?args=[$userProvinceId]"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      setState(() {
        _isLoading = false;
      });
      for(int i = 0; i < data.length; i++) {
        if(feastTab == 'Upcoming') {
          feast = data[i]['upcoming_feast_list'];
        } else {
          feast = data[i]['all_feast_list'];
        }
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
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getFeastData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getFeastData();
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
        child: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Center(
            child: _isLoading
                ? Center(
              child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/alert/spinner_1.gif"),
                    ),
                  )),
            ) : Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                feast.isNotEmpty ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                    const SizedBox(width: 3,),
                    Text('${feast.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),),
                    const SizedBox(width: 5,),
                  ],
                ) : Container(),
                feast.isNotEmpty ? SizedBox(
                  height: size.height * 0.01,
                ) : Container(),
                feastTab == 'Upcoming' ? feast.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: feast.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            today = DateFormat('dd - MMMM').format(now);
                            if(today == feast[index]['feastday']) {
                              return Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  feast[index]['image'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(feast[index]['image'], fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  ) : showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: size.height * 0.1,
                                                  width: size.width * 0.16,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: <BoxShadow>[
                                                      if(feast[index]['image'] != null && feast[index]['image'] != '') const BoxShadow(
                                                        color: Colors.grey,
                                                        spreadRadius: -1,
                                                        blurRadius: 5 ,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: feast[index]['image'] != null && feast[index]['image'] != ''
                                                          ? NetworkImage(feast[index]['image'])
                                                          : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 15, right: 10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        feast[index]['name'],
                                                        style: TextStyle(
                                                            fontSize: size.height * 0.02,
                                                            fontWeight: FontWeight.bold,
                                                            color: textHeadColor
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.01,
                                                      ),
                                                      Text(
                                                        feast[index]['feastday'],
                                                        style: GoogleFonts.lalezar(fontSize: size.height * 0.02, color: emptyColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: size.height * 0.001,
                                          right: size.width * 0.001,
                                          child: Center(
                                            child: Container(
                                              height: size.height * 0.08,
                                              width: size.width * 0.15,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage("assets/images/celebration.png"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                ],
                              );
                            } else {
                              return Container(
                                padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            feast[index]['image'] != '' ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.network(feast[index]['image'], fit: BoxFit.cover,),
                                                );
                                              },
                                            ) : showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: size.height * 0.1,
                                            width: size.width * 0.16,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: <BoxShadow>[
                                                if(feast[index]['image'] != null && feast[index]['image'] != '') const BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: -1,
                                                  blurRadius: 5 ,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: feast[index]['image'] != null && feast[index]['image'] != ''
                                                    ? NetworkImage(feast[index]['image'])
                                                    : const AssetImage('assets/images/profile.png') as ImageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        feast[index]['name'],
                                                        style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            color: valueColor
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${feast[index]['feastday']}",
                                                      style: GoogleFonts.lalezar(fontSize: size.height * 0.02, color: emptyColor),
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
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: NoResult(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context, 'refresh');
                          });
                        },
                        text: 'No Data available',
                      ),
                    ),
                  ),
                ) : feast.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: feast.length,
                          itemBuilder: (BuildContext context, int index) {
                            final now = DateTime.now();
                            var todays = DateFormat('dd - MMMM').format(now);
                            return Container(
                              padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
                              child: Stack(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              feast[index]['mem_image'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(feast[index]['mem_image'], fit: BoxFit.cover,),
                                                  );
                                                },
                                              ) : showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: size.height * 0.08,
                                              width: size.width * 0.15,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: <BoxShadow>[
                                                  if(feast[index]['mem_image'] != null && feast[index]['mem_image'] != '') const BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: -1,
                                                    blurRadius: 5 ,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: feast[index]['mem_image'] != null && feast[index]['mem_image'] != ''
                                                      ? NetworkImage(feast[index]['mem_image'])
                                                      : const AssetImage('assets/images/profile.png') as ImageProvider,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          feast[index]['name'],
                                                          style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.02,
                                                              color: valueColor
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${feast[index]['feastday']}",
                                                        style: GoogleFonts.lalezar(fontSize: size.height * 0.02, color: emptyColor),
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
                                  if(todays == feast[index]['feastday']) Positioned(
                                    bottom: size.height * 0.01,
                                    right: size.width * 0.01,
                                    child: Center(
                                      child: Container(
                                        height: size.height * 0.05,
                                        width: size.width * 0.1,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage( "assets/images/celebration.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: NoResult(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context, 'refresh');
                          });
                        },
                        text: 'No Data available',
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
