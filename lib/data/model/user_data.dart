import 'package:sporting_club/data/model/Box.dart';
import 'package:sporting_club/data/model/trips/Locker.dart';

class UserData {
  final String? name;
  final String? email;
  final int? id;
  final String? phone;
  final String? member_id;
  final String? national_id;
  String? birthdate;
  List<Locker>? lockers;
  List<Box>? boxes;
  double? totalBoxesLockers;
  UserData({
    this.name,
    this.email,
    this.id,
    this.phone,
    this.member_id,
    this.national_id,
    this.birthdate,
    this.lockers,
    this.boxes,
    this.totalBoxesLockers,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    List<Locker> lockers = [];
    if (json['lockers'] != null) {
      var list = json['lockers'] as List;
      if (list != null) {
        lockers = list.map((i) => Locker.fromJson(i)).toList();
      }
    }
    List<Box> boxes = [];
    if (json['boxes'] != null) {
      var list = json['boxes'] as List;
      if (list != null) {
        boxes = list.map((i) => Box.fromJson(i)).toList();
      }
    }
    return UserData(
      name: json['name'] == null ? null : json['name'],
      email: json['email'] == null ? null : json['email'],
      id: json['ID'] == null ? null : json['ID'],
      phone: json['phone'] == null ? null : json['phone'],
      member_id: json['member_id'] == null ? null : json['member_id'],
      national_id: json['national_id'] == null ? null : json['national_id'],
      birthdate: json['birthdate'] == null ? null : json['birthdate'],
      lockers: json["lockers"] == null ? null : lockers,
      boxes: json["boxes"] == null ? null : boxes,
      totalBoxesLockers: json["total_boxes_lockers"] == null
          ? null
          : json['total_boxes_lockers'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "email": this.email,
      "ID": this.id,
      "phone": this.phone,
      "member_id": this.member_id,
      "national_id": this.national_id,
      "birthdate": this.birthdate,
      "lockers": this.lockers,
      "boxes": this.boxes,
      "total_boxes_lockers": this.totalBoxesLockers,
    };
  }
}
