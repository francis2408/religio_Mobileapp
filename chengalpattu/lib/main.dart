import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chengai/private/screen/notification/notification_list.dart';
import 'package:chengai/widget/notification.dart';
import 'package:chengai/widget/widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chengai/widget/bottom_nav_bar.dart';
import 'package:chengai/widget/change_theme_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'private/screen/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isSignedIn = false;
  bool remem = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'your_channel_key',
      channelName: 'Your Channel Name',
      channelDescription: 'Your Channel Description',
    ),
  ]);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if(message.data['topic'] == db) {
      final notification = message.notification;
      if (notification != null) {
        MyNotificationService.showNotification(
          title: notification.title ?? 'New Notification',
          body: notification.body ?? 'Notification Body',
          payload: message.data['data'] ?? '',
        );
      }
    }
  });

  if (Platform.isIOS) {
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      await FirebaseMessaging.instance.subscribeToTopic(db);
    } else {
      await Future<void>.delayed(
        const Duration(
          seconds: 1,
        ),
      );
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        await FirebaseMessaging.instance.subscribeToTopic(db);
      }
    }
  } else {
    await FirebaseMessaging.instance.subscribeToTopic(db);
  }


  SharedPreferences prefs = await SharedPreferences.getInstance();
  String name = prefs.getString('setName') ?? '';
  String pass = prefs.getString('setPassword') ?? '';
  String base = prefs.getString('setDatabaseName') ?? '';
  remem = prefs.getBool('userRememberKey')  ?? false;
  isSignedIn = prefs.getBool('userLoggedInKey') ?? false;

  if(name != '' && name != null && pass != '' && pass != null && remem != false) {
    loginName = name;
    loginPassword = pass;
    databaseName = base;
    remember = remem;
  }

  runApp(MyApp(isSignedIn));
}

class MyApp extends StatefulWidget {
  final bool isSignedIn;
  const MyApp(this.isSignedIn, {Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSignedIn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _checker = InStoreAppVersionChecker();

  Future<void> checkVersion() async {
    final value = await _checker.checkUpdate();
    setState(() {
      updateAvailable = value.canUpdate;
      curentVersion = value.currentVersion;
      latestVersion = value.newVersion;
    });
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    if(updateAvailable) {
      checkForUpdate();
    } else {
      setState(() {
        isSignedIn = widget.isSignedIn;
      });
    }
  }

  void openStoreForUpdate() async {
    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.boscosoft.nagpur'
        : 'https://apps.apple.com/app/your-app/idYourAppID';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if(updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if(updateInfo.immediateUpdateAllowed) {
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if(appUpdateResult == AppUpdateResult.success) {
              setState(() {
                isSignedIn = widget.isSignedIn;
              });
            } else {
              setState(() {
                isSignedIn = widget.isSignedIn;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    isSignedIn = widget.isSignedIn;
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
          builder: (context, ModelTheme themeNotifier, child) {
            return MaterialApp(
              title: 'Religio',
              theme: themeNotifier.isDark ? ThemeData(
                brightness: Brightness.dark,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ),) : ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.blue,
                primarySwatch: Colors.blue,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ),
              ),
              debugShowCheckedModeBanner: false,
              home: ScaffoldMessenger(
                key: _scaffoldKey,
                child: isSignedIn ? const BottomNavBarScreen() : const SplashScreen(),
              ),
              routes: {
                "/notification_list": (_) => const NotificationListScreen(),
              },
            );
          }),
    );
  }
}
