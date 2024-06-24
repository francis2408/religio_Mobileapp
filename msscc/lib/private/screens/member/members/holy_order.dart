import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:msscc/private/screens/member/holy_order/add_holy_order.dart';
import 'package:msscc/private/screens/member/holy_order/edit_holy_order.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/common/snackbar.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

class MembersHolyOrderScreen extends StatefulWidget {
  const MembersHolyOrderScreen({Key? key}) : super(key: key);

  @override
  State<MembersHolyOrderScreen> createState() => _MembersHolyOrderScreenState();
}

class _MembersHolyOrderScreenState extends State<MembersHolyOrderScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;
  List holyOrder = [];
  int selected = -1;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getHolyOrderData() async {
    String holyUrl = "$baseUrl/search_read/res.holyorder?domain=[('member_id','=',$id)]&fields=['id','date','place','order','minister']&order=date desc";
    var request = http.Request('GET', Uri.parse(holyUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      holyOrder = data;
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

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.holyorder?ids=[$holyOrderId]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        Navigator.pop(context);
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Holy order data deleted successfully.',
            Colors.green
        );
      });
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
    // Check Internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
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
          child: _isLoading ? Center(
            child: Container(
                height: size.height * 0.1,
                width: size.width * 0.2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage( "assets/alert/spinner_1.gif"),
                  ),
                )
            ),
          ) : holyOrder.isNotEmpty ? Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
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
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          key: Key('builder ${selected.toString()}'),
                          shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: holyOrder.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  int indexValue;
                                  indexValue = holyOrder[index]['id'];
                                  holyOrderId = indexValue;
                                  // Bottom Sheet
                                  Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
                                    return CustomBottomSheet(
                                      size: size, // Pass the 'size' variable
                                      onDeletePressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmAlertDialog(
                                                message: 'Are you sure want to delete the holy order data ?',
                                                onCancelPressed: () {
                                                  cancel();
                                                },
                                                onYesPressed: () {
                                                  if(load) {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext context) {
                                                        return const CustomLoadingDialog();
                                                      },
                                                    );
                                                    delete();
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        });
                                      },
                                      onEditPressed: () async {
                                        Navigator.pop(context);
                                        String refresh = await Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => const EditHolyOrderScreen()));
                                        if(refresh == 'refresh') {
                                          changeData();
                                        }
                                      },
                                    );
                                  });
                                });
                              },
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
                                              holyOrder[index]['date'].isNotEmpty && holyOrder[index]['date'] != null && holyOrder[index]['date'] != '' ? Text(DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(holyOrder[index]['date'])),
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
          ) : Center(
            child: Container(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: NoResult(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                text: 'No Data available',
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: holyOrder.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddHolyOrderScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ) : ConditionalFloatingActionButton(
        isEmpty: false,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddHolyOrderScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
