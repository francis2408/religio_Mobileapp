import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scb/private/screens/news/add_news.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';

import 'news_detail.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading  = true;
  List data = [];
  List newsData = [];
  int selected = -1;
  String searchName = '';
  var searchController = TextEditingController();

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getNewsData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.news?domain=[('rel_province_id','=',$userProvinceId),('type','=','Province'),('state','=','publish')]&fields=['name','state','description','date','upload_image']&order=date desc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      newsData = data;
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

  void changeData() {
    setState(() {
      _isLoading = true;
      getNewsData();
    });
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('News'),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          toolbarHeight: 50,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, 'refresh');
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              )
          ),
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading ? Center(
              child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage( "assets/alert/spinner_1.gif"),
                    ),
                  )),
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
                          color: Colors.grey,
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
                                  ? const Icon(Icons.clear, color: redColor)
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
                                  color: menuThirdColor,
                                ),
                                child: const Icon(Icons.search, color: whiteColor),
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
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
                      const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                      const SizedBox(width: 3,),
                      Text('${newsData.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countValue),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  newsData.isNotEmpty ? Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      radius: const Radius.circular(20),
                      thickness: 8,
                      child: SlideFadeAnimation(
                        duration: const Duration(seconds: 1),
                        child: SingleChildScrollView(
                          child: ListView.builder(
                              key: Key('builder ${selected.toString()}'),
                              shrinkWrap: true,
                              // scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: newsData.length,
                              itemBuilder: (BuildContext context, int index) {
                                bool isSameDate = true;
                                final String dateString = DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(newsData[index]['date']));
                                final DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
                                if (index == 0) {
                                  isSameDate = false;
                                } else {
                                  final String prevDateString = newsData[index - 1]['date'];
                                  final DateTime prevDate = DateFormat('dd-MM-yyyy').parse(prevDateString);
                                  isSameDate = date.isSameDate(prevDate);
                                }
                                if(index == 0 || !(isSameDate)) {
                                  return Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: size.width * 0.5,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: hiLightColor,
                                          ),
                                          child: Text(
                                            date.formatDate(),
                                            style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: size.height * 0.018
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.005,),
                                      GestureDetector(
                                        onTap: () {
                                          int indexValue = newsData[index]['id'];
                                          newsID = indexValue;
                                          setState(() {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
                                          });
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    newsData[index]['upload_image'] != '' ? showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return Dialog(
                                                          child: Image.network(newsData[index]['upload_image'], fit: BoxFit.cover,),
                                                        );
                                                      },
                                                    ) : showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return Dialog(
                                                          child: Image.asset('assets/images/news1.jpg', fit: BoxFit.cover,),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    height: size.height * 0.1,
                                                    width: size.width * 0.20,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      shape: BoxShape.rectangle,
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: newsData[index]['upload_image'] != null && newsData[index]['upload_image'] != ''
                                                            ? NetworkImage(newsData[index]['upload_image'])
                                                            : const AssetImage('assets/images/news1.jpg') as ImageProvider,
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
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                newsData[index]['name'],
                                                                style: GoogleFonts.secularOne(
                                                                  fontSize: size.height * 0.02,
                                                                  color: textHeadColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: size.height * 0.01,),
                                                        newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                newsData[index]['description'].replaceAll(exp, ''),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
                                                              ),
                                                            ),
                                                            SizedBox(width: size.width * 0.01,),
                                                            GestureDetector(
                                                              onTap: () {
                                                                int indexValue = newsData[index]['id'];
                                                                newsID = indexValue;
                                                                setState(() {
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
                                                                });
                                                              },
                                                              child: Container(
                                                                  alignment: Alignment.topRight,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      const Text('More', style: TextStyle(
                                                                          color: mobileText
                                                                      ),),
                                                                      SizedBox(width: size.width * 0.018,),
                                                                      const Icon(Icons.arrow_forward_ios, color: mobileText, size: 11,)
                                                                    ],
                                                                  )
                                                              ),
                                                            )
                                                          ],
                                                        ) : Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                "No Description available",
                                                                style: TextStyle(
                                                                  letterSpacing: 0.5,
                                                                  fontSize: size.height * 0.017,
                                                                  // fontWeight: FontWeight.bold,
                                                                  color: Colors.grey,
                                                                  fontStyle: FontStyle.italic,
                                                                ),
                                                              ),
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
                                      ),
                                      SizedBox(height: size.height * 0.01,),
                                    ],
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      int indexValue = newsData[index]['id'];
                                      newsID = indexValue;
                                      setState(() {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
                                      });
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                newsData[index]['upload_image'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(newsData[index]['upload_image'], fit: BoxFit.cover,),
                                                    );
                                                  },
                                                ) : showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.asset('assets/images/news1.jpg', fit: BoxFit.cover,),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: size.height * 0.1,
                                                width: size.width * 0.20,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: newsData[index]['upload_image'] != null && newsData[index]['upload_image'] != ''
                                                        ? NetworkImage(newsData[index]['upload_image'])
                                                        : const AssetImage('assets/images/news1.jpg') as ImageProvider,
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
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            newsData[index]['name'],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.02,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: size.height * 0.01,),
                                                    newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            newsData[index]['description'].replaceAll(exp, ''),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
                                                          ),
                                                        ),
                                                        SizedBox(width: size.width * 0.01,),
                                                        GestureDetector(
                                                          onTap: () {
                                                            int indexValue = newsData[index]['id'];
                                                            newsID = indexValue;
                                                            setState(() {
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
                                                            });
                                                          },
                                                          child: Container(
                                                              alignment: Alignment.topRight,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  const Text('More', style: TextStyle(
                                                                      color: mobileText
                                                                  ),),
                                                                  SizedBox(width: size.width * 0.018,),
                                                                  const Icon(Icons.arrow_forward_ios, color: mobileText, size: 11,)
                                                                ],
                                                              )
                                                          ),
                                                        )
                                                      ],
                                                    ) : Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            "No Description available",
                                                            style: TextStyle(
                                                              letterSpacing: 0.5,
                                                              fontSize: size.height * 0.017,
                                                              // fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontStyle: FontStyle.italic,
                                                            ),
                                                          ),
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
                              }
                          ),
                        ),
                      ),
                    ),
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: NoResult(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          text: 'No Data available',
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: userRole == 'Religious Province' ? newsData.isEmpty ? ConditionalFloatingActionButton(
          isEmpty: true,
          iconBackColor: iconBackColor,
          onPressed: () async {
            String refresh = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddNewsScreen()));
            if(refresh == 'refresh') {
              changeData();
            }
          },
          child: const Icon(Icons.add, color: buttonIconColor,),
        ) : ConditionalFloatingActionButton(
          isEmpty: false,
          iconBackColor: iconBackColor,
          onPressed: () async {
            String refresh = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddNewsScreen()));
            if(refresh == 'refresh') {
              changeData();
            }
          },
          child: const Icon(Icons.add, color: buttonIconColor,),
        ) : Container(),
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
