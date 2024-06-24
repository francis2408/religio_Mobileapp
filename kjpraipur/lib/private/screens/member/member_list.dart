import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/slide_animations.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'members/member.dart';
import 'members_details.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({Key? key}) : super(key: key);

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  late ScrollController _controller;
  int page = 0;
  int limit = 20;

  bool _showContainer = false;
  Timer? _containerTimer;
  bool _isLoading = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  String membersCount = '';

  List data = [];
  List membersListData = [];
  List members = [];

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
      var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('id','!=',$memberId)]&fields=['full_name','image_1920','role_ids','mobile']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final List fetchedPosts = json.decode(await response.stream.bytesToString())['data'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            members.addAll(fetchedPosts);
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

  void getMembersData() async {
    setState(() {
      _isLoading = true;
    });

    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('id','!=',$memberId)]&fields=['full_name','image_1920','role_ids','mobile']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = json.decode(await response.stream.bytesToString())['data'];
      members = data;
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

  void getMembersListData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('id','!=',$memberId)]&fields=['full_name','image_1920','role_ids','mobile']&context={"bypass":1}&limit=500&offset=0&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      membersListData = json.decode(await response.stream.bytesToString())['data'];
      membersCount = membersListData.length.toString();
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
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      getMembersData();
    });
  }

  assignValues(indexValue, indexName) async {
    id = indexValue;
    name = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => userRole == 'Member' ? const MemberScreen () : const MembersDetailsTabBarScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  Future<void> smsAction(String number) async {
    final Uri uri = Uri(scheme: "sms", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Can not launch url";
    }
  }

  Future<void> whatsappAction(String whatsapp) async {
    // Remove any non-digit characters from the phone number
    final cleanNumber = whatsapp.replaceAll(RegExp(r'\D'), '');
    // Extract the country code from the WhatsApp number
    const countryCode = '91'; // Assuming country code length is 2
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    if (Platform.isAndroid) {
      final whatsappUrl = 'whatsapp://send?phone=$formattedNumber';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    } else {
      final whatsappUrl = 'https://api.whatsapp.com/send?phone=$formattedNumber';
      await canLaunch(whatsappUrl) ? launch(whatsappUrl) : throw "Can not launch URL";
    }
  }

  searchData(String searchWord) {
    List results = [];
    if (searchWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = data;
    } else {
      results = membersListData
          .where((user) =>
          user['full_name'].toLowerCase().contains(searchWord.toLowerCase())).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState((){
      members = results;
    });
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      getMembersData();
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
    getMembersListData();
    loadDataWithDelay();
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
      appBar: AppBar(
        title: const Text('Members'),
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
          ) : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
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
                    onChanged: (value) {
                      setState(() {
                        searchData(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: size.height * 0.02, fontStyle: FontStyle.italic),
                      suffixIcon: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)), color: tabBackColor),child: const Icon(Icons.search,  color: tabLabelColor,)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(width: 1, color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: tabBackColor,
                          width: 1.0,
                        ),
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
                    const Text('Total Count :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 3,),
                    Text(membersCount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),)
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                members.isNotEmpty ? Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(15),
                    thickness: 8,
                    child: SlideFadeAnimation(
                      duration: const Duration(seconds: 1),
                      child: ListView.builder(
                        controller: _controller,
                        itemCount: members.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                int indexValue;
                                String indexName = '';
                                indexValue = members[index]['id'];
                                indexName = members[index]['full_name'];
                                assignValues(indexValue, indexName);
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      height: size.height * 0.11,
                                      width: size.width * 0.18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.grey,
                                            spreadRadius: -1,
                                            blurRadius: 5 ,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: members[index]['image_1920'] != null && members[index]['image_1920'] != '' ? NetworkImage(members[index]['image_1920'])
                                              : const AssetImage('assets/images/profile.png') as ImageProvider,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 15, right: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    members[index]['full_name'].toUpperCase(),
                                                    style: GoogleFonts.secularOne(
                                                      fontSize: size.height * 0.022,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: size.height * 0.005,),
                                            Row(
                                              children: [
                                                members[index]['role_ids_name'] != null && members[index]['role_ids_name'] != '' ? Flexible(
                                                  child: Text(
                                                    members[index]['role_ids_name'],
                                                    style: TextStyle(
                                                      letterSpacing: 0.5,
                                                      fontSize: size.height * 0.017,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black54,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.visible,
                                                  ),
                                                ) : Flexible(
                                                  child: Text(
                                                    'No role assigned',
                                                    style: TextStyle(
                                                      letterSpacing: 0.5,
                                                      fontSize: size.height * 0.017,
                                                      // fontWeight: FontWeight.bold,
                                                      color: Colors.grey,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  (members[index]['mobile']).split(',')[0].trim(),
                                                  style: TextStyle(
                                                    fontSize: size.height * 0.02,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                      onPressed: () {
                                                        (members[index]['mobile']).split(',').length != 1 ? showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              contentPadding: const EdgeInsets.all(10),
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      ListTile(
                                                                        title: Text(
                                                                          (members[index]['mobile']).split(',')[0].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          callAction((members[index]['mobile']).split(',')[0].trim());
                                                                        },
                                                                      ),
                                                                      const Divider(),
                                                                      ListTile(
                                                                        title: Text(
                                                                          (members[index]['mobile']).split(',')[1].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          callAction((members[index]['mobile']).split(',')[1].trim());
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ) : callAction((members[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.phone),
                                                      color: Colors.blueAccent,
                                                    ),
                                                    if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                      onPressed: () {
                                                        (members[index]['mobile']).split(',').length != 1 ? showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              contentPadding: const EdgeInsets.all(10),
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      ListTile(
                                                                        title: Text(
                                                                          (members[index]['mobile']).split(',')[0].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          smsAction((members[index]['mobile']).split(',')[0].trim());
                                                                        },
                                                                      ),
                                                                      const Divider(),
                                                                      ListTile(
                                                                        title: Text(
                                                                          (members[index]['mobile']).split(',')[1].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          smsAction((members[index]['mobile']).split(',')[1].trim());
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ) : smsAction((members[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: const Icon(Icons.message),
                                                      color: Colors.orange,
                                                    ),
                                                    if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                      onPressed: () {
                                                        (members[index]['mobile']).split(',').length != 1 ? showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              contentPadding: const EdgeInsets.all(10),
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      ListTile(
                                                                        title: Text(
                                                                          (members[index]['mobile']).split(',')[0].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                                        },
                                                                      ),
                                                                      const Divider(),
                                                                      ListTile(
                                                                        title: Text(
                                                                          (members[index]['mobile']).split(',')[1].trim(),
                                                                          style: const TextStyle(color: Colors.blueAccent),
                                                                        ),
                                                                        onTap: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                          whatsappAction((members[index]['mobile']).split(',')[1].trim());
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ) : whatsappAction((members[index]['mobile']).split(',')[0].trim());
                                                      },
                                                      icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: Colors.green, height: 20, width: 20,),
                                                      color: Colors.green,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
                ) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
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
                    )
                  ],
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
          )
      ),
    );
  }
}
