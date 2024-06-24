import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scb/private/screens/member/publication/add_publication.dart';
import 'package:scb/private/screens/member/publication/edit_publication.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/common/internet_connection_checker.dart';
import 'package:scb/widget/common/slide_animations.dart';
import 'package:scb/widget/common/snackbar.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';

class MembersPublicationScreen extends StatefulWidget {
  const MembersPublicationScreen({Key? key}) : super(key: key);

  @override
  State<MembersPublicationScreen> createState() => _MembersPublicationScreenState();
}

class _MembersPublicationScreenState extends State<MembersPublicationScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;
  int selected = -1;
  List publicationData = [];
  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberPublicationData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.publication?domain=[('member_id','=',$id)]&fields=['publication_date','title','publisher','royalty','publication_type_id']&order=publication_date desc"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      publicationData = data;
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
      getMemberPublicationData();
    });
  }

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/res.publication?ids=[$publicationId]'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        Navigator.pop(context);
        Navigator.pop(context);
        changeData();
        AnimatedSnackBar.show(
            context,
            'Publication data deleted successfully.',
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
    // Check the internet connection
    internetCheck();
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getMemberPublicationData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberPublicationData();
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
          ) : publicationData.isNotEmpty ? Container(
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
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            key: Key('builder ${selected.toString()}'),
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: publicationData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int indexValue;
                                    indexValue = publicationData[index]['id'];
                                    publicationId = indexValue;
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
                                                  message: 'Are you sure want to delete the publication data ?',
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
                                              MaterialPageRoute(builder: (context) => const EditPublicationScreen()));
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
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Title', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            publicationData[index]['title'] != '' && publicationData[index]['title'] != null ? Text(publicationData[index]['title'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          children: [
                                            Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Type', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            publicationData[index]['publication_type_id'] != [] && publicationData[index]['publication_type_id'].isNotEmpty ? Text(publicationData[index]['publication_type_id'][1], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Publication Date', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            publicationData[index]['publication_date'] != null && publicationData[index]['publication_date'] != '' ? Text(DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(publicationData[index]['publication_date'])), style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          children: [
                                            Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Publisher', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            publicationData[index]['publisher'] != null && publicationData[index]['publisher'] != '' ? Text("${publicationData[index]['publisher']}", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                        SizedBox(height: size.height * 0.015,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: size.width * 0.23, alignment: Alignment.topLeft, child: Text('Royalty', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                            SizedBox(width: size.width * 0.02,),
                                            publicationData[index]['royalty']  != '' && publicationData[index]['royalty']  != null ? Flexible(child: Text('${publicationData[index]['royalty'] }', style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),)) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                          ],
                                        ),
                                      ],
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
      floatingActionButton: publicationData.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPublicationScreen()));
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
              MaterialPageRoute(builder: (context) => const AddPublicationScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
