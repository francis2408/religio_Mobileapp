import 'package:flutter/material.dart';

// Test Server
// const baseUrl = 'http://testshmcp.cristolive.org/api';
// const db = 'cristo_testshmcp';
// Live Server
const baseUrl = 'http://shm.cristolive.org/api';
const db = 'cristo_shmcp';

// Current Date Time
DateTime currentDateTime = DateTime.now();

// Token Expire Time
DateTime? expiryDateTime;

// Login
String userName = '';
String userRole = '';
String tokenExpire = '';
String authToken = '';
var userCongregationId;
var userProvinceId;
var userCommunityId;
var userInstituteId;
var memberId;
var userId;
var superiorId;
var databaseName;

// Home
List bannerImage = [];

// App Versions
var curentVersion;
var latestVersion;
var updateAvailable;

// Read Notification Count
var unReadNotificationCount;
var unReadNewsCount;
var unReadEventCount;
var unReadCircularCount;

// Device Token
String loginName = '';
String loginPassword = '';
String deviceName = '';
String deviceToken = '';
String myProfile = '';
bool? remember;

// Local Variable
String userMember = '';
String institution = '';
String house = '';

// ForgotPassword
String userLogin = '';
String userEmail = '';

// News
var newsID;

// Notification
var notificationId;
String notificationName = '';
int notificationCount = 0;
var read;

// Celebration
var celebrationTab = 'Birthday';

// Birthday
var birthdayCount;
var feastdayCount;
var birthdayTab = 'Upcoming';
var feastTab = 'Upcoming';

// Obituary
var obituaryCount;
var obituaryTab = 'Upcoming';

// Circular
var letterTab = 'Circular';
var circularID;
var letterID;
String circularName = '';
String letterName = '';
String localPath = '';
var fileName;

// Event
var eventID;
var deleteID;
String selectedTab = 'All';
int eventPage = 0;
int eventLimit = 20;

// House
var houseID;
String houseName = '';
var houseMemberId;
String houseMemberName = '';

// Institute
var instituteID;
String instituteName = '';

// Commission
var commissionID;

// Member
var id;
String name = '';
String memberSelectedTab = 'All';
var communityId;

// Education
var educationId;

// Emergency
var emergencyId;

// Family
var familyId;

// Formation
var formationId;

// Statutory
var statutoryId;

// Publication
var publicationId;

// Profession
var professionId;

// Document View
String field = '';