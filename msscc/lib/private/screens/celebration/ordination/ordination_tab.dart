import 'package:flutter/material.dart';
import 'package:msscc/widget/common/common.dart';
import 'package:msscc/widget/theme_color/theme_color.dart';
import 'package:msscc/widget/widget.dart';

import 'ordination.dart';

class OrdinationTabScreen extends StatefulWidget {
  const OrdinationTabScreen({Key? key}) : super(key: key);

  @override
  State<OrdinationTabScreen> createState() => _OrdinationTabScreenState();
}

class _OrdinationTabScreenState extends State<OrdinationTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List tabs = ["Upcoming", "All"];
  List<Widget> tabsContent = [
    const OrdinationScreen(),
    const OrdinationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      ordinationTab = "Upcoming";
      _tabController = TabController(length: tabs.length, vsync: this);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            ordinationTab = "Upcoming";
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
          ordinationTab = "Upcoming";
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
                      ordinationTab = tabs[index];
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
