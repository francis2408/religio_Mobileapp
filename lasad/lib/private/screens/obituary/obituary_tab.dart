import 'package:flutter/material.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';

import 'obituary.dart';

class ObituaryTabScreen extends StatefulWidget {
  const ObituaryTabScreen({Key? key}) : super(key: key);

  @override
  State<ObituaryTabScreen> createState() => _ObituaryTabScreenState();
}

class _ObituaryTabScreenState extends State<ObituaryTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List tabs = ["Upcoming", "All",];
  List<Widget> tabsContent = [
    const ObituaryScreen(),
    const ObituaryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    obituaryTab = 'Upcoming';
    if(expiryDateTime!.isAfter(currentDateTime)) {
      _tabController = TabController(length: tabs.length, vsync: this);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
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
          obituaryTab = "Upcoming";
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
                      obituaryTab = tabs[index];
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
