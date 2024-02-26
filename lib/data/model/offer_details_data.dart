import 'offer.dart';

class OfferDetailsData {
  final Offer? offer;

  OfferDetailsData({this.offer});

  factory OfferDetailsData.fromJson(Map<String, dynamic> json) {
    return OfferDetailsData(
      offer: json['promotion'] == null ? null : Offer.fromJson(json['promotion']),
    );
  }
}
