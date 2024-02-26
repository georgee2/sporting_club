import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';

class ShuttleData {
  Map<String, ShuttlePackage>? packageMap;
  List<ShuttleMember>? memberList;

  ShuttleData({ this.packageMap, this.memberList});

  ShuttleData.fromJson(Map<String, dynamic> json) {
    if (json['subs'] != null) {
      packageMap = {};
      json['subs'].forEach((key, value) {
        packageMap?[key]=ShuttlePackage.fromJson(value);
      });
    }
    if (json['members'] != null) {
      memberList = <ShuttleMember>[];
      json['members'].forEach((v) {
        memberList?.add(new ShuttleMember.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.packageMap != null) {
      // data['1'] = this.packageMap.toJson();
    }
    if (this.memberList != null) {
      data['members'] = this.memberList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
