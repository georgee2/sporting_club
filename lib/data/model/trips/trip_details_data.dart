import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_image.dart';

class TripDetailsData {
  final Trip? trip;
  final String? cancellation_policy_url;
  final String? trip_web_url;
  final int? id;
  final TripImage? image;

  TripDetailsData({
    this.trip,
    this.cancellation_policy_url,
    this.trip_web_url,
    this.id,
    this.image,

  });

  factory TripDetailsData.fromJson(Map<String, dynamic> json) {
    return TripDetailsData(
      trip: json['trip'] == null ? null : Trip.fromJson(json['trip']),
      cancellation_policy_url: json['cancellation_policy_url'] == null
          ? null
          : json['cancellation_policy_url'],
      trip_web_url: json['trip_web_url'] == null ? null : json['trip_web_url'],
      id: json['id'] == null ? null : json['id'],
      image: json["image"] == null ? null : TripImage.fromJson(json['image']),


    );
  }
}
