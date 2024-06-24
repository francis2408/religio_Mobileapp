import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/helper/helper_function.dart';
import 'package:chengai/private/screen/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local Server
// const baseUrl = 'http://192.168.1.129:2020/api';
// String db = 'chengai_diocese';
// Test Server
// const baseUrl = 'http://172.104.106.91:8267/api';
// String db = 'chengai_diocese_test';
// Live Server
const baseUrl = 'http://cdcs.net.in:8030/api';
String db = 'chengai_diocese_live';

String authToken = '';
String tokenExpire = '';
String userName = '';
String userEmail = '';
String userLevel = '';
String userImage = '';
String screenName = '';
String selectMenu = '';
var userDiocese;
var userMember;
var userDioceses;
var userMembers;
var userID;
var databaseName;
var membershipType;
var mshipType;
var navigation;

// App Versions
var curentVersion;
var latestVersion;
var updateAvailable;

// Read Notification Count
var unReadNotificationCount;
var unReadNewsCount;
var unReadEventCount;
var unReadCircularCount;

// Current Date Time
DateTime currentDateTime = DateTime.now();

// Token Expire Time
DateTime? expiryDateTime;

// Search Value
String searchName = '';

// Login
String loginName = '';
String loginPassword = '';
String deviceName = '';
String deviceToken = '';
bool? remember;

// Forgot Password
String loginUserName = '';
String loginUserEmail = '';

// Home
String userProfile = '';

// Vicariate
int? vicariateId;

// Parish
int? parishId;

// Calendar
int? eventId;

// Circular
int? circularID;
String localPath = '';
var filename;

// News
int? newsID;

// Notification
int? notificationId;
String notificationName = '';
int notificationCount = 0;

// Diocese
int? bishopID;
String feastDay = '';
String feastMonth = '';

// Seminarian
String seminarianTab = 'All';

// Celebration
var birthdayTab = 'Upcoming';
var ordinationTab = 'Upcoming';
var obituaryTab = 'Upcoming';

// Member
int? memberId;
String memberEmail = '';
String memberMobile = '';
String selectedTab = 'All';

// Education
int? educationId;

// Formation
int? formationId;

// Health
int? healthId;

// Family
int? familyId;

// Holy Order
int? holyOrderId;

// Bishop Speaks
int? speaksID;

// Institution
List dioceseInstitution = [];
var religiousInstitution;
var institutionTab;
var categoryName = 'All';
var categoryTypeName;
var mediumName = 'All';
List categoryTab = [];
List mediumTab = [];

// Colors
const backgroundColor = Color(0xFFFF512F);
// const backgroundColor = Color(0xFF3F51B5);
// const backgroundColor = Color(0xFFF5402D);
const screenBackgroundColor = Color(0xFFEEF1FC);
const greenColor = Colors.green;
const noDataColor = Color(0xFFE6A519);
const textColor = Color(0xFFF5402D);
const iconColor = Color(0xFFF5402D);
const disableColor = Color(0xFFF0F0F1);
const enableColor = Color(0xFFF5402D);
const inputColor = Color(0xFFF0F0F0);
const tabColor = Colors.redAccent;

// Tabbar Color
const tabBackColor = backgroundColor;
const tabLabelColor = Colors.white;
const tabBackgroundColor = Color(0xFFFAE0C5);
const unselectColor = Colors.black;


// TextButton
final textButton = TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: noDataColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  child: const Text(
      'No results found',
      style: TextStyle(fontSize: 16)
  ),
);

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute({required this.widget})
      : super(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      if (animation.status == AnimationStatus.reverse) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      } else {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      }
    },
  );
}

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    Key? key,
    required this.tabController,
    required this.tabs,
    required this.onTabTap,
  }) : super(key: key);

  final TabController tabController;
  final List<String> tabs;
  final Function(int) onTabTap;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tabBackgroundColor,
          borderRadius: BorderRadius.circular(25.0),
        ),
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.05),
        child: TabBar(
          controller: widget.tabController,
          indicator: BoxDecoration(
            color: tabBackColor, // Define tabBackColor elsewhere in your code
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: tabBackColor.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          labelColor: tabLabelColor, // Define tabLabelColor elsewhere in your code
          unselectedLabelColor: unselectColor, // Define unselectColor elsewhere in your code
          tabs: widget.tabs.map((tabText) => Tab(text: tabText)).toList(),
          onTap: (index) {
            widget.onTabTap(index);
          },
        ),
      ),
    );
  }
}

class LoginService {
  void login(BuildContext context, String username, String password, String database, {VoidCallback? callback}) async {
    String url = '$baseUrl/auth/token';
    Map data = {
      "params": {'login': username, 'password': password, 'db': database}
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
      if(data['status_code'] == 200) {
        HelperFunctions.setDatabaseNameSF(database);
        HelperFunctions.setUserLoginSF(data['status']);
        HelperFunctions.setAuthTokenSF(data['access_token']);
        String dateStr = "${data['expires']}";
        DateTime date = DateFormat("dd-MM-yyyy HH:mm:ss").parse(dateStr);
        String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
        HelperFunctions.setTokenExpiresSF(formattedDate);
        HelperFunctions.saveUserLoggedInStatus(true);
        var pref = await SharedPreferences.getInstance();
        if(pref.containsKey('userAuthTokenKey')) {
          authToken = (pref.getString('userAuthTokenKey'))!;
        }
        if(pref.containsKey('userTokenExpires')) {
          tokenExpire = (pref.getString('userTokenExpires'))!;
          expiryDateTime = DateTime.parse(tokenExpire);
        }
        if (callback != null) {
          callback();
        }
      } else {
        Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
        AnimatedSnackBar.material(
            'Please login again.',
            type: AnimatedSnackBarType.info,
            duration: const Duration(seconds: 10)
        ).show(context);
      }
    }
  }
}

class ClearSharedPreference {
  clearSharedPreferenceData(BuildContext context) async {
    // Deleting shared-preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAuthTokenKey');
    await prefs.remove('userTokenExpires');
    await prefs.remove('userIdKey');
    await prefs.remove('userNameKey');
    await prefs.remove('userEmailKey');
    await prefs.remove('userImageKey');
    await prefs.remove('userDioceseKey');
    await prefs.remove('userMemberKey');
    await HelperFunctions.setUserLoginSF(false);
    authToken = '';
    tokenExpire = '';
    userID = '';
    userName = '';
    userEmail = '';
    userImage = '';
    userLevel = '';
    userDiocese = '';
    userMember = '';
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
    AnimatedSnackBar.material(
        'Your session expired; please login again.',
        type: AnimatedSnackBarType.info,
        duration: const Duration(seconds: 3)
    ).show(context);
  }
}

class InstitutionRunBy {
  void runby(BuildContext context, {VoidCallback? callback}) async {
    String url = '$baseUrl/res.institution/get_institution_data_runby';
    Map data = {
      "params": {}
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
      if(data['status_code'] == 200 && data['status'] == true) {
        List result = data['result'];
        for(int i = 0; i < result.length; i++) {
          dioceseInstitution = result[i]['diocese'];
          religiousInstitution = result[i]['religious'];
        }
        if (callback != null) {
          callback();
        }
      } else {
        AnimatedSnackBar.material(
            data['message'],
            type: AnimatedSnackBarType.error,
            duration: const Duration(seconds: 10)
        ).show(context);
      }
    }
  }
}

class InstitutionCategoryRunBy {
  void runby(BuildContext context, {VoidCallback? callback}) async {
    String url = '$baseUrl/res.member/get_institution_main_minstry';
    Map data = {
      "params": {}
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
      final data = jsonDecode(response.body)['result'];
      if (data['status_code'] == 200 && data['status'] == true) {
        List result = data['result']['categories'];
        List type = data['result']['medium'];
        categoryTab.clear();
        categoryTab.add({'id': 0, 'name': 'All'});
        categoryTab.addAll(result.map((category) {
          return {
            'id': category['id'],
            'name': category['name'],
          };
        }));
        mediumTab.clear();
        mediumTab.add({'id': 0, 'name': 'All'});
        mediumTab.addAll(type.map((types) {
          return {
            'id': types['id'],
            'name': types['name'],
          };
        }));
        if (callback != null) {
          callback();
        }
      } else {
        AnimatedSnackBar.material(
            data['message'],
            type: AnimatedSnackBarType.error,
            duration: const Duration(seconds: 10)
        ).show(context);
      }
    }
  }
}

class CustomProfileBottomSheet extends StatelessWidget {
  final Size size;
  final VoidCallback onGalleryPressed;
  final VoidCallback onCameraPressed;

  const CustomProfileBottomSheet({
    Key? key,
    required this.size,
    required this.onGalleryPressed,
    required this.onCameraPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        height: size.height * 0.2,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: size.width * 0.3,
                height: size.height * 0.008,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: screenBackgroundColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              ListTile(
                leading: Image.asset('assets/images/gallery.png'),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.signika(
                    fontSize: size.height * 0.02,
                    color: Colors.black,
                  ),
                ),
                onTap: onGalleryPressed,
              ),
              SizedBox(width: size.height * 0.01),
              ListTile(
                leading: Image.asset('assets/images/camera.png'),
                title: Text(
                    'Camera',
                    style: GoogleFonts.signika(
                      fontSize: size.height * 0.02,
                      color: Colors.black,
                    )
                ),
                onTap: onCameraPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomLoadingDialog extends StatelessWidget {
  const CustomLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.15, // Adjust the height as desired
        width: size.width * 0.3, // Adjust the width as desired
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
            Text(
              'Loading....',
              style: TextStyle(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
