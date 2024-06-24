import 'package:flutter/material.dart';
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';

import 'other_institution_list.dart';
import 'my_institution.dart';
import 'other_institution.dart';

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

  @override
  void initState() {
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Institution'),
          backgroundColor: backgroundColor,
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
                        color: const Color(0xFF39E8BC),
                        borderRadius:  BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF39E8BC).withOpacity(0.8),
                            blurRadius: 10,
                            offset: const Offset(0, 5), // changes position of shadow
                          ),
                        ],
                      ) ,
                      labelColor: const Color(0xFF12274D),
                      unselectedLabelColor: const Color(0xFF384B6B),
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
