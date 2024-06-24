import 'package:flutter/material.dart';
import 'package:shm/private/screens/circular&news_letter/circular/circular.dart';
import 'package:shm/private/screens/circular&news_letter/news_letter/news_letter.dart';
import 'package:shm/widget/common/common.dart';
import 'package:shm/widget/theme_color/theme_color.dart';
import 'package:shm/widget/widget.dart';

class CircularAndNewsLetterTabScreen extends StatefulWidget {
  const CircularAndNewsLetterTabScreen({Key? key}) : super(key: key);

  @override
  State<CircularAndNewsLetterTabScreen> createState() => _CircularAndNewsLetterTabScreenState();
}

class _CircularAndNewsLetterTabScreenState extends State<CircularAndNewsLetterTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List letterTabs = ["Circular", "News Letter"];
  List<Widget> letterTabsContent = [
    const CircularScreen(),
    const NewsLetterScreen(),
  ];

  @override
  void initState() {
    super.initState();
    letterTab = "Circular";
    if(expiryDateTime!.isAfter(currentDateTime)) {
      _tabController = TabController(length: letterTabs.length, vsync: this);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            _tabController = TabController(length: letterTabs.length, vsync: this);
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
          letterTab = "Circular";
          Navigator.pop(context, 'refresh');
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text("Circular / News Letter"),
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
            length: letterTabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                CustomTabBar(
                  tabController: _tabController, // Pass your TabController here
                  tabs: const ["Circular", "News Letter"], // Pass your selected tab value here
                  onTabTap: (index) {
                    setState(() {
                      letterTab = letterTabs[index];
                    });
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: letterTabsContent,
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
