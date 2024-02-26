import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';

import 'emergency_category.dart';

class EmergencyCategoryData {
  List<EmergencyCategory>? emergencyCategoryList;

  EmergencyCategoryData({  this.emergencyCategoryList});

  EmergencyCategoryData.fromJson(Map<String, dynamic> json) {

    if (json['categories'] != null) {
      emergencyCategoryList = <EmergencyCategory>[];
      json['categories'].forEach((v) {
        emergencyCategoryList?.add(new EmergencyCategory.fromJson(v));
      });
    }
  }

}
