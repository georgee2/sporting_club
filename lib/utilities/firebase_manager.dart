// import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
// import 'package:sporting_club/network/api_urls.dart';

class FirebaseManager {
  initFirebase() async {
    // ApiUrls.getFirebaseConfigurations ();
    FirebaseApp defaultApp = await Firebase.initializeApp(
        // options: FirebaseOptions(
        // messagingSenderId: ApiUrls.FIREBASE_SENDER_ID,
        // apiKey: ApiUrls.FIREBASE_API_KEY,
        // appId: ApiUrls.FIREBASE_APP_ID,
        // projectId: ApiUrls.FIREBASE_PROJECT_ID,
        // ),
        );
  }
}
