import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/common/internet_connection_checker.dart';
import 'package:nagpur/widget/common/slide_animations.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

import 'other_house_details.dart';
import 'other_house_institution_list.dart';
import 'other_house_members_list.dart';

class OtherHouseListScreen extends StatefulWidget {
  const OtherHouseListScreen({Key? key}) : super(key: key);

  @override
  State<OtherHouseListScreen> createState() => _OtherHouseListScreenState();
}

class _OtherHouseListScreenState extends State<OtherHouseListScreen> {
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
  bool _isSearch = false;
  bool isSearchTrue = false;
  String houseCount = '';
  String limitCount = '';
  String searchName = '';
  var searchController = TextEditingController();

  List data = [];
  List houseListData = [];
  List houseData = [];
  List results = [];
  int? indexValue;
  String indexName = '';

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
      var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.community?domain=[('id','!=',$userCommunityId),('rel_province_id','=',$userProvinceId),('is_abroad','=',False),('is_other_diocese','=',False)]&fields=['image_512','name','superior_id','ministry_ids','members_count','institution_count']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final List fetchedPosts = json.decode(await response.stream.bytesToString())['data'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            houseData.addAll(fetchedPosts);
            limitCount = houseData.length.toString();
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

  void getHouseData() async {
    setState(() {
      _isLoading = true;
    });

    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.community?domain=[('id','!=',$userCommunityId),('rel_province_id','=',$userProvinceId),('is_abroad','=',False),('is_other_diocese','=',False)]&fields=['image_512','name','superior_id','ministry_ids','members_count','institution_count']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      houseCount = result['total_count'].toString();
      data = result['data'];
      houseData = data;
      limitCount = houseData.length.toString();
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

  Future<void> getHouseListData(String searchWord) async {
    searchName = searchWord;
    setState(() {
      _isSearch = true;
    });
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.community?domain=[('name','ilike','$searchName'),('id','!=',$userCommunityId),('rel_province_id','=',$userProvinceId),('is_abroad','=',False),('is_other_diocese','=',False)]&fields=['image_512','name','superior_id','ministry_ids','members_count','institution_count']&context={"bypass":1}&limit=500&offset=0&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      houseListData = result['data'];
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
      _isSearch = false;
    });
  }

  searchData(String searchWord) async {
    var values = [];
    if (searchWord.isEmpty) {
      setState(() {
        results = [];
        isSearchTrue = false;
      });
    } else {
      await getHouseListData(searchWord); // Wait for data to be fetched
      values = houseListData
          .where((user) =>
          user['name'].toLowerCase().contains(searchWord.toLowerCase()))
          .toList();

      setState(() {
        results = values; // Update the results list with filtered data
      });
    }
  }

  void changeData() {
    setState(() {
      _isLoading = true;
      houseData.clear();
      results.clear();
      isSearchTrue = false;
      page = 0;
      _hasNextPage = true;
      getHouseData();
      _controller = ScrollController()..addListener(_loadMore);
    });
  }

  assignValues(indexValue, indexName) async {
    houseID = indexValue;
    houseName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherHouseDetailsScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  assignMembersValues(indexValue, indexName) async {
    houseID = indexValue;
    houseName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherHouseMembersListScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  assignInstitutionValues(indexValue, indexName) async {
    houseID = indexValue;
    houseName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherHouseInstitutionListScreen()));

    if(refresh == 'refresh') {
      changeData();
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

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      getHouseData();
      _controller = ScrollController()..addListener(_loadMore);
    });
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
          ) : Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
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
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchName = value;
                        isSearchTrue = value.isNotEmpty;
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
                        color: Colors.grey,
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
                                color: menuThirdColor,
                              ),
                              child: const Icon(Icons.search, color: menuPrimaryColor),
                            ),
                          ),
                        ],
                      ),
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
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: _isSearch ? Center(
                    child: Container(
                        height: size.height * 0.1,
                        width: size.width * 0.2,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage( "assets/alert/spinner_1.gif"),
                          ),
                        )
                    ),
                  ) : isSearchTrue ? results.isNotEmpty ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Showing 1 - ${results.length} of $houseCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          radius: const Radius.circular(15),
                          thickness: 8,
                          child: SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    indexValue = results[index]['id'];
                                    indexName = results[index]['name'];
                                    assignValues(indexValue, indexName);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              results[index]['image_512'] != '' && results[index]['image_512'] != null ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(results[index]['image_512'], fit: BoxFit.cover,),
                                                  );
                                                },
                                              ) : showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/images/community.png', fit: BoxFit.cover),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: size.height * 0.08,
                                              width: size.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.fitHeight,
                                                  image: results[index]['image_512'] != null && results[index]['image_512'] != ''
                                                      ? NetworkImage(results[index]['image_512'])
                                                      : const AssetImage('assets/images/community.png') as ImageProvider,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 15, right: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          results[index]['name'],
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.02,
                                                            color: textHeadColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  results[index]['ministry_ids_name'] != '' && results[index]['ministry_ids_name'] != null ? SizedBox(
                                                    height: size.height * 0.01,
                                                  ) : Container(),
                                                  Row(
                                                    children: [
                                                      results[index]['ministry_ids_name'] != '' && results[index]['ministry_ids_name'] != null ? Flexible(
                                                        child: Text(
                                                          results[index]['ministry_ids_name'],
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.018,
                                                            color: valueColor,
                                                          ),
                                                        ),
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                  results[index]['superior_id'].isNotEmpty && results[index]['superior_id'] != null ? SizedBox(
                                                    height: size.height * 0.01,
                                                  ) : Container(),
                                                  results[index]['superior_id'].isNotEmpty && results[index]['superior_id'] != null ? Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          results[index]['superior_id'][1],
                                                          style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.018,
                                                              color: emptyColor,
                                                              fontStyle: FontStyle.italic
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ) : Container(),
                                                  SizedBox(
                                                    height: size.height * 0.01,
                                                  ),
                                                  Row(
                                                    children: [
                                                      results[index]['members_count'] != '' && results[index]['members_count'] != null ? GestureDetector(
                                                        onTap: () {
                                                          indexValue = results[index]['id'];
                                                          indexName = results[index]['name'];
                                                          assignMembersValues(indexValue, indexName);
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: customBackgroundColor2,
                                                          ),
                                                          child: RichText(
                                                            text: TextSpan(
                                                                text: results[index]['members_count'].toString(),
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: customTextColor2,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                                children: <InlineSpan>[
                                                                  results[index]['members_count'] == 1 ? TextSpan(
                                                                    text: ' Member',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor2,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  ) : TextSpan(
                                                                    text: ' Members',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor2,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ) : Container(),
                                                      results[index]['members_count'] != '' && results[index]['members_count'] != null ? SizedBox(
                                                        width: size.width * 0.05,
                                                      ) : Container(),
                                                      results[index]['institution_count'] != '' && results[index]['institution_count'] != null ? GestureDetector(
                                                        onTap: () {
                                                          indexValue = results[index]['id'];
                                                          indexName = results[index]['name'];
                                                          assignInstitutionValues(indexValue, indexName);
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: customBackgroundColor1,
                                                          ),
                                                          child: RichText(
                                                            text: TextSpan(
                                                                text: results[index]['institution_count'].toString(),
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: customTextColor1,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                                children: <InlineSpan>[
                                                                  results[index]['institution_count'] == 1 ? TextSpan(
                                                                    text: ' Institution',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor1,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  ) : TextSpan(
                                                                    text: ' Institutions',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor1,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ) : Container(),
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
                      )
                    ],
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
                  ) : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Showing 1 - $limitCount of $houseCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      houseData.isNotEmpty ? Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          radius: const Radius.circular(15),
                          thickness: 8,
                          child: SlideFadeAnimation(
                            duration: const Duration(seconds: 1),
                            child: ListView.builder(
                              controller: _controller,
                              itemCount: houseData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    indexValue = houseData[index]['id'];
                                    indexName = houseData[index]['name'];
                                    assignValues(indexValue, indexName);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              houseData[index]['image_512'] != '' && houseData[index]['image_512'] != null ? showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.network(houseData[index]['image_512'], fit: BoxFit.cover,),
                                                  );
                                                },
                                              ) : showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: Image.asset('assets/images/community.png', fit: BoxFit.cover),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: size.height * 0.08,
                                              width: size.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                  fit: BoxFit.fitHeight,
                                                  image: houseData[index]['image_512'] != null && houseData[index]['image_512'] != ''
                                                      ? NetworkImage(houseData[index]['image_512'])
                                                      : const AssetImage('assets/images/community.png') as ImageProvider,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 15, right: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          houseData[index]['name'],
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.019,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  houseData[index]['ministry_ids_name'] != '' && houseData[index]['ministry_ids_name'] != null ? SizedBox(
                                                    height: size.height * 0.01,
                                                  ) : Container(),
                                                  Row(
                                                    children: [
                                                      houseData[index]['ministry_ids_name'] != '' && houseData[index]['ministry_ids_name'] != null ? Flexible(
                                                        child: Text(
                                                          houseData[index]['ministry_ids_name'],
                                                          style: GoogleFonts.secularOne(
                                                            fontSize: size.height * 0.018,
                                                            color: valueColor,
                                                          ),
                                                        ),
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                  houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != null ? SizedBox(
                                                    height: size.height * 0.01,
                                                  ) : Container(),
                                                  houseData[index]['superior_id'].isNotEmpty && houseData[index]['superior_id'] != null ? Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          houseData[index]['superior_id'][1],
                                                          style: TextStyle(
                                                              letterSpacing: 1,
                                                              fontSize: size.height * 0.018,
                                                              color: labelColor,
                                                              fontStyle: FontStyle.italic
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ) : Container(),
                                                  SizedBox(
                                                    height: size.height * 0.01,
                                                  ),
                                                  Row(
                                                    children: [
                                                      houseData[index]['members_count'] != '' && houseData[index]['members_count'] != null ? GestureDetector(
                                                        onTap: () {
                                                          indexValue = houseData[index]['id'];
                                                          indexName = houseData[index]['name'];
                                                          assignMembersValues(indexValue, indexName);
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: customBackgroundColor2,
                                                          ),
                                                          child: RichText(
                                                            text: TextSpan(
                                                                text: houseData[index]['members_count'].toString(),
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: customTextColor2,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                                children: <InlineSpan>[
                                                                  houseData[index]['members_count'] == 1 ? TextSpan(
                                                                    text: ' Member',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor2,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  ) : TextSpan(
                                                                    text: ' Members',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor2,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ) : Container(),
                                                      houseData[index]['members_count'] != '' && houseData[index]['members_count'] != null ? SizedBox(
                                                        width: size.width * 0.05,
                                                      ) : Container(),
                                                      houseData[index]['institution_count'] != '' && houseData[index]['institution_count'] != null ? GestureDetector(
                                                        onTap: () {
                                                          indexValue = houseData[index]['id'];
                                                          indexName = houseData[index]['name'];
                                                          assignInstitutionValues(indexValue, indexName);
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: customBackgroundColor1,
                                                          ),
                                                          child: RichText(
                                                            text: TextSpan(
                                                                text: houseData[index]['institution_count'].toString(),
                                                                style: TextStyle(
                                                                    letterSpacing: 1,
                                                                    fontSize: size.height * 0.015,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: customTextColor1,
                                                                    fontStyle: FontStyle.italic
                                                                ),
                                                                children: <InlineSpan>[
                                                                  houseData[index]['institution_count'] == 1 ? TextSpan(
                                                                    text: ' Institution',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor1,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  ) : TextSpan(
                                                                    text: ' Institutions',
                                                                    style: TextStyle(
                                                                        letterSpacing: 1,
                                                                        fontSize: size.height * 0.015,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: customTextColor1,
                                                                        fontStyle: FontStyle.italic
                                                                    ),
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ) : Container(),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
