import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/network/repositories/emergency_network.dart';

import '../data/model/emergency/emergency_category_data.dart';
import '../data/model/notification.dart';
import '../data/response/base_response.dart';
import '../main.dart';
import '../network/api_urls.dart';
import '../ui/complaints/complaint_details.dart';
import '../ui/events/event_details.dart';
import '../ui/matches/match_details.dart';
import '../ui/menu_tabbar/menu_tabbar.dart';
import '../ui/news/news_details.dart';
import '../ui/notifications/notifications_list.dart';
import '../ui/offers_services/offer_service_details.dart';
import '../ui/sos/screens/sos_details.dart';
import '../ui/trips/trip_details.dart';
import 'local_settings.dart';
// import 'package:uuid/uuid.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'token_utilities.dart';

enum NotificationAction { accept, reject }

class NotificationManager {
  LocalSettings _localSettings = LocalSettings();
  String type = "";
  String post_id = "";
  bool from_branch = false;

  // initializeAwesomeNotifications() {
  //   AwesomeNotifications().initialize(
  //     'resource://drawable/sporting_notif_ic',
  //     [
  //       NotificationChannel(
  //         channelGroupKey: 'sporting_Key',
  //         channelKey: 'sporting_channel',
  //         channelName: 'sporting notifications',
  //         channelDescription: 'Notification channel for sporting _channel',
  //         defaultColor: AppColors.green,
  //         ledColor: Colors.white,
  //         importance: NotificationImportance.High,
  //         playSound: true,
  //         soundSource: 'resource://raw/high_emergency',
  //       )
  //     ],
  //     channelGroups: [
  //       NotificationChannelGroup(
  //           channelGroupkey: 'sporting_Key',
  //           channelGroupName: 'sporting_channel_group'),
  //     ],
  //   );
  // }

  // showAwesomeNotifications(RemoteMessage message, isSOS) async {
  //   // await AwesomeNotifications().createNotificationFromJsonData(message.data);
  //   await AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //         id: 0,
  //         channelKey: 'sporting_channel',
  //         title: message.data["title"],
  //         body: message.data["alert"],
  //         notificationLayout: NotificationLayout.BigPicture,
  //         largeIcon: isSOS
  //             ? 'asset://assets/emrgancy_details_ic.png'
  //             : 'asset://assets/sporting_club_logo.png',
  //         color: AppColors.green,
  //         displayOnBackground: true,
  //         displayOnForeground: true,
  //         // customSound: 'asset://assets/high_emergency.wav' ,
  //       ),
  //       actionButtons: [
  //         if (isSOS)
  //           NotificationActionButton(
  //               key: 'CANCEL_SOS', label: 'Cancel sos', color: AppColors.green)
  //       ]
  //       // schedule: NotificationInterval(interval: 60, timeZone: localTimeZone, repeats: true)
  //       );
  //   AwesomeNotifications().actionStream.asBroadcastStream().listen((event) {
  //     print('event received!');
  //     print(event.toMap().toString());
  //     if (event.buttonKeyPressed == "CANCEL_SOS") {
  //       FlutterRingtonePlayer.stop();
  //     }
  //     global.navigatorKey.currentState?.push(MaterialPageRoute(
  //         builder: (BuildContext context) => NotificationsList()));
  //     // do something based on event...
  //   });
  // }

  // showAwesomeOneSignalNotifications(
  //     OSNotification osNotification, bool isSOS) async {
  //   // await AwesomeNotifications().createNotificationFromJsonData(message.data);
  //   await AwesomeNotifications().createNotification(
  //       content: NotificationContent(
  //         id: osNotification.androidNotificationId ?? 0,
  //         channelKey: 'sporting_channel',
  //         title: osNotification.title,
  //         body: osNotification.body,
  //         notificationLayout: NotificationLayout.BigPicture,
  //         largeIcon: isSOS
  //             ? 'asset://assets/emrgancy_details_ic.png'
  //             : 'asset://assets/sporting_club_logo.png',
  //         displayOnBackground: true,
  //         displayOnForeground: true,
  //         // customSound: 'asset://assets/high_emergency.wav' ,
  //       ),
  //       actionButtons: [
  //         if (isSOS)
  //           NotificationActionButton(
  //               key: 'CANCEL_SOS', label: 'Cancel sos', color: AppColors.green)
  //       ]
  //       // schedule: NotificationInterval(interval: 60, timeZone: localTimeZone, repeats: true)
  //       );
  //   // showCallkitIncoming(
  //   //     Uuid().v4(), "setNotificationWillShowInForegroundHandler");
  //   AwesomeNotifications().actionStream.asBroadcastStream().listen((event) {
  //     print('event received!');
  //     print(event.toMap().toString());
  //     if (event.buttonKeyPressed == "CANCEL_SOS") {
  //       FlutterRingtonePlayer.stop();
  //     }
  //     global.navigatorKey.currentState?.push(MaterialPageRoute(
  //         builder: (BuildContext context) => NotificationsList()));
  //     // do something based on event...
  //   });
  // }

  // handleOpenAwesomeNotification(OSNotificationOpenedResult message) async {
  //   AwesomeNotifications().actionStream.asBroadcastStream().listen((event) {
  //     print('event received!');
  //     print(event.toMap().toString());
  //     global.navigatorKey.currentState?.push(MaterialPageRoute(
  //         builder: (BuildContext context) => NotificationsList()));
  //     // do something based on event...
  //   });
  // }

  // handleOpenNotification(OSNotificationReceivedEvent message) async {
  //   print("handleOpenNotification.onMessage");
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   if (!kIsWeb) {
  //     channel = const AndroidNotificationChannel(
  //       'high_importance_channel', // id
  //       'High Importance Notifications', // title
  //       // 'This channel is used for important notifications.', // description
  //       importance: Importance.high,
  //       sound: RawResourceAndroidNotificationSound("high_emergency"),
  //       playSound: true,
  //     );

  //     await flutterLocalNotificationsPlugin!
  //         .resolvePlatformSpecificImplementation<
  //             AndroidFlutterLocalNotificationsPlugin>()
  //         ?.createNotificationChannel(channel!);
  //     var android = AndroidInitializationSettings(
  //       'mipmap/ic_launcher',
  //     );
  //     var ios = DarwinInitializationSettings(
  //         requestSoundPermission: true,
  //         defaultPresentSound: true,
  //         notificationCategories: [
  //           DarwinNotificationCategory(
  //             'actionsCat',
  //             actions: <DarwinNotificationAction>[
  //               DarwinNotificationAction.plain(
  //                 NotificationAction.accept.name,
  //                 'Accept',
  //                 options: <DarwinNotificationActionOption>{
  //                   // DarwinNotificationActionOption.destructive,
  //                 },
  //               ),
  //               DarwinNotificationAction.plain(
  //                 NotificationAction.reject.name,
  //                 'Reject',
  //                 options: <DarwinNotificationActionOption>{
  //                   DarwinNotificationActionOption.destructive,
  //                 },
  //               ),
  //             ],
  //             options: <DarwinNotificationCategoryOption>{
  //               DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
  //             },
  //           )
  //         ]);
  //     var platform = InitializationSettings(android: android, iOS: ios);
  //     flutterLocalNotificationsPlugin?.initialize(
  //       platform,
  //       onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  //       onDidReceiveNotificationResponse: notificationTapBackground,
  //     );

  //     /// Update the iOS foreground notification presentation options to allow
  //     /// heads up notifications.
  //     await FirebaseMessaging.instance
  //         .setForegroundNotificationPresentationOptions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //   }
  //   var notification = message.notification;
  //   // AndroidNotification? android = message.notification.buttons.first.;
  //   if (notification != null && !kIsWeb) {
  //     flutterLocalNotificationsPlugin!.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel!.id, channel!.name,
  //             // channel!.description,
  //             icon: 'sporting_notif_ic',
  //             playSound: true,
  //             sound: RawResourceAndroidNotificationSound("high_emergency"),
  //             actions: <AndroidNotificationAction>[
  //               AndroidNotificationAction(
  //                 NotificationAction.accept.name,
  //                 'Accept',
  //                 cancelNotification: true,
  //               ),
  //               AndroidNotificationAction(
  //                 NotificationAction.reject.name,
  //                 'Reject',
  //                 cancelNotification: true,
  //               ),
  //             ],
  //           ),
  //           iOS: DarwinNotificationDetails(
  //               badgeNumber: 1,
  //               sound: 'high_emergency.wav',
  //               presentSound: true),
  //         ));
  //     // Map<dynamic, dynamic> data = message as Map<dynamic, dynamic>;
  //     // Map<dynamic, dynamic> rawPayload = message as Map<dynamic, dynamic>;

  //     print('notification is opened');
  //     // if (data != null) {
  //     //   if (data["type"] != null) {
  //     //     if (data["post_id"] != null) {
  //     //       _checkNotificationNavigation(
  //     //           data["type"].toString(), data["post_id"].toString(), false);
  //     //     } else {
  //     //       global.navigatorKey.currentState?.push(MaterialPageRoute(
  //     //           builder: (BuildContext context) => MenuTabBar(0, 0)));
  //     //     }
  //     //   } else {
  //     //     global.navigatorKey.currentState?.push(MaterialPageRoute(
  //     //         builder: (BuildContext context) => NotificationsList()));
  //     //   }
  //     //   //  }
  //     // }
  //   }
  // }

  void initOneSignal() async {
    print('_initOneSignal manager');
    OneSignal.shared.setAppId(ApiUrls.ONESIGNALKEY);
    OneSignal.shared.promptUserForPushNotificationPermission();
// If you want to know if the user allowed/denied permission,
// the function returns a Future<bool>:
    bool allowed =
        await OneSignal.shared.promptUserForPushNotificationPermission();
    print('promptUserForPushNotificationPermission: ' + allowed.toString());
    OneSignal.shared.setLocationShared(false);
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent notification) {
      print("setNotificationReceivedHandler");
      // bool isSos = notification.notification.additionalData?["sos"] != null;
      notification.notification.sound = 'high_emergency';
      notification.complete(notification.notification);
      LocalSettings _localSettings = LocalSettings();
      _localSettings.getNotificationsCount().then((count) {
        print('latest count: ' + count.toString());
        _localSettings.setNotificationsCount(1);
      });
      print('latest count: ' + "test");
      _localSettings.setNotificationsCount(1);

      LocalSettings.notificationsCount = 1;
      print('latest count: ' +
          "test2" +
          "${_localSettings.getNotificationsCount().then((value) => 0)}");
    });
    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      // will be called whenever a notification is opened/button pressed.
      print('notification is opened00000');
      // FlutterRingtonePlayer.stop();
      LocalSettings.notificationsCount = 0;
      print(result.action?.type);
      print(result.action?.actionId);

      Map<String, dynamic>? data = result.notification.additionalData;
      String? launchUrl = result.notification.launchUrl;
      print('notification is openedjj$launchUrl');

      if (data != null) {
        print("data666666 ${result.action}");
        print("data666666 ${data.toString()}");

        // if (data["url"] != null) {
        // _launchURL(data["url"]);
        if (result.action?.type == OSNotificationActionType.actionTaken &&
            data["sos"] != null) {
          var sosId = data["sos_id"]?.toString() ?? "";
          var uniqueId = data["unique"] ?? "";

          // var location = data["loaction"];
          if (result.action?.actionId == "accept") {
            acceptSos(uniqueId: uniqueId, sosId: sosId);
            global.navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (BuildContext context) => SOSDetailsScreen(
                    NotificationModel(id: data["id_notification"].toString()),
                    true)));
          } else if (result.action?.actionId == "reject") {
            rejectSos(sosId: sosId);
            // global.navigatorKey.currentState?.push(MaterialPageRoute(
            //     builder: (BuildContext context) => SOSDetailsScreen(
            //         NotificationModel(id: data["id_notification"].toString()),
            //         true)));
          }
        } else if (data["id_notification"] != null && data["sos"] != null) {
          // int sosId=int.parse( data["id_notification"]??0 );
          int idNotification = data["id_notification"];
          global.navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (BuildContext context) => SOSDetailsScreen(
                  NotificationModel(id: idNotification.toString()), true)));
        } else if (data["type"] != null) {
          if (data["post_id"] != null) {
            _checkNotificationNavigation(
                data["type"].toString(), data["post_id"].toString(), false);
          } else {
            global.navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (BuildContext context) => MenuTabBar(0, 0)));
          }
        } else {
          print("openmmmmmmmmmmm");
          LocalSettings.open_notificatonlist = true;
          global.navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (BuildContext context) => NotificationsList()));
        }
        //  }
      } else {
        // global.navigatorKey.currentState.push(MaterialPageRoute(
        //     builder: (BuildContext context) => NotificationsList()));
      }
      LocalSettings _localSettings = LocalSettings();
      _localSettings.getNotificationsCount().then((count) {
        print('latest count: ' + count.toString());

        _localSettings.setNotificationsCount(1);
      });
    });
    var status = await OneSignal.shared.getDeviceState();
    String? oneSignalPlayerId = status?.userId;
    print("onesignalhhhhh $status ${oneSignalPlayerId}");

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) async {
      // will be called whenever the subscription changes
      //(ie. user gets registered with OneSignal and gets a user ID)
      print('setSubscriptionObserver');
      OneSignal.shared.removeExternalUserId();
    });
  }

  void _checkNotificationNavigation(
      String type, String postId, bool from_branch) {
    print("_checkNotificationNavigation");
    this.post_id = postId;
    this.type = type;
    this.from_branch = from_branch;

    switch (type) {
      case "team_icon":
        // LocalSettings.postID = post
        // _navigationDirection = 3;
        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) => MatchDetails(postId, false)));
        break;

      case "new_icon":
        //_navigationDirection = 4;
        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) =>
                NewsDetails(int.parse(postId), from_branch)));
        break;

      case "event_icon":
        //_navigationDirection = 5;
        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) => EventDetails(postId)));
        break;

      case "service":
        //  _navigationDirection = 6;
        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) =>
                OfferServiceDetails(int.parse(postId), false)));
        break;
      case "offer":
        //_navigationDirection = 7;
        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) =>
                OfferServiceDetails(int.parse(postId), false)));
        break;
      case "trip_details":
        //  _navigationDirection = 8;

        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) => TripDetails(
                  int.parse(postId),
                  null,
                  false,
                )));
        break;
      case "admin_icon":
        print('admin no action');
        // _navigationDirection = 9;

        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (BuildContext context) => MenuTabBar(0, 0)));

        break;
      case "complaint":
        // LocalSettings.open_complainlist = true;
        // _navigationDirection = 10;
        global.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => ComplaintDetails(int.parse(postId))));
        break;
      default:
        break;
    }
  }

  Future<void> acceptSos({
    required String uniqueId,
    required String sosId,
    bool isRetry = false,
  }) async {
    var emergencyNetwork = EmergencyNetwork();
    BaseResponse<EmergencyCategoryData> baseResponse =
        await emergencyNetwork.acceptSOS(
      uniqueId: uniqueId,
      sosId: sosId,
    );
    if (baseResponse.statusCode != 200) {
      if (baseResponse.statusCode == InvalidValues) {
        if (baseResponse.message != null) {
          Fluttertoast.showToast(
              msg: baseResponse.message ?? "", toastLength: Toast.LENGTH_LONG);
        }
      } else if (baseResponse.statusCode == UNAUTHORIZED) {
        if (baseResponse.message != null) {
          Fluttertoast.showToast(
              msg: baseResponse.message ?? "", toastLength: Toast.LENGTH_LONG);
        }
      } else if (baseResponse.statusCode == INVALIDTOKEN) {
        if (!isRetry && global.navigatorKey.currentContext != null) {
          TokenUtilities tokenUtilities = TokenUtilities();
          await tokenUtilities
              .refreshToken(global.navigatorKey.currentContext!);
          acceptSos(sosId: sosId, uniqueId: uniqueId, isRetry: true);
        }
      } else if (baseResponse.statusCode == NO_NETWORK) {
        Fluttertoast.showToast(
            msg:
                "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
            toastLength: Toast.LENGTH_LONG);
      }
    }
  }

  Future<void> rejectSos({
    required String sosId,
    bool isRetry = false,
  }) async {
    var emergencyNetwork = EmergencyNetwork();
    BaseResponse<EmergencyCategoryData> baseResponse =
        await emergencyNetwork.rejectSOS(
      sosId: sosId,
    );
    if (baseResponse.statusCode != 200) {
      if (baseResponse.statusCode == InvalidValues) {
        if (baseResponse.message != null) {
          Fluttertoast.showToast(
              msg: baseResponse.message ?? "", toastLength: Toast.LENGTH_LONG);
        }
      } else if (baseResponse.statusCode == UNAUTHORIZED) {
        if (baseResponse.message != null) {
          Fluttertoast.showToast(
              msg: baseResponse.message ?? "", toastLength: Toast.LENGTH_LONG);
        }
      } else if (baseResponse.statusCode == INVALIDTOKEN) {
        if (!isRetry && global.navigatorKey.currentContext != null) {
          TokenUtilities tokenUtilities = TokenUtilities();
          await tokenUtilities
              .refreshToken(global.navigatorKey.currentContext!);
          rejectSos(sosId: sosId, isRetry: true);
        }
      } else if (baseResponse.statusCode == NO_NETWORK) {
        Fluttertoast.showToast(
            msg:
                "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
            toastLength: Toast.LENGTH_LONG);
      }
    }
  }
}

const int InvalidValues = 404;
const int VALIDATION_ERROR = 422;
const int UNAUTHORIZED = 403;
const int INVALIDTOKEN = 400;
const int NOT_ACCEPTABLE = 406;
const int NO_NETWORK = 600;
// @pragma('vm:entry-point')
// void notificationTapBackground(
//     NotificationResponse notificationResponse) async {
//   // handle action
//   if (notificationResponse.actionId == NotificationAction.accept.name) {
//     WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp();

//     LocalSettings().getToken();

//     FirebaseDatabase database = FirebaseDatabase.instance;
//     var now = DateTime.now();
//     var child =
//         database.ref("test").child(now.millisecondsSinceEpoch.toString());
//     await child.set("$now");
//   }
// }
