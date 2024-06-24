import 'package:flutter/material.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';

import 'member_profile_details/view_member_profile.dart';
import 'members_basic_details/education.dart';
import 'members_basic_details/emergency_contact.dart';
import 'members_basic_details/family_info.dart';
import 'members_basic_details/formation.dart';
import 'members_basic_details/ministry.dart';
import 'members_basic_details/profession.dart';
import 'members_basic_details/publication.dart';
import 'members_basic_details/statutory_renewals.dart';

class MemberProfileTabbarScreen extends StatefulWidget {
  const MemberProfileTabbarScreen({Key? key}) : super(key: key);

  @override
  State<MemberProfileTabbarScreen> createState() => _MemberProfileTabbarScreenState();
}

class _MemberProfileTabbarScreenState extends State<MemberProfileTabbarScreen> {

  List<Tab> tabs = [
    const Tab(child: Text('Basic'),),
    const Tab(child: Text('Education'),),
    const Tab(child: Text('Profession'),),
    const Tab(child: Text('Formation'),),
    const Tab(child: Text('Family Info'),),
    const Tab(child: Text('Ministry'),),
    const Tab(child: Text('Emergency Contact'),),
    const Tab(child: Text('Publication'),),
    const Tab(child: Text('Statutory Renewals'),),
  ];

  List<Widget> tabsContent = [
    const ViewMemberProfileScreen(),
    const MemberEducationScreen(),
    const MemberProfessionScreen(),
    const MemberFormationScreen(),
    const MemberFamilyInfoScreen(),
    const MemberMinistryScreen(),
    const MemberEmergencyContactScreen(),
    const MemberPublicationScreen(),
    const MemberStatutoryRenewalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text(
          userName,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A3F85),
                    Color(0xFFFA761E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              SizedBox(
                height: size.height * 0.04,
                child: TabBar(
                  unselectedLabelColor: navTextColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 3), // Adjust the padding value as needed
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: iconActiveColor,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Basic"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Education"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Profession"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Formation"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Family Info"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Ministry"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Emergency Contact"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Publication"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: navIconColor, width: 1.5)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("Statutory Renewals"),
                        ),
                      ),
                    ),
                  ],
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
