import 'package:flutter/material.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';

import 'members_list.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Indian Sector", "Sri Lankan Sector"];

  List<Widget> tabsContent = [
    const PublicMembersListScreen(),
    const PublicMembersListScreen(),
  ];

  @override
  void initState() {
    sectorTab = 'Indian Sector';
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    sectorTab = 'Indian Sector';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: backgroundColor,
        toolbarHeight: 50,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              CustomTabBar(
                tabController: _tabController, // Pass your TabController here
                tabs: const ["Indian Sector", "Sri Lankan Sector"], // Pass your selected tab value here
                onTabTap: (index) {
                  setState(() {
                    sectorTab = tabs[index];
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
    );
  }
}
