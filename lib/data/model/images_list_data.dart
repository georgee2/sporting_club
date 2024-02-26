import 'dart:convert';

import 'advertisement_data.dart';



class ImagesListData {

  List<String>? images;

  ImagesListData({ this.images});

  factory ImagesListData.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      images = new List<String>.from(json['images']);
    }
    return ImagesListData(

      images: json['images'] == null ? null : images,
    );


  }
}

