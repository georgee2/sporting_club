import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';

class ShuttleListResponse {
  String? bookingTotal;
   List<Shuttle>? shuttles;

  ShuttleListResponse({ this.bookingTotal, this.shuttles});

  ShuttleListResponse.fromJson(Map<String, dynamic> json) {

    bookingTotal=json["booking_total"].toString();

    if (json['data'] != null) {
      var list = json['data'] as List;
      if (list != null) {
        shuttles = list.map((i) => Shuttle.fromJson(i)).toList();
      }
    }
  }

}
