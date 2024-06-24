import 'dart:convert';

import 'package:chengai/widget/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class EducationListProvider extends ChangeNotifier {
  List educations = [];

  void add(context) async {
    String url = '$baseUrl/member.education';
    Map data = {
      "params": {
        "filter": "[['member_id','=',$memberId]]",
        "query": "{id,study_level_id,program_id,year_of_passing,institution,note,particulars,duration,mode,result,status,attachment,attachment_name,board_or_university}"
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
      List data = jsonDecode(response.body)['result']['data']['result'];
      educations = data;
    } else {
      final message = jsonDecode(response.body)['result'];
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: message['message'],
        confirmBtnColor: greenColor,
        width: 100.0,
      );
    }
    notifyListeners();
  }

}