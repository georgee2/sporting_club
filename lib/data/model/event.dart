import 'gallery_data.dart';

class Event {
  final String? id;
  final String? title;
  final String? date;
  final String? date_month;
  final String? date_day;
  final String? image;
  final String? description;
  final String? category;
  String? comment_before;
  final String? interest_status;
  String? url;
  final String? date_total;
  final List<GalleryData>? post_gallery;


  Event({
    this.id,
    this.title,
    this.date,
    this.date_day,
    this.date_month,
    this.image,
    this.description,
    this.category,
    this.interest_status,
    this.comment_before,
    this.url,
    this.date_total,
    this.post_gallery

  });

  factory Event.fromJson(Map<String, dynamic> json) {
    List<GalleryData> postGallery = [];
    if (json['post_gallery'] != null) {
      var list = json['post_gallery'] as List;
      if (list != null) {
        postGallery = list.map((i) => GalleryData.fromJson(i)).toList();
      }
    }
    return Event(
      id: json['id'] == null ? null : json['id'],
      title: json['title'] == null ? null : json['title'],
      date: json['date'] == null ? null : json['date'],
      date_day: json["date_day"] == null ? null : json['date_day'],
      date_month: json["date_month"] == null ? null : json['date_month'],
      date_total: json["date_total"] == null ? null : json['date_total'],

      image: json["image"] == null ? null : json['image'],
      description: json["description"] == null ? null : json['description'],
      category: json["category"] == null ? null : json['category'],
      interest_status:
          json["interest_status"] == null ? null : json['interest_status'],
      comment_before:
          json["comment_before"] == null ? null : json['comment_before'],
      url: json["url"] == null ? null : json['url'],
      post_gallery: json['post_gallery'] == null ? null : postGallery,
    );
  }
}
