import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';

import 'news_detail.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading  = true;
  List data = [];
  List newsData = [];
  int selected = -1;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);
  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getNewsData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.news?domain=[('rel_province_id','=',$userProvinceId),('type','=','Province'),('state','=','publish')]&fields=['name','state','description','date']&order=date desc"""));
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
    getNewsData();
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
                    Color(0xFF1A3F85),
                    Color(0xFFFA761E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? Center(
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
                    onChanged: (value) {
                      setState(() {
                        searchData(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),
                      suffixIcon: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)), color: tabBackColor),child: const Icon(Icons.search,  color: tabLabelColor,)),
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
                          color: tabBackColor,
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
                              if (index == 0 || !(isSameDate)) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        int indexValue = newsData[index]['id'];
                                        newsID = indexValue;
                                        setState(() {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
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
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
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
                                                newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
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
                                );
                              } else {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        int indexValue = newsData[index]['id'];
                                        newsID = indexValue;
                                        setState(() {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
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
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) {return const NewsDetailScreen();}));
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
                                                newsData[index]['description'] != null && newsData[index]['description'] != '' && newsData[index]['description'].replaceAll(exp, '') != '' ? SizedBox(height: size.height * 0.01,) : Container(),
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
