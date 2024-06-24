import 'dart:convert';

import 'package:chengai/private/screen/news/new_details.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading  = true;
  List data = [];
  List newsData = [];
  int selected = -1;
  var searchController = TextEditingController();

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  getNewsData() async {
    String url = '$baseUrl/res.news';
    Map datas = {
      "params": {
        "order": "date desc",
        "query":"{id,name,description,date,type}"
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
      data = json.decode(response.body)['result']['data']['result'];
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      newsData = data;

    } else {
      var message = json.decode(response.body)['result'];
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

  searchData(String searchWord) {
    List results = [];
    if (searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = data
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      newsData = results;
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
      getNewsData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getNewsData();
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
        title: const Text('News'),
        centerTitle: true,
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
                getNewsData();
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
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchName = value;
                        searchData(searchName);
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchData(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: backgroundColor,
                        fontSize: size.height * 0.02,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (searchName.isNotEmpty) {
                                setState(() {
                                  searchController.clear();
                                  searchName = '';
                                  searchData(searchName);
                                });
                              }
                            },
                            child: searchName.isNotEmpty && searchName != ''
                                ? const Icon(Icons.clear, color: backgroundColor)
                                : Container(),
                          ),
                          SizedBox(width: size.width * 0.01),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                searchData(searchName);
                              });
                            },
                            child: Container(
                              height: size.height * 0.055,
                              width: size.width * 0.11,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: Color(0xFFd9f1fc),
                              ),
                              child: const Icon(Icons.search, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(width: 1, color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 3,),
                    Text('${newsData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                newsData.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    interactive: true,
                    radius: const Radius.circular(10),
                    thickness: 5,
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: newsData.length,
                            itemBuilder: (BuildContext context, int index) {
                              bool isSameDate = true;
                              final String dateString = newsData[index]['date'];
                              final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                              if (index == 0) {
                                isSameDate = false;
                              } else {
                                final String prevDateString = newsData[index - 1]['date'];
                                final DateTime prevDate = DateFormat('dd-MM-yyyy').parse(prevDateString);
                                isSameDate = date.isSameDate(prevDate);
                              }
                              if (index == 0 || !(isSameDate)) {
                                return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 380),
                                    child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  int indexValue = newsData[index]['id'];
                                                  newsID = indexValue;
                                                  setState(() {
                                                    Navigator.of(context).push(CustomRoute(widget: const NewsDetailsScreen()));
                                                  });
                                                },
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(child: Text("${newsData[index]['name']}", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),),),
                                                          ],
                                                        ),
                                                        newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                                        newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Flexible(child: Text("${newsData[index]['description'].replaceAll(exp, '')}", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: size.height * 0.016, color: Colors.black54),),),
                                                            GestureDetector(
                                                              onTap: () {
                                                                int indexValue = newsData[index]['id'];
                                                                newsID = indexValue;
                                                                setState(() {
                                                                  Navigator.of(context).push(CustomRoute(widget: const NewsDetailsScreen()));
                                                                });
                                                              },
                                                              child: Container(
                                                                  alignment: Alignment.topRight,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      const Text('More', style: TextStyle(
                                                                          color: Colors.indigoAccent
                                                                      ),),
                                                                      SizedBox(width: size.width * 0.018,),
                                                                      const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                                    ],
                                                                  )
                                                              ),
                                                            )
                                                          ],
                                                        ) : Container(),
                                                        SizedBox(height: size.height * 0.01,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text(date.formatDate(), style: GoogleFonts.sansita(fontSize: size.height * 0.018, color: textColor),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                            ],
                                          ),
                                        )
                                    )
                                );
                              } else {
                                return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 380),
                                    child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  int indexValue = newsData[index]['id'];
                                                  newsID = indexValue;
                                                  setState(() {
                                                    Navigator.of(context).push(CustomRoute(widget: const NewsDetailsScreen()));
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Flexible(child: Text("${newsData[index]['name']}", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: size.height * 0.02, color: Colors.black87),),),
                                                            ],
                                                          ),
                                                          newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
                                                          newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Flexible(child: Text("${newsData[index]['description'].replaceAll(exp, '')}", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: size.height * 0.016, color: Colors.black54),),),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  int indexValue = newsData[index]['id'];
                                                                  newsID = indexValue;
                                                                  setState(() {
                                                                    Navigator.of(context).push(CustomRoute(widget: const NewsDetailsScreen()));
                                                                  });
                                                                },
                                                                child: Container(
                                                                    alignment: Alignment.topRight,
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                      children: [
                                                                        const Text('More', style: TextStyle(
                                                                            color: Colors.indigoAccent
                                                                        ),),
                                                                        SizedBox(width: size.width * 0.018,),
                                                                        const Icon(Icons.arrow_forward_ios, color: Colors.indigoAccent, size: 11,)
                                                                      ],
                                                                    )
                                                                ),
                                                              )
                                                            ],
                                                          ) : Container(),
                                                          SizedBox(height: size.height * 0.01,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(date.formatDate(), style: GoogleFonts.sansita(fontSize: size.height * 0.018, color: textColor),),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01,),
                                            ],
                                          ),
                                        )
                                    )
                                );
                              }
                            }
                        ),
                      ),
                    ),
                  ),
                ) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                      child: SizedBox(
                        height: 45,
                        width: 150,
                        child: textButton,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {

  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }
  bool isSameDate(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}
