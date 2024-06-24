import 'package:chengai/private/screen/home/home.dart';
import 'package:chengai/private/screen/member/members_tabs.dart';
import 'package:chengai/private/screen/user_profile/user_profile.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'change_theme_button.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;
  List listPage = [];

  getUserLevelData() async {
    var pref = await SharedPreferences.getInstance();
    if(pref.containsKey('userLevelKey')) {
      userLevel = (pref.getString('userLevelKey'))!;
    }

    if(userLevel != 'Diocesan Member') {
      setState(() {
        listPage = [
          const HomeScreen(),
          const MemberTabsScreen(),
          const UserProfileScreen()
        ];
      });
    } else {
      setState(() {
        listPage = [
          const HomeScreen(),
          const UserProfileScreen()
        ];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLevelData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
            body: Center(
              child: userLevel != 'Diocesan Member' ? listPage.elementAt(_selectedIndex) : listPage.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                  padding: userLevel != 'Diocesan Member' ? const EdgeInsets.symmetric(horizontal: 15, vertical: 8) : const EdgeInsets.symmetric(horizontal: 45, vertical: 8),
                  child: GNav(
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 25,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: userLevel != 'Diocesan Member' ? [
                      const GButton(
                        icon: Icons.home,
                        iconColor: Color(0xFFF5402D),
                        iconActiveColor: Color(0xFFF5402D),
                        text: 'Home',
                        textColor: Color(0xFFF5402D),
                        backgroundColor: Color(0xFFF7DCD9),
                      ),
                      const GButton(
                        icon: Icons.groups,
                        iconColor: Color(0xFFF5402D),
                        iconActiveColor: Color(0xFFF5402D),
                        text: 'Members',
                        textColor: Color(0xFFF5402D),
                        backgroundColor: Color(0xFFF7DCD9),
                      ),
                      const GButton(
                        icon: Icons.person,
                        iconColor: Color(0xFFF5402D),
                        iconActiveColor: Color(0xFFF5402D),
                        text: 'Profile',
                        textColor: Color(0xFFF5402D),
                        backgroundColor: Color(0xFFF7DCD9),
                      ),
                    ] : [
                      const GButton(
                      icon: Icons.home,
                      iconColor: Color(0xFFF5402D),
                      iconActiveColor: Color(0xFFF5402D),
                      text: 'Home',
                      textColor: Color(0xFFF5402D),
                      backgroundColor: Color(0xFFF7DCD9),
                    ),
                    const GButton(
                      icon: Icons.person,
                      iconColor: Color(0xFFF5402D),
                      iconActiveColor: Color(0xFFF5402D),
                      text: 'Profile',
                      textColor: Color(0xFFF5402D),
                      backgroundColor: Color(0xFFF7DCD9),
                    ),],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        _selectedIndex = index;
                        if(listPage.length == 3 && _selectedIndex == 1) {
                          navigation = true;
                        } else {
                          navigation = false;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}
