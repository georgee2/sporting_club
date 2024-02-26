
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/main.dart';

mixin BaseViewModel on ChangeNotifier {
  bool isLoading = false;
  bool noConnection = false;
  bool noData=false;

  void startLoading() {
    isLoading = true;
     noConnection = false;
    noData = false;
    notifyListeners();
  }

  void stopLoading({bool isConnected = true, bool noDataVal = false}) {
    isLoading = false;
    noConnection = !isConnected;
    noData =noDataVal ;
    notifyListeners();
  }

  void showToastMessage(String message) {
    var context = global.navigatorKey.currentContext;
    if (context != null) {
     Fluttertoast.showToast(msg:message, toastLength: Toast.LENGTH_LONG);
      // Fluttertoast.showToast(msg:msg: "This is Center Short Toast",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
    }
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  NavigatorState? get navigator => global.navigatorKey.currentState;
}
