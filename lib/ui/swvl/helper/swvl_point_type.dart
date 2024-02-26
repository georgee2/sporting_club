import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sporting_club/utilities/app_colors.dart';

enum SwvlPointType {
  started,
  coming,
  skipped,
  past,
  ended,
  bus,

}

extension SwvlPointTypeData on SwvlPointType {
  String get title {
    switch (this) {
      case SwvlPointType.started:
        return 'started';
      case SwvlPointType.coming:
        return 'coming';
      case SwvlPointType.skipped:
        return 'skipped';
      case SwvlPointType.past:
        return 'past';
      case SwvlPointType.ended:
        return 'ended';
      default:
        return 'started';
    }
  }

  String get icon {
    switch (this) {
      case SwvlPointType.started:
        return "assets/stopping_point_green.png";
      case SwvlPointType.coming:
        return "assets/Stopping_point_icon.png";
      case SwvlPointType.skipped:
        return "assets/red-point_ac.png";
      case SwvlPointType.past:
        return "assets/red-point_ac.png";
      case SwvlPointType.bus:
        return "assets/arrived_bus_point.png";
      case SwvlPointType.ended:
        return 'assets/stopping_point_red.png';
        default:
        return "assets/red-point_ac.png";
    }
  }
  Color get pointColor {
    switch (this) {
      case SwvlPointType.started:
        return AppColors.stationCircleColor;
      case SwvlPointType.coming:
        return  AppColors.green;
      case SwvlPointType.skipped:
        return  AppColors.skippedStationCircleColor;

      default:
        return  AppColors.green;
    }
  }

}
