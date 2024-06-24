import 'package:flutter/material.dart';
import 'package:lasad/private/screens/province/basic.dart';
import 'package:lasad/private/screens/province/commission.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'package:lasad/widget/widget.dart';
import 'package:lasad/widget/common/common.dart';

const double expandedHeight = 300;
const double roundedContainerHeight = 50;

class ProvinceDetailsScreen extends StatefulWidget {
  const ProvinceDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceDetailsScreen> createState() => _ProvinceDetailsScreenState();
}

class _ProvinceDetailsScreenState extends State<ProvinceDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List tabs = ["Profile", "Province Commission"];

  List<Widget> tabsContent = [
    const ProvinceBasicDetailsScreen(),
    const ProvinceCommissionsScreen()
  ];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              CustomTabBar(
                tabController: _tabController, // Pass your TabController here
                tabs: const ["Profile", "Province Commission"], // Pass your selected tab value here
                onTabTap: (index) {
                  setState(() {
                    provinceTab = tabs[index];
                  });
                },
              ),
              SizedBox(height: size.height * 0.01,),
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
    );
  }
}
