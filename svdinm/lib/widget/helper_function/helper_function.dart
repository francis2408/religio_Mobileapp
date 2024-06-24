import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // keys
  static String setName = "LoggedName";
  static String setPassword = "LoggedPassword";
  static String setDatabaseName = "DatabaseName";
  static String userRememberKey = "RememberKey";
  static String userTokenExpires = "TokenExpires";
  static String userLoggedInkey = "LoggedInKey";
  static String userAuthTokenKey = "AuthToken";
  static String userCongregationIdKey = "CongregationIdKey";
  static String userProvinceIdKey = "ProvinceIdKey";
  static String userCommunityIdKey = "CommunityIdKey";
  static String userCommunityIdsKey = "CommunityIdsKey";
  static String userInstituteIdKey = "InstituteIdKey";
  static String userInstituteIdsKey = "InstituteIdsKey";
  static String userMemberIdKey = "MemberIdKey";
  static String userMemberIdsKey = "MemberIdsKey";
  static String userIdKey = "IdKey";
  static String userIdsKey = "IdsKey";
  static String userNameKey = "NameKey";
  static String userRoleKey = "RoleKey";
  static String isReadKey = "ReadKey";

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

  static setUserRememberSF(isUserRemember) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('userRememberKey', isUserRemember);
  }

  static setNameSF(name) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setName', name);
  }

  static setPasswordSF(password) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setPassword', password);
  }

  static setDatabaseNameSF(databaseName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('setDatabaseName', databaseName);
  }

  static setTokenExpiresSF(tokenExpires) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userTokenExpires', tokenExpires);
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

  static setNotificationReadSF(isNotificationRead) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('isReadKey', isNotificationRead);
  }
}