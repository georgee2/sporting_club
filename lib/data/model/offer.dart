import 'package:flutter/material.dart';
import 'category.dart';
import 'gallery_data.dart';

class Offer {
  final int? id;
  final String? title;
  final String? image;
  final String? date;
  final String? content;
  final List<Category>? categories;
  bool? interest;
  String? url;
  bool? display_interest;
  String? service_url;
  final List<GalleryData>? post_gallery;

  Offer({
    this.id,
    this.title,
    this.image,
    this.date,
    this.categories,
    this.content,
    this.interest,
    this.display_interest,
    this.url,
    this.service_url,
    this.post_gallery

  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    List<Category> categoriesList = [];
    if (json['categories'] != null) {
      var list = json['categories'] as List;
      if (list != null) {
        categoriesList = list.map((i) => Category.fromJson(i)).toList();
      }
    }
    List<GalleryData> postGallery = [];
    if (json['post_gallery'] != null) {
      var list = json['post_gallery'] as List;
      print(list);
      if (list != null) {
        postGallery = list.map((i) => GalleryData.fromJson(i)).toList();
      }
    }
    return Offer(
      id: json['id'] == null ? null : json['id'],
      title: json['title'] == null ? null : json['title'],
      date: json['date'] == null ? null : json['date'],
      image: json["image"] == null ? null : json['image'],
      content: json["content"] == null ? null : json['content'],
      categories: json['categories'] == null ? null : categoriesList,
      interest: json["interest"] == null ? false : json['interest'],
      display_interest: json["display_interest"] == null ? false : json['display_interest'],

      url: json["url"] == null ? null : json['url'],
      service_url: json["service_url"] == null ? null : json['service_url'],
      post_gallery: json['post_gallery'] == null ? null : postGallery,

    );
  }
}
