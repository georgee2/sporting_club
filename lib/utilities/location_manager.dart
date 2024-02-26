import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permissionHandler;
import 'package:sporting_club/main.dart';

import '../ui/sos/widgets/app_location_permission_blocker_dialog.dart';

class LocationManager {
  static Location location = Location();

  static Future<LocationData?> getCurrentLocation() async {
    final hasPermission = await handlePermission();
    if (!hasPermission) {
      return null;
    }

    try {
      final position = await location.getLocation();
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> handlePermission() async {
    bool serviceEnabled;
    PermissionStatus permission;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      if(Platform.isIOS){
        permission = await location.requestPermission();
        if (permission!= PermissionStatus.granted) {
          BuildContext? context = global.navigatorKey.currentContext;
          if(context != null){
            AppLocationPermissionBlockerDialog.show(context);
          }
        }else{
          return true;
        }
        }else{
         permission = await location.requestPermission();
      }
      return false;
    }
    return true;
  }

}
