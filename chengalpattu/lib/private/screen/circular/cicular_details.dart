import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CircularScreenDetails extends StatefulWidget {
  const CircularScreenDetails({Key? key}) : super(key: key);

  @override
  State<CircularScreenDetails> createState() => _CircularScreenDetailsState();
}

class _CircularScreenDetailsState extends State<CircularScreenDetails> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  DateTime currentDateTime = DateTime.now();
  bool _isLoading = true;
  List circular = [];
  String name = '';
  String upload = '';
  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  var path;

  getCircularData() async {
    String url = '$baseUrl/cristo.circular';
    Map data = {
      "params": {
        "filter": "[['id','=',$circularID]]",
        "query": "{id,name,member_id{member_name},month,year,upload,content}"
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
      List data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      circular = data;
      for(int i = 0; i < circular.length; i++) {
        name = circular[i]['name'];
      }
    }
    else {
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
        final file = File("${downloadDir!.path}/${fileName+upload}");

        await file.writeAsBytes(response.data);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Future<bool> saveVideo(String url, String fileName) async {
  //   Directory directory;
  //   try {
  //     if (Platform.isAndroid) {
  //       if (await _requestPermission(Permission.storage)) {
  //         // directory = (await getExternalStorageDirectory())!;
  //         directory = Directory('/storage/emulated/0/Download');
  //       } else {
  //         return false;
  //       }
  //     } else {
  //       if (await _requestPermission(Permission.photos)) {
  //         directory = await getTemporaryDirectory();
  //       } else {
  //         return false;
  //       }
  //     }
  //     File saveFile = File("${directory.path}/${fileName+upload}");
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
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
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
    bool downloaded = await fileSave(localPath, "$filename");
    if(downloaded) {
      setState(() {
        AnimatedSnackBar.material(
            'Document downloaded successfully',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 2)
        ).show(context);
      });
    } else {
      setState(() {
        AnimatedSnackBar.material(
            'Document could not downloaded',
            type: AnimatedSnackBarType.error,
            duration: const Duration(seconds: 2)
        ).show(context);
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
        title: Text(name),
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
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: _isLoading
                ? SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballPulse,
                colors: [Colors.red,Colors.orange,Colors.yellow],
              ),
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
                    child: AnimationLimiter(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: circular.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                                duration: const Duration(milliseconds: 380),
                                position: index,
                                child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Card(
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
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(circular[index]['member_id']['member_name'],
                                                      style: GoogleFonts.sansita(fontSize: size.height * 0.021, color: Colors.blue),
                                                    ),
                                                  ),
                                                  RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(
                                                        text: circular[index]['month_label'],
                                                        style: GoogleFonts.sansita(fontSize: size.height * 0.02, color: textColor),
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
                                              circular[index]['content'].replaceAll(exp, '') != null && circular[index]['content'].replaceAll(exp, '') != '' ? SizedBox(
                                                height: size.height * 0.015,
                                              ) : Container(),
                                              circular[index]['content'].replaceAll(exp, '') != null && circular[index]['content'].replaceAll(exp, '') != '' ? Padding(
                                                padding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
                                                child: Html(
                                                  data: circular[index]['content'],
                                                  style: {
                                                    'html': Style(
                                                      fontSize: FontSize(size.height * 0.02),
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
                                                          filename = path.split("/").last;
                                                          Navigator.of(context).push(CustomRoute(widget: PDFViewerCachedFromUrl(url: localPath)));
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
                                                            filename = path.split("/").last;
                                                            upload = '.${circular[index]['upload_type']}';
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
                                      ),
                                    )
                                )
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
              style: const TextStyle(
                color: Colors.white,
                // fontWeight: FontWeight.bold,
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