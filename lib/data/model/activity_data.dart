import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/trips/trip.dart';

class ActivityData {
  final List<Offer>? promotions;
  final List<Offer>? services;

  ActivityData({this.promotions, this.services});

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    List<Offer> promotionsList = [];
    if (json['promotions'] != null) {
      var list = json['promotions'] as List;
      if (list != null) {
        promotionsList = list.map((i) => Offer.fromJson(i)).toList();
      }
    }

    List<Offer> servicesList = [];
    if (json['services'] != null) {
      var list = json['services'] as List;
      if (list != null) {
        servicesList = list.map((i) => Offer.fromJson(i)).toList();
      }
    }

    return ActivityData(
      services: json['services'] == null ? null : servicesList,
      promotions: json['promotions'] == null ? null : promotionsList,

    );
  }
}
