import 'offer.dart';

class OffersData {
  final List<Offer>? offers;

  OffersData({this.offers});

  factory OffersData.fromJson(Map<String, dynamic> json) {
    List<Offer> offersList = [];
    if (json['promotions'] != null) {
      var list = json['promotions'] as List;
      if (list != null) {
        offersList = list.map((i) => Offer.fromJson(i)).toList();
      }
    }

    return OffersData(
      offers: json['promotions'] == null ? null : offersList,
    );
  }
}
