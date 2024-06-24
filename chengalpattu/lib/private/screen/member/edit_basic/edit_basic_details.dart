import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:chengai/widget/internet_checker.dart';
import 'package:chengai/widget/widget.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditBasicDetailsScreen extends StatefulWidget {
  const EditBasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditBasicDetailsScreen> createState() => _EditBasicDetailsScreenState();
}

class _EditBasicDetailsScreenState extends State<EditBasicDetailsScreen> {
  DateTime currentDateTime = DateTime.now();
  final LoginService loginService = LoginService();
  final ClearSharedPreference shared = ClearSharedPreference();
  final formKey = GlobalKey<FormState>();
  final bool _canPop = false;
  bool _isLoading = true;
  bool isFirstName = false;
  bool isDob = false;
  bool isAge = false;
  bool isMobile = false;
  bool isEmail = false;
  bool isStreet = false;
  bool isCity = false;
  bool isMemberType = false;
  bool isMemberTitle = false;
  bool isDistrict = false;
  bool isState = false;
  bool isCountry = false;
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
  String place = '';
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
  String mType = '';
  String mTypeID = '';
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
  late File imageFile;

  List memberBasic = [];
  List memberType = [];
  List memberTypeBased = [];
  List memberTitle = [];
  List bloodData = [];
  List districtData = [];
  List districtBasedData = [];
  List stateData = [];
  List stateBasedData = [];
  List countryData = [];
  List<DropDownValueModel> memberTypeDropDown = [];
  List<DropDownValueModel> memberTitleDropDown = [];
  List<DropDownValueModel> bloodDropDown = [];
  List<DropDownValueModel> districtDropDown = [];
  List<DropDownValueModel> stateDropDown = [];
  List<DropDownValueModel> countryDropDown = [];

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  var headers = {
    'Authorization': authToken,
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {
        var imagePick = pickedFile.path;
        var attachFileType = imagePick.split('.').last;

        File files = File(imagePick);
        _image = files;
        List<int> fileBytes = files.readAsBytesSync();
        var bFile = base64Encode(fileBytes);
        baseImageFile = bFile;

        final aaf = File(imagePick);
        int sizeInBytes = aaf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb <= 25) {
          // This file is smaller than or equal to 25 MB
        } else {
          // This file is larger than 25 MB
        }
      });
    }
  }

  // Profile Image
  getsImage() async {
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

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        var imagePick = pickedFile.path;
        File files = File(imagePick);
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
      allowedExtensions: ['pdf'],
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
          baseAadharFile = bFile;
        } else {
          _attachAadharFile = '';
          _attachAadharFileName = '';
          AnimatedSnackBar.material(
            'Please select a PDF file or document file.',
            type: AnimatedSnackBarType.error,
            duration: const Duration(seconds: 3),
          ).show(context);
        }

        final aaf = File(_attachAadharFile);
        int sizeInBytes = aaf.lengthSync().toInt();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if(sizeInMb <= 25) {
          // This file is smaller than or equal to 25 MB
        } else {
          // This file is larger than 25 MB
        }
      });
    }
  }

  // Voter File
  getVoterFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
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
          baseVoterFile = bFile;
        } else {
          _attachVoterFile = '';
          _attachVoterFileName = '';
          AnimatedSnackBar.material(
              'Please select the PDF file or document file.',
              type: AnimatedSnackBarType.error,
              duration: const Duration(seconds: 3)
          ).show(context);
        }

        final votef = File(_attachVoterFile);
        int sizeInBytes = votef.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if(sizeInMb <= 25) {
          // This file is smaller than or equal to 25 MB
        } else {
          // This file is larger than 25 MB
        }
      });
    }
  }

  // PAN File
  getPanFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
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
          basePanFile = bFile;
        } else {
          _attachPanFile = '';
          _attachPanFileName = '';
          AnimatedSnackBar.material(
              'Please select the PDF file or document file.',
              type: AnimatedSnackBarType.error,
              duration: const Duration(seconds: 3)
          ).show(context);
        }

        final panf = File(_attachPanFile);
        int sizeInBytes = panf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if(sizeInMb <= 25) {
          // This file is smaller than or equal to 25 MB
        } else {
          // This file is larger than 25 MB
        }
      });
    }
  }

  // Passport File
  getPassportFile() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
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
          basePassportFile = bFile;
        } else {
          _attachPassportFile = '';
          _attachPassportFileName = '';
          AnimatedSnackBar.material(
              'Please select the PDF file or document file.',
              type: AnimatedSnackBarType.error,
              duration: const Duration(seconds: 3)
          ).show(context);
        }

        final pf = File(_attachPassportFile);
        int sizeInBytes = pf.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if(sizeInMb <= 25) {
          // This file is smaller than or equal to 25 MB
        } else {
          // This file is larger than 25 MB
        }
      });
    }
  }

  getAadharBase64File() async {
    String url = _netAadharAttachFile;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String base64String = base64Encode(bytes);

        setState(() {
          // Use the base64String as needed
          _netAadharAttachFile = base64String;
        });
      } else {
        throw Exception('Failed to fetch the file from the URL');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  getVoterBase64File() async {
    String url = _netVoterAttachFile;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String base64String = base64Encode(bytes);

        setState(() {
          // Use the base64String as needed
          _netVoterAttachFile = base64String;
        });
      } else {
        throw Exception('Failed to fetch the file from the URL');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  getPanBase64File() async {
    String url = _netPanAttachFile;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String base64String = base64Encode(bytes);

        setState(() {
          // Use the base64String as needed
          _netPanAttachFile = base64String;
        });
      } else {
        throw Exception('Failed to fetch the file from the URL');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  getPassportBase64File() async {
    String url = _netPassportAttachFile;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String base64String = base64Encode(bytes);

        setState(() {
          // Use the base64String as needed
          _netPassportAttachFile = base64String;
        });
      } else {
        throw Exception('Failed to fetch the file from the URL');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  getMemberBasicData() async {
    String url = '$baseUrl/res.member';
    Map data = {
      "params": {
        "filter": "[['id','=',${userProfile == "Profile" ? userMember : memberId}]]",
        "query": "{id,name,middle_name,last_name,member_name,image_1920,title_id,unique_code,gender,living_status,marital_status_id,blood_group_id,mother_tongue_id,occupation_status,occupation_id,occupation_type,dob,is_dob_or_age,age,active,physical_status_id,citizenship_id,religion_id,name_in_regional_language,native_place,native_district_id,driving_license_no,known_language_ids,twitter_account,fb_account,linkedin_account,whatsapp_no,mobile,email,passport_country_id,known_popularly_as,place_of_birth,membership_type,member_type_id,member_type_code,pancard_no,aadhaar_proof,aadhaar_proof_name,pan_proof,pan_proof_name,passport_no,passport_proof,passport_proof_name,passport_exp_date,voter_id,voter_proof_name,voter_proof,license_exp_date,street,street2,city,district_id,state_id,country_id,zip,native_diocese_id,native_parish_id}"
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
        if(memberBasic[i]['member_type_id']['id'] != '' && memberBasic[i]['member_type_id']['name'] != '') {
          int id = memberBasic[i]['member_type_id']['id'];
          mTypeID = id.toString();
          mType = memberBasic[i]['member_type_id']['name'];
          setState(() {
            memberTitleDropDown.clear();
            getMemberTypeBased(mTypeID);
          });
        } else {
          mType = '';
          mTypeID = '';
        }
        if(memberBasic[i]['title_id']['id'] != '' && memberBasic[i]['title_id']['name'] != '') {
          int id = memberBasic[i]['title_id']['id'];
          mTitleID = id.toString();
          mTitle = memberBasic[i]['title_id']['name'];
        } else {
          mTitle = '';
          mTitleID = '';
        }
        if(memberBasic[i]['is_dob_or_age'] == 'DOB') {
          isDOBandAge = memberBasic[i]['is_dob_or_age'];
          isDob = true;
          isAge = false;
        } else {
          isDOBandAge = memberBasic[i]['is_dob_or_age'];
          isAge = true;
          isDob = false;
        }
        if(memberBasic[i]['dob'] != '') {
          final date = format.parse(memberBasic[i]['dob']);
          dateOfBirthController.text = memberBasic[i]['dob'];
          dateOfBirth = reverse.format(date);
          int ag = memberBasic[i]['age'];
          ageController.text =  ag.toString();
          age = ag.toString();
        } else {
          dateOfBirthController.text = '';
          dateOfBirth = '';
          ageController.text = '';
          age = '0';
        }
        placeOfBirthController.text = memberBasic[i]['place_of_birth'];
        place = memberBasic[i]['place_of_birth'];
        if(memberBasic[i]['blood_group_id']['id'] != '' && memberBasic[i]['blood_group_id']['name'] != '') {
          int id = memberBasic[i]['blood_group_id']['id'];
          bloodGroupID = id.toString();
          bloodGroup = memberBasic[i]['blood_group_id']['name'];
        } else {
          bloodGroupID = '';
          bloodGroup = '';
        }
        if(memberBasic[i]['email'] != '') {
          emailController.text = memberBasic[i]['email'];
        } else {
          email = '';
          emailController.text = '';
        }
        mobileController.text = memberBasic[i]['mobile'];
        mobile = memberBasic[i]['mobile'];
        streetController.text = memberBasic[i]['street'];
        street2Controller.text = memberBasic[i]['street2'];
        street2 = memberBasic[i]['street2'];
        cityController.text = memberBasic[i]['city'];
        if(memberBasic[i]['district_id']['id'] != '' && memberBasic[i]['district_id']['name'] != '') {
          int id = memberBasic[i]['district_id']['id'];
          districtID = id.toString();
          district = memberBasic[i]['district_id']['name'];
          stateDropDown.clear();
          setState(() {
            getDistrictDetail();
          });
        } else {
          districtID = '';
          district = '';
        }
        if(memberBasic[i]['state_id']['id'] != '' && memberBasic[i]['state_id']['name'] != '') {
          int id = memberBasic[i]['state_id']['id'];
          stateID = id.toString();
          state = memberBasic[i]['state_id']['name'];
          countryDropDown.clear();
          setState(() {
            getStateDetail();
          });
        } else {
          stateID = '';
          state = '';
        }

        if(memberBasic[i]['country_id']['id'] != '' && memberBasic[i]['country_id']['name'] != '') {
          int id = memberBasic[i]['country_id']['id'];
          countryID = id.toString();
          country = memberBasic[i]['country_id']['name'];
        } else {
          countryID = '';
          country = '';
        }
        zipCodeController.text = memberBasic[i]['zip'];
        zip = memberBasic[i]['zip'];

        if(memberBasic[i]['aadhaar_proof'] != '') {
          aadharController.text = memberBasic[i]['unique_code'];
          aadharNo = memberBasic[i]['unique_code'];
          _netAadharAttachFile = memberBasic[i]['aadhaar_proof'];
          // getAadharBase64File();
          var aadhars = memberBasic[i]['aadhaar_proof'];
          File file = File(aadhars);
          var path = file.path;
          _attachAadharFileName = path.split("/").last;
        } else {
          aadharController.text = '';
          _attachAadharFile = '';
          _attachAadharFileName = '';
          _netAadharAttachFile = '';
        }

        if(memberBasic[i]['voter_proof'] != '') {
          voterController.text = memberBasic[i]['voter_id'];
          voterNo =  memberBasic[i]['voter_id'];
          _netVoterAttachFile = memberBasic[i]['voter_proof'];
          // getVoterBase64File();
          var voters = memberBasic[i]['voter_proof'];
          File file = File(voters);
          var path = file.path;
          _attachVoterFileName = path.split("/").last;
        } else {
          voterController.text = '';
          _attachVoterFile = '';
          _attachVoterFileName = '';
          _netVoterAttachFile = '';
        }

        if(memberBasic[i]['pan_proof'] != '') {
          panController.text = memberBasic[i]['pancard_no'];
          panNo = memberBasic[i]['pancard_no'];
          _netPanAttachFile = memberBasic[i]['pan_proof'];
          // getPanBase64File();
          var pans = memberBasic[i]['pan_proof'];
          File file = File(pans);
          var path = file.path;
          _attachPanFileName = path.split("/").last;
        } else {
          panController.text = '';
          _attachPanFile = '';
          _attachPanFileName = '';
          _netPanAttachFile = '';
        }

        if(memberBasic[i]['passport_proof'] != '') {
          passportController.text = memberBasic[i]['passport_no'];
          passNo = memberBasic[i]['passport_no'];
          _netPassportAttachFile = memberBasic[i]['passport_proof'];
          // getPassportBase64File();
          var passports = memberBasic[i]['passport_proof'];
          File file = File(passports);
          var path = file.path;
          _attachPassportFileName = path.split("/").last;
        } else {
          passportController.text = '';
          _attachPassportFile = '';
          _attachPassportFileName = '';
          _netPassportAttachFile = '';
        }
      }
    } else {
      final message = jsonDecode(response.body)['result'];
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

  getMemberType() async {
    String url = '$baseUrl/member.type';
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
      memberType = data;

      for(int i = 0; i < memberType.length; i++) {
        memberTypeDropDown.add(DropDownValueModel(name: memberType[i]['name'], value: memberType[i]['id']));
      }
      return memberTypeDropDown;
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

  getMemberTitleData() async {
    String url = '$baseUrl/member.title';
    Map data = {
      "params": {
        "query": "{id,name,member_type_ids}"
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
      memberTitle = data;

      for(int i = 0; i < memberTitle.length; i++) {
        memberTitleDropDown.add(DropDownValueModel(name: memberTitle[i]['name'], value: memberTitle[i]['id']));
      }
      return memberTitleDropDown;
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

  getMemberTypeBased(mTypeID) async {
    String url = '$baseUrl/member.title';
    Map data = {
      "params": {
        "filter": "[['member_type_ids', '=', $mTypeID ]]",
        "query": "{id,name,member_type_ids}"
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
      memberTypeBased = data;

      if(memberTypeBased.isNotEmpty){
        for(int i = 0; i < memberTypeBased.length; i++) {
          memberTitleDropDown.add(DropDownValueModel(name: memberTypeBased[i]['name'], value: memberTypeBased[i]['id']));
        }
        return memberTitleDropDown;
      } else {
        for(int i = 0; i <= memberTypeBased.length; i++) {
          memberTitleDropDown.add(DropDownValueModel(name: "No data found", value: i));
        }
        return memberTitleDropDown;
      }
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

  getBloodGroupData() async {
    String url = '$baseUrl/blood.group';
    Map data = {
      "params": {
        "query": "{id,name}"
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
      bloodData = data;

      for(int i = 0; i < bloodData.length; i++) {
        bloodDropDown.add(DropDownValueModel(name: bloodData[i]['name'], value: bloodData[i]['id']));
      }
      return bloodDropDown;
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

  getDistrictData() async {
    String url = '$baseUrl/res.state.district';
    Map data = {
      "params": {
        "query": "{id,name,code,state_id}"
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
      districtData = data;

      for(int i = 0; i < districtData.length; i++) {
        districtDropDown.add(DropDownValueModel(name: districtData[i]['name'], value: districtData[i]['id']));
      }
      return districtDropDown;
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

  getStateData() async {
    String url = '$baseUrl/res.country.state';
    Map data = {
      "params": {
        "query": "{id,name,code,country_id}"
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
      stateData = data;

      for(int i = 0; i < stateData.length; i++) {
        stateDropDown.add(DropDownValueModel(name: stateData[i]['name'], value: stateData[i]['id']));
      }
      return stateDropDown;
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

  getCountryData() async {
    String url = '$baseUrl/res.country';
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
      countryData = data;

      for(int i = 0; i < countryData.length; i++) {
        countryDropDown.add(DropDownValueModel(name: countryData[i]['name'], value: countryData[i]['id']));
      }
      return countryDropDown;
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

  getDistrictDetail() async {
    String url = '$baseUrl/res.state.district';
    Map data = {
      "params": {
        "filter": "[['id', '=', $districtID]]",
        "query": "{id,name,code,state_id}"
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
        if(data[i]['state_id']['id'] != '' && data[i]['state_id']['name'] != '') {
          int id = data[i]['state_id']['id'];
          stateID = id.toString();
        } else {
          stateID = '';
        }
      }

      getDistrictBased(stateID);
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

  getStateDetail() async {
    String url = '$baseUrl/res.country.state';
    Map data = {
      "params": {
        "filter": "[['id', '=', $stateID]]",
        "query": "{id,name,code,country_id}"
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
        if(data[i]['country_id']['id'] != '' && data[i]['country_id']['name'] != '') {
          int id = data[i]['country_id']['id'];
          countryID = id.toString();
        } else {
          countryID = '';
        }
      }

      getStateBased(countryID);
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

  getDistrictBased(stateID) async {
    String url = '$baseUrl/res.country.state';
    Map data = {
      "params": {
        "filter": "[['id', '=', $stateID]]",
        "query": "{id,name,code,country_id}"
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
      districtBasedData = data;

      if(districtBasedData.isNotEmpty){
        for(int i = 0; i < districtBasedData.length; i++) {
          stateDropDown.add(DropDownValueModel(name: districtBasedData[i]['name'], value: districtBasedData[i]['id']));
        }
        return stateDropDown;
      } else {
        for(int i = 0; i <= districtBasedData.length; i++) {
          stateDropDown.add(DropDownValueModel(name: "No data found", value: i));
        }
        return stateDropDown;
      }
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

  getStateBased(countryID) async {
    String url = '$baseUrl/res.country';
    Map data = {
      "params": {
        "filter": "[['id', '=', $countryID]]",
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
      stateBasedData = data;

      if(stateBasedData.isNotEmpty){
        for(int i = 0; i < stateBasedData.length; i++) {
          countryDropDown.add(DropDownValueModel(name: stateBasedData[i]['name'], value: stateBasedData[i]['id']));
        }
        return countryDropDown;
      } else {
        for(int i = 0; i <= stateBasedData.length; i++) {
          countryDropDown.add(DropDownValueModel(name: "No data found", value: i));
        }
        return countryDropDown;
      }
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

  cancel() {
    setState(() {
      Navigator.pop(context);
    });
  }

  update(String firstName, memberType, street, city, district, state, country) async {
    middle = middleNameController.text.toString();
    last = lastNameController.text.toString();
    place = placeOfBirthController.text.toString();
    mobile = mobileController.text.toString();
    street2 = street2Controller.text.toString();
    zip = zipCodeController.text.toString();
    aadharNo = aadharController.text.toString();
    voterNo = voterController.text.toString();
    panNo = panController.text.toString();
    passNo = passportController.text.toString();

    var aadharAttachment;
    if(_attachAadharFile != '' && _attachAadharFile != null) {
      aadharAttachment = baseAadharFile;
    } else if(_netAadharAttachFile != '' && _netAadharAttachFile != null) {
      aadharAttachment = _netAadharAttachFile;
    } else {
      aadharAttachment = "";
    }

    var voterAttachment;
    if(_attachVoterFile != '' && _attachVoterFile != null) {
      voterAttachment = baseVoterFile;
    } else if(_netVoterAttachFile != '' && _netVoterAttachFile != null) {
      voterAttachment = _netVoterAttachFile;
    } else {
      voterAttachment = "";
    }

    var panAttachment;
    if(_attachPanFile != '' && _attachPanFile != null) {
      panAttachment = basePanFile;
    } else if(_netPanAttachFile != '' && _netPanAttachFile != null) {
      panAttachment = _netPanAttachFile;
    } else {
      panAttachment = "";
    }

    var passAttachment;
    if(_attachPassportFile != '' && _attachPassportFile != null) {
      passAttachment = basePassportFile;
    } else if(_netPassportAttachFile != '' && _netPassportAttachFile != null) {
      passAttachment = _netPassportAttachFile;
    } else {
      passAttachment = "";
    }

    String url = '$baseUrl/edit/res.member/${userProfile == "Profile" ? userMember : memberId}';
    Map data = {
      "params": {
        "data": {
          if(_attachAadharFile == '' && _netAadharAttachFile == '') "aadhaar_proof": "",
          if(_attachVoterFile == '' && _netVoterAttachFile == '') "voter_proof": "",
          if(_attachPanFile == '' && _netPanAttachFile == '') "pan_proof": "",
          if(_attachPassportFile == '' && _netPassportAttachFile == '') "passport_proof": "",
          "name": firstName,"middle_name": middle,"last_name": last,"member_type_id": mTypeID,"title_id": mTitleID,"is_dob_or_age": isDOBandAge,"dob": dateOfBirth,"age": age,"place_of_birth": place,"blood_group_id": bloodGroupID,
          "email": email,"mobile": mobile,"street": street,"street2": street2,"city": city,"district_id": districtID,'state_id': stateID,'country_id': countryID,"zip": zip,"unique_code": aadharNo,"voter_id": voterNo,"pancard_no": panNo,"passport_no": passNo,
          if(_image != '' && _image != null) "image_1920": baseImageFile,
          if(_attachAadharFile != '' && _attachAadharFile != null) "aadhaar_proof": aadharAttachment,
          if(_attachVoterFile != '' && _attachVoterFile != null) "voter_proof": voterAttachment,
          if(_attachPanFile != '' && _attachPanFile != null) "pan_proof": panAttachment,
          if(_attachPassportFile != '' && _attachPassportFile != null) "passport_proof": passAttachment,
        }
      }
    };
    var body = jsonEncode(data);
    var response = await http.put(Uri.parse(url),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if (response.statusCode == 200) {
      final message = json.decode(response.body)['result'];
      setState(() {
        _isLoading = false;
        AnimatedSnackBar.material(
            'Member basic details updated successfully.',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 2)
        ).show(context);
        Navigator.pop(context);
        Navigator.pop(context, 'refresh');
      });
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
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    if(expiryDateTime!.isAfter(currentDateTime)) {
      getMemberType();
      getMemberTitleData();
      getBloodGroupData();
      getDistrictData();
      getStateData();
      getCountryData();
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          getMemberBasicData();
        });
      });
    } else {
      if(remember == true) {
        loginService.login(context, loginName, loginPassword, databaseName, callback: () {
          setState(() {
            getMemberType();
            getMemberTitleData();
            getBloodGroupData();
            getDistrictData();
            getStateData();
            getCountryData();
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _isLoading = false;
                getMemberBasicData();
              });
            });
          });
        });
      } else {
        shared.clearSharedPreferenceData(context);
      }
    }
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
          child: Center(
            child: _isLoading
                ? SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
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
                                image: _image != null ? FileImage(_image) : image.isNotEmpty ? NetworkImage(image) : const AssetImage('assets/images/profile.png') as ImageProvider,
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
                                  showModalBottomSheet<void>(
                                    context: context,
                                    backgroundColor: screenBackgroundColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                    ),
                                    builder: (BuildContext context) {
                                      return CustomProfileBottomSheet(
                                        size: size,
                                        onGalleryPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            if (Platform.isAndroid) {
                                              getsImage();
                                            } else {
                                              getImage();
                                            }
                                          });
                                        },
                                        onCameraPressed: () async {
                                          Navigator.pop(context);
                                          setState(() {
                                            pickImage();
                                          });
                                        },
                                      );
                                    },
                                  );
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
                            userLevel != 'Diocesan Member' ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: DropDownTextField(
                                // controller: _level,
                                initialValue: mType,
                                listSpace: 20,
                                listPadding: ListPadding(top: 20),
                                searchShowCursor: true,
                                searchAutofocus: true,
                                enableSearch: true,
                                readOnly: true,
                                listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                                textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                                dropDownItemCount: 6,
                                dropDownList: memberTypeDropDown,
                                textFieldDecoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: mType != '' ? mType : "Select member type",
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
                                      mType = val.name;
                                      mTypeID = val.value.toString();
                                      if(mType.isNotEmpty && mType != '') {
                                        isMemberType = false;
                                        memberTitleDropDown.clear();
                                        if(_isLoading == false) {
                                          _isLoading = true;
                                          getMemberTypeBased(mTypeID);
                                          _isLoading = false;
                                        } else {
                                          _isLoading = false;
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      isMemberType = true;
                                      mType = '';
                                      mTypeID = '';
                                    });
                                  }
                                },
                              ),
                            ) : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: inputColor
                              ),
                              child: TextFormField(
                                initialValue: mType,
                                keyboardType: TextInputType.none,
                                autocorrect: true,
                                readOnly: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: mType != '' ? mType : "Select member type",
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
                                      if(mTitle.isNotEmpty && mTitle != '') {
                                        setState(() {
                                          isMemberTitle = false;
                                        });
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      isMemberTitle = true;
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
                                        value: 'DOB',
                                        groupValue: isDOBandAge,
                                        title: Text('DOB', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                        onChanged: (String? value) {
                                          setState(() {
                                            isDOBandAge = value!;
                                            isDob = true;
                                            isAge = false;
                                          });
                                        }
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
                                        value: 'Age',
                                        groupValue: isDOBandAge,
                                        title: Text('Age', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                        onChanged: (String? value) {
                                          setState(() {
                                            isDOBandAge = value!;
                                            isAge = true;
                                            isDob = false;
                                          });
                                        }
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
                                keyboardType: TextInputType.none,
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
                                        data: ThemeData.light().copyWith(
                                          primaryColor: const Color(0xFFFF512F),
                                          buttonTheme: const ButtonThemeData(
                                              textTheme: ButtonTextTheme.primary),
                                          colorScheme: const ColorScheme.light(
                                              primary: Color(0xFFFF512F))
                                              .copyWith(
                                              secondary:
                                              const Color(0xFFFF512F)),
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
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
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
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: true,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your email",
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
                                  } else {
                                    isEmail = false;
                                    email = '';
                                  }
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
                                    var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                                    if(reg.hasMatch(val)) {
                                      isMobile = false;
                                      mobile = mobileController.text.toString();
                                    } else {
                                      isMobile = true;
                                    }
                                  } else {
                                    isMobile = false;
                                    mobile = '';
                                  }
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
                                controller: streetController,
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
                                // check tha validation
                                validator: (val) {
                                  if (val!.isEmpty && val == '') {
                                    isStreet = true;
                                  } else {
                                    isStreet = false;
                                  }
                                },
                              ),
                            ),
                            isStreet ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Street is required",
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
                                    'City',
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
                                controller: cityController,
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
                                // check tha validation
                                validator: (val) {
                                  if (val!.isEmpty && val == '') {
                                    isCity = true;
                                  } else {
                                    isCity = false;
                                  }
                                },
                              ),
                            ),
                            isCity ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "City is required",
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
                              child: DropDownTextField(
                                // controller: _level,
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
                                        isDistrict = false;
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
                                      isDistrict = true;
                                      district = '';
                                      districtID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            isDistrict ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "District is required",
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
                              child: Row(
                                children: [
                                  Text(
                                    'State',
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
                              child: DropDownTextField(
                                // controller: _level,
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
                                        isState = false;
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
                                      isState = true;
                                      state = '';
                                      stateID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            isState ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "State is required",
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
                              child: Row(
                                children: [
                                  Text(
                                    'Country',
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
                              child: DropDownTextField(
                                // controller: _level,
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
                                      if(country.isNotEmpty && country != '') {
                                        setState(() {
                                          isCountry = false;
                                        });
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      isCountry = true;
                                      country = '';
                                      countryID = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            isCountry ? Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 10, top: 8),
                                child: const Text(
                                  "Country is required",
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
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'Confirm',
                                            text: 'Are you sure want to delete the file.',
                                            confirmBtnColor: greenColor,
                                            showCancelBtn: true,
                                            onConfirmBtnTap: () {
                                              setState(() {
                                                _attachAadharFile = '';
                                                _attachAadharFileName = '';
                                                _netAadharAttachFile = '';
                                                AnimatedSnackBar.material(
                                                    'File is removed successfully',
                                                    type: AnimatedSnackBarType.success,
                                                    duration: const Duration(seconds: 2)
                                                ).show(context);
                                              });
                                              Navigator.pop(context);
                                            },
                                            onCancelBtnTap: () {
                                              cancel();
                                            },
                                            width: 100.0,
                                          );
                                        },
                                      ) : Container(),
                                      _attachAadharFileName != null && _attachAadharFileName != '' && _netAadharAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          // Check Internet connection
                                          internetCheck();

                                          netPath = _netAadharAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          filename = netFileName;
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
                                          // Check Internet connection
                                          internetCheck();

                                          localPath = _attachAadharFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          filename = path.split("/").last;
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
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'Confirm',
                                            text: 'Are you sure want to delete the file.',
                                            confirmBtnColor: greenColor,
                                            showCancelBtn: true,
                                            onConfirmBtnTap: () {
                                              setState(() {
                                                _attachVoterFile = '';
                                                _attachVoterFileName = '';
                                                _netVoterAttachFile = '';
                                                AnimatedSnackBar.material(
                                                    'File is removed successfully',
                                                    type: AnimatedSnackBarType.success,
                                                    duration: const Duration(seconds: 2)
                                                ).show(context);
                                              });
                                              Navigator.pop(context);
                                            },
                                            onCancelBtnTap: () {
                                              cancel();
                                            },
                                            width: 100.0,
                                          );
                                        },
                                      ) : Container(),
                                      _attachVoterFileName != null && _attachVoterFileName != '' && _netVoterAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          // Check Internet connection
                                          internetCheck();

                                          netPath = _netVoterAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          filename = netFileName;
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
                                          // Check Internet connection
                                          internetCheck();

                                          localPath = _attachVoterFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          filename = path.split("/").last;
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
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'Confirm',
                                            text: 'Are you sure want to delete the file.',
                                            confirmBtnColor: greenColor,
                                            showCancelBtn: true,
                                            onConfirmBtnTap: () {
                                              setState(() {
                                                _attachPanFile = '';
                                                _attachPanFileName = '';
                                                _netPanAttachFile = '';
                                                AnimatedSnackBar.material(
                                                    'PAN file is removed successfully',
                                                    type: AnimatedSnackBarType.success,
                                                    duration: const Duration(seconds: 2)
                                                ).show(context);
                                              });
                                              Navigator.pop(context);
                                            },
                                            onCancelBtnTap: () {
                                              cancel();
                                            },
                                            width: 100.0,
                                          );
                                        },
                                      ) : Container(),
                                      _attachPanFileName != null && _attachPanFileName != '' && _netPanAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          // Check Internet connection
                                          internetCheck();

                                          netPath = _netPanAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          filename = netFileName;
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
                                          // Check Internet connection
                                          internetCheck();

                                          localPath = _attachPanFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          filename = path.split("/").last;
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
                                controller: panController,
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
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'Confirm',
                                            text: 'Are you sure want to delete the file.',
                                            confirmBtnColor: greenColor,
                                            showCancelBtn: true,
                                            onConfirmBtnTap: () {
                                              setState(() {
                                                _attachPassportFile = '';
                                                _attachPassportFileName = '';
                                                _netPassportAttachFile = '';
                                                AnimatedSnackBar.material(
                                                    'Passport file is removed successfully',
                                                    type: AnimatedSnackBarType.success,
                                                    duration: const Duration(seconds: 2)
                                                ).show(context);
                                              });
                                              Navigator.pop(context);
                                            },
                                            onCancelBtnTap: () {
                                              cancel();
                                            },
                                            width: 100.0,
                                          );
                                        },
                                      ) : Container(),
                                      _attachPassportFileName != null && _attachPassportFileName != '' && _netPassportAttachFile != '' ? IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        color: Colors.orangeAccent,
                                        onPressed: () {
                                          // Check Internet connection
                                          internetCheck();

                                          netPath = _netPassportAttachFile;
                                          File file = File(netPath);
                                          path = file.path;
                                          netFileName = path.split("/").last;
                                          filename = netFileName;
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
                                          // Check Internet connection
                                          internetCheck();

                                          localPath = _attachPassportFile;
                                          File file = File(localPath);
                                          path = file.path;
                                          filename = path.split("/").last;
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
              color: Colors.white,
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
                        if(firstNameController.text.isNotEmpty && mType.isNotEmpty
                            && streetController.text.isNotEmpty && cityController.text.isNotEmpty
                            && district.isNotEmpty && state.isNotEmpty && country.isNotEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const CustomLoadingDialog();
                            },
                          );
                          update(firstNameController.text.toString(), mType, streetController.text.toString(), cityController.text.toString(), district, state, country);
                        } else {
                          firstNameController.text.isEmpty ? isFirstName = true : isFirstName = false;
                          mType.isEmpty ? isMemberType = true : isMemberType = false;
                          streetController.text.isEmpty ? isStreet = true : isStreet = false;
                          cityController.text.isEmpty ? isCity = true : isCity = false;
                          district.isEmpty ? isDistrict = true : isDistrict = false;
                          state.isEmpty ? isState = true : isState = false;
                          country.isEmpty ? isCountry = true : isCountry = false;
                          AnimatedSnackBar.material(
                              'Please fill the required fields',
                              type: AnimatedSnackBarType.warning,
                              duration: const Duration(seconds: 2)
                          ).show(context);
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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
        title: Text('$filename'),
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