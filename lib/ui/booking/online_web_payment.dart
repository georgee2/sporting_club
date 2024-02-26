import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/trips/booking_request.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/delegates/success_payment_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/ui/booking/session_expired.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class OnlineWebPayment extends StatefulWidget {
  String _url;
  Trip _trip = Trip();
  BookingRequest _bookingRequest = BookingRequest();
  bool _isFromPushNotification = false;
  SuccessPaymentDelegate _successPaymentDelegate;

  OnlineWebPayment(
    this._url,
    this._trip,
    this._bookingRequest,
    this._isFromPushNotification,
    this._successPaymentDelegate,
  );

  @override
  State<StatefulWidget> createState() {
    return OnlineWebPaymentState(
      this._url,
      this._trip,
      this._bookingRequest,
      this._isFromPushNotification,
      this._successPaymentDelegate,
    );
  }
}

class OnlineWebPaymentState extends State<OnlineWebPayment> {
  String _url;
  Trip _trip = Trip();
  bool _isloading = false;
  BookingRequest _bookingRequest = BookingRequest();
  bool _isFromPushNotification = false;
  SuccessPaymentDelegate _successPaymentDelegate;

  Timer? timer;
  String _timerValue = "";
  bool _isSessionExpired = false;

  OnlineWebPaymentState(
    this._url,
    this._trip,
    this._bookingRequest,
    this._isFromPushNotification,
    this._successPaymentDelegate,
  );

  @override
  void initState() {
    super.initState();
   // showLoading();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    print("url:"+_url);
    if (timer != null) {
      timer?.cancel();
    }
    _setTimer();
    return new ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: WillPopScope(
          onWillPop: ()async{
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(builder: (BuildContext context) => Home()),
            //         (Route<dynamic> route) => false);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                _trip.name ?? "",
              ),
              leading: IconButton(
                icon: new Image.asset('assets/back_white.png'),
                // onPressed: () => Navigator.of(context).pop(null),
                  onPressed: (){
                  // to return to trip details
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    // Navigator.pushAndRemoveUntil(
                    //     context,
                    //     MaterialPageRoute(builder: (BuildContext context) => Home()),
                    //         (Route<dynamic> route) => false);
                  }
              ),
            ),
            body: Stack(
              children: <Widget>[
                _buildFooter(),
                Padding(
                  child: Container(
                    height: height - 140,
                    child:
//                   WebviewScaffold(
//                     url: _url,
//                     withJavascript: true,
//                     javascriptChannels:   [
//                       JavascriptChannel(
//                           name: 'mobilePayment',
//                           onMessageReceived: (JavascriptMessage msg) {
//                             print('onMessageReceived ');
//                             print('msg: ' + msg.message);
//                             Map<String, dynamic> jsonData =
//                             json.decode(msg.message);
//                             print(jsonData.keys);
//                             if (jsonData['status'] != null) {
//                               print(jsonData['status']);
//                               if (jsonData['status']) {
//                                 print('Success Payment');
//                                 successPaymentAction(jsonData);
//
// //                    _successPaymentDelegate.showSuccessOnlinePayment("");
// //
// //                      Navigator.of(context).pop(null);
//                               } else {
//                                 print('Failed Payment');
//                                 failedPaymentAction(jsonData);
//                               }
//                             }
//                             print(jsonData.values);
//                           })
//                     ].toSet(),
//                     // onWebViewCreated: (WebViewController w) {},
//                     // onPageFinished: (String url) {
//                     //   print('Page finished loading');
//                     //   hideLoading();
//                     // },
//                   ),
                    WebView(
                      initialUrl: _url,
                      userAgent: 'random',
                      javascriptMode: JavascriptMode.unrestricted,
                      zoomEnabled: true,
                      allowsInlineMediaPlayback: true,
                      gestureNavigationEnabled: true,
                      javascriptChannels: {
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
                                if (jsonData['status']) {
                                  print('Success Payment');
                                  successPaymentAction(jsonData);
                                } else {
                                  print('Failed Payment');
                                  failedPaymentAction(jsonData);
                                }
                              }
                            })
                      },
                    ),
                  ),
                  padding: EdgeInsets.only(top: 55),
                ),
              ],
            ),
          ),
        ),
//          bottomNavigationBar: _buildFooter(),
      ),
      inAsyncCall: _isloading,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    );
  }

  Widget _buildFooter() {
    int difference = 0;
    if (_bookingRequest.expired_at != null) {
//      final endTime = DateTime.parse(_bookingRequest.expired_at);
      final endTime = DateTime.parse("2019-10-24T12:48:23+02:00");
      final date2 = DateTime.now();
      if (endTime.isAfter(date2)) {
        difference = endTime.difference(date2).inSeconds;
        print("difference: " + difference.toString());
      } else {
        print('before');
      }
    }
    int estimateTs = DateTime.parse("2019-10-24T13:04:23+02:00")
        .millisecondsSinceEpoch; // set needed date

    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          right: 20,
          left: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
//            Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
            Text(
              'سيتم الغاء الحجز تلقائياً بعد',
              style: TextStyle(
                color: Color(0xff03240a),
                fontSize: 14,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              _timerValue,
              style: TextStyle(
                  color: Color(0xff03240a),
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
//              ],
//            ),
          ],
        ),
      ),
      height: 55,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffeeeeee))),
        color: Colors.white,
      ),
    );
  }

  void _setTimer() {
    int difference = 0;
    if (_bookingRequest.expired_at != null) {
      final endTime = DateTime.parse(_bookingRequest.expired_at??"2000-01-01");
      final date2 = DateTime.now();
      if (endTime.isAfter(date2)) {
        difference = endTime.difference(date2).inSeconds;
//        print("difference: " + difference.toString());
      } else {
//        print('before');
      }
    }
    int remainsDuration = difference;
    if (remainsDuration > 0) {
      setState(() {
        _timerValue = formatHHMMSS(remainsDuration);
      });
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        remainsDuration -= 1;
        setState(() {
          _timerValue = formatHHMMSS(remainsDuration);
        });
        if (remainsDuration <= 0) {
          print('end timer');
          timer.cancel();
          if (ModalRoute.of(context)?.isCurrent??false) {
            print('navigate to end payment');
            _isSessionExpired = true;
            Navigator.pop(context);
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    SessionExpired(_trip, _isFromPushNotification)));
          }
        }
      });
    }
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

//    if (hours == 0) {
//      return "$minutesStr:$secondsStr";
//    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  void failedPaymentAction(Map<String, dynamic> jsonData) {
    if (jsonData['message'] != null) {
      Fluttertoast.showToast(msg:jsonData['message'], toastLength: Toast.LENGTH_LONG);
    }
    if (jsonData['payment_status'] != null) {
      if (jsonData['payment_status']) {
        //success payment but failed in server
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => Home()),
            (Route<dynamic> route) => false);
      } else {
        //failed payment
        if (_isFromPushNotification) {
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: RouteSettings(name: 'TripDetails'),
              builder: (context) =>
                  TripDetails(_trip.id??0, null, _isFromPushNotification),
            ),
          );
        } else {
          Navigator.of(context).popUntil(ModalRoute.withName('TripDetails'));
        }
      }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => Home()),
          (Route<dynamic> route) => false);
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
    setState(() {
      _isloading = true;
    });
  }
}
