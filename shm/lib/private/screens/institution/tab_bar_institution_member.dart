import 'package:flutter/material.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

import 'institution_members_list.dart';
import 'other_institution_members_list.dart';

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

  internetCheck() {
    CheckInternetConnection.checkInternet().then((value) {
      if(value) {
        return null;
      } else {
        showDialogBox();
      }
    });
  }

  showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningAlertDialog(
          message: 'Please check your internet connection.',
          onOkPressed: () {
            Navigator.pop(context);
            CheckInternetConnection.checkInternet().then((value) {
              if (value) {
                return null;
              } else {
                showDialogBox();
              }
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
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
        centerTitle: true,
        backgroundColor: appBackgroundColor,
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
