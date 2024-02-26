import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/gallery_data.dart';
import 'category.dart';

class News {
  final int? id;
  final String? title;
  final String? image;
  final String? date;
  final String? post_title;
  final String? post_content;
  final List<Category>? categories;
  final List<Category>? tags;
  bool? check_commnet;
  String? comment_id;
  String? url;
  final List<GalleryData>? post_gallery;
  News(
      {this.id,
      this.title,
      this.image,
      this.date,
      this.categories,
      this.post_content,
      this.post_title,
      this.tags,
      this.check_commnet,
      this.comment_id,
      this.url,
        this.post_gallery
      });

  factory News.fromJson(Map<String, dynamic> json) {
    List<Category> categoriesList = [];
    if (json['categories'] != null) {
      var list = json['categories'] as List;
      if (list != null) {
        categoriesList = list.map((i) => Category.fromJson(i)).toList();
      }
    }

    List<Category> tagsList = [];
    if (json['tags'] != null) {
      var list = json['tags'] as List;
      if (list != null) {
        tagsList = list.map((i) => Category.fromJson(i)).toList();
      }
    }

    List<GalleryData> postGallery = [];
    if (json['post_gallery'] != null) {
      var list = json['post_gallery'] as List;
      if (list != null) {
        postGallery = list.map((i) => GalleryData.fromJson(i)).toList();
      }
    }
    return News(
      id: json['id'] == null ? null : json['id'],
      title: json['title'] == null ? null : json['title'],
      date: json['date'] == null ? null : json['date'],
      image: json["image"] == null ? null : json['image'],
      post_content: json["post_content"] == null ? null : json['post_content'],
      post_title: json["post_title"] == null ? null : json['post_title'],
      categories: json['categories'] == null ? null : categoriesList,
      tags: json['tags'] == null ? null : tagsList,
      check_commnet:
          json["check_commnet"] == null ? false : json['check_commnet'],
      comment_id: json["comment_id"] == null ? null : json['comment_id'],
      url: json["url"] == null ? null : json['url'],
      post_gallery: json['post_gallery'] == null ? null : postGallery,
    );
  }
}
