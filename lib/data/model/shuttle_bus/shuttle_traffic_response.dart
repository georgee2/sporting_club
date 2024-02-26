import 'package:sporting_club/data/model/shuttle_bus/traffic_line.dart';

class ShuttleTrafficResponse {
  int? total;
  List<TrafficLine>? trafficLines;

  ShuttleTrafficResponse({this.total, this.trafficLines});

  ShuttleTrafficResponse.fromJson(Map<String, dynamic> json) {
    total = json["traffic_total"];
    trafficLines =
        (json['data'] as List?)?.map((i) => TrafficLine.fromJson(i)).toList();
  }
}
