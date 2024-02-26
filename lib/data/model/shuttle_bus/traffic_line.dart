import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';

class TrafficLine {
  String? lineImage;
  String? name;
  int? id;

  TrafficLine({
    this.lineImage,
    this.name,
    this.id,
  });

  TrafficLine.fromJson(Map<String, dynamic> json) {
    lineImage = json['image'];
    name = json['title'];
    id = json['id'];
  }
}
