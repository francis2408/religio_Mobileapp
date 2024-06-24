import 'package:flutter/material.dart';
import 'package:eluru/private/screens/event/all_event.dart';
import 'package:eluru/widget/common/common.dart';
import 'package:eluru/widget/theme_color/theme_color.dart';
import 'package:eluru/widget/widget.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List tabs = userRole == 'Religious Province' ? ["All", "Upcoming", "My Calendar", "Provincial", "Province"] : ["All", "Upcoming", "My Calendar", "Province"];
  List<Widget> tabsContent = userRole == 'Religious Province' ? [
    const AllEventScreen(),
    const AllEventScreen(),
    const AllEventScreen(),
    const AllEventScreen(),
    const AllEventScreen(),
  ] : [
    const AllEventScreen(),
    const AllEventScreen(),
    const AllEventScreen(),
    const AllEventScreen(),
  ];

  @override
  void initState() {
    super.initState();
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
          selectedTab = "All";
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Calendar Event'),
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
                  child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: menuPrimaryColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: menuPrimaryColor,
                      border: Border.all(
                        color: menuPrimaryColor,
                        width: 1.5,
                      ),
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
                            child: Text("All"),
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
                            child: Text("Upcoming"),
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
                            child: Text("My Calendar"),
                          ),
                        ),
                      ),
                      if(userRole == 'Religious Province') Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: menuPrimaryColor, width: 1.5)),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text("Provincial"),
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
                            child: Text("Province"),
                          ),
                        ),
                      ),
                    ],
                    onTap: (index) {
                      setState(() {
                        eventPage = 0;
                        eventLimit = 20;
                        selectedTab = tabs[index];
                      });
                    },
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
