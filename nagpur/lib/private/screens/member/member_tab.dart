import 'package:flutter/material.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

import 'member_list.dart';

class MemberTabScreen extends StatefulWidget {
  const MemberTabScreen({Key? key}) : super(key: key);

  @override
  State<MemberTabScreen> createState() => _MemberTabScreenState();
}

class _MemberTabScreenState extends State<MemberTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List tabs =["All", "Priest", "Deacon", "Brother", "Novice"];
  List<Widget> tabsContent = [
    const MembersListScreen(),
    const MembersListScreen(),
    const MembersListScreen(),
    const MembersListScreen(),
    const MembersListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    memberSelectedTab = 'All';
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
    userMember = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if(_canPop) {
          memberSelectedTab = "All";
          return true;
        } else {
          Navigator.pop(context, 'refresh');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Members'),
          centerTitle: true,
          backgroundColor: appBackgroundColor,
          toolbarHeight: 50,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, 'refresh');
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
          ),
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
                SizedBox(
                  height: size.height * 0.04,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TabBar(
                      controller: _tabController,
                      unselectedLabelColor: tabBackColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: tabBackColor,
                        border: Border.all(
                          color: tabBackColor,
                          width: 1.5,
                        ),
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tabBackColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("All"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tabBackColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Priest"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tabBackColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Deacon"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tabBackColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Brother"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tabBackColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Novice"),
                            ),
                          ),
                        ),
                      ],
                      onTap: (index) {
                        setState(() {
                          memberSelectedTab = tabs[index];
                        });
                      },
                    ),
                  ),
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
