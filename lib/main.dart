import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sporting_club/ui/complaints/complaint_details.dart';
import 'package:sporting_club/ui/events/event_details.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/login/login.dart';
import 'package:sporting_club/ui/matches/match_details.dart';
import 'package:sporting_club/ui/menu_tabbar/menu_tabbar.dart';
import 'package:sporting_club/ui/news/news_details.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/offers_services/offer_service_details.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/utilities/firebase_manager.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/notification_manager.dart';

import 'network/api_urls.dart';
import 'network/repositories/info_network.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) await AndroidAlarmManager.initialize();
  // ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  LocalSettings _localSettings = LocalSettings();
  InfoNetwork _infoNetwork = InfoNetwork();
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!ApiUrls.RELEASE_MODE) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      // Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseManager().initFirebase();
  _localSettings.getToken().then((value) async {
    if (value != null) {
      await _infoNetwork.getAdsList(null, null, null);
      runZoned<Future<Null>>(() async {
        runApp(SportingClub());
      }, onError: (error, stackTrace) async {
        // Whenever an error occurs, call the `reportCrash` function. This will send
        // Dart errors to our dev console or Crashlytics depending on the environment.
        // await FlutterCrashlytics().reportCrash(error, stackTrace, forceCrash: false);
      });
    } else {
      runZoned<Future<Null>>(() async {
        await _infoNetwork.getAdsList(null, null, null);
        runApp(SportingClub());
      }, onError: (error, stackTrace) async {
        // Whenever an error occurs, call the `reportCrash` function. This will send
        // Dart errors to our dev console or Crashlytics depending on the environment.
        // await FlutterCrashlytics().reportCrash(error, stackTrace, forceCrash: false);
      });
    }
  });
}

class SportingClub extends StatefulWidget {
  SportingClub({Key? key}) : super(key: key);

  @override
  _SportingClubState createState() => _SportingClubState();
}

class _SportingClubState extends State<SportingClub> {
  LocalSettings _localSettings = LocalSettings();

  //0.. for Login    1.. for Home
  int? _navigationDirection = 1;

  String _data = '-';
  String generatedLink = '-';
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String id = "";
  String type = "";
  String post_id = "";
  bool from_branch = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar'),
        Locale('en'),
      ],
      title: 'Sporting Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff43a047),
        textSelectionColor: Color(0xff76d275),
        textSelectionHandleColor: Color(0xff76d275),
        cursorColor: Color(0xff76d275),
        accentColor: Color(0xff43a047),
        fontFamily: 'Bahij',
      ),
      home: _setAppRoot(),
      //MyShuttleBusPackageScreen(), //
      navigatorKey: global.navigatorKey,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }

  @override
  void initState() {
    super.initState();
    _checkNavigation();
    _initNewBranchIO();
    if (ApiUrls.RELEASE_MODE) {
      _logDeviceType();
    }
    _initFirebaseMessaging();
    // _initOneSignal();
    NotificationManager().initOneSignal();
  }

//   void _initOneSignal() async {
//     print('_initOneSignal');
//     OneSignal.shared.setAppId(ApiUrls.ONESIGNALKEY);
//     OneSignal.shared.promptUserForPushNotificationPermission();
// // If you want to know if the user allowed/denied permission,
// // the function returns a Future<bool>:
//     bool allowed =
//         await OneSignal.shared.promptUserForPushNotificationPermission();
//     print('promptUserForPushNotificationPermission: ' + allowed.toString());
//     OneSignal.shared.setLocationShared(false);
//     OneSignal.shared.setNotificationWillShowInForegroundHandler(
//         (OSNotificationReceivedEvent notification) {
//       print("setNotificationReceivedHandler");
//       bool isSos = notification.notification.additionalData?["sos"] != null;
//       // if (isSos) {}
//       notification.notification.sound = 'high_emergency';
//       // showCallkitIncoming(Uuid().v4(), "setNotificationWillShowInForegroundHandler");
//       notification.complete(notification.notification);
//       LocalSettings _localSettings = LocalSettings();
//       _localSettings.getNotificationsCount().then((count) {
//         // if (count < 0) {
//         //   count = 0;
//         // }
//         print('latest count: ' + count.toString());
//         _localSettings.setNotificationsCount(1);
//       });
//       print('latest count: ' + "test");
//       _localSettings.setNotificationsCount(1);

//       LocalSettings.notificationsCount = 1;
//       print('latest count: ' +
//           "test2" +
//           "${_localSettings.getNotificationsCount().then((value) => 0)}");
//     });
//     // OneSignal.shared.set
//     OneSignal.shared.setNotificationOpenedHandler(
//         (OSNotificationOpenedResult result) async {
//       // will be called whenever a notification is opened/button pressed.
//       print('notification is opened00000');
//       FlutterRingtonePlayer.stop();
//       LocalSettings.notificationsCount = 0;
//       print(result.action?.type);
//       print(result.action?.actionId);

//       Map<String, dynamic>? data = result.notification.additionalData;
//       String? launchUrl = result.notification.launchUrl;
//       print('notification is openedjj$launchUrl');

//       if (launchUrl != null) {
// //      if (await canLaunch(url)) {
// //    await launch(url);
// //    } else {
// //    throw 'Could not launch $url';
// //    }
// //      // The following can be used to open an Activity of your choice.
// //      // Replace - getApplicationContext() - with any Android Context.
// //      // Replace - YOURACTIVITY.class with your activity to deep link
// //      Intent intent = new Intent(getApplicationContext(), YOURACTIVITY.class);
// //      intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT | Intent.FLAG_ACTIVITY_NEW_TASK);
// //      intent.putExtra("openURL", launchUrl);
// //      Log.i("OneSignalExample", "openURL = " + launchUrl);
// //      startActivity(intent);
//       }
//       if (data != null) {
//         print("data666666${data.toString()}");
//         // if (data["url"] != null) {
//         // _launchURL(data["url"]);
//         if (result.action?.type == OSNotificationActionType.actionTaken &&
//             data["sos"] != null) {
//           var phone = data["phone"] ?? "";
//           var location = data["loaction"];
//           if (result.action?.actionId == "phone") {
//             print(result.action?.actionId);
//             if (await launch("tel://$phone")) {
//               await launch("");
//             } else {
//               throw 'Could not open the call.';
//             }
//           } else {
//             if (await canLaunch(location)) {
//               await launch(location);
//             } else {
//               throw 'Could not open the map.';
//             }
//           }
//         } else if (data["id_notification"] != null && data["sos"] != null) {
//           // int sosId=int.parse( data["id_notification"]??0 );
//           global.navigatorKey.currentState?.push(MaterialPageRoute(
//               builder: (BuildContext context) => SOSDetailsScreen(
//                   NotificationModel(id: data["id_notification"].toString()),
//                   true)));
//         } else if (data["type"] != null) {
//           if (data["post_id"] != null) {
//             _checkNotificationNavigation(
//                 data["type"].toString(), data["post_id"].toString(), false);
//           } else {
//             global.navigatorKey.currentState?.push(MaterialPageRoute(
//                 builder: (BuildContext context) => MenuTabBar(0, 0)));
//           }
//         } else {
//           // https: //www.google.com/search?client=safari&rls=en&q=ope.+screen+in+launch+flutter&ie=UTF-8&oe=UTF-8
//           print("openmmmmmmmmmmm");
//           // _navigationDirection = 1;
//           // NotificationsList();
//           LocalSettings.open_notificatonlist = true;
//           global.navigatorKey.currentState?.push(MaterialPageRoute(
//               builder: (BuildContext context) => NotificationsList()));
//         }
//         //  }
//       } else {
//         // global.navigatorKey.currentState.push(MaterialPageRoute(
//         //     builder: (BuildContext context) => NotificationsList()));
//       }
//       LocalSettings _localSettings = LocalSettings();
//       _localSettings.getNotificationsCount().then((count) {
//         print('latest count: ' + count.toString());

//         _localSettings.setNotificationsCount(1);
//       });
//     });
//     var status = await OneSignal.shared.getDeviceState();
//     String? oneSignalPlayerId = status?.userId;
//     print("onesignalhhhhh $status ${oneSignalPlayerId}");

//     OneSignal.shared
//         .setSubscriptionObserver((OSSubscriptionStateChanges changes) async {
//       // will be called whenever the subscription changes
//       //(ie. user gets registered with OneSignal and gets a user ID)
//       print('setSubscriptionObserver');
//       OneSignal.shared.removeExternalUserId();

// //    LocalSettings _localSettings = LocalSettings();
// //    var status = await OneSignal.shared.getPermissionSubscriptionState();
// //    String oneSignalPlayerId = status.subscriptionStatus.userId;
// // //    print(status.subscriptionStatus.userId);
// //     print("onesignalhhhhh ${oneSignalPlayerId}");
// //    if (oneSignalPlayerId != null) {
// //      print("player id: " + oneSignalPlayerId);
// //      _localSettings.setPlayerId(oneSignalPlayerId);
// //      LocalSettings.playerId = oneSignalPlayerId;
// //    }
//     });
//   }

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

  void _checkNavigation() {
    _localSettings.getToken().then((value) async {
      if (value != null) {
        // await _localSettings.getUser();
        // await _localSettings.getLoginData();
        setState(() {
          if (LocalSettings.open_notificatonlist) {
            _navigationDirection = 2;
            LocalSettings.open_notificatonlist = false;
          } else {
            _navigationDirection = 1;
          }
        });
      } else {
        setState(() {
          _navigationDirection = 1;
        });
      }
    });
    _localSettings.getRefreshToken();
    _localSettings.getInterests();
    _localSettings.getNotificationsCount().then((count) {
      print('notifications count: ' + count.toString());
    });
  }

  void _logDeviceType() {
    _localSettings.isOpenedBefore().then((value) {
      if (value == null) {
        print('first open');
        if (Platform.isAndroid) {
          print('first open log event Android');
          analytics.logEvent(name: 'Android');
        } else {
          print('first open log event iOS');
          analytics.logEvent(name: 'iOS');
        }
        _localSettings.setOpenedBefore(true);
      }
    });
  }

  Widget _setAppRoot() {
    print("home");

    switch (_navigationDirection) {
      case 0:
        return Login();
        break;
      case 1:
        return Home();
        break;
      case 2:
        return NotificationsList(
          fromNotification: true,
        );
        break;
      case 3:
        return MatchDetails(post_id, true);
        break;
      // case 4 :
      //   return  NewsDetails(int.parse(post_id),from_branch);
      //   break;
      // case 5 :
      //   return   EventDetails((post_id));
      //   break;
      //
      // case 6 :
      //   return   OfferServiceDetails(int.parse(post_id),false);
      //   break;
      // case 7 :
      //   return    OfferServiceDetails(int.parse(post_id),true);
      //   break;
      // case 8 :
      //   return  TripDetails(
      //     int.parse(post_id),
      //     null,
      //     true,
      //   );
      //   break;
      //   case 9:
      //     return   MenuTabBar(0,0);
      //     break;
      //   case 10 :
      //     return  ComplaintDetails(int.parse(post_id));
      //     break;
      default:
        return Login();
    }
    // return  NewsDetails(45207);
//    switch (_navigationDirection) {
//
//      case 3:
//        return  NewsDetails(45207);
//        break;
//      default:
//        return Home();
//    }
  }

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  _initNewBranchIO() {
    FlutterBranchSdk.setIdentity('branch_user_test');
    //FlutterBranchSdk.setIOSSKAdNetworkMaxTime(72);

    listenDynamicLinks();
  }

  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {}
      String initialLink = data["link"];
      if (initialLink != null) {
        // var uri = Uri.parse(initialLink);
        // int  index = uri.path.lastIndexOf("/");
        // String  link = uri.path.substring(index+1);
        final String link = data['link'];
        final String id = data['id'];
        setState(() {
          if (link == 'news') {
            // this._navigationDirection = 3;
            _checkNotificationNavigation("new_icon", id, true);
          } else if (link == 'event') {
            print("ff" + _navigationDirection.toString());
            if (_navigationDirection == 1) {
              LocalSettings.token == null
                  ? global.navigatorKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => Login(
                                type: "event_icon",
                                postId: id,
                                from_branch: true,
                              )),
                      (Route<dynamic> route) => false)
                  : _checkNotificationNavigation("event_icon", id, true);
            } else {
              global.navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => Login(
                            type: "event_icon",
                            postId: id,
                            from_branch: true,
                          )),
                  (Route<dynamic> route) => false);
              // global.navigatorKey.currentState.push(MaterialPageRoute(
              //     builder: (BuildContext context) => Home()));
            }
          } else if (link == 'match') {
            _checkNotificationNavigation("team_icon", id, true);
          } else if (link == 'service') {
            if (_navigationDirection == 1) {
              LocalSettings.token == null
                  ? global.navigatorKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => Login(
                                type: "service",
                                postId: id,
                                from_branch: true,
                              )),
                      (Route<dynamic> route) => false)
                  : _checkNotificationNavigation("service", id, true);
            } else {
              global.navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => Login(
                            type: "service",
                            postId: id,
                            from_branch: true,
                          )),
                  (Route<dynamic> route) => false);
              // global.navigatorKey.currentState.push(MaterialPageRoute(
              //     builder: (BuildContext context) => Home()));
            }
          } else if (link == 'offer') {
            _checkNotificationNavigation("offer", id, true);
          } else if (link == 'trip') {
            if (_navigationDirection == 1) {
              LocalSettings.token == null
                  ? global.navigatorKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => Login(
                                type: "trip_details",
                                postId: id,
                                from_branch: true,
                              )),
                      (Route<dynamic> route) => false)
                  : _checkNotificationNavigation("trip_details", id, true);
            } else {
              // global.navigatorKey.currentState?.pushAndRemoveUntil(
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => Login(type: "trip_details",postId: id,from_branch: true,)),
              //         (Route<dynamic> route) => false);
              global.navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (BuildContext context) => Home()));
            }
          }
          this._data = initialLink;
        });
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print(
          'InitSession error: ${platformException.code} - ${platformException.message}');
      controllerInitSession.add(
          'InitSession error: ${platformException.code} - ${platformException.message}');
    });
  }

  void _initFirebaseMessaging() async {
    LocalSettings _localSettings = LocalSettings();

    setPermission();

    if (Platform.isAndroid) {
      _firebaseMessaging.getToken().then((token) {
        print("firebase token: $token");
        if (Platform.isIOS) {
          String newString = token?.replaceAll("-", "") ?? "";
          newString = newString.replaceAll(":", "");
          newString = newString.replaceAll("_", "");

          print("new ios firebase token: " + newString);
          LocalSettings.firebaseToken = newString;
        } else {
          LocalSettings.firebaseToken = token;
        }
      });
    } else {
      getIOSFirebaseToken();
    }
  }

  Future setPermission() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true)
        .then((value) {
      print("Settings registered: $value");
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      return firebaseMessagingBackgroundHandler(message);
    });

    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   handleOpenNotification(message);
    // });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FirebaseMessaging.onMessage");
      // showCallkitIncoming(Uuid().v4() ,"onMessage");
      // handleOpenNotification(message);
      // NotificationManager().handleOpenNotification(message);
    });
  }

  // handleReceiveNotification(
  //     OSNotificationReceivedEvent osNotificationReceivedEvent) {
  //   print("handleReceiveNotification");
  //   OSNotification notification = osNotificationReceivedEvent.notification;
  //   if (notification != null && !kIsWeb) {
  //     flutterLocalNotificationsPlugin!.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel!.id, channel!.name,
  //             // channel!.description,
  //             icon: 'ic_launcher2',
  //             playSound: true,
  //             sound: RawResourceAndroidNotificationSound("high_emergency"),
  //           ),
  //           iOS: DarwinNotificationDetails(
  //               badgeNumber: 1,
  //               sound: 'high_emergency.wav',
  //               presentSound: true),
  //         ));
  //   }
  // }

  // handleOpenNotification(RemoteMessage message) {
  //   print("handleOpenNotification.onMessage");

  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;
  //   if (notification != null && android != null && !kIsWeb) {
  //     flutterLocalNotificationsPlugin!.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel!.id, channel!.name,
  //             // channel!.description,
  //             icon: 'ic_launcher2',
  //             playSound: true,
  //             sound: RawResourceAndroidNotificationSound("high_emergency"),
  //           ),
  //           iOS: DarwinNotificationDetails(
  //               badgeNumber: 1,
  //               sound: 'high_emergency.wav',
  //               presentSound: true),
  //         ));
  //     Map<dynamic, dynamic> data = message as Map<dynamic, dynamic>;
  //     // Map<dynamic, dynamic> rawPayload = message as Map<dynamic, dynamic>;

  //     print('notification is opened');
  //     if (data != null) {
  //       print("data666666${data.toString()}");
  //       // if (data["url"] != null) {
  //       // _launchURL(data["url"]);
  //       if (data["type"] != null) {
  //         if (data["post_id"] != null) {
  //           _checkNotificationNavigation(
  //               data["type"].toString(), data["post_id"].toString(), false);
  //         } else {
  //           global.navigatorKey.currentState?.push(MaterialPageRoute(
  //               builder: (BuildContext context) => MenuTabBar(0, 0)));
  //         }
  //       } else {
  //         global.navigatorKey.currentState?.push(MaterialPageRoute(
  //             builder: (BuildContext context) => NotificationsList()));
  //       }
  //       //  }
  //     }
  //     LocalSettings.notificationsCount = 1;

  //     _localSettings.getNotificationsCount().then((count) {
  //       print('latest count: ' + count.toString());

  //       _localSettings.setNotificationsCount(1);
  //     });
  //   }
  //   // else{
  //   // }
  // }

  // Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   // OverlayWindowAlert.showOverlayWindow();
  //   // global.navigatorKey.currentState?.push(MaterialPageRoute(
  //   //     builder: (BuildContext context) => PlaySoundScreen()));
  //   handleOpenNotification(message);
  //   // handleBackgroundNotification(message);
  // }

  Future<void> getIOSFirebaseToken() async {
    const platform = const MethodChannel('getIOSFirebaseToken');

    String firebaseToken;
    try {
      firebaseToken = await platform.invokeMethod('getIOSFirebaseToken');
      print(firebaseToken + '    ios native code');
      LocalSettings.firebaseToken = firebaseToken;
    } on PlatformException catch (e) {
      print("Failed to get data from native : '${e.message}'.");
    }
  }
}

// AndroidNotificationChannel? channel;
// FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // handleCallkitIncomingHandler(message);
  // NotificationManager().handleOpenNotification(message);
}

class global {
  static final navigatorKey = new GlobalKey<NavigatorState>();
}
