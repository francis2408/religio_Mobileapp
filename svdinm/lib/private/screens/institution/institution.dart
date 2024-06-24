import 'package:flutter/material.dart';
import 'package:svdinm/widget/common/common.dart';
import 'package:svdinm/widget/common/internet_connection_checker.dart';
import 'package:svdinm/widget/theme_color/theme_color.dart';
import 'package:svdinm/widget/widget.dart';

import 'other_institution_list.dart';
import 'my_institution.dart';

class InstitutionScreen extends StatefulWidget {
  const InstitutionScreen({Key? key}) : super(key: key);

  @override
  State<InstitutionScreen> createState() => _InstitutionScreenState();
}

class _InstitutionScreenState extends State<InstitutionScreen> {

  List<Tab> tabs = [
    const Tab(child: Text('Own Institution'),),
    const Tab(child: Text('Other Institution'),),
  ];

  List<Widget> tabsContent = [
    const MyInstitutionScreen(),
    const OtherInstitutionListScreen(),
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    institution = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Institution'),
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
                      color: tabBackColor,
                      borderRadius:  BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: tabBackColor.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ) ,
                    labelColor: tabLabelColor,
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
