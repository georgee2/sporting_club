import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';

class ShuttleList {
  final List<Shuttle>? shuttles;

  ShuttleList({this.shuttles, });

  factory ShuttleList.fromJson(Map<String, dynamic> json) {
    List<Shuttle> shuttles = [];
    if (json['data'] != null) {
      var list = json['data'] as List;
      if (list != null) {
        shuttles = list.map((i) => Shuttle.fromJson(i)).toList();
      }
    }

    return ShuttleList(
      shuttles: json['data'] == null ? null : shuttles,
    );
  }
}
class Shuttle{
  String? date;
  String? name;
  String? bookingId;
  int? id;


  Shuttle(
      {this.date,
        this.name,
        this.id,
        this.bookingId,
      });

  Shuttle.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    name = json['name'];
    id = json['id'];
    bookingId = json['booking_id'];
  }

}