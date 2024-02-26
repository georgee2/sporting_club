import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trip_details_data.dart';

class TripsData {
  final List<Trip>? trips;
  final bool? has_interest;
  final List<TripDetailsData>? bookings;

  TripsData({this.trips, this.has_interest,this.bookings});

  factory TripsData.fromJson(Map<String, dynamic> json) {
    List<Trip> tripsList = [];
    if (json['trips'] != null) {
      var list = json['trips'] as List;
      if (list != null) {
        tripsList = list.map((i) => Trip.fromJson(i)).toList();
      }
    }

    List<TripDetailsData> bookingsList = [];
    if (json['bookings'] != null) {
      var list = json['bookings'] as List;
      if (list != null) {
        bookingsList = list.map((i) => TripDetailsData.fromJson(i)).toList();
      }
    }



    return TripsData(
      trips: json['trips'] == null ? null : tripsList,
      bookings: json['bookings'] == null ? null : bookingsList,
      has_interest: json['has_interest'] == null ? false : json['has_interest'],
    );
  }
}
