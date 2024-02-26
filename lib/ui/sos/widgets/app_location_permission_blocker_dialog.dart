import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sporting_club/main.dart';

class AppLocationPermissionBlockerDialog {
  static bool isShown = false;

  static show(BuildContext mcontext) {
    if (!isShown) {
      isShown = true;
      return showDialog(
          context: mcontext,
          builder: (BuildContext context) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20),
              content: Container(
                padding: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "تحذير",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "يجب عليك السماح بالوصول إلى الموقع للمتابعة",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                        onTap: ()async {
                       bool result=  await openAppSettings();
                         Navigator.pop(context);
                        },
                        child: Text(
                          "السماح الآن",
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        )),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
            );
          }).then((value) {
        isShown = false;
        // global.navigatorKey.currentState?.pop();
      });
    }
  }

  static hide() {
    if (isShown) {
      BuildContext? context = global.navigatorKey.currentContext;
      if (context != null) {
        Navigator.pop(context);
        isShown = false;
      }
    }
  }
}
