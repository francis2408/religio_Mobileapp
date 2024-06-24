import 'package:chengai/private/screen/anniversary/birthday/birthday.dart';
import 'package:chengai/private/screen/anniversary/ordination/ordination.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:quickalert/quickalert.dart';

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({Key? key}) : super(key: key);

  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  int index= 0;

  List<Widget> tabsContent = [
    const BirthdayScreen(),
    const OrdinationScreen(),
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
    // Check Internet connection
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
        title: const Text('Anniversary'),
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
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: AnimationConfiguration.staggeredList(
            duration: const Duration(milliseconds: 375),
            position: index,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  padding: EdgeInsets.only(left: size.width * 0.03, right: size.width * 0.03),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: const Color(0xFFFAE0C5),
                              borderRadius: BorderRadius.circular(25.0)
                          ),
                          constraints: BoxConstraints.expand(height: size.height * 0.04),
                          child: TabBar(
                            indicator: BoxDecoration(
                                color: const Color(0xFFFF512F),
                                borderRadius:  BorderRadius.circular(25.0)
                            ) ,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            tabs: const  [
                              Tab(text: 'Birthday',),
                              Tab(text: 'Ordination',),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: tabsContent,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
