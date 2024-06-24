import 'dart:convert';
import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kjpraipur/widget/common/common.dart';
import 'package:kjpraipur/widget/common/internet_connection_checker.dart';
import 'package:kjpraipur/widget/common/snackbar.dart';
import 'package:kjpraipur/widget/theme_color/theme_color.dart';
import 'package:kjpraipur/widget/widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditBasicDetailsScreen extends StatefulWidget {
  const EditBasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditBasicDetailsScreen> createState() => _EditBasicDetailsScreenState();
}

class _EditBasicDetailsScreenState extends State<EditBasicDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  final bool _canPop = false;
  bool load = true;
  bool _isLoading = true;
  bool isFirstName = false;
  bool isDob = false;
  bool isAge = false;
  bool isMobile = false;
  bool isEmail = false;
  bool isMemberType = false;
  bool isPin = false;
  bool isAadhar = false;
  bool isPan = false;
  bool isVoter = false;
  bool isPassport = false;

  var firstNameController = TextEditingController();
  var middleNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var dateOfBirthController = TextEditingController();
  var ageController = TextEditingController();
  var placeOfBirthController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var aadharController = TextEditingController();
  var voterController = TextEditingController();
  var panController = TextEditingController();
  var passportController = TextEditingController();
  var streetController = TextEditingController();
  var street2Controller = TextEditingController();
  var cityController = TextEditingController();
  var zipCodeController = TextEditingController();

  String image = '';
  String middle = '';
  String last = '';
  String mobile = '';
  String street2 = '';
  String zip = '';
  String aadharNo = '';
  String voterNo = '';
  String panNo = '';
  String passNo = '';
  String isDOBandAge = '';
  String dateOfBirth = '';
  String age = '';
  String email = '';
  String bloodGroupID = '';
  String bloodGroup = '';
  String languageName = '';
  String motherTongueID = '';
  String motherTongue = '';
  String mType = 'Sister';
  String mTitle = '';
  String mTitleID = '';
  String district = '';
  String districtID = '';
  String state = '';
  String stateID = '';
  String country = '';
  String countryID = '';
  var _image;
  var _attachAadharFile;
  var _attachAadharFileName;
  var _attachVoterFile;
  var _attachVoterFileName;
  var _attachPanFile;
  var _attachPanFileName;
  var _attachPassportFile;
  var _attachPassportFileName;

  var _netAadharAttachFile;
  var _netVoterAttachFile;
  var _netPanAttachFile;
  var _netPassportAttachFile;
  var path;
  var netPath;
  var netFileName;
  var baseImageFile;
  var baseAadharFile;
  var baseVoterFile;
  var basePanFile;
  var basePassportFile;

  List memberBasic = [];
  List memberTitle = [];
  List bloodData = [];
  List languagesKnownData = [];
  List languagesIDs = [];
  List languages = [];
  List motherTongueData = [];
  List districtData = [];
  List districtBasedData = [];
  List stateData = [];
  List stateBasedData = [];
  List countryData = [];
  List<DropDownValueModel> memberTitleDropDown = [];
  List<DropDownValueModel> bloodDropDown = [];
  List<DropDownValueModel> languagesKnownDropDown = [];
  List<DropDownValueModel> motherTongueDropDown = [];
  List<DropDownValueModel> districtDropDown = [];
  List<DropDownValueModel> stateDropDown = [];
  List<DropDownValueModel> countryDropDown = [];

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode middleNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode isDOBFocusNode = FocusNode();
  FocusNode ageFocusNode = FocusNode();
  FocusNode placeFocusNode = FocusNode();
  FocusNode bloodFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileFocusNode = FocusNode();
  FocusNode streetFocusNode = FocusNode();
  FocusNode street2FocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode districtFocusNode = FocusNode();
  FocusNode zipFocusNode = FocusNode();
  FocusNode aadharFocusNode = FocusNode();
  FocusNode voterFocusNode = FocusNode();
  FocusNode panFocusNode = FocusNode();
  FocusNode passportFocusNode = FocusNode();

  List<dynamic> options = [
    {'id': 1, 'name': 'Option 1'},
    {'id': 2, 'name': 'Option 2'},
    {'id': 3, 'name': 'Option 3'},
    {'id': 4, 'name': 'Option 4'},
    {'id': 5, 'name': 'Option 5'},
    {'id': 6, 'name': 'Option 6'},
  ];

  List<dynamic> selectedOptions = [
    {'id': 2, 'name': 'Option 2'},
    {'id': 4, 'name': 'Option 4'},
  ];

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': 'Bearer $authToken',
  };

  getMemberBasicData() async {
    var request =  userMember == 'Member' ? http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$id)]&fields=['name','middle_name','image_1920','last_name','member_type','title','place_of_birth','is_dob_or_age','dob','age','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','blood_group_id','mother_tongue_id','known_language_ids','aadhar_proof','pan_proof','voter_proof','passport_proof','unique_code','voter_id','pancard_no','passport_no']")) : http.Request('GET', Uri.parse("$baseUrl/search_read/res.member?domain=[('id','=',$memberId)]&fields=['name','middle_name','image_1920','last_name','member_type','title','place_of_birth','is_dob_or_age','dob','age','street','street2','place','city','district_id','state_id','country_id','zip','mobile','email','blood_group_id','mother_tongue_id','known_language_ids','aadhar_proof','pan_proof','voter_proof','passport_proof','unique_code','voter_id','pancard_no','passport_no']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      setState(() {
        _isLoading = false;
      });
      memberBasic = data;

      for(int i = 0; i < memberBasic.length; i++) {
        image = memberBasic[i]['image_1920'];
        firstNameController.text = memberBasic[i]['name'];
        middleNameController.text = memberBasic[i]['middle_name'];
        middle = memberBasic[i]['middle_name'];
        lastNameController.text = memberBasic[i]['last_name'];
        last = memberBasic[i]['last_name'];
        mType = memberBasic[i]['member_type'];
        if(memberBasic[i]['title'] != '' && memberBasic[i]['title'] != null && memberBasic[i]['title'].isNotEmpty) {
          mTitleID = memberBasic[i]['title'][0].toString();
          mTitle = memberBasic[i]['title'][1];
        } else {
          mTitle = '';
          mTitleID = '';
        }
        if(memberBasic[i]['is_dob_or_age'] == 'dob') {
          isDOBandAge = memberBasic[i]['is_dob_or_age'];
          isDob = true;
          isAge = false;
        } else {
          isDOBandAge = memberBasic[i]['is_dob_or_age'];
          isAge = true;
          isDob = false;
        }
        if(memberBasic[i]['dob'] != '') {
          dateOfBirthController.text = DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(memberBasic[i]['dob']));
          // dateOfBirth = DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-dd").parse(memberBasic[i]['dob']));
          dateOfBirth = memberBasic[i]['dob'];
          int ag = memberBasic[i]['age'];
          ageController.text =  ag.toString();
          age = ag.toString();
        }
        placeOfBirthController.text = memberBasic[i]['place_of_birth'];
        if(memberBasic[i]['blood_group_id'].isNotEmpty && memberBasic[i]['blood_group_id'] != null && memberBasic[i]['blood_group_id'] != []) {
          bloodGroupID = memberBasic[i]['blood_group_id'][0].toString();
          bloodGroup = memberBasic[i]['blood_group_id'][1];
        } else {
          bloodGroupID = '';
          bloodGroup = '';
        }
        if(memberBasic[i]['known_language_ids'].isNotEmpty && memberBasic[i]['known_language_ids'] != null && memberBasic[i]['known_language_ids'] != []) {
          for(int j = 0; j < memberBasic[i]['known_language_ids'].length; j++) {
            languagesIDs.add(memberBasic[i]['known_language_ids'][j]['id']);
            languages.add(memberBasic[i]['known_language_ids'][j]['name']);
          }
        }
        if(memberBasic[i]['mother_tongue_id'].isNotEmpty && memberBasic[i]['mother_tongue_id'] != null && memberBasic[i]['mother_tongue_id'] != []) {
          motherTongueID = memberBasic[i]['mother_tongue_id'][0].toString();
          motherTongue = memberBasic[i]['mother_tongue_id'][1];
        } else {
          motherTongueID = '';
          motherTongue = '';
        }
        emailController.text = memberBasic[i]['email'];
        email = memberBasic[i]['email'];
        mobileController.text = memberBasic[i]['mobile'];
        mobile = memberBasic[i]['mobile'];
        streetController.text = memberBasic[i]['street'];
        street2Controller.text = memberBasic[i]['street2'];
        street2 = memberBasic[i]['street2'];
        cityController.text = memberBasic[i]['city'];
        if(memberBasic[i]['district_id'] != [] && memberBasic[i]['district_id'] != null && memberBasic[i]['district_id'].isNotEmpty) {
          districtID = memberBasic[i]['district_id'][0].toString();
          district = memberBasic[i]['district_id'][1];
          stateDropDown.clear();
          setState(() {
            getDistrictDetail();
          });
        } else {
          districtID = '';
          district = '';
        }
        if(memberBasic[i]['state_id'] != [] && memberBasic[i]['state_id'] != null && memberBasic[i]['state_id'].isNotEmpty) {
          stateID = memberBasic[i]['state_id'][0].toString();
          state = memberBasic[i]['state_id'][1];
          countryDropDown.clear();
          setState(() {
            getStateDetail();
          });
        } else {
          stateID = '';
          state = '';
        }

        if(memberBasic[i]['country_id'] != [] && memberBasic[i]['country_id'] != null && memberBasic[i]['country_id'].isNotEmpty) {
          countryID = memberBasic[i]['country_id'][0].toString();
          country = memberBasic[i]['country_id'][1];
        } else {
          countryID = '';
          country = '';
        }
        zipCodeController.text = memberBasic[i]['zip'];
        zip = memberBasic[i]['zip'];

        if(memberBasic[i]['aadhar_proof'] != '' && memberBasic[i]['aadhar_proof_name'] != '') {
          if(memberBasic[i]['unique_code'] == 'false') {
            aadharController.text = '';
            aadharNo = '';
          } else {
            aadharController.text = memberBasic[i]['unique_code'];
            aadharNo = memberBasic[i]['unique_code'];
          }
          _netAadharAttachFile = memberBasic[i]['aadhar_proof'];
          var aadhars = memberBasic[i]['aadhar_proof'];
          File file = File(aadhars);
          var path = file.path;
          _attachAadharFileName = path.split("/").last;
        } else if(memberBasic[i]['unique_code'] != '') {
          aadharController.text = memberBasic[i]['unique_code'];
          aadharNo = memberBasic[i]['unique_code'];
          _attachAadharFile = '';
          _attachAadharFileName = '';
          _netAadharAttachFile = '';
        } else {
          aadharController.text = '';
          _attachAadharFile = '';
          _attachAadharFileName = '';
          _netAadharAttachFile = '';
        }

        if(memberBasic[i]['voter_proof'] != '' && memberBasic[i]['voter_proof_name'] != '') {
          voterController.text = memberBasic[i]['voter_id'];
          voterNo =  memberBasic[i]['voter_id'];
          _netVoterAttachFile = memberBasic[i]['voter_proof'];
          var voters = memberBasic[i]['voter_proof'];
          File file = File(voters);
          var path = file.path;
          _attachVoterFileName = path.split("/").last;
        } else if(memberBasic[i]['voter_id'] != '') {
          voterController.text = memberBasic[i]['voter_id'];
          voterNo =  memberBasic[i]['voter_id'];
          _attachVoterFile = '';
          _attachVoterFileName = '';
          _netVoterAttachFile = '';
        } else {
          voterController.text = '';
          _attachVoterFile = '';
          _attachVoterFileName = '';
          _netVoterAttachFile = '';
        }

        if(memberBasic[i]['pan_proof'] != '' && memberBasic[i]['pan_proof_name'] != '') {
          panController.text = memberBasic[i]['pancard_no'];
          panNo = memberBasic[i]['pancard_no'];
          _netPanAttachFile = memberBasic[i]['pan_proof'];
          var pans = memberBasic[i]['pan_proof'];
          File file = File(pans);
          var path = file.path;
          _attachPanFileName = path.split("/").last;
        } else if(memberBasic[i]['pancard_no'] != '') {
          panController.text = memberBasic[i]['pancard_no'];
          panNo = memberBasic[i]['pancard_no'];
          _attachPanFile = '';
          _attachPanFileName = '';
          _netPanAttachFile = '';
        } else {
          panController.text = '';
          _attachPanFile = '';
          _attachPanFileName = '';
          _netPanAttachFile = '';
        }

        if(memberBasic[i]['passport_proof'] != '' && memberBasic[i]['passport_proof_name'] != '') {
          passportController.text = memberBasic[i]['passport_no'];
          passNo = memberBasic[i]['passport_no'];
          _netPassportAttachFile = memberBasic[i]['passport_proof'];
          var passports = memberBasic[i]['passport_proof'];
          File file = File(passports);
          var path = file.path;
          _attachPassportFileName = path.split("/").last;
        } else if(memberBasic[i]['passport_no'] != '') {
          passportController.text = memberBasic[i]['passport_no'];
          passNo = memberBasic[i]['passport_no'];
          _attachPassportFile = '';
          _attachPassportFileName = '';
          _netPassportAttachFile = '';
        } else {
          passportController.text = '';
          _attachPassportFile = '';
          _attachPassportFileName = '';
          _netPassportAttachFile = '';
        }
      }
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  // Profile Image
  getImage() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (resultFile != null) {
      setState(() {
        PlatformFile imageFile = resultFile.files.first;
        var imagePick = imageFile.path;

        var attachFileType = imagePick?.split('.').last;

        File files = File(imagePick!);
        _image = files;
        List<int> fileBytes = files.readAsBytesSync();
        var bFile = base64Encode(fileBytes);
        baseImageFile = bFile;

        final aaf = File(imagePick);
        int sizeInBytes = aaf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if(sizeInMb <= 25) {
          // This file is smaller than or equal to 25 MB
        } else {
          // This file is larger than 25 MB
        }
      });
    }
  }

  // Aadhar File
  getAadharFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['docx', 'pdf'],
    );

    if(resultFile != null) {
      setState(() {
        PlatformFile aadharFile = resultFile.files.first;
        _attachAadharFile = aadharFile.path;
        _attachAadharFileName = aadharFile.name;

        var attachFileType = _attachAadharFile.split('.').last;
        if(attachFileType != 'jpg') {
          File files = File(_attachAadharFile);
          List<int> fileBytes = files.readAsBytesSync();
          var bFile = base64Encode(fileBytes);
          baseAadharFile = 'data:@file/$attachFileType;base64,$bFile';
        } else {
          _attachAadharFile = '';
          _attachAadharFileName = '';
          AnimatedSnackBar.show(
              context,
              'Please select the PDF file or document file.',
              Colors.red
          );
        }

        final aaf = File(_attachAadharFile);
        int sizeInBytes = aaf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb <= 25){
          // This file is Longer the
        } else {

        }
      });
    }
  }

  // Voter File
  getVoterFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['docx', 'pdf'],
    );

    if(resultFile != null) {
      setState(() {
        PlatformFile voterFile = resultFile.files.first;
        _attachVoterFile = voterFile.path;
        _attachVoterFileName = voterFile.name;

        var attachFileType = _attachVoterFile.split('.').last;
        if(attachFileType != 'jpg') {
          File files = File(_attachVoterFile);
          List<int> fileBytes = files.readAsBytesSync();
          var bFile = base64Encode(fileBytes);
          baseVoterFile = 'data:@file/$attachFileType;base64,$bFile';
        } else {
          _attachVoterFile = '';
          _attachVoterFileName = '';
          AnimatedSnackBar.show(
              context,
              'Please select the PDF file or document file.',
              Colors.red
          );
        }

        final votef = File(_attachVoterFile);
        int sizeInBytes = votef.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb <= 25){
          // This file is Longer the
        } else {

        }
      });
    }
  }

  // PAN File
  getPanFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['docx', 'pdf'],
    );

    if(resultFile != null) {
      setState(() {
        PlatformFile panFile = resultFile.files.first;
        _attachPanFile = panFile.path;
        _attachPanFileName = panFile.name;

        var attachFileType = _attachPanFile.split('.').last;
        if(attachFileType != 'jpg') {
          File files = File(_attachPanFile);
          List<int> fileBytes = files.readAsBytesSync();
          var bFile = base64Encode(fileBytes);
          basePanFile = 'data:@file/$attachFileType;base64,$bFile';
        } else {
          _attachPanFile = '';
          _attachPanFileName = '';
          AnimatedSnackBar.show(
              context,
              'Please select the PDF file or document file.',
              Colors.red
          );
        }

        final panf = File(_attachPanFile);
        int sizeInBytes = panf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb <= 25){
          // This file is Longer the
        } else {

        }
      });
    }
  }

  // Passport File
  getPassportFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['docx', 'pdf'],
    );

    if(resultFile != null) {
      setState(() {
        PlatformFile passFile = resultFile.files.first;
        _attachPassportFile = passFile.path;
        _attachPassportFileName = passFile.name;

        var attachFileType = _attachPassportFile.split('.').last;
        if(attachFileType != 'jpg') {
          File files = File(_attachPassportFile);
          List<int> fileBytes = files.readAsBytesSync();
          var bFile = base64Encode(fileBytes);
          basePassportFile = 'data:@file/$attachFileType;base64,$bFile';
        } else {
          _attachPassportFile = '';
          _attachPassportFileName = '';
          AnimatedSnackBar.show(
              context,
              'Please select the PDF file or document file.',
              Colors.red
          );
        }

        final pf = File(_attachPassportFile);
        int sizeInBytes = pf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb <= 25){
          // This file is Longer the
        } else {

        }
      });
    }
  }

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  getMemberTitleData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.partner.title?fields=['name']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      List data = json.decode(responseData)['data'];
      memberTitle = data;
      for(int i = 0; i < memberTitle.length; i++) {
        if(memberTitle[i]['name'] == 'Sr.') {
          memberTitleDropDown.add(DropDownValueModel(name: memberTitle[i]['name'], value: memberTitle[i]['id']));
        }
      }
      return memberTitleDropDown;
    }
    else {
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

  getBloodGroupData() async {
    var request = http.Request(
        'GET', Uri.parse("$baseUrl/search_read/res.blood.group?fields=['name']"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      List data = json.decode(responseData)['data'];
      bloodData = data;
      for(int i = 0; i < bloodData.length; i++) {
        bloodDropDown.add(DropDownValueModel(name: bloodData[i]['name'], value: bloodData[i]['id']));
      }
      return bloodDropDown;
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

  getLanguagesKnownData() async {
    var request = http.Request(
        'GET', Uri.parse("$baseUrl/search_read/res.languages?fields=['name']&limit=500"));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      List data = json.decode(responseData)['data'];
      languagesKnownData = data;
      for(int i = 0; i < languagesKnownData.length; i++) {
        languagesKnownDropDown.add(DropDownValueModel(name: languagesKnownData[i]['name'], value: languagesKnownData[i]['id']));
      }
      return languagesKnownDropDown;
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

  getMotherTongueData() async {
    var request = http.Request(
        'GET', Uri.parse("$baseUrl/search_read/res.languages?fields=['name']&limit=500"));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      List data = json.decode(responseData)['data'];
      motherTongueData = data;
      for(int i = 0; i < motherTongueData.length; i++) {
        motherTongueDropDown.add(DropDownValueModel(name: motherTongueData[i]['name'], value: motherTongueData[i]['id']));
      }
      return motherTongueDropDown;
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

  getDistrictData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.state.district?fields=['name','state_id']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      districtData = data;
      for(int i = 0; i < districtData.length; i++) {
        setState(() {
          districtDropDown.add(DropDownValueModel(name: districtData[i]['name'], value: districtData[i]['id']));
        });
      }
      return districtDropDown;
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

  getStateData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country.state?fields=['name','country_id']&limit=2000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      stateData = data;
      for(int i = 0; i < stateData.length; i++) {
        setState(() {
          stateDropDown.add(DropDownValueModel(name: stateData[i]['name'], value: stateData[i]['id']));
        });
      }
      return stateDropDown;
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

  getCountryData() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country?fields=['name']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      countryData = data;
      for(int i = 0; i < countryData.length; i++) {
        setState(() {
          countryDropDown.add(DropDownValueModel(name: countryData[i]['name'], value: countryData[i]['id']));
        });
      }
      return countryDropDown;
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

  getDistrictDetail() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.state.district?id=$districtID&fields=['name','state_id']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];

      for(int i = 0; i < data.length; i++) {
        if(data[i]['state_id'] != '' && data[i]['state_id'] != []) {
          int id = data[i]['state_id'][0];
          stateID = id.toString();
        } else {
          stateID = '';
        }
      }
      getDistrictBased(stateID);
    }
    else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  getStateDetail() async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country.state?id=$stateID&fields=['name','country_id']&limit=2000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];

      for(int i = 0; i < data.length; i++) {
        if(data[i]['country_id'] != '' && data[i]['country_id'] != []) {
          int id = data[i]['country_id'][0];
          countryID = id.toString();
        } else {
          countryID = '';
        }
      }
      getStateBased(countryID);
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  getDistrictBased(stateID) async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country.state?id=$stateID&fields=['name','country_id']&limit=2000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      districtBasedData = data;

      if(districtBasedData.isNotEmpty){
        for(int i = 0; i < districtBasedData.length; i++) {
          setState(() {
            stateDropDown.add(DropDownValueModel(name: districtBasedData[i]['name'], value: districtBasedData[i]['id']));
          });
        }
        return stateDropDown;
      } else {
        for(int i = 0; i <= districtBasedData.length; i++) {
          setState(() {
            stateDropDown.add(DropDownValueModel(name: "No data found", value: i));
          });
        }
        return stateDropDown;
      }
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  getStateBased(countryID) async {
    var request = http.Request('GET', Uri.parse("$baseUrl/search_read/res.country?id=$countryID&fields=['name']&limit=1000"));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      stateBasedData = data;

      if(stateBasedData.isNotEmpty){
        for(int i = 0; i < stateBasedData.length; i++) {
          setState(() {
            countryDropDown.add(DropDownValueModel(name: stateBasedData[i]['name'], value: stateBasedData[i]['id']));
          });
        }
        return countryDropDown;
      } else {
        for(int i = 0; i <= stateBasedData.length; i++) {
          setState(() {
            countryDropDown.add(DropDownValueModel(name: "No data found", value: i));
          });
        }
        return countryDropDown;
      }
    } else {
      final message = json.decode(await response.stream.bytesToString())['message'];
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

  update(String name,memberType) async {
    if(firstNameController.text.isNotEmpty && mType.isNotEmpty) {

      String middleName = middleNameController.text.toString();
      String lastName = lastNameController.text.toString();
      String place = placeOfBirthController.text.toString();
      String street = streetController.text.toString();
      String street2 = street2Controller.text.toString();
      String city = cityController.text.toString();
      String zip = zipCodeController.text.toString();

      var aadharAttachment;
      if(_attachAadharFile != '' && _attachAadharFile != null) {
        aadharAttachment = baseAadharFile;
      } else if(_netAadharAttachFile != '' && _netAadharAttachFile != null) {
        aadharAttachment = _netAadharAttachFile;
      } else {
        aadharAttachment = '';
      }

      var voterAttachment;
      if(_attachVoterFile != '' && _attachVoterFile != null) {
        voterAttachment = baseVoterFile;
      } else if(_netVoterAttachFile != '' && _netVoterAttachFile != null) {
        voterAttachment = _netVoterAttachFile;
      } else {
        voterAttachment = '';
      }

      var panAttachment;
      if(_attachPanFile != '' && _attachPanFile != null) {
        panAttachment = basePanFile;
      } else if(_netPanAttachFile != '' && _netPanAttachFile != null) {
        panAttachment = _netPanAttachFile;
      } else {
        panAttachment = '';
      }

      var passAttachment;
      if(_attachPassportFile != '' && _attachPassportFile != null) {
        passAttachment = basePassportFile;
      } else if(_netPassportAttachFile != '' && _netPassportAttachFile != null) {
        passAttachment = _netPassportAttachFile;
      } else {
        passAttachment = '';
      }

      var request = userMember == 'Member' ? http.MultipartRequest('PUT', Uri.parse('$baseUrl/write/res.member?ids=[$id]')) : http.MultipartRequest('PUT', Uri.parse('$baseUrl/write/res.member?ids=[$memberId]'));
      request.fields.addAll({
        'name':'$name','middle_name':'$middleName','last_name':'$lastName','is_dob_or_age':'$isDOBandAge','dob':'$dateOfBirth','age':'$age','member_type':'$memberType','place_of_birth':'$place','mobile':'$mobile','email':'$email','street':'$street','street2':'$street2','city':'$city','zip':'$zip','unique_code': '$aadharNo','voter_id': '$voterNo','pancard_no': '$panNo','passport_no': '$passNo'
      });

      if(bloodGroupID != null) {
        request.fields.addAll({'blood_group_id':bloodGroupID});
      } else {
        List bloodGroup = [];
        request.fields.addAll({'blood_group_id':'$bloodGroup'});
      }

      if(motherTongueID != null) {
        request.fields.addAll({'mother_tongue_id':motherTongueID});
      } else {
        List motherTongue = [];
        request.fields.addAll({'mother_tongue_id':'$motherTongue'});
      }

      if(languagesIDs != null && languagesIDs.isNotEmpty) {
        request.fields.addAll({'known_language_ids':'$languagesIDs'});
      } else {
        List knownLanguage = [];
        request.fields.addAll({'known_language_ids':'$knownLanguage'});
      }

      if(countryID != null) {
        request.fields.addAll({'country_id':countryID});
      } else {
        List country = [];
        request.fields.addAll({'country_id':'$country'});
      }

      if(stateID != null) {
        request.fields.addAll({'state_id':stateID});
      } else {
        List state = [];
        request.fields.addAll({'state_id':'$state'});
      }

      if(districtID != null) {
        request.fields.addAll({'district_id':districtID});
      } else {
        List district = [];
        request.fields.addAll({'district_id':'$district'});
      }

      if(_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image_1920', _image!.path));
      } else {
        request.fields.addAll({'image_1920': '$image'});
      }

      if(_attachAadharFile != null && _attachAadharFile != '') {
        request.files.add(await http.MultipartFile.fromPath('aadhar_proof', _attachAadharFile));
      } else {
        String aadhar = 'false';
        request.fields.addAll({'aadhar_proof': '$aadhar'});
      }

      if(_attachVoterFile != null && _attachVoterFile != '') {
        request.files.add(await http.MultipartFile.fromPath('voter_proof', _attachVoterFile));
      } else {
        request.fields.addAll({'voter_proof': '$voterAttachment'});
      }

      if(_attachPanFile != null && _attachPanFile != '') {
        request.files.add(await http.MultipartFile.fromPath('pan_proof', _attachPanFile));
      } else {
        request.fields.addAll({'pan_proof': '$panAttachment'});
      }

      if(_attachPassportFile != null && _attachPassportFile != '') {
        request.files.add(await http.MultipartFile.fromPath('passport_proof', _attachPassportFile));
      } else {
        request.fields.addAll({'passport_proof': '$passAttachment'});
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if(response.statusCode == 200) {
        final message = json.decode(await response.stream.bytesToString())['message'];
        setState(() {
          _isLoading = false;
          load = false;
          AnimatedSnackBar.show(
              context,
              'Basic details data updated successfully.',
              Colors.green
          );
          Navigator.pop(context);
          Navigator.pop(context, 'refresh');
        });
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
    } else {
      AnimatedSnackBar.show(
          context,
          'Please fill the required fields',
          Colors.red
      );
    }
  }

  void loadDataWithDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      getMemberBasicData();
    });
  }

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningAlertDialog(
          message: 'Please check your internet connection.',
          onOkPressed: () {
            Navigator.pop(context);
            CheckInternetConnection.checkInternet().then((value) {
              if (value) {
                return null;
              } else {
                showDialogBox();
              }
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    getMemberTitleData();
    getBloodGroupData();
    getLanguagesKnownData();
    getMotherTongueData();
    getDistrictData();
    getStateData();
    getCountryData();
    loadDataWithDelay();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_canPop) {
          return true;
        } else {
          Navigator.pop(context, 'refresh');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: screenBackgroundColor,
        appBar: AppBar(
          title: const Text('Edit Basic Details'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A3F85),
                      Color(0xFFFA761E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading ? Center(
              child: Container(
                  height: size.height * 0.1,
                  width: size.width * 0.2,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage( "assets/alert/spinner_1.gif"),
                    ),
                  )
              ),
            ) : Container(
              padding: EdgeInsets.only(left: size.width * 0.01, right: size.width * 0.01),
              alignment: Alignment.topLeft,
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    SizedBox(height: size.height * 0.02,),
                    Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 10)
                                )
                              ],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: _image != null ? FileImage(_image!) : image.isNotEmpty ? NetworkImage(image) : const AssetImage('assets/images/profile.png') as ImageProvider,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              width: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                onPressed: () {
                                  getImage();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02,),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      color: const Color(0xFFF0F0F0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Basic',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'First Name',
                                    style: GoogleFonts.poppins(
                                      fontSize: size.height * 0.018,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02,),
                                  Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: firstNameController,
                                focusNode: firstNameFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your first name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validation
                                validator: (val) {
                                  if (val!.isEmpty && val == '') {
                                    isFirstName = true;
                                  } else {
                                    isFirstName = false;
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(middleNameFocusNode);
                                },
                              ),
                            ),
                            isFirstName ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "First Name is required",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Middle Name',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: middleNameController,
                                focusNode: middleNameFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your middle name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(lastNameFocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Last Name',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: lastNameController,
                                focusNode: lastNameFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your last name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Member Type',
                                    style: GoogleFonts.poppins(
                                      fontSize: size.height * 0.018,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02,),
                                  Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                                ],
                              ),
                            ),
                            RadioListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              dense: true,
                              tileColor: inputColor,
                              activeColor: enableColor,
                              value: 'Sister',
                              groupValue: mType,
                              title: Text('Working Sister', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  if (value!.isEmpty && value == '') {
                                    isMemberType = true;
                                  } else {
                                    isMemberType = false;
                                    mType = value;
                                  }
                                });
                              },
                            ),
                            RadioListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              dense: true,
                              tileColor: inputColor,
                              activeColor: enableColor,
                              value: 'Junior Sister',
                              groupValue: mType,
                              title: Text('Junior Sister', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  if (value!.isEmpty && value == '') {
                                    isMemberType = true;
                                  } else {
                                    isMemberType = false;
                                    mType = value;
                                  }
                                });
                              },
                            ),
                            RadioListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              dense: true,
                              tileColor: inputColor,
                              activeColor: enableColor,
                              value: 'Novice',
                              groupValue: mType,
                              title: Text('Novice', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  if (value!.isEmpty && value == '') {
                                    isMemberType = true;
                                  } else {
                                    isMemberType = false;
                                    mType = value;
                                  }
                                });
                              },
                            ),
                            RadioListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              dense: true,
                              tileColor: inputColor,
                              activeColor: enableColor,
                              value: 'Retired Sister',
                              groupValue: mType,
                              title: Text('Retired Sister', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                              onChanged: (String? value) {
                                setState(() {
                                  if (value!.isEmpty && value == '') {
                                    isMemberType = true;
                                  } else {
                                    isMemberType = false;
                                    mType = value;
                                  }
                                });
                              },
                            ),
                            isMemberType ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Member Type is required",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Member Title',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                // controller: _level,
                                initialValue: mTitle,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: memberTitleDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: mTitle != '' ? mTitle : "Select member title",
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != "") {
                                    setState(() {
                                      mTitle = val.name;
                                      mTitleID = val.value.toString();
                                    });
                                  } else {
                                    setState(() {
                                      mTitle = '';
                                      mTitleID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Is DOB/Age?',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: RadioListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        dense: true,
                                        tileColor: inputColor,
                                        activeColor: enableColor,
                                        value: 'dob',
                                        groupValue: isDOBandAge,
                                        focusNode: isDOBFocusNode,
                                        title: Text('DOB', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                        onChanged: (String? value) {
                                          setState(() {
                                            isDOBandAge = value!;
                                            isDob = true;
                                            isAge = false;
                                          });
                                        },
                                    )
                                ),
                                SizedBox(width: size.width * 0.05,),
                                Expanded(
                                    child: RadioListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        dense: true,
                                        tileColor: inputColor,
                                        activeColor: enableColor,
                                        value: 'age',
                                        groupValue: isDOBandAge,
                                        focusNode: isDOBFocusNode,
                                        title: Text('Age', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                        onChanged: (String? value) {
                                          setState(() {
                                            isDOBandAge = value!;
                                            isAge = true;
                                            isDob = false;
                                          });
                                        },
                                      onFocusChange: (_) {
                                          FocusScope.of(context)
                                              .requestFocus(ageFocusNode);
                                      },
                                    )
                                ),
                              ],
                            ),
                            isDob == true ? SizedBox(
                              height: size.height * 0.01,
                            ) : isAge == true ? SizedBox(
                              height: size.height * 0.01,
                            ) : Container(),
                            if(isDob == true) Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Date of Birth',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            if(isDob == true) Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: dateOfBirthController,
                                keyboardType: TextInputType.datetime,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(
                                    Icons.calendar_month,
                                    color: Colors.indigo,
                                  ),
                                  hintText: "Choose the birthday date",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  DateTime? datePick = await showDatePicker(
                                    context: context,
                                    initialDate: dateOfBirthController.text.isNotEmpty ? format.parse(dateOfBirthController.text) : DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Colors.red,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: backgroundColor,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (datePick != null) {
                                    setState(() {
                                      var dateNow = DateTime.now();
                                      var diff = dateNow.difference(datePick);
                                      var year = ((diff.inDays)/365).round();
                                      ageController.text = year.toString();
                                      age = year.toString();
                                      dateOfBirthController.text = format.format(datePick);
                                      dateOfBirth = reverse.format(datePick);
                                    });
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(placeFocusNode);
                                },
                              ),
                            ),
                            if(isDob == true) SizedBox(
                              height: size.height * 0.005,
                            ),
                            isDob == true ? Container(
                              alignment: Alignment.topRight,
                              child: Text(
                                'Your age is : $age',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ) : isAge == true ? Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Age',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ) : Container(),
                            if(isAge == true) Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: ageController,
                                focusNode: ageFocusNode,
                                keyboardType: TextInputType.number,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your age",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(placeFocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Place of Birth',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: placeOfBirthController,
                                focusNode: placeFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your place of birth",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(bloodFocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Blood Group',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                // controller: _level,
                                initialValue: bloodGroup,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: bloodDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: bloodGroup != '' ? bloodGroup : "Select blood group",
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != "") {
                                    setState(() {
                                      bloodGroup = val.name;
                                      bloodGroupID = val.value.toString();
                                    });
                                  } else {
                                    setState(() {
                                      bloodGroup = '';
                                      bloodGroupID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Languages Known',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField.multiSelection(
                                initialValue: languages,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: languagesKnownDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: "Select languages known",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if(val.isNotEmpty) {
                                    for(int i = 0; i < val.length; i++) {
                                      setState((){
                                        languageName = val[i].name;
                                        languagesIDs.add(val[i].value);
                                        languages.add(languageName);
                                      });
                                    }
                                  } else {
                                    languagesIDs.clear();
                                    languages.clear();
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Mother Tongue',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                initialValue: motherTongue,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: motherTongueDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: motherTongue != '' ? motherTongue : "Select mother tongue",
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != "") {
                                    setState(() {
                                      motherTongue = val.name;
                                      motherTongueID = val.value.toString();
                                    });
                                  } else {
                                    setState(() {
                                      motherTongue = '';
                                      motherTongueID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Email',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: emailController,
                                focusNode: emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your Email",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validationValidator
                                validator: (val) {
                                  if(val!.isNotEmpty && val != '') {
                                    var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if(reg.hasMatch(val)) {
                                      email = emailController.text.toString();
                                      isEmail = false;
                                    } else {
                                      isEmail = true;
                                    }
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(mobileFocusNode);
                                },
                              ),
                            ),
                            isEmail ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid email address",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Mobile Number',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: mobileController,
                                focusNode: mobileFocusNode,
                                keyboardType: TextInputType.number,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your mobile number",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validationValidator
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"(^(?:[+0]9)?[0-9]{10,12}$)");
                                    if(reg.hasMatch(val)) {
                                      isMobile = false;
                                      mobile = mobileController.text.toString();
                                    } else {
                                      isMobile = true;
                                    }
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(streetFocusNode);
                                },
                              ),
                            ),
                            isMobile ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid mobile number",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02,),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      color: const Color(0xFFF0F0F0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Home Address',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Street',
                                    style: GoogleFonts.poppins(
                                      fontSize: size.height * 0.018,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: streetController,
                                focusNode: streetFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your street name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(street2FocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Street 2',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: street2Controller,
                                focusNode: street2FocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your second street name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(cityFocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'City',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: cityController,
                                focusNode: cityFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your city name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(districtFocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'District',
                                    style: GoogleFonts.poppins(
                                      fontSize: size.height * 0.018,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                initialValue: district,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: districtDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: district != '' ? district : "Select the district",
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != "") {
                                    setState(() {
                                      district = val.name;
                                      districtID = val.value.toString();
                                      if(district.isNotEmpty && district != '') {
                                        stateDropDown.clear();
                                        if(_isLoading == false) {
                                          _isLoading = true;
                                          getDistrictDetail();
                                          _isLoading = false;
                                        } else {
                                          _isLoading = false;
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      district = '';
                                      districtID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'State',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                initialValue: state,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: stateDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: state != '' ? state : "Select the state",
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != "") {
                                    setState(() {
                                      state = val.name;
                                      stateID = val.value.toString();
                                      if(state.isNotEmpty && state != '') {
                                        countryDropDown.clear();
                                        if(_isLoading == false) {
                                          _isLoading = true;
                                          getStateDetail();
                                          _isLoading = false;
                                        } else {
                                          _isLoading = false;
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      state = '';
                                      stateID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Country',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                initialValue: country,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: countryDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: country != '' ? country : "Select the country",
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null && val != "") {
                                    setState(() {
                                      country = val.name;
                                      countryID = val.value.toString();
                                    });
                                  } else {
                                    setState(() {
                                      country = '';
                                      countryID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'PIN code',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: zipCodeController,
                                focusNode: zipFocusNode,
                                keyboardType: TextInputType.number,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your pin code number",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validation
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^[1-9][0-9]{5}$");
                                    if(reg.hasMatch(val)) {
                                      isPin = false;
                                    } else {
                                      isPin = true;
                                    }
                                  } else {
                                    isPin = false;
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(aadharFocusNode);
                                },
                              ),
                            ),
                            isPin ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid PIN code",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02,),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      color: const Color(0xFFF0F0F0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Document',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Aadhar',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: aadharController,
                                focusNode: aadharFocusNode,
                                keyboardType: TextInputType.number,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Eg: 23456789023",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validation
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^\d{12}$");
                                    if(reg.hasMatch(val)) {
                                      isAadhar = false;
                                    } else {
                                      isAadhar = true;
                                    }
                                  } else {
                                    isAadhar = false;
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(voterFocusNode);
                                },
                              ),
                            ),
                            isAadhar ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid aadhar number",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.indigo
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        getAadharFile();
                                      });
                                    },
                                    icon: const Icon(Icons.attachment, color: Colors.white,),
                                    label: Text(
                                      "Attach Proof",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.breeSerif(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03,),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _attachAadharFileName != null && _attachAadharFileName != '' ? Flexible(child: Text('$_attachAadharFileName')) : const Text(''),
                                      _attachAadharFileName != null && _attachAadharFileName != ''? IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red,),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmAlertDialog(
                                                message: 'Are you sure want to delete the file ?',
                                                onCancelPressed: () {
                                                  cancel();
                                                },
                                                onYesPressed: () {
                                                  setState(() {
                                                    _attachAadharFile = '';
                                                    _attachAadharFileName = '';
                                                    _netAadharAttachFile = '';
                                                    AnimatedSnackBar.show(
                                                        context,
                                                        'File is removed successfully',
                                                        Colors.green
                                                    );
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ) : Container(),
                                      _attachAadharFileName != null && _attachAadharFileName != '' && _netAadharAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          netPath = _netAadharAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          fileName = netFileName;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedFromNetworkUrl(
                                                netUrl: netPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : _attachAadharFileName != null && _attachAadharFileName != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          localPath = _attachAadharFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          fileName = path.split("/").last;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedFromUrl(
                                                url: localPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Voter ID',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: voterController,
                                focusNode: voterFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Eg: ABC1234567",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validation
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^[A-Z]{3}[0-9]{7}$");
                                    if(reg.hasMatch(val)) {
                                      isVoter = false;
                                    } else {
                                      isVoter = true;
                                    }
                                  } else {
                                    isVoter = false;
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(panFocusNode);
                                },
                              ),
                            ),
                            isVoter ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid voter ID number",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.indigo
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        getVoterFile();
                                      });
                                    },
                                    icon: const Icon(Icons.attachment, color: Colors.white,),
                                    label: Text(
                                      "Attach Proof",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.breeSerif(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03,),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _attachVoterFileName != null && _attachVoterFileName != '' ? Flexible(child: Text('$_attachVoterFileName')) : const Text(''),
                                      _attachVoterFileName != null && _attachVoterFileName != ''? IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red,),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmAlertDialog(
                                                message: 'Are you sure want to delete the file ?',
                                                onCancelPressed: () {
                                                  cancel();
                                                },
                                                onYesPressed: () {
                                                  setState(() {
                                                    _attachVoterFile = '';
                                                    _attachVoterFileName = '';
                                                    _netVoterAttachFile = '';
                                                    AnimatedSnackBar.show(
                                                        context,
                                                        'File is removed successfully',
                                                        Colors.green
                                                    );
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ) : Container(),
                                      _attachVoterFileName != null && _attachVoterFileName != '' && _netVoterAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          netPath = _netVoterAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          fileName = netFileName;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedVoterFromNetworkUrl(
                                                netVoterUrl: netPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : _attachVoterFileName != null && _attachVoterFileName != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          localPath = _attachVoterFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          fileName = path.split("/").last;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedVoterFromUrl(
                                                voterUrl: localPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'PAN',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: panController,
                                focusNode: panFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Eg: ABCDE1234F",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validation
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^[A-Z]{5}[0-9]{4}[A-Z]{1}$");
                                    if(reg.hasMatch(val)) {
                                      isPan = false;
                                    } else {
                                      isPan = true;
                                    }
                                  } else {
                                    isPan = false;
                                  }
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(passportFocusNode);
                                },
                              ),
                            ),
                            isPan ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid PAN number",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.indigo
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        getPanFile();
                                      });
                                    },
                                    icon: const Icon(Icons.attachment, color: Colors.white,),
                                    label: Text(
                                      "Attach Proof",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.breeSerif(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03,),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _attachPanFileName != null && _attachPanFileName != '' ? Flexible(child: Text('$_attachPanFileName')) : const Text(''),
                                      _attachPanFileName != null && _attachPanFileName != ''? IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red,),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmAlertDialog(
                                                message: 'Are you sure want to delete the file ?',
                                                onCancelPressed: () {
                                                  cancel();
                                                },
                                                onYesPressed: () {
                                                  setState(() {
                                                    _attachPanFile = '';
                                                    _attachPanFileName = '';
                                                    _netPanAttachFile = '';
                                                    AnimatedSnackBar.show(
                                                        context,
                                                        'File is removed successfully',
                                                        Colors.green
                                                    );
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ) : Container(),
                                      _attachPanFileName != null && _attachPanFileName != '' && _netPanAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          netPath = _netPanAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          fileName = netFileName;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedPanFromNetworkUrl(
                                                netPanUrl: netPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : _attachPanFileName != null && _attachPanFileName != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          localPath = _attachPanFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          fileName = path.split("/").last;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedPanFromUrl(
                                                panUrl: localPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Passport',
                                style: GoogleFonts.poppins(
                                  fontSize: size.height * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                controller: passportController,
                                focusNode: passportFocusNode,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Eg: AB1234567",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: enableColor,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                // check tha validation
                                validator: (val) {
                                  if(val!.isNotEmpty) {
                                    var reg = RegExp(r"^[A-Z]{1,3}\d{6,9}$");
                                    if(reg.hasMatch(val)) {
                                      isPassport = false;
                                    } else {
                                      isPassport = true;
                                    }
                                  } else {
                                    isPassport = false;
                                  }
                                },
                              ),
                            ),
                            isPassport ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Please enter the valid passport number",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500
                                  ),
                                )
                            ) : Container(),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.indigo
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        getPassportFile();
                                      });
                                    },
                                    icon: const Icon(Icons.attachment, color: Colors.white,),
                                    label: Text(
                                      "Attach Proof",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.breeSerif(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03,),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _attachPassportFileName != null && _attachPassportFileName != '' ? Flexible(child: Text('$_attachPassportFileName')) : const Text(''),
                                      _attachPassportFileName != null && _attachPassportFileName != ''? IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red,),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmAlertDialog(
                                                message: 'Are you sure want to delete the file ?',
                                                onCancelPressed: () {
                                                  cancel();
                                                },
                                                onYesPressed: () {
                                                  setState(() {
                                                    _attachPassportFile = '';
                                                    _attachPassportFileName = '';
                                                    _netPassportAttachFile = '';
                                                    AnimatedSnackBar.show(
                                                        context,
                                                        'File is removed successfully',
                                                        Colors.green
                                                    );
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ) : Container(),
                                      _attachPassportFileName != null && _attachPassportFileName != '' && _netPassportAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          netPath = _netPassportAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          fileName = netFileName;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedPassFromNetworkUrl(
                                                netPassUrl: netPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : _attachPassportFileName != null && _attachPassportFileName != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          localPath = _attachPassportFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          fileName = path.split("/").last;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (_) => PDFViewerCachedPassFromUrl(
                                                passUrl: localPath,
                                              ),
                                            ),
                                          );
                                        },
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.1,),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: Container(
          decoration: const BoxDecoration(
              color: screenBackgroundColor,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey,
                      width: 1.0
                  )
              )
          ),
          padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: size.width * 0.4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red
                ),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context, 'refresh');
                      });
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                ),
              ),
              Container(
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: greenColor,
                  ),
                  child: TextButton(
                      onPressed: () {
                        if(firstNameController.text.isNotEmpty && mType.isNotEmpty) {
                          if(isMobile == true && isEmail == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid mobile number and email address',
                                Colors.red
                            );
                          } else if(isMobile == true && isEmail == false) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid mobile number',
                                Colors.red
                            );
                          } else if(isMobile == false && isEmail == true) {
                            AnimatedSnackBar.show(
                                context,
                                'Please enter the valid email number',
                                Colors.red
                            );
                          } else {
                            if(load) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              update(firstNameController.text.toString(), mType);
                            }
                          }
                        } else {
                          firstNameController.text.isEmpty ? isFirstName = true : isFirstName = false;
                          mType.isEmpty ? isMemberType = true : isMemberType = false;
                          AnimatedSnackBar.show(
                              context,
                              'Please fill the required fields',
                              Colors.red
                          );
                        }
                      },
                      child: Text('Update', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerCachedFromNetworkUrl extends StatelessWidget {
  const PDFViewerCachedFromNetworkUrl({Key? key, required this.netUrl}) : super(key: key);

  final String netUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.network(netUrl),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.file(File(url)),
    );
  }
}

class PDFViewerCachedVoterFromNetworkUrl extends StatelessWidget {
  const PDFViewerCachedVoterFromNetworkUrl({Key? key, required this.netVoterUrl}) : super(key: key);

  final String netVoterUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.network(netVoterUrl),
    );
  }
}

class PDFViewerCachedVoterFromUrl extends StatelessWidget {
  const PDFViewerCachedVoterFromUrl({Key? key, required this.voterUrl}) : super(key: key);

  final String voterUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.file(File(voterUrl)),
    );
  }
}

class PDFViewerCachedPanFromNetworkUrl extends StatelessWidget {
  const PDFViewerCachedPanFromNetworkUrl({Key? key, required this.netPanUrl}) : super(key: key);

  final String netPanUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.network(netPanUrl),
    );
  }
}

class PDFViewerCachedPanFromUrl extends StatelessWidget {
  const PDFViewerCachedPanFromUrl({Key? key, required this.panUrl}) : super(key: key);

  final String panUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.file(File(panUrl)),
    );
  }
}

class PDFViewerCachedPassFromNetworkUrl extends StatelessWidget {
  const PDFViewerCachedPassFromNetworkUrl({Key? key, required this.netPassUrl}) : super(key: key);

  final String netPassUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.network(netPassUrl),
    );
  }
}

class PDFViewerCachedPassFromUrl extends StatelessWidget {
  const PDFViewerCachedPassFromUrl({Key? key, required this.passUrl}) : super(key: key);

  final String passUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        centerTitle: true,
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
      body: SfPdfViewer.file(File(passUrl)),
    );
  }
}