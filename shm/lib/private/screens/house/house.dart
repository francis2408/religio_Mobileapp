import 'package:flutter/material.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/common/internet_connection_checker.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

import 'other_house_list.dart';
import 'my_house.dart';

class HouseScreen extends StatefulWidget {
  const HouseScreen({Key? key}) : super(key: key);

  @override
  State<HouseScreen> createState() => _HouseScreenState();
}

class _HouseScreenState extends State<HouseScreen> with TickerProviderStateMixin {
  List<Tab> tabs = [
    const Tab(child: Text('My House'),),
    const Tab(child: Text('Other House'),),
  ];

  List<Widget> tabsContent = [
    const MyHouseScreen(),
    const OtherHouseListScreen(),
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
    house = '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return true;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('House'),
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
      ),
    );
  }
}
