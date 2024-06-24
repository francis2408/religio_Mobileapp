import 'package:chengai/private/screen/parish/parish_list.dart';
import 'package:chengai/private/screen/shrine/shrine.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ParishTabScreen extends StatefulWidget {
  const ParishTabScreen({Key? key}) : super(key: key);

  @override
  State<ParishTabScreen> createState() => _ParishTabScreenState();
}

class _ParishTabScreenState extends State<ParishTabScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  final bool _canPop = true;
  bool _isLoading = true;

  List tabs = ["All", "Shrine", "Diocesan", "Religious"] ;
  List<Widget> tabsContent = [
    const ParishListScreen(),
    const ShrineScreen(),
    const ParishListScreen(),
    const ParishListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    selectedTab = "All";
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
        _tabController = TabController(length: tabs.length, vsync: this);
      });
    });
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
          title: const Text('Parish'),
          centerTitle: true,
          backgroundColor: backgroundColor,
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
                _isLoading = true;
                setState(() {
                  if(_isLoading) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  }
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white,size: 30,),
            )
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : DefaultTabController(
            length: tabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                SizedBox(
                  height: size.height * 0.04,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TabBar(
                      controller: _tabController,
                      unselectedLabelColor: textColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: backgroundColor,
                        border: Border.all(
                          color: backgroundColor,
                          width: 1.5,
                        ),
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: backgroundColor, width: 1.5)),
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
                                border: Border.all(color: backgroundColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Shrine"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: backgroundColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Diocesan"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: backgroundColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Religious"),
                            ),
                          ),
                        ),
                      ],
                      onTap: (index) {
                        setState(() {
                          selectedTab = tabs[index];
                        });
                      },
                    ),
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
