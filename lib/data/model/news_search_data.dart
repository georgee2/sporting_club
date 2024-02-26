import 'offer.dart';

class NewsSearchData {
  final List<Offer>? news;

  NewsSearchData({this.news});

  factory NewsSearchData.fromJson(Map<String, dynamic> json) {
    List<Offer> newsList = [];
    if (json['news'] != null) {
      var list = json['news'] as List;
      if (list != null) {
        newsList = list.map((i) => Offer.fromJson(i)).toList();
      }
    }

    return NewsSearchData(
      news: json['news'] == null ? null : newsList,
    );
  }
}
