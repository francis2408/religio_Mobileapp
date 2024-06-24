import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // keys
  static String setName = "LoggedName";
  static String setPassword = "LoggedPassword";
  static String setDatabaseName = "DatabaseName";
  static String userLoggedInKey = "LoggedInKey";
  static String userRememberKey = "RememberKey";
  static String userAuthTokenKey = "AuthToken";
  static String userTokenExpires = "TokenExpires";
  static String userIdKey = "UserIdKey";
  static String userIdsKey = "UserIdKey";
  static String userNameKey = "UserNameKey";
  static String userImageKey = "UserImage";
  static String userEmailKey = "UserEmail";
  static String userLevelKey = "UserLevel";
  static String userDioceseKey = "UserDiocese";
  static String userDiocesesKey = "UserDioceses";
  static String userMemberKey = "UserMember";
  static String userMembersKey = "UserMembers";
  static String isReadKey = "ReadKey";

  // Saving the data to Shared Preferences
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  // Getting the data to Shared Preferences
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future getUserLoggedOutStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.clear();
  }

  static setUserLoginSF(isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('userLoggedInKey', isUserLoggedIn);
  }

  static setUserRememberSF(isUserRemember) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('userRememberKey', isUserRemember);
  }

  static setAuthTokenSF(authToken) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userAuthTokenKey', authToken);
  }

  static setTokenExpiresSF(tokenExpires) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userTokenExpires', tokenExpires);
  }

  static setIdSF(userId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userIdKey', userId);
  }

  static setIdsSF(userIds) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userIdsKey', userIds);
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

  static setUserNameSF(userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userNameKey', userName);
  }

  static setUserImageSF(userImage) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userImageKey', userImage);
  }

  static setUserEmailSF(userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userEmailKey', userEmail);
  }

  static setUserLevelSF(userLevel) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userLevelKey', userLevel);
  }

  static setUserDioceseSF(userDiocese) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userDioceseKey', userDiocese);
  }

  static setUserDiocesesSF(userDiocese) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userDiocesesKey', userDiocese);
  }

  static setUserMemberSF(userMember) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setInt('userMemberKey', userMember);
  }

  static setUserMembersSF(userMembers) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString('userMembersKey', userMembers);
  }

  static setNotificationReadSF(isNotificationRead) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool('isReadKey', isNotificationRead);
  }
}