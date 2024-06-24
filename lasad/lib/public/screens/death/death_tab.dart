import 'package:flutter/material.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';

import 'death_members.dart';

class DeathScreen extends StatefulWidget {
  const DeathScreen({Key? key}) : super(key: key);

  @override
  State<DeathScreen> createState() => _DeathScreenState();
}

class _DeathScreenState extends State<DeathScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Indian Sector", "Sri Lankan Sector"];

  List<Widget> tabsContent = [
    const DeathMembersScreen(),
    const DeathMembersScreen(),
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
        title: const Text('Obituary'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        toolbarHeight: 50,
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
