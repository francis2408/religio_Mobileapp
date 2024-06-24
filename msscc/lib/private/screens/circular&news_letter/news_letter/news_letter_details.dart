import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/common/snackbar.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NewsLetterDetailsScreen extends StatefulWidget {
  const NewsLetterDetailsScreen({Key? key}) : super(key: key);

  @override
  State<NewsLetterDetailsScreen> createState() => _NewsLetterDetailsScreenState();
}

class _NewsLetterDetailsScreenState extends State<NewsLetterDetailsScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List newsLetter = [];

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  var path;

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getNewsLetterData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/cristo.circular?domain=[('id','=',$letterID)]&fields=['id','name','month','year','upload','type','content','theme','member_id']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      newsLetter = data;
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
      getNewsLetterData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getNewsLetterData();
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
        title: Text(letterName),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
              ),
              gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
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
                          itemCount: newsLetter.length,
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
                                            newsLetter[index]['name'],
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
                                          child: Text(newsLetter[index]['member_id'][1],
                                            style: GoogleFonts.signika(fontSize: size.height * 0.021, color: Colors.blue),
                                          ),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                              text: newsLetter[index]['month_label'],
                                              style: GoogleFonts.signika(fontSize: size.height * 0.02, color: textColor),
                                              children: [
                                                const TextSpan(
                                                  text: '  ',
                                                ),
                                                TextSpan(
                                                  text: newsLetter[index]['year'],
                                                  style: GoogleFonts.sansita(fontSize: size.height * 0.02, color: Colors.black),
                                                ),
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                    newsLetter[index]['theme'] != null && newsLetter[index]['theme'] != '' ? SizedBox(height: size.height * 0.005,) : Container(),
                                    newsLetter[index]['theme'] != null && newsLetter[index]['theme'] != '' ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            newsLetter[index]['theme'],
                                            style: GoogleFonts.secularOne(color: orangeColor, fontSize: size.height * 0.02),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ],
                                    ) : Container(),
                                    newsLetter[index]['content'].replaceAll(exp, '') != null && newsLetter[index]['content'].replaceAll(exp, '') != '' ? SizedBox(
                                      height: size.height * 0.015,
                                    ) : Container(),
                                    newsLetter[index]['content'].replaceAll(exp, '') != null && newsLetter[index]['content'].replaceAll(exp, '') != '' ? Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
                                      child: Html(
                                        data: newsLetter[index]['content'],
                                        style: {
                                          'html': Style(
                                            textAlign: TextAlign.justify,
                                          ),
                                        },
                                      ),
                                    ) : Container(),
                                    newsLetter[index]['upload'].isNotEmpty && newsLetter[index]['upload'] != '' ? SizedBox(
                                      height: size.height * 0.015,
                                    ) : Container(),
                                    newsLetter[index]['upload'].isNotEmpty && newsLetter[index]['upload'] != '' ? Row(
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
                                                localPath = newsLetter[index]['upload'];
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
                                                  localPath = newsLetter[index]['upload'];
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
        title: const Text('View News Letter'),
        centerTitle: true,
        backgroundColor: appBackgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            ),
          ),
        ),
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
