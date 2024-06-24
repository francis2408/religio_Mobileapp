import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lasad/widget/common/common.dart';
import 'package:lasad/widget/widget.dart';

import 'members/education.dart';
import 'members/emergency_contact.dart';
import 'package:lasad/widget/theme_color/color.dart';
import 'members/family_info.dart';
import 'members/formation.dart';
import 'members/member.dart';
import 'members/ministry.dart';
import 'members/profession.dart';
import 'members/publication.dart';
import 'members/statutory_renewals.dart';

class MembersDetailsTabBarScreen extends StatefulWidget {
  const MembersDetailsTabBarScreen({Key? key}) : super(key: key);

  @override
  State<MembersDetailsTabBarScreen> createState() => _MembersDetailsTabBarScreenState();
}

class _MembersDetailsTabBarScreenState extends State<MembersDetailsTabBarScreen> {
  bool _isLoading = true;
  List member = [];
  List<Tab> tabs = [
    const Tab(child: Text('Basic'),),
    const Tab(child: Text('Education'),),
    const Tab(child: Text('Profession'),),
    const Tab(child: Text('Formation'),),
    const Tab(child: Text('Family Info'),),
    const Tab(child: Text('Ministry'),),
    const Tab(child: Text('Emergency Contact'),),
    const Tab(child: Text('Publication'),),
    const Tab(child: Text('Statutory Renewals'),),
  ];

  List<Tab> tabsList = [const Tab(child: Text('Basic'),)];
  List<Widget> tabsListContent = [const MemberScreen()];

  List<Widget> tabsContent = [
    const MemberScreen(),
    const MembersEducationScreen(),
    const MembersProfessionScreen(),
    const MembersFormationScreen(),
    const MembersFamilyInfoScreen(),
    const MembersMinistryScreen(),
    const MembersEmergencyContactScreen(),
    const MembersPublicationScreen(),
    const MembersStatutoryRenewalsScreen(),
  ];

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberDetails() async {
    var request = http.Request('GET', Uri.parse("""$baseUrl/search_read/res.member?domain=[('id','=',$id)]&fields=['member_name','image_512','mobile','email','member_type','community_id']&context={"bypass":1}"""));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      member = data;
      for(int i = 0; i < member.length; i++) {
        if(member[i]['community_id'].isNotEmpty && member[i]['community_id'] != []) {
          communityId = member[i]['community_id'][0];
        }
      }
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      setState(() {
        _isLoading = false;
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
    // TODO: implement initState
    super.initState();
    getMemberDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userMember = '';
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
          title: Text(name),
          backgroundColor: backgroundColor,
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
            length: userRole == 'House/Community' && userCommunityId != communityId ? tabsList.length : userRole != 'Member' ? sectorTab == 'Indian Sector' ? tabs.length : tabsList.length : tabsList.length,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                  constraints: BoxConstraints.expand(height: size.height * 0.04),
                  alignment: userRole == 'House/Community' && userCommunityId != communityId ? Alignment.center : userRole != 'Member' ? sectorTab == 'Indian Sector' ? Alignment.topLeft : Alignment.center : Alignment.center,
                  child : TabBar(
                      unselectedLabelColor: menuPrimaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                      isScrollable: true,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: menuPrimaryColor
                      ),
                      tabs: userRole == 'House/Community' && userCommunityId != communityId ? [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Basic"),
                            ),
                          ),
                        ),
                      ] : userRole != 'Member' ? sectorTab == 'Indian Sector' ? [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Basic"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Education"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Profession"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Formation"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Family Info"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Ministry"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Emergency Contact"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Publication"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Statutory Renewals"),
                            ),
                          ),
                        ),
                      ] : [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Basic"),
                            ),
                          ),
                        ),
                      ] : [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * 0.05, right: size.width * 0.05),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: menuPrimaryColor, width: 1.5)),
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text("Basic"),
                            ),
                          ),
                        ),
                      ]
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: TabBarView(
                    children: userRole == 'House/Community' && userCommunityId != communityId ? tabsListContent : userRole != 'Member' ? sectorTab == 'Indian Sector' ? tabsContent : tabsListContent : tabsListContent,
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
