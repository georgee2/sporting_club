import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';

class ShuttleBookingData {
  List<String>? memberList=[];
  String? startDate;
  String? endDate;
  String? message;

  ShuttleBookingData({ this.memberList, this.message,this.startDate, this.endDate , });

  ShuttleBookingData.fromJson(Map<String, dynamic> json) {
    startDate=json["start_date"];
    endDate=json["end_date"];
    message=json["message"];

    if (json['members'] != null) {
      memberList = <String>[];
      json['members'].forEach((value) {
        memberList?.add(value.toString());
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['message'] = this.message;

    if (this.memberList != null) {
      data['members'] = this.memberList;
    }
    return data;
  }
}
