// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqcsw5aWVqD5jszWuMiYIuhHGX8aa6uNo',
    appId: '1:1058178655174:android:da4a1ade6d702a0d2d88c7',
    messagingSenderId: '1058178655174',
    projectId: 'cristoversiontwo',
    databaseURL: 'https://cristoversiontwo-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cristoversiontwo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIdF0TUFlPhW3LCgR_n1k_y1ivzd-M1Is',
    appId: '1:1058178655174:ios:05f8944fac91e0492d88c7',
    messagingSenderId: '1058178655174',
    projectId: 'cristoversiontwo',
    databaseURL: 'https://cristoversiontwo-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cristoversiontwo.appspot.com',
    iosBundleId: 'com.boscosoft.shm',
  );
}
