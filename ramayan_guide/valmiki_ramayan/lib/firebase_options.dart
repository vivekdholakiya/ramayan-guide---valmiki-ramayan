import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// DefaultFirebaseOptions configures Firebase for Android and Web.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmajDeIUpWeZI_tnYED4O9vNBUB3P192g',
    appId: '1:786506244452:web:1d8df88452630575175a71',
    messagingSenderId: '786506244452',
    projectId: 'valmikiramayan-7fec9',
    storageBucket: 'valmikiramayan-7fec9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmajDeIUpWeZI_tnYED4O9vNBUB3P192g',
    appId: '1:786506244452:android:1d8df88452630575175a71',
    messagingSenderId: '786506244452',
    projectId: 'valmikiramayan-7fec9',
    storageBucket: 'valmikiramayan-7fec9.firebasestorage.app',
  );
}
