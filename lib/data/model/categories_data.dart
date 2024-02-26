import 'package:sporting_club/data/model/restaurant.dart';

import 'category.dart';

class CategoriesData {

  final List<Category>? categories;

  CategoriesData({this.categories});

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    List<Category> categoriesList = [];
    if(json['categories'] != null){
      var list = json['categories']  as List;
      if (list != null){
        categoriesList = list.map((i) => Category.fromJson(i)).toList();
      }
    }

    return CategoriesData(
      categories: json['categories'] == null? null: categoriesList,
    );
  }
}