import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lasad/private/screens/account/user_profile.dart';
import 'package:lasad/private/screens/authentication/login.dart';
import 'package:lasad/private/screens/home/home_screen.dart';
import 'package:lasad/public/screens/home/home.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;
  final bool _canPop = true;

  final pages = [
    const PublicHomeScreen(),
    const LoginScreen(),
  ];

  final page = [
    const HomeScreen(),
    const UserProfileScreen()
  ];

  getData() async {
    var pref = await SharedPreferences.getInstance();
    setState(() {
      if(pref.containsKey('userLoggedInkey')) {
        login_status = (pref.getBool('userLoggedInkey'))!;
      } else {
        login_status = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_canPop) {
          setState(() {
            _selectedIndex = 0;
          });
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        body: Center(
          child: login_status ? page.elementAt(_selectedIndex) : pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0.5,
                color: Colors.grey,
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.black,
                iconSize: 30,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.black,
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    iconColor: navIconColor,
                    iconActiveColor: iconActiveColor,
                    text: 'Home',
                    textColor: navTextColor,
                    backgroundColor: navBackgroundColor,
                  ),
                  GButton(
                    icon: Icons.person,
                    iconColor: navIconColor,
                    iconActiveColor: iconActiveColor,
                    text: 'Profile',
                    textColor: navTextColor,
                    backgroundColor: navBackgroundColor,
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
