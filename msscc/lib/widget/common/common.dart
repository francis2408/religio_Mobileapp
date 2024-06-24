// Test Server
// const baseUrl = 'http://testmsscc.cristolive.org/api';
// String db = 'cristo_testmsscc';
// Live Server
const baseUrl = 'https://region.msscc.in/api';
const db = 'cristo_mshj_bangalore';

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

// Read Notification Count
var unReadNotificationCount;
var unReadNewsCount;
var unReadEventCount;
var unReadCircularCount;

// App Version
var curentVersion;
var latestVersion;
var updateAvailable;

// Login
String loginName = '';
String loginPassword = '';
String deviceName = '';
String deviceToken = '';
String myProfile = '';
bool? remember;

// Home
List bannerImage = [];

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

// Obituary
var obituaryCount;
var feastdayCount;
var obituaryTab = 'Upcoming';

// Celebration
var celebrationTab = 'Birthday';

// Birthday
var birthdayCount;
var birthdayTab = 'Upcoming';
var feastTab = 'Upcoming';

// Ordination
var ordinationTab = 'Upcoming';
var ordinationCount;

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

// Holy order
var holyOrderId;

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