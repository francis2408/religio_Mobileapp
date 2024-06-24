import 'dart:async';
import 'dart:convert';

import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

import 'parish_details.dart';

class ParishListScreen extends StatefulWidget {
  const ParishListScreen({Key? key}) : super(key: key);

  @override
  State<ParishListScreen> createState() => _ParishListScreenState();
}

class _ParishListScreenState extends State<ParishListScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late ScrollController _controller;
  int page = 1;
  int limit = 20;

  bool _isLoading = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _showContainer = false;
  String parishCount = '';
  var searchController = TextEditingController();

  List parishListData = [];
  List parish = [];
  List data = [];

  assignValues(indexValue) {
    parishId = indexValue;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const ParishDetailsScreen()));
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isLoading == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 500
    ) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });

      page += 1; // Increase _page by 1

      String url = '$baseUrl/res.parish';
      Map data = selectedTab == 'All' ? {
        "params": {
          "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False]]",
          "order": "name asc",
          "page_size": limit,
          "page": page,
          "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
        }
      } : selectedTab == 'Diocesan' ? {
        "params": {
          "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['run_by','=','Diocesan'],['shrine','not in',['Independent Diocesan Shrine','Independent National Shrine']]]",
          "order": "name asc",
          "page_size": limit,
          "page": page,
          "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
        }
      } : {
        "params": {
          "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['run_by','=','Religious']]",
          "order": "name asc",
          "page_size": limit,
          "page": page,
          "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
        }
      };
      var body =json.encode(data);
      var response = await http.post(Uri.parse(url),
          headers: {
            'Authorization': authToken,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: body);
      if (response.statusCode == 200) {
        final List fetchedPosts = json.decode(response.body)['result']['data']['result'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            parish.addAll(fetchedPosts);
          });
        } else {
          _hasNextPage = false;
          setState(() {
            _showContainer = true;
          });
          Timer(const Duration(seconds: 1), () {
            setState(() {
              _showContainer = false;
            });
          });
        }
      } else {
        final message = jsonDecode(response.body)['result'];
        setState(() {
          _hasNextPage = false;
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

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  void parishData() async {
    setState(() {
      _isLoading = true;
    });

    String url = '$baseUrl/res.parish';
    Map datas = selectedTab == 'All' ? {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False]]",
        "order": "name asc",
        "page_size": limit,
        "page": page,
        "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
      }
    } : selectedTab == 'Diocesan' ? {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['run_by','=','Diocesan'],['shrine','not in',['Independent Diocesan Shrine','Independent National Shrine']]]",
        "order": "name asc",
        "page_size": limit,
        "page": page,
        "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
      }
    } : {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['run_by','=','Religious']]",
        "order": "name asc",
        "page_size": limit,
        "page": page,
        "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
      }
    };
    var body =json.encode(datas);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      var count = json.decode(response.body)['result']['data']['total_count'];
      parishCount = count.toString();
      data = jsonDecode(response.body)['result']['data']['result'];
      parish = data;
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        _hasNextPage = false;
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

    setState(() {
      _isLoading = false;
    });
  }

  getParishListData() async {
    setState(() {
      _isLoading = true;
    });

    String url = '$baseUrl/res.parish';
    Map datas = selectedTab == 'All' ? {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False]]",
        "order": "name asc",
        "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
      }
    } : selectedTab == 'Diocesan' ? {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['run_by','=','Diocesan'],['shrine','not in',['Independent Diocesan Shrine','Independent National Shrine']]]",
        "order": "name asc",
        "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
      }
    } : {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['run_by','=','Religious']]",
        "order": "name asc",
        "query": "{id,image_1920,name,priest_id{member_name,role_ids},ass_priest_id{member_name,role_ids},run_by}"
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
      parishListData = json.decode(response.body)['result']['data']['result'];
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

    setState(() {
      _isLoading = false;
    });
  }

  searchData(String searchWord) {
    List results = [];
    if (searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = parishListData
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      parish = results;
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
      parishData();
      getParishListData();
      _controller = ScrollController()..addListener(_loadMore);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            parishData();
            getParishListData();
            _controller = ScrollController()..addListener(_loadMore);
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
          child: Center(
            child: _isLoading ? Center(
                child: SizedBox(
                  height: size.height * 0.06,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                  ),
                )
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
                      Text(parishCount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  parish.isNotEmpty ? Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        controller: _controller,
                        itemCount: parish.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.005,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        int indexValue;
                                        indexValue = parish[index]['id'];
                                        assignValues(indexValue);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  parish[index]['image_1920'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(parish[index]['image_1920'], fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  ) : showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.asset('assets/others/parish.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: size.height * 0.08,
                                                      width: size.width * 0.2,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: const <BoxShadow>[
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            spreadRadius: -1,
                                                            blurRadius: 5 ,
                                                            offset: Offset(0, 1),
                                                          ),
                                                        ],
                                                        shape: BoxShape.rectangle,
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: parish[index]['image_1920'] != null && parish[index]['image_1920'] != ''
                                                              ? NetworkImage(parish[index]['image_1920'])
                                                              : const AssetImage('assets/others/parish.png') as ImageProvider,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: size.height * 0,
                                                      right: size.width * 0,
                                                      child: Container(
                                                        height: size.height * 0.03,
                                                        width: size.width * 0.07,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: parish[index]['run_by'] == 'Diocesan' ? Colors.green : Colors.indigo,
                                                        ),
                                                        child: parish[index]['run_by'] == 'Diocesan' ? Text('D',
                                                          style: GoogleFonts.heebo(
                                                              fontSize: size.height * 0.022,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ) : Text('R',
                                                          style: GoogleFonts.heebo(
                                                              fontSize: size.height * 0.022,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                                              parish[index]['name'],
                                                              style: GoogleFonts.secularOne(
                                                                fontSize: size.height * 0.02,
                                                                color: textColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.005,
                                                      ),
                                                      Row(
                                                        children: [
                                                          parish[index]['priest_id']['member_name'] != '' ? Flexible(
                                                            child: RichText(
                                                              textAlign: TextAlign.left,
                                                              text: TextSpan(
                                                                  text: parish[index]['priest_id']['member_name'],
                                                                  style: TextStyle(
                                                                    // letterSpacing: 1,
                                                                      fontSize: size.height * 0.017,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.black87,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                  children: parish[index]['priest_id']['role_ids_view'] != null && parish[index]['priest_id']['role_ids_view'] != '' ? [
                                                                    const TextSpan(
                                                                      text: '  ',
                                                                    ),
                                                                    TextSpan(
                                                                      text: '(${parish[index]['priest_id']['role_ids_view']})',
                                                                      style: TextStyle(
                                                                        // letterSpacing: 1,
                                                                          fontSize: size.height * 0.017,
                                                                          color: Colors.black45,
                                                                          fontStyle: FontStyle.italic
                                                                      ),
                                                                    ),
                                                                  ] : []
                                                              ),
                                                            ),
                                                          ) : Container(),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.005,
                                                      ),
                                                      parish[index]['ass_priest_id'] != [] && parish[index]['ass_priest_id'].isNotEmpty ? ListView.builder(
                                                        shrinkWrap: true,
                                                        scrollDirection: Axis.vertical,
                                                        itemCount: parish[index]['ass_priest_id'].length,
                                                        itemBuilder: (BuildContext context, int indexs) {
                                                          return AnimationConfiguration.staggeredList(
                                                            position: indexs,
                                                            duration: const Duration(milliseconds: 375),
                                                            child: SlideAnimation(
                                                              verticalOffset: 50.0,
                                                              child: FadeInAnimation(
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        parish[index]['ass_priest_id'][indexs]['member_name'] != '' ? Flexible(
                                                                          child: RichText(
                                                                            textAlign: TextAlign.left,
                                                                            text: TextSpan(
                                                                                text: parish[index]['ass_priest_id'][indexs]['member_name'],
                                                                                style: TextStyle(
                                                                                  // letterSpacing: 1,
                                                                                    fontSize: size.height * 0.016,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Colors.black87,
                                                                                    fontStyle: FontStyle.italic
                                                                                ),
                                                                                children: parish[index]['ass_priest_id'][indexs]['role_ids_view'] != null && parish[index]['ass_priest_id'][indexs]['role_ids_view'] != '' ? [
                                                                                  const TextSpan(
                                                                                    text: '  ',
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: '(${parish[index]['ass_priest_id'][indexs]['role_ids_view']})',
                                                                                    style: TextStyle(
                                                                                      // letterSpacing: 1,
                                                                                        fontSize: size.height * 0.016,
                                                                                        color: Colors.black45,
                                                                                        fontStyle: FontStyle.italic
                                                                                    ),
                                                                                  ),
                                                                                ] : []
                                                                            ),
                                                                          ),
                                                                        ) : Container(),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: size.height * 0.005,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ) : Container(),
                                                      // parish[index]['ass_priest_id'] != [] && parish[index]['ass_priest_id'].isNotEmpty ? Row(
                                                      //   children: [
                                                      //     parish[index]['ass_priest_id'][0]['member_name'] != '' ? Flexible(
                                                      //       child: RichText(
                                                      //         textAlign: TextAlign.left,
                                                      //         text: TextSpan(
                                                      //             text: parish[index]['ass_priest_id'][0]['member_name'],
                                                      //             style: TextStyle(
                                                      //               // letterSpacing: 1,
                                                      //                 fontSize: size.height * 0.017,
                                                      //                 fontWeight: FontWeight.bold,
                                                      //                 color: Colors.black87,
                                                      //                 fontStyle: FontStyle.italic
                                                      //             ),
                                                      //             children: parish[index]['ass_priest_id'][0]['role_ids_view'] != null && parish[index]['ass_priest_id'][0]['role_ids_view'] != '' ? [
                                                      //               const TextSpan(
                                                      //                 text: '  ',
                                                      //               ),
                                                      //               TextSpan(
                                                      //                 text: '(${parish[index]['ass_priest_id'][0]['role_ids_view']})',
                                                      //                 style: TextStyle(
                                                      //                   // letterSpacing: 1,
                                                      //                     fontSize: size.height * 0.017,
                                                      //                     color: Colors.black45,
                                                      //                     fontStyle: FontStyle.italic
                                                      //                 ),
                                                      //               ),
                                                      //             ] : []
                                                      //         ),
                                                      //       ),
                                                      //     ) : Container(),
                                                      //   ],
                                                      // ) : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ) : Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                            child: SizedBox(
                              height: 45,
                              width: 150,
                              child: textButton,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (_isLoadMoreRunning == true)
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.width * 0.01),
                      child: Center(
                        child: SizedBox(
                          height: size.height * 0.06,
                          child: const LoadingIndicator(
                            indicatorType: Indicator.ballRotateChase,
                            colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                          ),
                        ),
                      ),
                    ),
                  if(_showContainer)
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      height: 40,
                      color: Colors.grey,
                      child: const Center(
                        child: Text('You have fetched all of the data'),
                      ),
                    ) else const SizedBox.shrink()
                ],
              ),
            ),
          )
      ),
    );
  }
}
