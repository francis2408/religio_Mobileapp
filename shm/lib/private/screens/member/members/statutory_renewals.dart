import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shm/private/screens/member/statutory_renewals/add_statutory.dart';
import 'package:shm/private/screens/member/statutory_renewals/edit_statutory.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/slide_animations.dart';
import 'package:shm/widget/common/snackbar.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

class MembersStatutoryRenewalsScreen extends StatefulWidget {
  const MembersStatutoryRenewalsScreen({Key? key}) : super(key: key);

  @override
  State<MembersStatutoryRenewalsScreen> createState() => _MembersStatutoryRenewalsScreenState();
}

class _MembersStatutoryRenewalsScreenState extends State<MembersStatutoryRenewalsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  bool load = true;
  int selected = -1;
  List statutoryData = [];
  final format = DateFormat("dd-MM-yyyy");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberStatutoryData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/member.statutory.renewals?domain=[('member_id','=',$id)]&fields=['no','document_type_id','valid_from','valid_to','agency','next_renewal','proof']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      statutoryData = data;
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
      getMemberStatutoryData();
    });
  }

  delete() async {
    var request = http.Request('DELETE', Uri.parse('$baseUrl/unlink/member.statutory.renewals?ids=[$statutoryId]'));
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
            'Statutory renewals data deleted successfully.',
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
      getMemberStatutoryData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberStatutoryData();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    field = '';
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
          ) : statutoryData.isNotEmpty ? Container(
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
                            itemCount: statutoryData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int indexValue;
                                    indexValue = statutoryData[index]['id'];
                                    statutoryId = indexValue;
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
                                                  message: 'Are you sure want to delete the statutory renewals data ?',
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
                                              MaterialPageRoute(builder: (context) => const EditStatutoryRenewalsScreen()));
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
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Document Name', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                statutoryData[index]['document_type_id'] != [] && statutoryData[index]['document_type_id'].isNotEmpty ? Text(statutoryData[index]['document_type_id'][1], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Document Number', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                statutoryData[index]['no'] != null && statutoryData[index]['no'] != '' ? Text(statutoryData[index]['no'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Agency', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                statutoryData[index]['agency'] != null && statutoryData[index]['agency'] != '' ? Text(statutoryData[index]['agency'], style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              children: [
                                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Validity', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                statutoryData[index]['valid_from'] != null && statutoryData[index]['valid_from'] != '' ? Row(
                                                  children: [
                                                    statutoryData[index]['valid_from'] != null && statutoryData[index]['valid_from'] != '' ? Text(DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(statutoryData[index]['valid_from'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : const Text(""),
                                                    SizedBox(width: size.width * 0.03,),
                                                    Text("-", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),),
                                                    SizedBox(width: size.width * 0.03,),
                                                    statutoryData[index]['valid_to'] != null && statutoryData[index]['valid_to'] != '' ? Text(
                                                      DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(statutoryData[index]['valid_to'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
                                                    ) : Text(
                                                      "Till Now", style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02,),
                                                    ),
                                                  ],
                                                ) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.015,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(width: size.width * 0.2, alignment: Alignment.topLeft, child: Text('Next Renewal', style: GoogleFonts.signika(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: labelColor),)),
                                                SizedBox(width: size.width * 0.02,),
                                                statutoryData[index]['next_renewal'] != '' && statutoryData[index]['next_renewal'] != null ? Text(DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(statutoryData[index]['next_renewal'])), style: GoogleFonts.secularOne(color: valueColor, fontSize: size.height * 0.02),) : Text("NA", style: GoogleFonts.secularOne(fontSize: size.height * 0.02, color: emptyColor, fontStyle: FontStyle.italic),),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: statutoryData[index]['proof'] != '' && statutoryData[index]['proof'] != null ? GestureDetector(
                                              onTap: () {
                                                localPath = statutoryData[index]['proof'];
                                                File file = File(localPath);
                                                var path = file.path;
                                                fileName = path.split("/").last;

                                                Map<String, String> queryParams = Uri.parse(fileName).queryParameters;
                                                // Extract the 'field' parameter
                                                field = queryParams['field'] ?? '';

                                                Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerUrl(url: localPath,),),);
                                              },
                                              child: const Icon(
                                                Icons.attach_file,
                                                color: menuPrimaryColor,
                                              )
                                          ) : Container(),
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
      floatingActionButton: statutoryData.isEmpty ? ConditionalFloatingActionButton(
        isEmpty: true,
        iconBackColor: iconBackColor, // Customize this color
        onPressed: () async {
          String refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddStatutoryRenewalsScreen()));
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
              MaterialPageRoute(builder: (context) => const AddStatutoryRenewalsScreen()));
          if(refresh == 'refresh') {
            changeData();
          }
        },
        child: const Icon(Icons.add, color: buttonIconColor,), // Customize the child widget here
      ),
    );
  }
}
