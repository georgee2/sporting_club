import 'dart:convert';
import 'package:flutter/material.dart';

// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:sporting_club/data/model/shuttle_bus/online_shuttle_payment.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/select_shuttle_package.dart';
import 'dart:async';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'my_shuttle_details_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnlineShuttlePayment extends StatefulWidget {
  OnlineBookingPayment? onlineBookingPayment;

  OnlineShuttlePayment({
    this.onlineBookingPayment,
  });

  @override
  State<StatefulWidget> createState() {
    return OnlineWebPaymentState();
  }
}

class OnlineWebPaymentState extends State<OnlineShuttlePayment> {
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    // showLoading();
    Future.delayed(Duration(minutes: 15), (){
      failedPaymentAction({});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;

    return  ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            title: Text(
              "حجز شاتل باص",
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                top: 15,
                left: 10,
                right: 10,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    showReturnHint
                        ? "سيتم الرجوع لقائمة الحجوزات بعد 5 ثواني"
                        : "يرجي تكملة الدفع الاكتروني خلال ١٥ دقيقة و الا سيعتبر الحجز لاغي",
                  ),
                ),
              )
              ,
              Padding(
                child: Container(
                  height: height - 260,
                  child: buildPaymentWebView(),
                ),
                padding: EdgeInsets.only(top: 60),
              ),
            ],
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

  bool showReturnHint = false;

  buildPaymentWebView() {
    return
      // WebviewScaffold(
      // url: widget.onlineBookingPayment?.iframe_url??"",
      // withJavascript: true,
      // debuggingEnabled: true,
      //     userAgent: 'random',
      WebView(
        initialUrl:widget.onlineBookingPayment?.iframe_url??"",
        userAgent: 'random',
        javascriptMode: JavascriptMode.unrestricted,
        zoomEnabled: true,
        allowsInlineMediaPlayback: true,
        gestureNavigationEnabled: true,
      javascriptChannels: [
        JavascriptChannel(
          name: 'mobilePayment',
          onMessageReceived: (JavascriptMessage msg) {
            print('onMessageReceived ');
            print('msg: ' + msg.message);
            Map<String, dynamic> jsonData = json.decode(msg.message);
            print(jsonData.keys);

            if (jsonData['status'] != null) {
              print(jsonData['status']);
              if (jsonData['status'] == 1) {
                print('Success Payment');
                successPaymentAction(jsonData);
              } else {
                print('Failed Payment');
                failedPaymentAction(jsonData);
              }
            }
            print(jsonData.values);
          },
        )
      ].toSet(),
    );
  }

  void failedPaymentAction(Map<String, dynamic> jsonData) {
    // Toast.show("سيتم الرجوع لقائمة الحجوزات بعد 5 ثواني", context, duration: Toast.LENGTH_LONG);
    setState(() {
      showReturnHint = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  SelectShuttleBusPackageScreen()));
    });
  }

  void successPaymentAction(Map<String, dynamic> jsonData) {
    // Toast.show("سيتم الرجوع لقائمة الحجوزات بعد 5 ثواني", context, duration: Toast.LENGTH_LONG);
    setState(() {
      showReturnHint = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  ShuttleDetailsScreen(
                    suttleId: widget.onlineBookingPayment?.booking_id?.toString()??"",
                  )));
    });
  }
}
