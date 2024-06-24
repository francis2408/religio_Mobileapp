import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

import 'diocese_institution_list.dart';
import 'religious_institution_list.dart';

class InstitutionScreen extends StatefulWidget {
  const InstitutionScreen({Key? key}) : super(key: key);

  @override
  State<InstitutionScreen> createState() => _InstitutionScreenState();
}

class _InstitutionScreenState extends State<InstitutionScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Tab> tabs = [
    const Tab(child: Text('Diocese'),),
    const Tab(child: Text('Religious'),),
  ];

  // List<Widget> tabsContent = [
  //   const DioceseInstitutionListScreen(),
  //   const ReligiousInstitutionListScreen()
  // ];

  List<Widget> tabsContent = [
    const DioceseInstitutionList(),
    const ReligiousInstitutionList()
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
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Warning',
      text: 'Please check your internet connection',
      confirmBtnColor: greenColor,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        CheckInternetConnection.checkInternet().then((value) {
          if (value) {
            return null;
          } else {
            showDialogBox();
          }
        });
      },
      width: 100.0,
    );
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    _isLoading = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('Institution'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        toolbarHeight: 50,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF512F),
                    Color(0xFFF09819)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,size: size.height * 0.03,),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                Future.delayed(const Duration(milliseconds: 50), () {
                  setState(() {
                    _isLoading = false;
                  });
                });
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.red,Colors.orange,Colors.yellow],
            ),
          ),
        ) : DefaultTabController(
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
                    color: const Color(0xFFFAE0C5),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  constraints: BoxConstraints.expand(height: size.height * 0.05),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFFFF512F),
                      borderRadius:  BorderRadius.circular(25.0),
                    ) ,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
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