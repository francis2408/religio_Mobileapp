import 'package:flutter/material.dart';

import 'member_profile_details/view_member_profile.dart';
import 'package:lasad/widget/theme_color/color.dart';
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
  bool _isLoading = true;
  List profile = [];

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF0861B6),
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
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                  constraints: BoxConstraints.expand(height: size.height * 0.04),
                  alignment: Alignment.topLeft,
                  child : TabBar(
                      unselectedLabelColor: menuPrimaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                      isScrollable: true,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: menuPrimaryColor
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Statutory Renewals"),
                            ),
                          ),
                        ),
                      ]
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
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
      ),
    );
  }
}
