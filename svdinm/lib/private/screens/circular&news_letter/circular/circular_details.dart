import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:svdinm/widget/common/common.dart';
import 'package:svdinm/widget/common/internet_connection_checker.dart';
import 'package:svdinm/widget/common/slide_animations.dart';
import 'package:svdinm/widget/common/snackbar.dart';
import 'package:svdinm/widget/theme_color/theme_color.dart';
import 'package:svdinm/widget/widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CircularDetailsScreen extends StatefulWidget {
  const CircularDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CircularDetailsScreen> createState() => _CircularDetailsScreenState();
}

class _CircularDetailsScreenState extends State<CircularDetailsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List circular = [];

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  var path;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getCircularData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/cristo.circular?domain=[('id','=',$circularID)]&fields=['id','name','month','year','upload','type','content','theme','member_id']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
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

  // Future<bool> fileSave(String url, String fileName) async {
  //   Directory directory;
  //   try {
  //     if (Platform.isAndroid) {
  //       if (await _requestPermission(Permission.manageExternalStorage)) {
  //         directory = (await getExternalStorageDirectory())!;
  //       } else {
  //         return false; // Permission not granted, return false immediately.
  //       }
  //     } else {
  //       if (await _requestPermission(Permission.storage)) {
  //         directory = await getTemporaryDirectory();
  //       } else {
  //         return false; // Permission not granted, return false immediately.
  //       }
  //     }
  //     File saveFile = File("${directory.path}/$fileName");
  //     if (!await directory.exists()) directory = (await getExternalStorageDirectory())!;
  //     if (await directory.exists()) {
  //       await dio.download(url, saveFile.path,
  //           onReceiveProgress: (value1, value2) {
  //             setState(() {
  //               progress = value1 / value2;
  //             });
  //           });
  //       if (Platform.isIOS) {
  //         await ImageGallerySaver.saveFile(saveFile.path,
  //             isReturnPathOfIOS: true);
  //       }
  //       return true; // File downloaded successfully.
  //     }
  //     return false; // Directory doesn't exist.
  //   } catch (e) {
  //     return false; // Exception occurred.
  //   }
  // }
  //
  // Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     var result = await permission.request();
  //     if (result == PermissionStatus.granted) {
  //       return true;
  //     } else if (result == PermissionStatus.denied) {
  //       await OpenAppSettings.openAppSettings();
  //       print("Permission denied. Opened app settings.");
  //     }
  //   }
  //   return false;
  // }

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
    // Check the internet connection
    internetCheck();
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getCircularData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getCircularData();
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
        title: Text(circularName),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
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
            ) : Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: circular.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            circular[index]['name'],
                                            style: GoogleFonts.secularOne(color: Colors.black, fontSize: size.height * 0.022),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.005,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(circular[index]['member_id'][1],
                                            style: GoogleFonts.signika(fontSize: size.height * 0.021, color: Colors.blue),
                                          ),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                              text: circular[index]['month_label'],
                                              style: GoogleFonts.signika(fontSize: size.height * 0.02, color: textColor),
                                              children: [
                                                const TextSpan(
                                                  text: '  ',
                                                ),
                                                TextSpan(
                                                  text: circular[index]['year'],
                                                  style: GoogleFonts.sansita(fontSize: size.height * 0.02, color: Colors.black),
                                                ),
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                    circular[index]['theme'] != null && circular[index]['theme'] != '' ? SizedBox(height: size.height * 0.005,) : Container(),
                                    circular[index]['theme'] != null && circular[index]['theme'] != '' ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            circular[index]['theme'],
                                            style: GoogleFonts.secularOne(color: orangeColor, fontSize: size.height * 0.02),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ],
                                    ) : Container(),
                                    circular[index]['content'].replaceAll(exp, '') != null && circular[index]['content'].replaceAll(exp, '') != '' ? SizedBox(
                                      height: size.height * 0.015,
                                    ) : Container(),
                                    circular[index]['content'].replaceAll(exp, '') != null && circular[index]['content'].replaceAll(exp, '') != '' ? Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
                                      child: Html(
                                        data: circular[index]['content'],
                                        style: {
                                          'html': Style(
                                            textAlign: TextAlign.justify,
                                          ),
                                        },
                                      ),
                                    ) : Container(),
                                    circular[index]['upload'].isNotEmpty && circular[index]['upload'] != '' ? SizedBox(
                                      height: size.height * 0.015,
                                    ) : Container(),
                                    circular[index]['upload'].isNotEmpty && circular[index]['upload'] != '' ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: size.height * 0.045,
                                          width: size.width * 0.35,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Colors.blueAccent
                                          ),
                                          child: TextButton(
                                              onPressed: () {
                                                localPath = circular[index]['upload'];
                                                File file = File(localPath);
                                                path = file.path;
                                                fileName = path.split("/").last;
                                                Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => PDFViewerCachedFromUrl(url: localPath,),),);
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.remove_red_eye, color: Colors.white,),
                                                  SizedBox(width: size.width * 0.03,),
                                                  Text('View', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),),
                                                ],
                                              )
                                          ),
                                        ),
                                        Container(
                                            height: size.height * 0.045,
                                            width: size.width * 0.35,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Colors.orange,
                                            ),
                                            child: TextButton(
                                                onPressed: () {
                                                  localPath = circular[index]['upload'];
                                                  File file = File(localPath);
                                                  path = file.path;
                                                  fileName = path.split("/").last;
                                                  downloadFile();
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.cloud_download, color: Colors.white,),
                                                    SizedBox(width: size.width * 0.03,),
                                                    Text('Download', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),),
                                                  ],
                                                )
                                            )
                                        ),
                                      ],
                                    ) : Container(),
                                  ],
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
        ),
      ),
      floatingActionButton: loading
          ? FloatingActionButton(
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
        title: Text(circularName),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
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
