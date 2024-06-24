import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/common/slide_animations.dart';
import 'package:lasad/widget/common/snackbar.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/internet_checker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lasad/widget/widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CircularScreen extends StatefulWidget {
  const CircularScreen({Key? key}) : super(key: key);

  @override
  State<CircularScreen> createState() => _CircularScreenState();
}

class _CircularScreenState extends State<CircularScreen> with TickerProviderStateMixin {
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  List circular = [];
  int selected = -1;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  var path;

  getCircularData() async {
      var request = http.Request('GET', Uri.parse("$baseUrl/circular/province/$userProvinceId"));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      circular = data;

      // for(int j = 0; j < circular.length; j++) {
      //   localPath = circular[j]['upload'];
      //   File file = File(localPath);
      //   path = file.path;
      //   filename = path.split("/").last;
      //   month = DateFormat('MMMM').format(DateTime(0, 9));
      // }
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

  fileSave(String url, String fileName) async {
    final dio = Dio();
    try {
      final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (value1, value2) {
            setState(() {
              progress = value1 / value2;
            });
          });

      if(response.statusCode == 200) {
        Directory? downloadDir;
        if (Platform.isAndroid) {
          downloadDir = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          downloadDir = await getApplicationDocumentsDirectory();
        } else {
          // Handle other platforms if necessary
          return false;
        }
        final file = File("${downloadDir!.path}/$fileName.pdf");

        await file.writeAsBytes(response.data);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await fileSave(localPath, "$fileName");
    if (downloaded) {
      setState(() {
        AnimatedSnackBar.show(
            context,
            'Document downloaded successfully',
            Colors.green
        );
      });
    } else {
      setState(() {
        AnimatedSnackBar.show(
            context,
            'Document could not downloaded',
            Colors.red
        );
      });
    }
    setState(() {
      loading = false;
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
    // Check Internet connection
    internetCheck();
    super.initState();
    getCircularData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Circular'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: _isLoading ? SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ) : circular.isEmpty ? Center(
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: NoResult(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ),
            ) : Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.01,),
                    Text('${circular.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(height: size.height * 0.01,),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    controller: _secondController,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: circular.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool isSameDate = true;
                        final String dateString = circular[index]['year'];
                        final DateTime date = DateFormat('yyyy').parse(dateString);
                        if (index == 0) {
                          isSameDate = false;
                        } else {
                          final String prevDateString = circular[index - 1]['year'];
                          final DateTime prevDate = DateFormat('yyyy').parse(prevDateString);
                          if(date == prevDate) {
                            isSameDate = true;
                          } else {
                            isSameDate = false;
                          }
                        }
                        if (!(isSameDate)) {
                          return SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.grey),
                                          height: 2,
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.025,),
                                      Text(
                                        date.formatDate(),
                                        style: const TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(width: size.width * 0.025,),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.grey),
                                          height: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.topRight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(child: Container(padding: const EdgeInsets.only(right: 10),child: Text("${circular[index]['name']}", style: GoogleFonts.roboto(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.black),)),),
                                              Text(
                                                DateFormat('MMMM').format(DateTime(DateTime.now().year, int.parse(circular[index]['month']))),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.01,),
                                        circular[index]['member_id'].isNotEmpty && circular[index]['member_id'] != [] ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(child: Text("${circular[index]['member_id'][1]}", style: TextStyle(fontSize: size.height * 0.016, fontWeight: FontWeight.bold, color: textColor),)),
                                            circular[index]['upload'].isNotEmpty && circular[index]['upload'] != '' ? Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      localPath = circular[index]['upload'];
                                                      File file = File(localPath);
                                                      path = file.path;
                                                      filename = path.split("/").last;
                                                      downloadFile();
                                                    },
                                                    child: const Icon(
                                                      Icons.cloud_download,
                                                      color: Colors.blue,
                                                    )
                                                ),
                                                SizedBox(width: size.width * 0.03,),
                                                GestureDetector(
                                                    onTap: () {
                                                      localPath = circular[index]['upload'];
                                                      File file = File(localPath);
                                                      path = file.path;
                                                      filename = path.split("/").last;
                                                      Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerCachedFromUrl(url: localPath,),),);
                                                    },
                                                    child: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Colors.orangeAccent,
                                                    )
                                                ),
                                              ],
                                            ) : Container(),
                                          ],
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01,),
                              ],
                            ),
                          );
                        } else {
                          return SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.topRight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(child: Container(padding: const EdgeInsets.only(right: 10),child: Text("${circular[index]['name']}", style: GoogleFonts.roboto(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.black),)),),
                                              Text(
                                                DateFormat('MMMM').format(DateTime(DateTime.now().year, int.parse(circular[index]['month']))),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.01,),
                                        circular[index]['member_id'].isNotEmpty && circular[index]['member_id'] != [] ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(child: Text("${circular[index]['member_id'][1]}", style: TextStyle(fontSize: size.height * 0.016, fontWeight: FontWeight.bold, color: textColor),)),
                                            circular[index]['upload'].isNotEmpty && circular[index]['upload'] != '' ? Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      localPath = circular[index]['upload'];
                                                      File file = File(localPath);
                                                      path = file.path;
                                                      filename = path.split("/").last;
                                                      downloadFile();
                                                    },
                                                    child: const Icon(
                                                      Icons.cloud_download,
                                                      color: Colors.blue,
                                                    )
                                                ),
                                                SizedBox(width: size.width * 0.03,),
                                                GestureDetector(
                                                    onTap: () {
                                                      localPath = circular[index]['upload'];
                                                      File file = File(localPath);
                                                      path = file.path;
                                                      filename = path.split("/").last;
                                                      Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerCachedFromUrl(url: localPath,),),);
                                                    },
                                                    child: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Colors.orangeAccent,
                                                    )
                                                ),
                                              ],
                                            ) : Container(),
                                          ],
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01,),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: loading ? FloatingActionButton(
        backgroundColor: backgroundColor,
        onPressed: null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: size.height * 0.016
              ),
            ),
          ],
        ),
      ) : Container(),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Circular'),
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}

const String dateFormatter = 'yyyy';

extension DateHelper on DateTime {

  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }
  bool isSameDate(DateTime other) {
    return year == other.year;
  }
}
