import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nagpur/private/screens/province/province_institution_list.dart';
import 'package:nagpur/widget/common/common.dart';
import 'package:nagpur/widget/theme_color/theme_color.dart';
import 'package:nagpur/widget/widget.dart';

class ParishAndInstitutionTabScreen extends StatefulWidget {
  const ParishAndInstitutionTabScreen({Key? key}) : super(key: key);

  @override
  State<ParishAndInstitutionTabScreen> createState() => _ParishAndInstitutionTabScreenState();
}

class _ParishAndInstitutionTabScreenState extends State<ParishAndInstitutionTabScreen> with SingleTickerProviderStateMixin {
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  late TabController _tabController;
  final bool _canPop = true;

  List parishTabs = ["Parishes", "Institution"];
  List<Widget> parishTabsContent = [
    const ProvinceInstitutionListScreen(),
    const ProvinceInstitutionListScreen(),
  ];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getInstitutionCategoryData() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.institution.category?fields=['id','name','code','parent_id']&context={"bypass":1}&limit=500"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      List data = result['data'];
      for(int i = 0; i < data.length; i++) {
        if(data[i]['name'] == 'Pastoral') {
          categoryId = data[i]['id'];
        }
        if(data[i]['name'] == 'Parishes' && data[i]['parent_id'][1] == 'Pastoral') {
          parishesId = data[i]['id'];
        }
        if(data[i]['name'] == 'Parishes & Mission Stations' && data[i]['parent_id'][1] == 'Pastoral') {
          missionId = data[i]['id'];
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorAlertDialog(
              message: message,
              onOkPressed: () async {
                Navigator.pop(context);
              },
            );
          },
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    parishTab = 'Parishes';
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getInstitutionCategoryData();
      _tabController = TabController(length: parishTabs.length, vsync: this);
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getInstitutionCategoryData();
            _tabController = TabController(length: parishTabs.length, vsync: this);
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
    parishTab = 'Parishes';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if(_canPop) {
          parishTab = 'Parishes';
          Navigator.pop(context, 'refresh');
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text("Parishes / Institutions"),
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
            length: parishTabs.length,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01,),
                CustomTabBar(
                  tabController: _tabController, // Pass your TabController here
                  tabs: const ["Parishes", "Institutions"], // Pass your selected tab value here
                  onTabTap: (index) {
                    setState(() {
                      getInstitutionCategoryData();
                      parishTab = parishTabs[index];
                    });
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: parishTabsContent,
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
