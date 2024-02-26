import UIKit
import Flutter
import GoogleMaps
import Branch
import Firebase
import FirebaseCore
import OneSignal


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
//    static var FIREBASE_TOKEN_TYPE  : MessagingAPNSTokenType = .sandbox //test
    static var FIREBASE_TOKEN_TYPE  : MessagingAPNSTokenType =  .prod //prod
    private var eventSink: FlutterEventSink?
//        static var ONE_SIGNAL_APP_ID = "c37ed674-f612-49a8-a658-972e37c8dbaf"; //test
    static var ONE_SIGNAL_APP_ID  = "c2af908b-a933-479a-8a27-a5ec795a1ed6";    //  prod
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
            GeneratedPluginRegistrant.register(with: self)

        GMSServices.provideAPIKey("AIzaSyCqYqelBPGcM7HEZ3celzuCzwMPNXNsk9M")
//        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//            GeneratedPluginRegistrant.register(with: registry)
//        }


        //***************************         firebase        *********************************

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let iosFirebaseTokenChannel = FlutterMethodChannel(name: "getIOSFirebaseToken",binaryMessenger: controller as! FlutterBinaryMessenger)
        
        iosFirebaseTokenChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            // Handle battery messages.
            guard call.method == "getIOSFirebaseToken" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self.getIOSFirebaseToken(result: result)
        })
        
//        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
//
//        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
//        OneSignal.initWithLaunchOptions(launchOptions,
//                                        appId: AppDelegate.ONE_SIGNAL_APP_ID,
//                                        handleNotificationAction: nil,
//                                        settings: onesignalInitSettings)
//
//        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
//
//        // Recommend moving the below line to prompt for push after informing the user about
//        //   how your app will use them.
//        OneSignal.promptForPushNotifications(userResponse: { accepted in
//            print("User accepted notifications: \(accepted)")
//        })
        UNUserNotificationCenter.current().delegate = self

        
        
//***************************         branch io        *********************************
        
//        guard let controller = window?.rootViewController as? FlutterViewController else {
//            fatalError("rootViewController cannot be casted to FlutterViewController")
//        }
////
//        let eventChannel = FlutterEventChannel(name: "flutter_branch_io/event", binaryMessenger: controller)
////
      //  eventChannel.setStreamHandler(self)
//
//        // if you are using the TEST key
//        // WARNING: DELETE THIS LINE FOR PRODUCTION USE
//        Branch.setUseTestBranchKey(true)
//        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
            print(params as? [String: AnyObject] ?? {})
            if (self.eventSink != nil) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                    self.eventSink!(jsonString)
                } catch {
                    print("BRANCH IO FLUTTER IOS ERROR")
                    print(error)
                }
            } else {
                print("Branch IO eventSink is nil")
            }
        }
      
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
//    @available(iOS 10.0, *)
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("didReceive response");
//        completionHandler()
//    }
//    
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
//    {
//        print("will present")
//        let notificationInfo = notification.request.content.userInfo
//        print(notificationInfo as Any)
//        Messaging.messaging().appDidReceiveMessage(notificationInfo)
////        completionHandler()
//
//        completionHandler([.alert, .badge, .sound])
//    }
    
    private func getIOSFirebaseToken(result: FlutterResult) {
        if (Messaging.messaging().apnsToken != nil){

        Messaging.messaging().setAPNSToken(Messaging.messaging().apnsToken!, type:AppDelegate.FIREBASE_TOKEN_TYPE)
        
            let token = Messaging.messaging().apnsToken!.hexString()
            result(token)
            print("success get firebsae token "+token);
        }
        else {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "can not get ios firebase token",
                                details: nil))
        }
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
//    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // handler for Push Notifications
//        Branch.getInstance().handlePushNotification(userInfo)
//print("hghghghghghg")
//        Messaging.messaging().appDidReceiveMessage(userInfo)
//        print(userInfo)
//
//        if Auth.auth().canHandleNotification(userInfo) {
//
//            completionHandler(.noData)
//            return
//        }
//
//
//        completionHandler(.newData)
//
//    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    
}
extension Data {
    func hexString() -> String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}

