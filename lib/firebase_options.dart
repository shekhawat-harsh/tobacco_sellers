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
    apiKey: 'AIzaSyD8cP6elbvnfVkak6Gau8sh9Fqmy0ttOFc',
    appId: '1:261142238885:web:0bf2a21c9e690a484c1f4c',
    messagingSenderId: '261142238885',
    projectId: 'tabacco-fda3c',
    authDomain: 'tabacco-fda3c.firebaseapp.com',
    storageBucket: 'tabacco-fda3c.firebasestorage.app',
    measurementId: 'G-YGSSD6DZ3F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCrA39v_-i1QJ2-u1ihv2IpTpU0RqG22Sg',
    appId: '1:261142238885:android:000c1261beb459124c1f4c',
    messagingSenderId: '261142238885',
    projectId: 'tabacco-fda3c',
    storageBucket: 'tabacco-fda3c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC29nvxEklf7jI53cpQyQr4AMFm1VQXFg0',
    appId: '1:261142238885:ios:645560c3ae8aad994c1f4c',
    messagingSenderId: '261142238885',
    projectId: 'tabacco-fda3c',
    storageBucket: 'tabacco-fda3c.firebasestorage.app',
    androidClientId: '261142238885-7magqiec9f70sp3f13b3q0esa26sao3e.apps.googleusercontent.com',
    iosClientId: '261142238885-6g03t80d62fbp0jjl7efhast9p8np0sf.apps.googleusercontent.com',
    iosBundleId: 'com.example.tobaccoSellers',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC29nvxEklf7jI53cpQyQr4AMFm1VQXFg0',
    appId: '1:261142238885:ios:9ab2f51ef3ded9834c1f4c',
    messagingSenderId: '261142238885',
    projectId: 'tabacco-fda3c',
    storageBucket: 'tabacco-fda3c.firebasestorage.app',
    androidClientId: '261142238885-7magqiec9f70sp3f13b3q0esa26sao3e.apps.googleusercontent.com',
    iosClientId: '261142238885-7od88ebq39deiu0t03h39viqbc75ck34.apps.googleusercontent.com',
    iosBundleId: 'com.example.auctionapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD8cP6elbvnfVkak6Gau8sh9Fqmy0ttOFc',
    appId: '1:261142238885:web:69bf24ca534800614c1f4c',
    messagingSenderId: '261142238885',
    projectId: 'tabacco-fda3c',
    authDomain: 'tabacco-fda3c.firebaseapp.com',
    storageBucket: 'tabacco-fda3c.firebasestorage.app',
    measurementId: 'G-PSSL09Z9RW',
  );

}