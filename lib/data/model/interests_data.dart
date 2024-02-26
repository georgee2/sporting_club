import 'package:sporting_club/data/model/trips/trips_interests.dart';
import 'package:sporting_club/data/model/user.dart';
import 'interest.dart';

class InterestsData {
  final List<Interest>? teams;
  final List<Interest>? events;
  final List<Interest>? news;
  final List<TripsInterest>? trips;

  InterestsData({this.teams, this.events, this.news, this.trips});

  factory InterestsData.fromJson(Map<String, dynamic> json) {
    List<Interest> teamsList = [];
    if (json['teams'] != null) {
      var list = json['teams'] as List;
      if (list != null) {
        teamsList = list.map((i) => Interest.fromJson(i)).toList();
      }
    }

    List<Interest> eventsList = [];
    if (json['events'] != null) {
      var list = json['events'] as List;
      if (list != null) {
        eventsList = list.map((i) => Interest.fromJson(i)).toList();
      }
    }

    List<Interest> newsList = [];
    if (json['news'] != null) {
      var list = json['news'] as List;
      if (list != null) {
        newsList = list.map((i) => Interest.fromJson(i)).toList();
      }
    }

    List<TripsInterest> tripsList = [];
    if (json['trips'] != null) {
      var list = json['trips'] as List;
      if (list != null) {
        tripsList = list.map((i) => TripsInterest.fromJson(i)).toList();
      }
    }
    return InterestsData(
      teams: json['teams'] == null ? null : teamsList,
      events: json['events'] == null ? null : eventsList,
      news: json["news"] == null ? null : newsList,
      trips: json["trips"] == null ? null : tripsList,
    );
  }
}
