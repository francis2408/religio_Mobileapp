import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/common/slide_animations.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'members_details.dart';
import 'profile/member_profile_details.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({Key? key}) : super(key: key);

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
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
  String membersCount = '';
  String limitCount = '';
  String searchName = '';
  var searchController = TextEditingController();

  List data = [];
  List membersListData = [];
  List members = [];
  List results = [];

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
      var request;
      if(memberSelectedTab == "All") {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId)]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
      } else if(memberSelectedTab == 'Sister') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
      } else if(memberSelectedTab == 'Junior Sister') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Junior Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
      } else if(memberSelectedTab == 'Novice') {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Novice')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
      } else {
        request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Retired Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var result = json.decode(await response.stream.bytesToString());
        final List fetchedPosts = result['data'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            members.addAll(fetchedPosts);
            limitCount = members.length.toString();
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
    var request;
    if(memberSelectedTab == "All") {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId)]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    } else if(memberSelectedTab == 'Sister') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    } else if(memberSelectedTab == 'Junior Sister') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Junior Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    } else if(memberSelectedTab == 'Novice') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Novice')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    } else {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Retired Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=$limit&offset=$page&order=name asc"""));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      membersCount = result['total_count'].toString();
      data = result['data'];
      members = data;
      limitCount = members.length.toString();
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

  Future<void> getMembersListData() async {
    var request;
    if(memberSelectedTab == "All") {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId)]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=500&order=name asc"""));
    } else if(memberSelectedTab == 'Sister') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=500&order=name asc"""));
    } else if(memberSelectedTab == 'Junior Sister') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Junior Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=500&order=name asc"""));
    } else if(memberSelectedTab == 'Novice') {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Novice')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=500&order=name asc"""));
    } else {
      request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('rel_province_id','=',$userProvinceId),('member_type','=','Retired Sister')]&fields=['full_name','image_512','role_ids','mobile','member_type','community_id']&context={"bypass":1}&limit=500&order=name asc"""));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      membersListData = result['data'];
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
      members.clear();
      results.clear();
      isSearchTrue = false;
      page = 0;
      _hasNextPage = true;
      getMembersData();
      _controller = ScrollController()..addListener(_loadMore);
    });
  }

  assignValues(indexValue, indexName) async {
    id = indexValue;
    name = indexName;

    if(id == memberId) {
      userMember = '';
      String refresh = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MemberProfileTabbarScreen()));

      if(refresh == 'refresh') {
        changeData();
      }
    } else {
      userMember = 'Member';
      String refresh = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MembersDetailsTabBarScreen()));

      if(refresh == 'refresh') {
        changeData();
      }
    }
  }

  Future<void> smsAction(String number) async {
    const countryCode = '+91'; // Indian country code
    // Remove any non-digit characters from the phone number
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    final Uri uri = Uri(scheme: "sms", path: formattedNumber);
    if(!await launchUrl(uri, mode: LaunchMode.externalApplication,)) {
      throw "Can not launch url";
    }
  }

  Future<void> callAction(String number) async {
    const countryCode = '+91'; // Indian country code
    // Remove any non-digit characters from the phone number
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    // Add the country code if it's missing
    final formattedNumber = cleanNumber.startsWith(countryCode)
        ? cleanNumber
        : countryCode + cleanNumber;
    final Uri uri = Uri(scheme: 'tel', path: formattedNumber);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Can not launch URL';
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

  searchData(String searchWord) async {
    var values = [];
    if (searchWord.isEmpty) {
      setState(() {
        results = [];
        isSearchTrue = false;
      });
    } else {
      // await getMembersListData(searchWord); // Wait for data to be fetched
      values = membersListData
          .where((user) =>
          user['full_name'].toLowerCase().contains(searchWord.toLowerCase()))
          .toList();

      setState(() {
        results = values; // Update the results list with filtered data
      });
    }
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 1), () {
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
    userMember = 'Member';
    if(expiryDateTime!.isAfter(currentDateTime)) {
      loadDataWithDelay();
      getMembersListData();
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            loadDataWithDelay();
            getMembersListData();
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
    userMember = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
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
                      results.isNotEmpty ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Showing 1 - ${results.length} of $membersCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ],
                      ) : Container(),
                      results.isNotEmpty ? SizedBox(
                        height: size.height * 0.01,
                      ) : Container(),
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
                                    int indexValue;
                                    String indexName = '';
                                    indexValue = results[index]['id'];
                                    indexName = results[index]['full_name'];
                                    assignValues(indexValue, indexName);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                                                        child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: size.height * 0.11,
                                                  width: size.width * 0.18,
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
                                                          : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                                                              results[index]['full_name'],
                                                              style: GoogleFonts.secularOne(
                                                                  letterSpacing: 1,
                                                                  fontSize: size.height * 0.018,
                                                                  color: textColor
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.005,
                                                      ),
                                                      Row(
                                                        children: [
                                                          results[index]['role_ids_name'] != null && results[index]['role_ids_name'] != '' ? Flexible(
                                                            child: Text(
                                                              results[index]['role_ids_name'],
                                                              style: TextStyle(
                                                                letterSpacing: 0.5,
                                                                fontSize: size.height * 0.017,
                                                                color: labelColor,
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
                                                                color: emptyColor,
                                                                fontStyle: FontStyle.italic,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.005,
                                                      ),
                                                      Row(
                                                        children: [
                                                          results[index]['community_id'].isNotEmpty && results[index]['community_id'] != [] && results[index]['community_id'] != '' ? Flexible(
                                                            child: Text(
                                                              results[index]['community_id'][1],
                                                              style: TextStyle(
                                                                fontSize: size.height * 0.017,
                                                                color: valueColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.visible,
                                                            ),
                                                          ) : Container(),
                                                        ],
                                                      ),
                                                      results[index]['mobile'] != '' && results[index]['mobile'] != null ? Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                (results[index]['mobile'] as String).split(',')[0].trim(),
                                                                style: TextStyle(
                                                                  color: mobileText,
                                                                  fontSize: size.height * 0.02,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  if(results[index]['mobile'] != null && results[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (results[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (results[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        callAction((results[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (results[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        callAction((results[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : callAction((results[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: const Icon(Icons.phone),
                                                                    color: callColor,
                                                                  ),
                                                                  if (results[index]['mobile'] != null && results[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (results[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (results[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        smsAction((results[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (results[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        smsAction((results[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : smsAction((results[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: const Icon(Icons.message),
                                                                    color: smsColor,
                                                                  ),
                                                                  if (results[index]['mobile'] != null && results[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (results[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (results[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        whatsappAction((results[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (results[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        whatsappAction((results[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : whatsappAction((results[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                    color: whatsAppColor,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: size.height * 0.01,
                                          right: size.width * 0.025,
                                          child: Container(
                                            height: size.height * 0.03,
                                            width: size.width * 0.07,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: results[index]['member_type'] == 'Sister' ? Colors.green : results[index]['member_type'] == 'Retired Sister' ? Colors.redAccent : results[index]['member_type'] == 'Novice' ? Colors.indigo : Colors.pinkAccent,
                                            ),
                                            child: results[index]['member_type'] == 'Sister' ? Text('S',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ) : results[index]['member_type'] == 'Retired Sister' ? Text('R',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ) : results[index]['member_type'] == 'Novice' ? Text('N',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ) : Text('JS',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
                            Navigator.pop(context, 'refresh');
                          });
                        },
                        text: 'No Data available',
                      ),
                    ),
                  ) : Column(
                    children: [
                      members.isNotEmpty ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Showing 1 - $limitCount of $membersCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: countLabel),),
                        ],
                      ) : Container(),
                      members.isNotEmpty ? SizedBox(
                        height: size.height * 0.01,
                      ) : Container(),
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
                                return GestureDetector(
                                  onTap: () {
                                    int indexValue;
                                    String indexName = '';
                                    indexValue = members[index]['id'];
                                    indexName = members[index]['full_name'];
                                    assignValues(indexValue, indexName);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  members[index]['image_512'] != '' ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.network(members[index]['image_512'], fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  ) : showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Dialog(
                                                        child: Image.asset('assets/images/profile.png', fit: BoxFit.cover,),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: size.height * 0.11,
                                                  width: size.width * 0.18,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: <BoxShadow>[
                                                      if(members[index]['image_512'] != null && members[index]['image_512'] != '') const BoxShadow(
                                                        color: Colors.grey,
                                                        spreadRadius: -1,
                                                        blurRadius: 5 ,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: members[index]['image_512'] != null && members[index]['image_512'] != ''
                                                          ? NetworkImage(members[index]['image_512'])
                                                          : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                                                              members[index]['full_name'],
                                                              style: GoogleFonts.secularOne(
                                                                  // letterSpacing: 0.5,
                                                                  fontSize: size.height * 0.018,
                                                                  color: textColor
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.005,
                                                      ),
                                                      Row(
                                                        children: [
                                                          members[index]['role_ids_name'] != null && members[index]['role_ids_name'] != '' ? Flexible(
                                                            child: Text(
                                                              members[index]['role_ids_name'],
                                                              style: TextStyle(
                                                                // letterSpacing: 0.5,
                                                                fontSize: size.height * 0.017,
                                                                color: labelColor,
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
                                                                color: emptyColor,
                                                                fontStyle: FontStyle.italic,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height * 0.008,
                                                      ),
                                                      Row(
                                                        children: [
                                                          members[index]['community_id'].isNotEmpty && members[index]['community_id'] != [] && members[index]['community_id'] != '' ? Flexible(
                                                            child: Text(
                                                              members[index]['community_id'][1],
                                                              style: TextStyle(
                                                                fontSize: size.height * 0.017,
                                                                color: valueColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.visible,
                                                            ),
                                                          ) : Container(),
                                                        ],
                                                      ),
                                                      members[index]['mobile'] != '' && members[index]['mobile'] != null ? Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                (members[index]['mobile'] as String)
                                                                    .split(',')[0]
                                                                    .trim(),
                                                                style: TextStyle(
                                                                  color: mobileText,
                                                                  fontSize: size.height * 0.02,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  if(members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (members[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (members[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        callAction((members[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (members[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        callAction((members[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : callAction((members[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: const Icon(Icons.phone),
                                                                    color: callColor,
                                                                  ),
                                                                  if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (members[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (members[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        smsAction((members[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (members[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        smsAction((members[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : smsAction((members[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: const Icon(Icons.message),
                                                                    color: smsColor,
                                                                  ),
                                                                  if (members[index]['mobile'] != null && members[index]['mobile'] != '') IconButton(
                                                                    onPressed: () {
                                                                      (members[index]['mobile'] as String).split(',').length != 1 ? showDialog(
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
                                                                                        (members[index]['mobile'] as String).split(',')[0].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        whatsappAction((members[index]['mobile'] as String).split(',')[0].trim());
                                                                                      },
                                                                                    ),
                                                                                    const Divider(),
                                                                                    ListTile(
                                                                                      title: Text(
                                                                                        (members[index]['mobile'] as String).split(',')[1].trim(),
                                                                                        style: const TextStyle(color: mobileText),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.pop(context); // Close the dialog
                                                                                        whatsappAction((members[index]['mobile'] as String).split(',')[1].trim());
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ) : whatsappAction((members[index]['mobile'] as String).split(',')[0].trim());
                                                                    },
                                                                    icon: SvgPicture.asset('assets/icons/whatsapp.svg', color: whatsAppColor, height: 20, width: 20,),
                                                                    color: whatsAppColor,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: size.height * 0.01,
                                          right: size.width * 0.025,
                                          child: Container(
                                            height: size.height * 0.03,
                                            width: size.width * 0.07,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: members[index]['member_type'] == 'Sister' ? Colors.green : members[index]['member_type'] == 'Retired Sister' ? Colors.redAccent : members[index]['member_type'] == 'Novice' ? Colors.indigo : Colors.pinkAccent,
                                            ),
                                            child: members[index]['member_type'] == 'Sister' ? Text('S',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ) : members[index]['member_type'] == 'Retired Sister' ? Text('R',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ) : members[index]['member_type'] == 'Novice' ? Text('N',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ) : Text('JS',
                                              style: GoogleFonts.heebo(
                                                  fontSize: size.height * 0.022,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
                                padding: const EdgeInsets.only(left: 30, right: 30),
                                child: NoResult(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context, 'refresh');
                                    });
                                  },
                                  text: 'No Data available',
                                ),
                              ),
                            )
                          ],
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
                )
              ],
            ),
          )
      ),
    );
  }
}
