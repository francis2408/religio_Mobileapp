import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/common/snackbar.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'circular_details.dart';

class CircularScreen extends StatefulWidget {
  const CircularScreen({Key? key}) : super(key: key);

  @override
  State<CircularScreen> createState() => _CircularScreenState();
}

class _CircularScreenState extends State<CircularScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late ScrollController _controller;
  int page = 0;
  int limit = 20;

  bool _showContainer = false;
  Timer? _containerTimer;
  bool _isLoading = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  String limitCount = '';
  String circularCount = '';

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

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isLoading == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 500) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      // Cancel the previous timer if it exists
      _containerTimer?.cancel();
      page += limit;
      var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/cristo.circular?domain=[('news_letter','!=','True')]&fields=['id','name','month','year','upload','type','content','theme','member_id']&context={"bypass":1}&limit=$limit&offset=$page"""));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var result = json.decode(await response.stream.bytesToString());
        final List fetchedPosts = result['data'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            circular.addAll(fetchedPosts);
            limitCount = circular.length.toString();
          });
        } else {
          setState(() {
            _hasNextPage = false;
            _showContainer = true;
          });
          // Start the timer to auto-close the container after 2 seconds
          _containerTimer = Timer(const Duration(seconds: 2), () {
            setState(() {
              _showContainer = false;
            });
          });
        }
      } else {
        var message = json.decode(await response.stream.bytesToString())['message'];
        setState(() {
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
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  void getCircularData() async {
    setState(() {
      _isLoading = true;
    });
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/cristo.circular?domain=[('news_letter','!=','True')]&fields=['id','name','month','year','upload','type','content','theme','member_id']&context={"bypass":1}&limit=$limit&offset=$page"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      circularCount = result['total_count'].toString();
      List data = result['data'];
      circular = data;
      limitCount = circular.length.toString();
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
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

    setState(() {
      _isLoading = false;
    });
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
  //     File saveFile = File("${directory.path}/$fileName.pdf");
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

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getCircularData();
      _controller = ScrollController()..addListener(_loadMore);
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
      loadDataWithDelay();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            loadDataWithDelay();
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _containerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
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
                    Text('Showing 1 - $limitCount of $circularCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                  ],
                ),
                SizedBox(height: size.height * 0.01,),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: ListView.builder(
                        controller: _controller,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
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
                                GestureDetector(
                                  onTap: () {
                                    circularID = circular[index]['id'];
                                    circularName = circular[index]['name'];
                                    setState(() {
                                      Navigator.of(context).push(CustomRoute(widget: const CircularDetailsScreen()));
                                    });
                                  },
                                  child: Card(
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
                                          circular[index]['theme'] != '' && circular[index]['theme'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                          circular[index]['theme'] != '' && circular[index]['theme'] != null ? Text("${circular[index]['theme']}", style: GoogleFonts.signika(fontSize: size.height * 0.02, color: orangeColor), textAlign: TextAlign.justify,) : Container(),
                                          SizedBox(height: size.height * 0.01,),
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
                                          ) : circular[index]['type'] == '' ? Row(
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
                                              // Bottom sheet
                                              showModalBottomSheet<void>(
                                                context: context,
                                                backgroundColor: screenBackgroundColor,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                ),
                                                builder: (BuildContext context) {
                                                  return CustomContentBottomSheet(
                                                      size: size,
                                                      title: "Content",
                                                      content: circular[index]['content']
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    circular[index]['content'].replaceAll(exp, ''),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
                                                  ),
                                                ),
                                                SizedBox(width: size.width * 0.01,),
                                                const Text('More', style: TextStyle(
                                                    color: Colors.blue
                                                ),),
                                                SizedBox(width: size.width * 0.03,),
                                                const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 11,)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                                GestureDetector(
                                  onTap: () {
                                    circularID = circular[index]['id'];
                                    circularName = circular[index]['name'];
                                    setState(() {
                                      Navigator.of(context).push(CustomRoute(widget: const CircularDetailsScreen()));
                                    });
                                  },
                                  child: Card(
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
                                          circular[index]['theme'] != '' && circular[index]['theme'] != null ? SizedBox(height: size.height * 0.01,) : Container(),
                                          circular[index]['theme'] != '' && circular[index]['theme'] != null ? Text("${circular[index]['theme']}", style: GoogleFonts.signika(fontSize: size.height * 0.018, color: orangeColor), textAlign: TextAlign.justify,) : Container(),
                                          SizedBox(height: size.height * 0.01,),
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
                                          ) : circular[index]['type'] == '' ? Row(
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
                                              // Bottom sheet
                                              showModalBottomSheet<void>(
                                                context: context,
                                                backgroundColor: screenBackgroundColor,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                                ),
                                                builder: (BuildContext context) {
                                                  return CustomContentBottomSheet(
                                                      size: size,
                                                      title: "Content",
                                                      content: circular[index]['content']
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    circular[index]['content'].replaceAll(exp, ''),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: size.height * 0.018,color: labelColor),
                                                  ),
                                                ),
                                                SizedBox(width: size.width * 0.01,),
                                                const Text('More', style: TextStyle(
                                                    color: Colors.blue
                                                ),),
                                                SizedBox(width: size.width * 0.03,),
                                                const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 11,)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                if (_isLoadMoreRunning == true)
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.width * 0.01),
                    child: Center(
                      child: Container(
                          height: size.height * 0.1,
                          width: size.width * 0.2,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage( "assets/alert/spinner_1.gif"),
                            ),
                          )
                      ),
                    ),
                  ),
                if (_hasNextPage == false)
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: _showContainer ? 40 : 0,
                    color: Colors.grey,
                    child: const Center(
                      child: Text('You have fetched all of the data'),
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
        title: const Text('View Circular'),
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
