import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // keys
  static String userLoggedInkey = "LOGGEDINKEY";
  static String userAuthTokenKey = "AUTHTOKEN";
  static String userCongregationIdKey = "CONGREGATIONID";
  static String userProvinceIdKey = "PROVINCEID";
  static String userCommunityIdKey = "COMMUNITYID";
  static String userCommunityIdsKey = "USERCOMMUNITYID";
  static String userInstituteIdKey = "INSTITUTEID";
  static String userInstituteIdsKey = "USERINSTITUTEID";
  static String userMemberIdKey = "MEMBERID";
  static String userMemberIdsKey = "MEMBERID";
  static String userIdKey = "USERID";
  static String userIdsKey = "USERSID";
  static String userNameKey = "USERNAME";
  static String userRoleKey = "USERROLE";

  // Saving the data to Shared Preferences
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInkey, isUserLoggedIn);
  }

  // Getting the data to Shared Preferences
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInkey);
  }

  static Future getUserLoggedOutStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.clear();
  }

  static setUserLoginSF(isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('userLoggedInkey', isUserLoggedIn);
  }

  static setAuthTokenSF(authToken) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userAuthTokenKey', authToken);
  }

  static setCongregationIdSF(congregationId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userCongregationIdKey', congregationId);
  }

  static setProvinceIdSF(provinceId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userProvinceIdKey', provinceId);
  }

  static setUserNameSF(userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userNameKey', userName);
  }

  static setUserRoleSF(userRole) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userRoleKey', userRole);
  }

  static setCommunityIdSF(communityId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userCommunityIdKey', communityId);
  }

  static setCommunityIdsSF(communityIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userCommunityIdsKey', communityIds);
  }

  static setInstituteIdSF(instituteId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userInstituteIdKey', instituteId);
  }

  static setInstituteIdsSF(instituteIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userInstituteIdsKey', instituteIds);
  }

  static setMemberIdSF(memberId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userMemberIdKey', memberId);
  }

  static setMemberIdsSF(memberIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userMemberIdsKey', memberIds);
  }

  static setUserIdSF(userId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userIdKey', userId);
  }

  static setUserIdsSF(userIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userIdsKey', userIds);
  }
}
