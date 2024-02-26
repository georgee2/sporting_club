import 'package:sporting_club/data/model/restaurant.dart';
import 'package:sporting_club/data/model/serviceCategory.dart';

import 'category.dart';

class ServiceCategoriesData {

  final ServiceCategory? categories;

  ServiceCategoriesData({this.categories});

  factory ServiceCategoriesData.fromJson(Map<String, dynamic> json) {
    ServiceCategory? categoriesList ;
    if(json['categories'] != null){
        categoriesList = ServiceCategory.fromJson(json['categories']);
    }

    return ServiceCategoriesData(
      categories: json['categories'] == null? null: categoriesList,
    );
  }
}