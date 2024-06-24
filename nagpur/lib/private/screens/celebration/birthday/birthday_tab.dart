import 'package:flutter/material.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

import 'birthday.dart';

class BirthdayTabScreen extends StatefulWidget {
  const BirthdayTabScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayTabScreen> createState() => _BirthdayTabScreenState();
}

class _BirthdayTabScreenState extends State<BirthdayTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List tabs = ["Upcoming", "All",];
  List<Widget> tabsContent = [
    const BirthdayScreen(),
    const BirthdayScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      birthdayTab = "Upcoming";
      _tabController = TabController(length: tabs.length, vsync: this);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            birthdayTab = "Upcoming";
            _tabController = TabController(length: tabs.length, vsync: this);
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if(_canPop) {
          birthdayTab = "Upcoming";
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        body: SafeArea(
          child: DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                CustomTabBar(
                  tabController: _tabController, // Pass your TabController here
                  tabs: const ["Upcoming", "All"], // Pass your selected tab value here
                  onTabTap: (index) {
                    setState(() {
                      birthdayTab = tabs[index];
                    });
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: tabsContent,
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
