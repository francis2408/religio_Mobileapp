import 'dart:convert';

import 'package:chengai/private/screen/seminarian/seminarian.dart';
import 'package:chengai/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';

class SeminarianTabScreen extends StatefulWidget {
  const SeminarianTabScreen({Key? key}) : super(key: key);

  @override
  State<SeminarianTabScreen> createState() => _SeminarianTabScreenState();
}

class _SeminarianTabScreenState extends State<SeminarianTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;
  bool _isLoading = true;

  List tabs =["All"];

  getStageData() async {
    String url = '$baseUrl/res.formation.stage';
    Map data = {
      "params": {
        "query": "{id,name,code}"
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['result']['data']['result'];
      for(int i = 0; i < data.length; i++) {
        tabs.add(data[i]['name']);
      }
      setState(() {
        _isLoading = false;
      });
      _tabController = TabController(length: tabs.length, vsync: this);
    } else {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isLoading = false;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: message['message'],
          confirmBtnColor: greenColor,
          width: 100.0,
        );
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    seminarianTab = "All";
    getStageData();
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
          seminarianTab = "All";
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Seminarian'),
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
        ),
        body: SafeArea(
          child: _isLoading ? Center(
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
                  child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: textColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: tabColor,
                      border: Border.all(
                        color: tabColor,
                        width: 1.5,
                      ),
                    ),
                    tabs: tabs.map((tabName) {
                      return Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tabColor, width: 1.5),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(tabName),
                          ),
                        ),
                      );
                    }).toList(),
                    onTap: (index) {
                      setState(() {
                        seminarianTab = tabs[index];
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: tabs.map((tabName) {
                      return const SeminarianScreen();
                    }).toList(),
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
