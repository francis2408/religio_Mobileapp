import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/private/screen/circular/cicular_details.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/quickalert.dart';

class CircularScreen extends StatefulWidget {
  const CircularScreen({Key? key}) : super(key: key);

  @override
  State<CircularScreen> createState() => _CircularScreenState();
}

class _CircularScreenState extends State<CircularScreen> with TickerProviderStateMixin {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  bool _isLoading = true;
  List data = [];
  List circular = [];
  List circularListData = [];
  int selected = -1;
  String upload = '';
  var searchController = TextEditingController();

  RegExp exp = RegExp(r"<[^>]*>",multiLine: true,caseSensitive: true);

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  var path;

  getCircularData() async {
    String url = '$baseUrl/cristo.circular';
    Map datas = {
      "params": {
        "order": "year desc, month desc",
        "query": "{id,name,month,year,upload,content}"
      }
    };
    var body = jsonEncode(datas);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if (response.statusCode == 200) {
      data = json.decode(response.body)['result']['data']['result'];
      setState(() {
        _isLoading = false;
      });
      circular = data;
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

  searchData(String searchWord) {
    List results = [];
    if(searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = data
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      circular = results;
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
          if(value) {
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
        title: const Text('Circular'),
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                getCircularData();
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
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
            ) : Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchName = value;
                        searchData(searchName);
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchData(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: backgroundColor,
                        fontSize: size.height * 0.02,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (searchName.isNotEmpty) {
                                setState(() {
                                  searchController.clear();
                                  searchName = '';
                                  searchData(searchName);
                                });
                              }
                            },
                            child: searchName.isNotEmpty && searchName != ''
                                ? const Icon(Icons.clear, color: backgroundColor)
                                : Container(),
                          ),
                          SizedBox(width: size.width * 0.01),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                searchData(searchName);
                              });
                            },
                            child: Container(
                              height: size.height * 0.055,
                              width: size.width * 0.11,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: Color(0xFFd9f1fc),
                              ),
                              child: const Icon(Icons.search, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(width: 1, color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.01,),
                    Text('${circular.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(height: size.height * 0.01,),
                circular.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: AnimationLimiter(
                      child: ListView.builder(
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
                            return AnimationConfiguration.staggeredList(
                                duration: const Duration(milliseconds: 380),
                                position: index,
                                child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
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
                                          GestureDetector(
                                            onTap: () {
                                              int indexValue = circular[index]['id'];
                                              circularID = indexValue;
                                              setState(() {
                                                Navigator.of(context).push(CustomRoute(widget: const CircularScreenDetails()));
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
                                                            circular[index]['month_label'],
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
                                                    circular[index]['upload'].isNotEmpty && circular[index]['upload'] != '' ? Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () {
                                                              // Check Internet connection
                                                              internetCheck();
                                                              localPath = circular[index]['upload'];
                                                              File file = File(localPath);
                                                              path = file.path;
                                                              filename = path.split("/").last;
                                                              upload = '.${circular[index]['upload_type']}';
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
                                                              // Check Internet connection
                                                              internetCheck();
                                                              localPath = circular[index]['upload'];
                                                              File file = File(localPath);
                                                              path = file.path;
                                                              filename = path.split("/").last;
                                                              Navigator.of(context).push(CustomRoute(widget: PDFViewerCachedFromUrl(url: localPath)));
                                                            },
                                                            child: const Icon(
                                                              Icons.remove_red_eye,
                                                              color: Colors.orangeAccent,
                                                            )
                                                        ),
                                                      ],
                                                    ) : Container(),
                                                    circular[index]['content'].replaceAll(exp, '').isNotEmpty && circular[index]['content'].replaceAll(exp, '') != '' ? GestureDetector(
                                                      onTap: () {
                                                        int indexValue = circular[index]['id'];
                                                        circularID = indexValue;
                                                        setState(() {
                                                          Navigator.of(context).push(CustomRoute(widget: const CircularScreenDetails()));
                                                        });
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
                                                    ) : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01,),
                                        ],
                                      ),
                                    )
                                )
                            );
                          } else {
                            return AnimationConfiguration.staggeredList(
                                duration: const Duration(milliseconds: 380),
                                position: index,
                                child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              int indexValue = circular[index]['id'];
                                              circularID = indexValue;
                                              setState(() {
                                                Navigator.of(context).push(CustomRoute(widget: const CircularScreenDetails()));
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
                                                            circular[index]['month_label'],
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
                                                    circular[index]['upload'].isNotEmpty && circular[index]['upload'] != '' ? Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () {
                                                              // Check Internet connection
                                                              internetCheck();
                                                              localPath = circular[index]['upload'];
                                                              File file = File(localPath);
                                                              path = file.path;
                                                              filename = path.split("/").last;
                                                              upload = '.${circular[index]['upload_type']}';
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
                                                              // Check Internet connection
                                                              internetCheck();
                                                              localPath = circular[index]['upload'];
                                                              File file = File(localPath);
                                                              path = file.path;
                                                              filename = path.split("/").last;
                                                              Navigator.of(context).push(CustomRoute(widget: PDFViewerCachedFromUrl(url: localPath)));
                                                            },
                                                            child: const Icon(
                                                              Icons.remove_red_eye,
                                                              color: Colors.orangeAccent,
                                                            )
                                                        ),
                                                      ],
                                                   ) : Container(),
                                                    circular[index]['content'].replaceAll(exp, '').isNotEmpty && circular[index]['content'].replaceAll(exp, '') != '' ? GestureDetector(
                                                      onTap: () {
                                                        int indexValue = circular[index]['id'];
                                                        circularID = indexValue;
                                                        setState(() {
                                                          Navigator.of(context).push(CustomRoute(widget: const CircularScreenDetails()));
                                                        });
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
                                                    ) : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01,),
                                        ],
                                      ),
                                    )
                                )
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ) : Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                          child: SizedBox(
                            height: 45,
                            width: 150,
                            child: textButton,
                          ),
                        ),
                      )
                    ],
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