// File generated manually from google-services.json
// (Only Android platform configured - project: valmikiramayan-7fec9)
//
// Jo tame pachi iOS ke Web mate pan app banavo, to Firebase Console mathi
// te platform no config levo padse ane niche `ios`/`web` case add karvo padse.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web config nathi apyu - Firebase Console mathi Web app add kari '
        'config levo, ane aahi web case add karo.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS config nathi apyu - Firebase Console mathi iOS app add kari '
          'config levo, ane aahi ios case add karo.',
        );
      default:
        throw UnsupportedError(
          '${defaultTargetPlatform} platform mate config nathi.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmajDeIUpWeZI_tnYED4O9vNBUB3P192g',
    appId: '1:786506244452:android:1d8df88452630575175a71',
    messagingSenderId: '786506244452',
    projectId: 'valmikiramayan-7fec9',
    storageBucket: 'valmikiramayan-7fec9.firebasestorage.app',
  );
}
