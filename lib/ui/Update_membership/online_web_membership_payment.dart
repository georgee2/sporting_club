import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/delegates/success_payment_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/ui/booking/session_expired.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

class OnlineWebMembershipPayment extends StatefulWidget {
  String _url;
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  bool _isFromPushNotification = false;
  SuccessPaymentDelegate _successPaymentDelegate;

  OnlineWebMembershipPayment(
    this._url,

    this._successPaymentDelegate,
  );

  @override
  State<StatefulWidget> createState() {
    return OnlineWebMembershipPaymentState(
      this._url,
      this._successPaymentDelegate,
    );
  }
}

class OnlineWebMembershipPaymentState extends State<OnlineWebMembershipPayment> {
  String _url;
 // Trip _trip = Trip();
  bool _isloading = false;
 // BookingRequest _bookingRequest = BookingRequest();
 // bool _isFromPushNotification = false;
  SuccessPaymentDelegate _successPaymentDelegate;

  Timer? timer;
  String _timerValue = "";
  bool _isSessionExpired = false;

  OnlineWebMembershipPaymentState(
    this._url,
    this._successPaymentDelegate,
  );


  @override
  void initState() {
    super.initState();
    showLoading();

  }

  @override
  void dispose() {

    super.dispose();
  }
//https://staging-payment.xpay.app/core/payment_iframe/2065/
  @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return new Directionality(
//       textDirection: TextDirection.rtl,
//       child:
//       WebviewScaffold(
//         url: _url,
//         javascriptChannels:   [
//           JavascriptChannel(
//               name: 'mobilePayment',
//               onMessageReceived: (JavascriptMessage msg) {
//                 print('onMessageReceived ');
//                 print('msg: ' + msg.message);
//                 Map<String, dynamic> jsonData =
//                 json.decode(msg.message);
//                 print(jsonData.keys);
//                 if (jsonData['status'] != null) {
//                   print(jsonData['status']);
//                   if (jsonData['status']== 1) {
//                     print('Success Payment');
//                     successPaymentAction(jsonData);
//
// //                    _successPaymentDelegate.showSuccessOnlinePayment("");
// //
// //                      Navigator.of(context).pop(null);
//                   } else {
//                     print('Failed Payment');
//                       failedPaymentAction(jsonData);
//                   }
//                 }
//                 print(jsonData.values);
//               })
//
//         ].toSet(),
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).primaryColor,
//           title: Text(
//              "تجديد الاشتراك السنوي",
//           ),
//           leading: IconButton(
//             icon: new Image.asset('assets/back_white.png'),
//             onPressed: () {
//               _successPaymentDelegate.showSuccessOnlinePayment("");
//
//               Navigator.of(context).pop(null);
//           },
//           ),
//         ),
//         withZoom: true,
//         withLocalStorage: true,
//         initialChild: Container(
//           color: Colors.white,
//           child: const Center(
//             child: Text('يرجى الانتظار ....'),
//           ),
//         ),
//       ),
//     );
//   }

  Widget build(BuildContext context) {
    // TODO: implement build
    return new Directionality(
      textDirection: TextDirection.rtl,
      child:
      // WebviewScaffold(
      //   url: _url,
      Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "تجديد الاشتراك السنوي",
          ),
          leading: IconButton(
            icon: new Image.asset('assets/back_white.png'),
            onPressed: () {
              _successPaymentDelegate.showSuccessOnlinePayment("");

              Navigator.of(context).pop(null);
            },
          ),
        ),
        body:
        // _isloading?  Container(
        //   color: Colors.white,
        //   child: const Center(
        //     child: Text('يرجى الانتظار ....'),
        //   ),
        // ):
        WebView(
          initialUrl: _url,
          userAgent: 'random',
          javascriptMode: JavascriptMode.unrestricted,
          zoomEnabled: true,
          allowsInlineMediaPlayback: true,
          gestureNavigationEnabled: true,
          javascriptChannels:   [
            JavascriptChannel(
                name: 'mobilePayment',
                onMessageReceived: (JavascriptMessage msg) {
                  print('onMessageReceived ');
                  print('msg: ' + msg.message);
                  Map<String, dynamic> jsonData =
                  json.decode(msg.message);
                  print(jsonData.keys);
                  if (jsonData['status'] != null) {
                    print(jsonData['status']);
                    if (jsonData['status']== 1) {
                      print('Success Payment');
                      successPaymentAction(jsonData);
                    } else {
                      print('Failed Payment');
                      failedPaymentAction(jsonData);
                    }
                  }
                  print(jsonData.values);
                })

          ].toSet(),
          onPageFinished: (val){
            hideLoading();
          },
        ),
      ),
    );
  }






  void failedPaymentAction(Map<String, dynamic> jsonData) {
    if (jsonData['message'] != null) {
      Fluttertoast.showToast(msg:jsonData['message'], toastLength: Toast.LENGTH_LONG);
    }
    if (jsonData['payment_status'] != null) {
      if (jsonData['payment_status']) {
        Navigator.pop(context);

      }
        //success payment but failed in server
//        Navigator.pushAndRemoveUntil(
//            context,
//            MaterialPageRoute(builder: (BuildContext context) => Home()),
//            (Route<dynamic> route) => false);
//      } else {
//        //failed payment
////        if (_isFromPushNotification) {
////          Navigator.of(context).push(
////            MaterialPageRoute(
////              settings: RouteSettings(name: 'TripDetails'),
////              builder: (context) =>
////                  TripDetails(_trip.id, null, _isFromPushNotification),
////            ),
////          );
////        } else {
//          Navigator.of(context).popUntil(ModalRoute.withName('TripDetails'));
//       // }
//      }
//    } else {
//      Navigator.pushAndRemoveUntil(
//          context,
//          MaterialPageRoute(builder: (BuildContext context) => Home()),
//          (Route<dynamic> route) => false);
    }
  }

  void successPaymentAction(Map<String, dynamic> jsonData) {
    if (jsonData['message'] != null) {
      Fluttertoast.showToast(msg:jsonData['message'], toastLength: Toast.LENGTH_LONG);
    }
    String recieptUrl = "";
    if (jsonData['reciept_url'] != null) {
      recieptUrl = ApiUrls.BOOKING_RECIEPT + jsonData['reciept_url'];
    }
    if (_successPaymentDelegate != null) {
      print("recieptUrl"+recieptUrl);

      _successPaymentDelegate.showSuccessOnlinePayment(recieptUrl);
    }
    if (_isSessionExpired) {
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  void hideLoading() {
    setState(() {
      _isloading = false;
    });
  }

  void showLoading() {
    Future.delayed(Duration.zero, (){
      // setState(() {
      //   _isloading = true;
      // });
    });

  }
}
