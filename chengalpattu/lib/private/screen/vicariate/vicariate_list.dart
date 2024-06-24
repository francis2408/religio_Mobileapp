import 'dart:convert';

import 'package:chengai/private/screen/vicariate/vicariate_parish_list.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class VicariateListScreen extends StatefulWidget {
  const VicariateListScreen({Key? key}) : super(key: key);

  @override
  State<VicariateListScreen> createState() => _VicariateListScreenState();
}

class _VicariateListScreenState extends State<VicariateListScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List vicariate = [];
  List data = [];
  List parishCount = [];
  var searchController = TextEditingController();

  assignValues(indexValue) {
  vicariateId = indexValue;

    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const VicariateParishListScreen()));
    });
  }

  vicariateData() async {
    String url = '$baseUrl/res.vicariate';
    Map datas = {
      "params": {
        "filter": "[['diocese_id', '=',$userDiocese]]",
        "order": "sequence, name asc",
        "query": "{id,image_1920,name,parish_ids,vicarare_forane}"
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
      data = jsonDecode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      vicariate = data;
    }
    else {
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
      vicariate = results;
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
      vicariateData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            vicariateData();
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
        title: const Text('Vicariate'),
        centerTitle: true,
        backgroundColor: backgroundColor,
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
                vicariateData();
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
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
                    Text('${vicariate.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                vicariate.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: vicariate.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: GestureDetector(
                                  onTap: () {
                                    int indexValue;
                                    indexValue = vicariate[index]['id'];
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
                                              vicariate[index]['image_1920'] != '' ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(vicariate[index]['image_1920'], fit: BoxFit.cover,),
                                                  );
                                                },
                                              ) : showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/others/vicariate.png', fit: BoxFit.cover,),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
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
                                                  image: vicariate[index]['image_1920'] != null && vicariate[index]['image_1920'] != ''
                                                      ? NetworkImage(vicariate[index]['image_1920'])
                                                      : const AssetImage('assets/others/vicariate.png') as ImageProvider,
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
                                                          vicariate[index]['name'],
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height * 0.01,
                                                  ),
                                                  Row(
                                                    children: [
                                                      vicariate[index]['vicarare_forane']['name'] != '' ? Flexible(
                                                        child: RichText(
                                                          textAlign: TextAlign.left,
                                                          text: TextSpan(
                                                              text: vicariate[index]['vicarare_forane']['name'],
                                                              style: TextStyle(
                                                                  fontSize: size.height * 0.016,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black87,
                                                                  fontStyle: FontStyle.italic
                                                              ),
                                                              children: [
                                                                const TextSpan(
                                                                  text: '  ',
                                                                ),
                                                                TextSpan(
                                                                  text: '(Vicarare Forane)',
                                                                  style: TextStyle(
                                                                      fontSize: size.height * 0.016,
                                                                      color: Colors.black45,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                ),
                                                              ]
                                                          ),
                                                        ),
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: size.height * 0.01,
                                                  ),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          int indexValue;
                                                          indexValue = vicariate[index]['id'];
                                                          assignValues(indexValue);
                                                        },
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text: vicariate[index]['parish_ids'].length.toString(),
                                                              style: TextStyle(
                                                                letterSpacing: 1,
                                                                fontSize: size.height * 0.016,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.blueGrey,
                                                                fontStyle: FontStyle.italic,
                                                                decoration: TextDecoration.underline,
                                                              ),
                                                              children: <InlineSpan>[
                                                                vicariate[index]['parish_ids'].length == 1 ? TextSpan(
                                                                  text: ' Parish',
                                                                  style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.016,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.blueGrey,
                                                                    fontStyle: FontStyle.italic,
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                                ) : TextSpan(
                                                                  text: ' Parishes',
                                                                  style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.016,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.blueGrey,
                                                                    fontStyle: FontStyle.italic,
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                                )
                                                              ]
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ) : Column(
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
              ],
            ),
          ),
        )
      ),
    );
  }
}
