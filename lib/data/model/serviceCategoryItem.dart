import 'package:flutter/material.dart';
import 'category.dart';

class ServiceCategoryItem {
  final String? id;
  final String? title;


  ServiceCategoryItem({
    this.id,
    this.title,
  });

  factory ServiceCategoryItem.fromJson(Map<String, dynamic> json) {


    return ServiceCategoryItem(
      id: json['id'] == null ? null : json['id'],
      title: json['title'] == null ? null : json['title'],
    );
  }
}
