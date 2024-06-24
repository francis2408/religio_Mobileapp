import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kjpraipur/private/screens/splash/splash_screen.dart';
import 'package:kjpraipur/widget/navigation/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isSignedIn = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isSignedIn = prefs.getBool('userLoggedInkey') ?? false;

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
  AppUpdateInfo? _updateInfo;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        if(_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
          InAppUpdate.startFlexibleUpdate().then((_) {
            setState(() {
              _flexibleUpdateAvailable = true;
              if(_flexibleUpdateAvailable == true) {
                InAppUpdate.completeFlexibleUpdate().then((_) {
                  showSnack("Success!");
                }).catchError((e) {
                  showSnack(e.toString());
                });
              } else {
                InAppUpdate.completeFlexibleUpdate().then((_) {
                }).catchError((e) {
                  showSnack(e.toString());
                });
              }
            });
          });
        } else {
          InAppUpdate.startFlexibleUpdate().then((_) {
            setState(() {
              _flexibleUpdateAvailable = false;
            });
          }).catchError((e) {
            showSnack(e.toString());
          });
        }
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentState != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    isSignedIn = widget.isSignedIn;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSSCC',
      home: ScaffoldMessenger(
        key: _scaffoldKey,
        child: isSignedIn ? const NavigationBarScreen() : const SplashScreen(),
      ),
    );
  }
}
