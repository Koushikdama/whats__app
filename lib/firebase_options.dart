// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlh74PLauSVFcE7KpxCSOQunWbULUY7z0',
    appId: '1:963659368992:web:980c56f39b36fc5cc04a45',
    messagingSenderId: '963659368992',
    projectId: 'whatsapp-backend-5dfe6',
    authDomain: 'whatsapp-backend-5dfe6.firebaseapp.com',
    storageBucket: 'whatsapp-backend-5dfe6.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALINr6tHti7waAcynru07Q1igTlnTLIlk',
    appId: '1:963659368992:android:704c9fba2c7abe87c04a45',
    messagingSenderId: '963659368992',
    projectId: 'whatsapp-backend-5dfe6',
    storageBucket: 'whatsapp-backend-5dfe6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCn3eWI-LydUzWZl-WgCQyS9JBLPSNSSSA',
    appId: '1:963659368992:ios:d9e5cc8bdfd750d7c04a45',
    messagingSenderId: '963659368992',
    projectId: 'whatsapp-backend-5dfe6',
    storageBucket: 'whatsapp-backend-5dfe6.appspot.com',
    iosBundleId: 'com.example.chattingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCn3eWI-LydUzWZl-WgCQyS9JBLPSNSSSA',
    appId: '1:963659368992:ios:d9e5cc8bdfd750d7c04a45',
    messagingSenderId: '963659368992',
    projectId: 'whatsapp-backend-5dfe6',
    storageBucket: 'whatsapp-backend-5dfe6.appspot.com',
    iosBundleId: 'com.example.chattingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBlh74PLauSVFcE7KpxCSOQunWbULUY7z0',
    appId: '1:963659368992:web:ddf53db4c6d3ec94c04a45',
    messagingSenderId: '963659368992',
    projectId: 'whatsapp-backend-5dfe6',
    authDomain: 'whatsapp-backend-5dfe6.firebaseapp.com',
    storageBucket: 'whatsapp-backend-5dfe6.appspot.com',
  );
}