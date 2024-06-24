import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CircularScreen extends StatefulWidget {
  const CircularScreen({Key? key}) : super(key: key);

  @override
  State<CircularScreen> createState() => _CircularScreenState();
}

class _CircularScreenState extends State<CircularScreen> {
  final ScrollController _secondController = ScrollController();
  bool _isLoading = true;
  List circular = [];
  int selected = -1;

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  var path;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getCircularData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/call/cristo.circular/api_get_year_month_wise_circular"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data']['month_data'];
      setState(() {
        _isLoading = false;
      });
      circular = data;
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

  Future<bool> saveVideo(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          // directory = (await getExternalStorageDirectory())!;
          directory = Directory('/storage/emulated/0/Download');
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File("${directory.path}/$fileName");
      if (!await directory.exists()) directory = (await getExternalStorageDirectory())!;
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
              setState(() {
                progress = value1 / value2;
              });
            });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded = await saveVideo(localPath, "$fileName");
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
    // Check the internet connection
    // internetCheck();
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
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
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
            ) : circular.isEmpty
                ? Center(
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
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
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
                            return Column(
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
                                        circular[index]['member_id'] != '' && circular[index]['member_id'] != null ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(child: Text("${circular[index]['member_id']}", style: TextStyle(fontSize: size.height * 0.016, fontWeight: FontWeight.bold, color: textColor),)),
                                            circular[index]['type'] == 'upload' ? Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      localPath = circular[index]['upload'];
                                                      File file = File(localPath);
                                                      path = file.path;
                                                      fileName = path.split("/").last;
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
                                                      fileName = path.split("/").last;
                                                      Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerCachedFromUrl(url: localPath,),),);
                                                    },
                                                    child: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Colors.orangeAccent,
                                                    )
                                                ),
                                              ],
                                            ) : GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Card(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15)
                                                      ),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(10),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                                IconButton(
                                                                  icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: size.height * 0.01,
                                                            ),
                                                            Html(
                                                              data: circular[index]['content'],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                  alignment: Alignment.topRight,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      const Text('More', style: TextStyle(
                                                          color: Colors.blue
                                                      ),),
                                                      SizedBox(width: size.width * 0.03,),
                                                      const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 11,)
                                                    ],
                                                  )
                                              ),
                                            ),
                                          ],
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01,),
                              ],
                            );
                          } else {
                            return Column(
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
                                        circular[index]['member_id'] != '' && circular[index]['member_id'] != null ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(child: Text("${circular[index]['member_id']}", style: TextStyle(fontSize: size.height * 0.016, fontWeight: FontWeight.bold, color: textColor),)),
                                            circular[index]['type'] == 'upload' ? Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      localPath = circular[index]['upload'];
                                                      File file = File(localPath);
                                                      path = file.path;
                                                      fileName = path.split("/").last;
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
                                                      fileName = path.split("/").last;
                                                      Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerCachedFromUrl(url: localPath,),),);
                                                    },
                                                    child: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Colors.orangeAccent,
                                                    )
                                                ),
                                              ],
                                            ) : GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Card(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15)
                                                      ),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(10),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text("Content", style: GoogleFonts.signika(fontSize: size.height * 0.025, color: backgroundColor),),
                                                                IconButton(
                                                                  icon: const Icon(Icons.close, color: Colors.redAccent,),
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: size.height * 0.01,
                                                            ),
                                                            Html(
                                                              data: circular[index]['content'],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                  alignment: Alignment.topRight,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      const Text('More', style: TextStyle(
                                                          color: Colors.blue
                                                      ),),
                                                      SizedBox(width: size.width * 0.03,),
                                                      const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 11,)
                                                    ],
                                                  )
                                              ),
                                            ),
                                          ],
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01,),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        floatingActionButton: loading ? FloatingActionButton(
          backgroundColor: iconBackColor,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ) : Container()
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
        centerTitle: true,
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

