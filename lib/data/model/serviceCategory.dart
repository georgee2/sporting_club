import 'package:sporting_club/data/model/restaurant.dart';
import 'package:sporting_club/data/model/serviceCategoryItem.dart';

import 'category.dart';
import 'offer.dart';

class ServiceCategory {

  final  List<ServiceCategoryItem>? electronic_services;
  final  List<ServiceCategoryItem>? public_services;

  ServiceCategory({this.electronic_services, this.public_services});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    List<ServiceCategoryItem> electronic_services = [];
    if(json['electronic_services'] != null){
      var list = json['electronic_services']  as List;
      if (list != null){
        electronic_services = list.map((i) => ServiceCategoryItem.fromJson(i)).toList();
      }
    }
    List<ServiceCategoryItem> public_services = [];
    if(json['public_services'] != null){
      var list = json['public_services']  as List;
      if (list != null){
        public_services = list.map((i) => ServiceCategoryItem.fromJson(i)).toList();
      }
    }
    return ServiceCategory(
      electronic_services: json['electronic_services'] == null? null: electronic_services,
      public_services: json['public_services'] == null? null: public_services,
    );
  }
}