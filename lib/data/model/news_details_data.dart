import 'news.dart';

class NewsDetailsData {
  final News? news;

  NewsDetailsData({this.news});

  factory NewsDetailsData.fromJson(Map<String, dynamic> json) {
    return NewsDetailsData(
      news: json['post'] == null ? null : News.fromJson(json['post']),
    );
  }
}
