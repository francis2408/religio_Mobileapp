import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/private/screen/member/holy_order/add_holy_order.dart';
import 'package:chengai/private/screen/member/holy_order/edit_holy_order.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class ProfileHolyOrderScreen extends StatefulWidget {
  const ProfileHolyOrderScreen({Key? key}) : super(key: key);

  @override
  State<ProfileHolyOrderScreen> createState() => _ProfileHolyOrderScreenState();
}

class _ProfileHolyOrderScreenState extends State<ProfileHolyOrderScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List holyOrder = [];
  int selected = -1;

  var headers = {
    'Authorization': authToken,
    'Content-Type': 'application/json',
  };

  getHolyOrderData() async {
    String url = '$baseUrl/member.holyorder';
    Map data = {
      "params": {
        "filter": "[['member_id','=',$userMember]]",
        "query": "{id,date,place,order,minister}"
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

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      holyOrder = data;
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

  deleteData() async {
    String url = '$baseUrl/delete/member.holyorder/$holyOrderId';
    Map data = {};
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      final message = jsonDecode(response.body)['result'];
      setState(() {
        _isLoading = false;
      });

      Navigator.maybePop(context, MaterialPageRoute(builder: (context) => ProfileHolyOrderScreen()),).then((res) => setState(() {
        _isLoading = true;
        getHolyOrderData();
      }));

      AnimatedSnackBar.material(
          message['message'],
          type: AnimatedSnackBarType.success,
          duration: const Duration(seconds: 2)
      ).show(context);
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
  }

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getHolyOrderData();
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
    if (expiryDateTime!.isAfter(currentDateTime)) {
      getHolyOrderData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getHolyOrderData();
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
              ? SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ) : holyOrder.isNotEmpty ? Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
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
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: holyOrder.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: ScaleAnimation(
                                    child: GestureDetector(
                                      onTap: () {
                                        if(userLevel != 'Diocesan Member') {
                                          setState(() {
                                          int indexValue;
                                          indexValue = holyOrder[index]['id'];
                                          holyOrderId = indexValue;

                                          // Bottom sheet
                                          Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                            return Container(
                                              height: size.height * 0.15,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(25),
                                                    topLeft: Radius.circular(25)
                                                ),
                                                color: Color(0xFFCDCDCD),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      width: size.width * 0.3,
                                                      height: size.height * 0.008,
                                                      alignment: Alignment.topCenter,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: size.height * 0.05,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: size.width * 0.3,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              setState(() {
                                                                QuickAlert.show(
                                                                  context: context,
                                                                  type: QuickAlertType.confirm,
                                                                  title: 'Confirm',
                                                                  text: 'Are you sure want to delete the holy order data.',
                                                                  confirmBtnColor: greenColor,
                                                                  showCancelBtn: true,
                                                                  onConfirmBtnTap: () {
                                                                    deleteData();
                                                                  },
                                                                  onCancelBtnTap: () {
                                                                    cancel();
                                                                  },
                                                                  width: 100.0,
                                                                );
                                                              });
                                                            }, icon: const Icon(Icons.delete), label: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),),
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.03,
                                                        ),
                                                        Container(
                                                          width: size.width * 0.3,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: TextButton.icon(
                                                            onPressed: () async {
                                                              Navigator.pop(context);

                                                              String refresh = await Navigator.push(context,
                                                                  MaterialPageRoute(builder: (context) => const EditHolyOrderScreen()));

                                                              if(refresh == 'refresh') {
                                                                changeData();
                                                              }
                                                            },
                                                            icon: const Icon(Icons.edit),
                                                            label: const Text('Edit'),
                                                            style: TextButton.styleFrom(
                                                                foregroundColor: Colors.white,
                                                                backgroundColor: Colors.orange,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        });
                                        }
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
                                            padding: const EdgeInsets.all(15),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Order', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        holyOrder[index]['order'] != null && holyOrder[index]['order'] != '' ? Text(holyOrder[index]['order'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                      ],
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    Row(
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        holyOrder[index]['date'].isNotEmpty && holyOrder[index]['date'] != null && holyOrder[index]['date'] != '' ? Text("${holyOrder[index]['date']}",
                                                          style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),
                                                        ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                      ],
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    Row(
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Minister', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        holyOrder[index]['minister'] != null && holyOrder[index]['minister'] != '' ? Flexible(child: Text(holyOrder[index]['minister'],style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                      ],
                                                    ),
                                                    SizedBox(height: size.height * 0.015,),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Place', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.black87),)),
                                                        holyOrder[index]['place'] != null && holyOrder[index]['place'] != '' ? Flexible(child: Text(holyOrder[index]['place'], style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: Colors.grey, fontStyle: FontStyle.italic),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                // Positioned(
                                                //   top: 0,
                                                //   right: 0,
                                                //   child: Container(
                                                //     alignment: Alignment.topRight,
                                                //     child: Row(
                                                //         children: [
                                                //           holyOrder[index]['state'].isNotEmpty && holyOrder[index]['state'] != null && holyOrder[index]['state'] != '' ? holyOrder[index]['state'] == 'Completed' ? Container(
                                                //             padding: const EdgeInsets.all(5),
                                                //             decoration: BoxDecoration(
                                                //               borderRadius: BorderRadius.circular(5),
                                                //               color: Colors.teal,
                                                //             ),
                                                //             child: Text('${holyOrder[index]['state']}',style: GoogleFonts.secularOne(color: Colors.white),),
                                                //           ) : Container(
                                                //             padding: const EdgeInsets.all(5),
                                                //             decoration: BoxDecoration(
                                                //                 borderRadius: BorderRadius.circular(5),
                                                //                 color: greenColor
                                                //             ),
                                                //             child: Text('${holyOrder[index]['state']}', style: GoogleFonts.secularOne(color: Colors.white),),
                                                //           ) : Container(),
                                                //         ]
                                                //     ),
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) : Center(
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
              child: SizedBox(
                height: 50,
                width: 180,
                child: textButton,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: userLevel != 'Diocesan Member' ? FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddHolyOrderScreen()));

          if(refresh == 'refresh') {
            changeData();
          }
        },
        backgroundColor: const Color(0xFFFF512F),
        child: const Icon(Icons.add),
      ) : Container(),
    );
  }
}
