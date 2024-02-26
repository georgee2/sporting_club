import 'package:sporting_club/data/model/swvl/station_data.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';


class SwvlRideResult {
  List<Rides>? rides;
  int? count;

  SwvlRideResult({this.rides, this.count});

  SwvlRideResult.fromJson(Map<String, dynamic> json) {
    if (json['rides'] != null) {
      rides = <Rides>[];
      json['rides'].forEach((v) {
        rides!.add(new Rides.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rides != null) {
      data['rides'] = this.rides!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}




