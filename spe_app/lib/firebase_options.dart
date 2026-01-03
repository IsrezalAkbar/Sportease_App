import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

// Generated manually from android/app/google-services.json. Add other platform
// configs if you enable iOS/Web/desktop.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Run flutterfire configure or add web options.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. '
          'Run flutterfire configure to generate them.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'API_KEY',
    appId: '1:358640842286:android:4045ec57f7ae4cad1551bf',
    messagingSenderId: '358640842286',
    projectId: 'speapp-f3936',
    storageBucket: 'speapp-f3936.firebasestorage.app',
  );
}
