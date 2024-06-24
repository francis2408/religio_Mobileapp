import 'package:flutter/material.dart';
import 'package:lasad/private/screens/institution/institution_members_list.dart';
import 'package:lasad/private/screens/institution/other_institution_members_list.dart';
import 'package:lasad/widget/theme_color/color.dart';

class TabBarInstitutionMembersScreen extends StatefulWidget {
  const TabBarInstitutionMembersScreen({Key? key}) : super(key: key);

  @override
  State<TabBarInstitutionMembersScreen> createState() => _TabBarInstitutionMembersScreenState();
}

class _TabBarInstitutionMembersScreenState extends State<TabBarInstitutionMembersScreen> {
  List<Tab> tabs = [
    const Tab(child: Text('Own Members'),),
    const Tab(child: Text('Other Members'),),
  ];

  List<Widget> tabsContent = [
    const InstitutionMembersListScreen(),
    const OtherInstitutionMembersListScreen(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(left: size.width * 0.1, right: size.width * 0.1,),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  constraints: BoxConstraints.expand(height: size.height * 0.05),
                  child: TabBar(
                    // isScrollable: true,
                    indicator: BoxDecoration(
                      color: iconActiveColor,
                      borderRadius:  BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: iconActiveColor.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ) ,
                    labelColor: navTextColor,
                    unselectedLabelColor: unselectColor,
                    tabs: tabs,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
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
