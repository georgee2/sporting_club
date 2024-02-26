import 'news.dart';

class NewsData {
  final List<News>? news;

  NewsData({this.news});

  factory NewsData.fromJson(Map<String, dynamic> json) {
    List<News> newsList = [];
    if (json['news'] != null) {
      var list = json['news'] as List;
      if (list != null) {
        newsList = list.map((i) => News.fromJson(i)).toList();
      }
    }

    return NewsData(
      news: json['news'] == null ? null : newsList,
    );
  }
}
