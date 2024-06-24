// import 'dart:convert';
// import 'dart:io';
//
// import 'package:chengai/widget/internet_checker.dart';
// import 'package:chengai/widget/widget.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:line_awesome_flutter/line_awesome_flutter.dart';
// import 'package:quickalert/quickalert.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'basic_details/basic_details.dart';
// import 'basic_details/education.dart';
// import 'basic_details/family_info.dart';
// import 'basic_details/formation.dart';
// import 'basic_details/health.dart';
// import 'basic_details/holy_order.dart';
//
// class Member extends StatefulWidget {
//   const Member({Key? key}) : super(key: key);
//
//   @override
//   State<Member> createState() => _MemberState();
// }
//
// class _MemberState extends State<Member> {
//   DateTime currentDateTime = DateTime.now();
//   final LoginService loginService = LoginService();
//   final ClearSharedPreference shared = ClearSharedPreference();
//   bool _isLoading = true;
//   List member = [];
//   int index = 0;
//
//   // Teb Bar
//   List<Tab> tabs = [
//     // const Tab(icon: Icon(Icons.person), child: Text('Member'),),
//     const Tab(child: Text('Education'),),
//     const Tab(child: Text('Formation'),),
//     const Tab(child: Text('Holy Order'),),
//     const Tab(child: Text('Family Info'),),
//     const Tab(child: Text('Health'),),
//   ];
//
//   List<Widget> tabsContent = [
//     const BasicDetailsScreen(),
//     const EducationScreen(),
//     const FormationScreen(),
//     const HolyOrderScreen(),
//     const FamilyInfoScreen(),
//     const HealthScreen(),
//   ];
//
//   getMemberDetails() async {
//     String url = '$baseUrl/res.member';
//     Map data = {
//       "params": {
//         "filter": "[['id','=',$memberId]]",
//         "query": "{id,name,middle_name,last_name,member_name,image_1920,title_id,unique_code,gender,living_status,marital_status_id,blood_group_id,mother_tongue_id,occupation_status,occupation_id,occupation_type,dob,is_dob_or_age,age,active,physical_status_id,citizenship_id,religion_id,name_in_regional_language,native_place,native_district_id,driving_license_no,known_language_ids,twitter_account,fb_account,linkedin_account,whatsapp_no,mobile,email,passport_country_id,known_popularly_as,place_of_birth,membership_type,member_type_id,member_type_code,pancard_no,aadhaar_proof,aadhaar_proof_name,pan_proof,pan_proof_name,passport_no,passport_proof,passport_proof_name,passport_exp_date,voter_id,voter_proof_name,voter_proof,license_exp_date,street,street2,city,district_id,state_id,country_id,zip,native_diocese_id,native_parish_id}"
//       }
//     };
//     var body = jsonEncode(data);
//     var response = await http.post(Uri.parse(url),
//         headers: {
//           'Authorization': authToken,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json'
//         },
//         body: body);
//
//     if (response.statusCode == 200) {
//       List data = jsonDecode(response.body)['result']['data']['result'];
//       setState(() {
//         _isLoading = false;
//       });
//       member = data;
//     }
//     else {
//       final message = jsonDecode(response.body)['result'];
//       setState(() {
//         _isLoading = false;
//         QuickAlert.show(
//           context: context,
//           type: QuickAlertType.error,
//           title: 'Error',
//           text: message['message'],
//           confirmBtnColor: greenColor,
//           width: 100.0,
//         );
//       });
//     }
//   }
//
//   Future<void> smsAction(String number) async {
//     final Uri uri = Uri(scheme: "sms", path: number);
//     if(!await launchUrl(
//       uri,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw "Can not launch url";
//     }
//   }
//
//   Future<void> callAction(String number) async {
//     final Uri uri = Uri(scheme: "tel", path: number);
//     if(!await launchUrl(
//       uri,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw "Can not launch url";
//     }
//   }
//
//   Future<void> whatsappAction(String whatsapp) async {
//     if (Platform.isAndroid) {
//       var whatsappUrl ="whatsapp://send?phone=$whatsapp";
//       await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
//     } else {
//       var whatsappUrl ="https://api.whatsapp.com/send?phone=$whatsapp";
//       await canLaunch(whatsappUrl)? launch(whatsappUrl) : throw "Can not launch url";
//     }
//   }
//
//   Future<void> emailAction(String email) async {
//     final Uri uri = Uri(scheme: "mailto", path: email);
//     if(!await launchUrl(
//       uri,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw "Can not launch url";
//     }
//   }
//
//   internetCheck() {
//     CheckInternetConnection.checkInternet().then((value) {
//       if(value) {
//         return null;
//       } else {
//         showDialogBox();
//       }
//     });
//   }
//
//   showDialogBox() {
//     QuickAlert.show(
//       context: context,
//       type: QuickAlertType.warning,
//       title: 'Warning',
//       text: 'Please check your internet connection',
//       confirmBtnColor: greenColor,
//       onConfirmBtnTap: () {
//         Navigator.pop(context);
//         CheckInternetConnection.checkInternet().then((value) {
//           if (value) {
//             return null;
//           } else {
//             showDialogBox();
//           }
//         });
//       },
//       width: 100.0,
//     );
//   }
//
//   @override
//   void initState() {
//     // Check Internet connection
//     internetCheck();
//     // TODO: implement initState
//     super.initState();
//     if (expiryDateTime!.isAfter(currentDateTime)) {
//       getMemberDetails();
//     } else {
//       if(remember == true) {
//         loginService.login(context, loginName, loginPassword, databaseName, callback: () {
//           setState(() {
//             getMemberDetails();
//           });
//         });
//       } else {
//         shared.clearSharedPreferenceData(context);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // appBar: AppBar(
//       //   title: Text(memberName),
//       //   backgroundColor: backgroundColor,
//       //   shape: const RoundedRectangleBorder(
//       //       borderRadius: BorderRadius.only(
//       //           bottomLeft: Radius.circular(25),
//       //           bottomRight: Radius.circular(25)
//       //       )
//       //   ),
//       // ),
//       body: SafeArea(
//           child: Center(
//             child: _isLoading
//                 ? const Center(
//                 child: CircularProgressIndicator(
//                   color: backgroundColor,
//                 ))
//                 : AnimationLimiter(
//               child: AnimationConfiguration.staggeredList(
//                 duration: const Duration(milliseconds: 375),
//                 position: index,
//                 child: SlideAnimation(
//                   verticalOffset: 50.0,
//                   child: FadeInAnimation(
//                     child: DefaultTabController(
//                       length: 6,
//                       child: Column(
//                         children: [
//                           Container(
//                             width: size.width,
//                             height: size.height * 0.25,
//                             decoration: const BoxDecoration(
//                               // borderRadius: BorderRadius.only(
//                               //     bottomRight: Radius.circular(40),
//                               //     bottomLeft: Radius.circular(40)
//                               // ),
//                               // color: Color(0xFFC23A31),
//                               // boxShadow: <BoxShadow>[
//                               //   BoxShadow(
//                               //     color: Colors.black38,
//                               //     spreadRadius: 3.5,
//                               //     blurRadius: 5 ,
//                               //     offset: Offset(0, 1),
//                               //   ),
//                               // ],
//                             ),
//                             child: Stack(
//                               children: [
//                                 Image.asset(
//                                   'assets/images/one.jpg',
//                                   width: size.width,
//                                   height: size.height * 0.1,
//                                   fit:BoxFit.cover,
//                                   opacity: const AlwaysStoppedAnimation(.7),
//                                 ),
//                                 Positioned(
//                                   top: size.height * 0.01,
//                                   left: 0,
//                                   child: IconButton(
//                                       icon: const Icon(Icons.arrow_back_sharp, color: Colors.white,),
//                                       onPressed: () {
//                                         Navigator.pop(context);
//                                       }),
//                                 ),
//                                 Positioned(
//                                   top: size.height * 0.012,
//                                   left: size.width / 3,
//                                   child: SizedBox(
//                                     height: size.height * 0.15,
//                                     width: size.width * 0.32,
//                                     child: CircleAvatar(
//                                       child: ClipOval(
//                                         child: member[index]['image_1920'] != null && member[index]['image_1920'] != '' ? Image.network(
//                                             member[index]['image_1920'],
//                                             height: size.height * 0.15,
//                                             width: size.width * 0.32,
//                                             fit: BoxFit.cover
//                                         ) : Image.asset(
//                                           'assets/images/profile.png',
//                                           height: size.height * 0.15,
//                                           width: size.width * 0.32,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                     padding: EdgeInsets.only(top: size.height * 0.13),
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       member[index]['member_name'],
//                                       textAlign: TextAlign.center,
//                                       style: GoogleFonts.kavoon(
//                                         letterSpacing: 1,
//                                         fontSize: size.height * 0.025,
//                                         color: const Color(0xffad2e27),
//                                       ),
//                                     )
//                                 ),
//                                 memberMobile != '' && memberEmail != '' ? Positioned(
//                                   top: size.height * 0.21,
//                                   left: size.width * 0.2,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white10,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             callAction(memberMobile);
//                                           },
//                                           icon: const Icon(Icons.phone),
//                                           color: Colors.blueAccent,
//                                           iconSize: size.height * 0.03
//                                       )
//                                   ),
//                                 ) : Positioned(
//                                   top: size.height * 0.21,
//                                   left: size.width * 0.25,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white10,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             callAction(memberMobile);
//                                           },
//                                           icon: const Icon(Icons.phone),
//                                           color: Colors.blueAccent,
//                                           iconSize: size.height * 0.03
//                                       )
//                                   ),
//                                 ),
//                                 memberMobile != '' && memberEmail != '' ? Positioned(
//                                   top: size.height * 0.21,
//                                   left: size.width * 0.35,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white10,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             smsAction(memberMobile);
//                                           },
//                                           icon: const Icon(Icons.message),
//                                           color: Colors.orange,
//                                           iconSize: size.height * 0.03
//                                       )
//                                   ),
//                                 ) : Positioned(
//                                   top: size.height * 0.21,
//                                   left: size.width * 0.43,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white10,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             smsAction(memberMobile);
//                                           },
//                                           icon: const Icon(Icons.message),
//                                           color: Colors.orange,
//                                           iconSize: size.height * 0.03
//                                       )
//                                   ),
//                                 ),
//                                 memberMobile != '' && memberEmail != ''  ? Positioned(
//                                   top: size.height * 0.21,
//                                   left: size.width * 0.5,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             whatsappAction(memberMobile);
//                                           },
//                                           icon: const Icon(LineAwesomeIcons.what_s_app),
//                                           color: Colors.green,
//                                           iconSize: size.height * 0.035
//                                       )
//                                   ),
//                                 ) : Positioned(
//                                   top: size.height * 0.21,
//                                   left: size.width * 0.6,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             whatsappAction(memberMobile);
//                                           },
//                                           icon: const Icon(LineAwesomeIcons.what_s_app),
//                                           color: Colors.green,
//                                           iconSize: size.height * 0.035
//                                       )
//                                   ),
//                                 ),
//                                 memberEmail != '' ? Positioned(
//                                   top: size.height * 0.21,
//                                   left: memberMobile == '' ? size.width * 0.45 : size.width * 0.65,
//                                   child: Container(
//                                       height: size.height * 0.05,
//                                       width : size.width * 0.11,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(25),
//                                         // color: Colors.white,
//                                       ),
//                                       child: IconButton(
//                                           onPressed: () {
//                                             emailAction(memberEmail);
//                                           },
//                                           icon: const Icon(Icons.email_outlined),
//                                           color: Colors.red,
//                                           iconSize: size.height * 0.035
//                                       )
//                                   ),
//                                 ) : Container(),
//                                 memberMobile == '' && memberEmail == '' ? Container(
//                                   padding: EdgeInsets.only(top: size.height * 0.21),
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     'Communication details are not available',
//                                     style: GoogleFonts.secularOne(color: const Color(0xFFE1A243)),
//                                   ),
//                                 ) : Container(),
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             height: size.height * 0.02,
//                           ),
//                           Container(
//                             constraints: BoxConstraints.expand(height: size.height * 0.04),
//                             child : TabBar(
//                                 unselectedLabelColor: Colors.redAccent,
//                                 indicatorSize: TabBarIndicatorSize.label,
//                                 isScrollable: true,
//                                 indicator: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(50),
//                                     color: Colors.redAccent),
//                                 tabs: [
//                                   Tab(
//                                     child: Container(
//                                       padding: const EdgeInsets.only(left: 10, right: 10),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(50),
//                                           border: Border.all(color: Colors.redAccent, width: 1.5)),
//                                       child: const Align(
//                                         alignment: Alignment.center,
//                                         child: Text("Basic"),
//                                       ),
//                                     ),
//                                   ),
//                                   Tab(
//                                     child: Container(
//                                       padding: const EdgeInsets.only(left: 10, right: 10),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(50),
//                                           border: Border.all(color: Colors.redAccent, width: 1.5)),
//                                       child: const Align(
//                                         alignment: Alignment.center,
//                                         child: Text("Education"),
//                                       ),
//                                     ),
//                                   ),
//                                   Tab(
//                                     child: Container(
//                                       padding: const EdgeInsets.only(left: 10, right: 10),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(50),
//                                           border: Border.all(color: Colors.redAccent, width: 1.5)),
//                                       child: const Align(
//                                         alignment: Alignment.center,
//                                         child: Text("Formation"),
//                                       ),
//                                     ),
//                                   ),
//                                   Tab(
//                                     child: Container(
//                                       padding: const EdgeInsets.only(left: 10, right: 10),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(50),
//                                           border: Border.all(color: Colors.redAccent, width: 1.5)),
//                                       child: const Align(
//                                         alignment: Alignment.center,
//                                         child: Text("Holy Order"),
//                                       ),
//                                     ),
//                                   ),
//                                   Tab(
//                                     child: Container(
//                                       padding: const EdgeInsets.only(left: 10, right: 10),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(50),
//                                           border: Border.all(color: Colors.redAccent, width: 1.5)),
//                                       child: const Align(
//                                         alignment: Alignment.center,
//                                         child: Text("Family Info"),
//                                       ),
//                                     ),
//                                   ),
//                                   Tab(
//                                     child: Container(
//                                       padding: const EdgeInsets.only(left: 10, right: 10),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(50),
//                                           border: Border.all(color: Colors.redAccent, width: 1.5)),
//                                       child: const Align(
//                                         alignment: Alignment.center,
//                                         child: Text("Health"),
//                                       ),
//                                     ),
//                                   ),
//                                 ]
//                             ),
//                           ),
//                           SizedBox(
//                             height: size.height * 0.01,
//                           ),
//                           Expanded(
//                             child: TabBarView(
//                               children: tabsContent,
//                             ),
//                           )
//                         ],),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//       ),
//     );
//   }
// }
