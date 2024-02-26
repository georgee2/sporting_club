import 'package:flutter/material.dart';
import 'category.dart';

class GalleryData {
  final String? title;
  final List<String>? gallery;
  GalleryData(
      {
        this.title,
        this.gallery
      });

  factory GalleryData.fromJson(Map<String, dynamic> json) {
    List<String> galleryList = [];
    if (json['gallery'] != null) {
      var list = json['gallery'] as List;
      if (list != null) {
        galleryList = list.map((i) => i.toString()).toList();
      }
    }
    return GalleryData(
      title: json['gallery_title'] == null ? null : json['gallery_title'],
      gallery: json['gallery'] == null ? null : galleryList,
    );
  }
}
