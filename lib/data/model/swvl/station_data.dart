import 'package:sporting_club/data/model/swvl/swvl_ride_location.dart';
import 'package:intl/intl.dart';

class StationsData {
  String? sId;
  SwvlRideLoc? loc;
  String? name;
  String? status;
  EstimatedRideAnalytics? estimatedAnalytics;


  StationsData({this.sId, this.loc, this.name, this.status});

  StationsData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    loc = json['loc'] != null ? new SwvlRideLoc.fromJson(json['loc']) : null;
    estimatedAnalytics = json['estimated_analytics'] != null ? new EstimatedRideAnalytics.fromJson(json['estimated_analytics']) : null;
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.loc != null) {
      data['loc'] = this.loc!.toJson();
    }
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }
}

class EstimatedRideAnalytics {
  String? arrival_time;
  String? departure_time;
  int? waiting_time;
  int? bookings_pick_up_count;
  int? bookings_drop_off_count;

  String? arrivalDay;
  String? arrivalTime;
  String? departureDay;
  String? departureTime;

  EstimatedRideAnalytics({this.arrival_time,this.departure_time, this.waiting_time, this.bookings_pick_up_count, this.bookings_drop_off_count});

  EstimatedRideAnalytics.fromJson(Map<String, dynamic> json) {
    arrival_time = json['arrival_time'];
    departure_time = json['departure_time'] ;

    DateTime parseStartDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parseUTC(arrival_time??"");
    DateTime parseEndDate = new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parseUTC(departure_time??"");
    arrivalDay = DateFormat('EEEE', "ar").format(parseStartDate.toLocal(),);
    arrivalTime = DateFormat('h:mm a',).format(parseStartDate.toLocal());

    departureDay = DateFormat('EEEE', "ar").format(parseEndDate.toLocal(),);
    departureTime = DateFormat('h:mm a',).format(parseEndDate.toLocal());


    waiting_time = json['waiting_time'];
    bookings_pick_up_count = json['bookings_pick_up_count'];
    bookings_drop_off_count = json['bookings_drop_off_count'];
  }

}

