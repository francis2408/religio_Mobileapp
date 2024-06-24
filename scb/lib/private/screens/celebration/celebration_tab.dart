import 'package:flutter/material.dart';
import 'package:scb/private/screens/celebration/birthday/birthday_tab.dart';
import 'package:scb/private/screens/celebration/feast/feast_tab.dart';
import 'package:scb/widget/common/common.dart';
import 'package:scb/widget/theme_color/theme_color.dart';
import 'package:scb/widget/widget.dart';

class CelebrationTabScreen extends StatefulWidget {
  const CelebrationTabScreen({Key? key}) : super(key: key);

  @override
  State<CelebrationTabScreen> createState() => _CelebrationTabScreenState();
}

class _CelebrationTabScreenState extends State<CelebrationTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List celebrationTabs = ["Birthday", "Feast"];
  List<Widget> celebrationTabsContent = [
    const BirthdayTabScreen(),
    const FeastTabScreen(),
  ];

  @override
  void initState() {
    super.initState();
    celebrationTab = "Birthday";
    birthdayTab = "Upcoming";
    feastTab = "Upcoming";
    if(expiryDateTime!.isAfter(currentDateTime)) {
      _tabController = TabController(length: celebrationTabs.length, vsync: this);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            _tabController = TabController(length: celebrationTabs.length, vsync: this);
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
          celebrationTab = "Birthday";
          birthdayTab = "Upcoming";
          feastTab = "Upcoming";
          Navigator.pop(context, 'refresh');
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text("Celebration"),
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
            length: celebrationTabs.length,
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
                            child: Text("Birthday"),
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
                            child: Text("Feast"),
                          ),
                        ),
                      ),
                    ],
                    onTap: (index) {
                      setState(() {
                        celebrationTab = celebrationTabs[index];
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: celebrationTabsContent,
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
