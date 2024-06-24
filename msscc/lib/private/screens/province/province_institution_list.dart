import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:msscc/private/screens/institution/other_institution_details.dart';
import 'package:msscc/private/screens/institution/other_institution_members_list.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/common/internet_connection_checker.dart';
import 'package:msscc/widget/common/slide_animations.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

class ProvinceInstitutionListScreen extends StatefulWidget {
  const ProvinceInstitutionListScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceInstitutionListScreen> createState() => _ProvinceInstitutionListScreenState();
}

class _ProvinceInstitutionListScreenState extends State<ProvinceInstitutionListScreen> {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late ScrollController _controller;
  final bool _canPop = false;
  int page = 0;
  int limit = 20;

  bool _showContainer = false;
  Timer? _containerTimer;
  bool _isLoading = true;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _isSearch = false;
  bool isSearchTrue = false;
  String institutionCount = '';
  String limitCount = '';
  String searchName = '';
  var searchController = TextEditingController();

  List data = [];
  List institutionListData = [];
  List institutionData = [];
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
      var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution?domain=[('rel_province_id','=',$userProvinceId),('is_abroad','=',False),('is_other_diocese','=',False)]&fields=['name','image_512','superior_id','ministry_category_id','members_count']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final List fetchedPosts = json.decode(await response.stream.bytesToString())['data'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            institutionData.addAll(fetchedPosts);
            limitCount = institutionData.length.toString();
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

  void getInstitutionData() async {
    setState(() {
      _isLoading = true;
    });

    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution?domain=[('rel_province_id','=',$userProvinceId),('is_abroad','=',False),('is_other_diocese','=',False)]&fields=['name','image_512','superior_id','ministry_category_id','members_count']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      institutionCount = result['total_count'].toString();
      data = result['data'];
      institutionData = data;
      limitCount = institutionData.length.toString();
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

  Future<void> getInstitutionListData(String searchWord) async {
    searchName = searchWord;
    setState(() {
      _isSearch = true;
    });
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution?domain=[('name','ilike','$searchName'),('rel_province_id','=',$userProvinceId),('is_abroad','=',False),('is_other_diocese','=',False)]&fields=['name','image_512','superior_id','ministry_category_id','members_count']&context={"bypass":1}&limit=500&offset=0&order=name asc"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      institutionListData = result['data'];
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
      await getInstitutionListData(searchWord); // Wait for data to be fetched
      values = institutionListData
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
      institutionData.clear();
      results.clear();
      isSearchTrue = false;
      page = 0;
      _hasNextPage = true;
      getInstitutionData();
      _controller = ScrollController()..addListener(_loadMore);
    });
  }

  assignValues(indexValue, indexName) async {
    instituteID = indexValue;
    instituteName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherInstitutionDetailsScreen()));

    if(refresh == 'refresh') {
      changeData();
    }
  }

  institutionMembers(indexValue, indexName) async {
    instituteID = indexValue;
    instituteName = indexName;

    String refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OtherInstitutionMembersListScreen()));

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
      getInstitutionData();
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
    return WillPopScope(
      onWillPop: () async {
        if(_canPop) {
          Navigator.pop(context, 'refresh');
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Institution'),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, 'refresh');
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
          ),
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
                                  ? const Icon(Icons.clear, color: redColor)
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
                                  color: backgroundColor,
                                ),
                                child: const Icon(Icons.search, color: whiteColor),
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
                            Text('Showing 1 - ${results.length} of $institutionCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
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
                                      assignValues(indexValue,indexName);
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
                                                results[index]['image_512'] != '' ? showDialog(
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
                                                      child: Image.asset('assets/images/institution.png', fit: BoxFit.cover,),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: size.height * 0.08,
                                                width: size.width * 0.2,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: <BoxShadow>[
                                                    if(results[index]['image_512'] != null && results[index]['image_512'] != '') const BoxShadow(
                                                      color: Colors.grey,
                                                      spreadRadius: -1,
                                                      blurRadius: 5 ,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: results[index]['image_512'] != null && results[index]['image_512'] != ''
                                                        ? NetworkImage(results[index]['image_512'])
                                                        : const AssetImage('assets/images/institution.png') as ImageProvider,
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
                                                              fontSize: size.height * 0.019,
                                                              color: textHeadColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    results[index]['ministry_category_id'].isNotEmpty && results[index]['ministry_category_id'] != [] ? SizedBox(
                                                      height: size.height * 0.01,
                                                    ) : Container(),
                                                    Row(
                                                      children: [
                                                        results[index]['ministry_category_id'].isNotEmpty && results[index]['ministry_category_id'] != [] ? Flexible(
                                                          child: Text(
                                                            results[index]['ministry_category_id'][1],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.017,
                                                              color: valueColor,
                                                            ),
                                                          ),
                                                        ) : Container(),
                                                      ],
                                                    ),
                                                    results[index]['superior_id'].isNotEmpty && results[index]['superior_id'] != [] ? SizedBox(
                                                      height: size.height * 0.01,
                                                    ) : Container(),
                                                    Row(
                                                      children: [
                                                        results[index]['superior_id'].isNotEmpty && results[index]['superior_id'] != [] ? Flexible(
                                                          child: Text(
                                                            results[index]['superior_id'][1],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.017,
                                                              color: emptyColor,
                                                            ),
                                                          ),
                                                        ) : Container(),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: size.height * 0.01,
                                                    ),
                                                    Row(
                                                      children: [
                                                        results[index]['members_count'] != '' && results[index]['members_count'] != null && institutionData[index]['members_count'] != 0 ? GestureDetector(
                                                          onTap: () {
                                                            int indexValue;
                                                            String indexName;
                                                            indexValue = results[index]['id'];
                                                            indexName = results[index]['name'];
                                                            institutionMembers(indexValue, indexName);
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
                                                                      fontSize: size.height * 0.014,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor2,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                  children: <InlineSpan>[
                                                                    results[index]['members_count'] == 1 ? TextSpan(
                                                                      text: ' Member',
                                                                      style: TextStyle(
                                                                          letterSpacing: 1,
                                                                          fontSize: size.height * 0.014,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: customTextColor2,
                                                                          fontStyle: FontStyle.italic
                                                                      ),
                                                                    ) : TextSpan(
                                                                      text: ' Members',
                                                                      style: TextStyle(
                                                                          letterSpacing: 1,
                                                                          fontSize: size.height * 0.014,
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
                            Text('Showing 1 - $limitCount of $institutionCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        institutionData.isNotEmpty ? Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            interactive: true,
                            radius: const Radius.circular(15),
                            thickness: 8,
                            child: SlideFadeAnimation(
                              duration: const Duration(seconds: 1),
                              child: ListView.builder(
                                controller: _controller,
                                itemCount: institutionData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      indexValue = institutionData[index]['id'];
                                      indexName = institutionData[index]['name'];
                                      assignValues(indexValue,indexName);
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
                                                institutionData[index]['image_512'] != '' ? showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.network(institutionData[index]['image_512'], fit: BoxFit.cover,),
                                                    );
                                                  },
                                                ) : showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Image.asset('assets/images/institution.png', fit: BoxFit.cover,),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: size.height * 0.08,
                                                width: size.width * 0.2,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: <BoxShadow>[
                                                    if(institutionData[index]['image_512'] != null && institutionData[index]['image_512'] != '') const BoxShadow(
                                                      color: Colors.grey,
                                                      spreadRadius: -1,
                                                      blurRadius: 5 ,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: institutionData[index]['image_512'] != null && institutionData[index]['image_512'] != ''
                                                        ? NetworkImage(institutionData[index]['image_512'])
                                                        : const AssetImage('assets/images/institution.png') as ImageProvider,
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
                                                            institutionData[index]['name'],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.019,
                                                              color: textHeadColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    institutionData[index]['superior_name'] != null && institutionData[index]['superior_name'] != '' ? SizedBox(
                                                      height: size.height * 0.01,
                                                    ) : Container(),
                                                    Row(
                                                      children: [
                                                        institutionData[index]['superior_name'] != null && institutionData[index]['superior_name'] != '' ? Flexible(
                                                          child: Text(
                                                            institutionData[index]['superior_name'],
                                                            style: TextStyle(
                                                              fontSize: size.height * 0.017,
                                                              color: labelColor2,
                                                            ),
                                                          ),
                                                        ) : Container(),
                                                      ],
                                                    ),
                                                    institutionData[index]['ministry_category_id'].isNotEmpty && institutionData[index]['ministry_category_id'] != [] ? SizedBox(
                                                      height: size.height * 0.01,
                                                    ) : Container(),
                                                    Row(
                                                      children: [
                                                        institutionData[index]['ministry_category_id'].isNotEmpty && institutionData[index]['ministry_category_id'] != [] ? Flexible(
                                                          child: Text(
                                                            institutionData[index]['ministry_category_id'][1],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.017,
                                                              color: valueColor,
                                                            ),
                                                          ),
                                                        ) : Container(),
                                                      ],
                                                    ),
                                                    institutionData[index]['superior_id'].isNotEmpty && institutionData[index]['superior_id'] != [] ? SizedBox(
                                                      height: size.height * 0.01,
                                                    ) : Container(),
                                                    Row(
                                                      children: [
                                                        institutionData[index]['superior_id'].isNotEmpty && institutionData[index]['superior_id'] != [] ? Flexible(
                                                          child: Text(
                                                            institutionData[index]['superior_id'][1],
                                                            style: GoogleFonts.secularOne(
                                                              fontSize: size.height * 0.017,
                                                              color: emptyColor,
                                                            ),
                                                          ),
                                                        ) : Container(),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: size.height * 0.01,
                                                    ),
                                                    Row(
                                                      children: [
                                                        institutionData[index]['members_count'] != '' && institutionData[index]['members_count'] != null && institutionData[index]['members_count'] != 0 ? GestureDetector(
                                                          onTap: () {
                                                            int indexValue;
                                                            String indexName;
                                                            indexValue = institutionData[index]['id'];
                                                            indexName = institutionData[index]['name'];
                                                            institutionMembers(indexValue, indexName);
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
                                                              color: customBackgroundColor2,
                                                            ),
                                                            child: RichText(
                                                              text: TextSpan(
                                                                  text: institutionData[index]['members_count'].toString(),
                                                                  style: TextStyle(
                                                                      letterSpacing: 1,
                                                                      fontSize: size.height * 0.014,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: customTextColor2,
                                                                      fontStyle: FontStyle.italic
                                                                  ),
                                                                  children: <InlineSpan>[
                                                                    institutionData[index]['members_count'] == 1 ? TextSpan(
                                                                      text: ' Member',
                                                                      style: TextStyle(
                                                                          letterSpacing: 1,
                                                                          fontSize: size.height * 0.014,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: customTextColor2,
                                                                          fontStyle: FontStyle.italic
                                                                      ),
                                                                    ) : TextSpan(
                                                                      text: ' Members',
                                                                      style: TextStyle(
                                                                          letterSpacing: 1,
                                                                          fontSize: size.height * 0.014,
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
      ),
    );
  }
}
