import 'dart:convert';

import 'package:chengai/private/screen/parish/parish_details.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class ShrineScreen extends StatefulWidget {
  const ShrineScreen({Key? key}) : super(key: key);

  @override
  State<ShrineScreen> createState() => _ShrineScreenState();
}

class _ShrineScreenState extends State<ShrineScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool _isParish = false;
  List shrineData = ['Independent Diocesan Shrine','Independent National Shrine'];
  List parishData = [];

  String selectedShrine ='';
  int selected = -1;
  int selected2 = -1;
  bool isCategoryExpanded = false;

  getParishData() async {
    String url = '$baseUrl/res.parish';
    Map datas = {
      "params": {
        "filter": "[['diocese_id','=',$userDiocese],['is_house','=',False],['shrine','=','$selectedShrine']]",
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
      List data = jsonDecode(response.body)['result']['data']['result'];
      setState(() {
        _isParish = false;
      });
      parishData = data;
    } else {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        _isParish = false;
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

  assignValues(indexValue) {
    parishId = indexValue;
    setState(() {
      Navigator.of(context).push(CustomRoute(widget: const ParishDetailsScreen()));
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
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _isLoading = false;
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
      body: SafeArea(
          child: Center(
            child: _isLoading
                ? Center(
              child: SizedBox(
                height: size.height * 0.06,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
                ),
              ),
            ) : Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      radius: const Radius.circular(20),
                      thickness: 8,
                      child: AnimationLimiter(
                        child: SingleChildScrollView(
                          child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: shrineData.length, // Update the itemCount to 2 for two expansion tiles
                            itemBuilder: (BuildContext context, int index) {
                              final isTileExpanded = index == selected;
                              final textExpandColor = isTileExpanded ? textColor : Colors.white;
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: ScaleAnimation(
                                    child: Column(
                                      children: [
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFED8F03), Color(0xFFFFB75E),],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(15.0)
                                            ),
                                            child: ExpansionTile(
                                              key: Key(index.toString()),// Use the generated GlobalKey for each expansion tile
                                              initiallyExpanded: index == selected,
                                              backgroundColor: Colors.white,
                                              iconColor: iconColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              onExpansionChanged: (newState) {
                                                if (newState) {
                                                  setState(() {
                                                    selected = index;
                                                    selectedShrine = shrineData[index];
                                                    getParishData();
                                                    _isParish = true;
                                                    selected2 = -1;
                                                    isCategoryExpanded = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    selected = -1;
                                                    isCategoryExpanded = false;
                                                  });
                                                }
                                              },
                                              title: Container(
                                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                child: Text(
                                                  '${shrineData[index]}',
                                                  style: GoogleFonts.signika(
                                                    fontSize: size.height * 0.023,
                                                    color: textExpandColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              children: [
                                                _isParish ? Center(
                                                  child: SizedBox(
                                                    height: size.height * 0.06,
                                                    child: const LoadingIndicator(
                                                      indicatorType: Indicator.ballPulse,
                                                      colors: [Colors.red,Colors.orange,Colors.yellow],
                                                    ),
                                                  ),
                                                ) : parishData.isNotEmpty ? ListView.builder(
                                                  key: Key('builder ${selected2.toString()}'),
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: isCategoryExpanded ? parishData.length : 0, // Update the itemCount to 2 for two expansion tiles
                                                  itemBuilder: (BuildContext context, int indexs) {
                                                    final isTileExpanded = indexs == selected2;
                                                    final subTextExpandColor = isTileExpanded ? noDataColor : Colors.blueAccent;
                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 8),
                                                      child: Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              int indexValue;
                                                              indexValue = parishData[indexs]['id'];
                                                              assignValues(indexValue);
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                                              color: Colors.white,
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      parishData[indexs]['image_1920'] != '' ? showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) {
                                                                          return Dialog(
                                                                            child: Image.network(parishData[indexs]['image_1920'], fit: BoxFit.cover,),
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
                                                                              image: parishData[indexs]['image_1920'] != null && parishData[indexs]['image_1920'] != ''
                                                                                  ? NetworkImage(parishData[indexs]['image_1920'])
                                                                                  : const AssetImage('assets/others/parish.png') as ImageProvider,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          bottom: size.height * 0.0,
                                                                          right: size.width * 0.015,
                                                                          child: Container(
                                                                            height: size.height * 0.03,
                                                                            width: size.width * 0.065,
                                                                            alignment: Alignment.center,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(5),
                                                                              color: parishData[indexs]['run_by'] == 'Diocesan' ? Colors.green : Colors.indigo,
                                                                            ),
                                                                            child: parishData[indexs]['run_by'] == 'Diocesan' ? Text('D',
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
                                                                                  parishData[indexs]['name'],
                                                                                  style: GoogleFonts.secularOne(
                                                                                    fontSize: size.height * 0.02,
                                                                                    color: subTextExpandColor,
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
                                                                              parishData[indexs]['priest_id']['member_name'] != '' ? Flexible(
                                                                                child: RichText(
                                                                                  textAlign: TextAlign.left,
                                                                                  text: TextSpan(
                                                                                      text: parishData[indexs]['priest_id']['member_name'],
                                                                                      style: TextStyle(
                                                                                        // letterSpacing: 1,
                                                                                          fontSize: size.height * 0.017,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Colors.black87,
                                                                                          fontStyle: FontStyle.italic
                                                                                      ),
                                                                                      children: parishData[indexs]['priest_id']['role_ids_view'] != null && parishData[indexs]['priest_id']['role_ids_view'] != '' ? [
                                                                                        const TextSpan(
                                                                                          text: '  ',
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '(${parishData[indexs]['priest_id']['role_ids_view']})',
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
                                                                          parishData[indexs]['ass_priest_id'] != [] && parishData[indexs]['ass_priest_id'].isNotEmpty ? Row(
                                                                            children: [
                                                                              parishData[indexs]['ass_priest_id'][0]['member_name'] != '' ? Flexible(
                                                                                child: RichText(
                                                                                  textAlign: TextAlign.left,
                                                                                  text: TextSpan(
                                                                                      text: parishData[indexs]['ass_priest_id'][0]['member_name'],
                                                                                      style: TextStyle(
                                                                                        // letterSpacing: 1,
                                                                                          fontSize: size.height * 0.017,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Colors.black87,
                                                                                          fontStyle: FontStyle.italic
                                                                                      ),
                                                                                      children: parishData[indexs]['ass_priest_id'][0]['role_ids_view'] != null && parishData[indexs]['ass_priest_id'][0]['role_ids_view'] != '' ? [
                                                                                        const TextSpan(
                                                                                          text: '  ',
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '(${parishData[indexs]['ass_priest_id'][0]['role_ids_view']})',
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
                                                                          ) : Container(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          if(indexs < parishData.length - 1) const Divider(
                                                            thickness: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ) : Center(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 180,
                                                      child: textButton,
                                                    ),
                                                  ),
                                                )
                                              ],
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
