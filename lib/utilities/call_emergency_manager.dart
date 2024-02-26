import 'package:uuid/uuid.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

Future<void> handleCallkitIncomingHandler(RemoteMessage message) async {
  // print("Handling a background message: ${message.messageId}");
  // showCallkitIncoming(Uuid().v4() , "Handling a background message");
}

// Future<void> showCallkitIncoming(String uuid, title) async {
//   AndroidAlarmManager.oneShot(
//       const Duration(minutes: 0), 0, showCallkitIncomingAlert);
//   showCallkitIncomingAlert();
//   FlutterRingtonePlayer.play(
//     fromAsset: "assets/high_emergency.wav", // will be the sound on Android
//     ios: const IosSound(1023),
//     looping: true,
//     volume: 1.0,
//   );
//   Future.delayed(const Duration(seconds: 180), () {
//     FlutterRingtonePlayer.stop();
//   });
// }

// Future<void> showCallkitIncomingAlert() async {
//   var params = <String, dynamic>{
//     'id': Uuid().v4(),
//     'nameCaller': 'Sporting',
//     'appName': 'Sporting',
//     // 'avatar': '/android/src/main/res/drawable-xxxhdpi/ic_default_avatar.png',
//     'handle': 'ارجو الوصول في أسرع وقت',
//     'type': 0,
//     'duration': 30000,
//     'textAccept': 'Accept',
//     'textDecline': 'Decline',
//     'textMissedCall': 'Missed call',
//     'textCallback': 'Call back',
//     'extra': <String, dynamic>{'userId': '1a2b3c4d'},
//     'headers': <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//     'android': <String, dynamic>{
//       'isCustomNotification': true,
//       'isShowLogo': false,
//       'isShowCallback': false,
//       'ringtonePath': 'high_low_emergency',
//       'backgroundColor': '#0955fa',
//       // 'background': 'https://i.pravatar.cc/500',
//       'actionColor': '#4CAF50'
//     },
//     'ios': <String, dynamic>{
//       'iconName': 'CallKitLogo',
//       'handleType': '',
//       'supportsVideo': true,
//       'maximumCallGroups': 2,
//       'maximumCallsPerCallGroup': 1,
//       'audioSessionMode': 'default',
//       'audioSessionActive': true,
//       'audioSessionPreferredSampleRate': 44100.0,
//       'audioSessionPreferredIOBufferDuration': 0.005,
//       'supportsDTMF': true,
//       'supportsHolding': true,
//       'supportsGrouping': false,
//       'supportsUngrouping': false,
//       'ringtonePath': 'system_ringtone_default'
//     }
//   };
//   await FlutterCallkitIncoming.showCallkitIncoming(params);
// }
