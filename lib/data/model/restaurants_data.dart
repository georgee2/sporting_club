import 'package:sporting_club/data/model/restaurant.dart';

import 'category.dart';

class RestaurantsData {
  final List<Category>? restaurants;
  Restaurant? singleRestaurant;

  RestaurantsData({this.restaurants, this.singleRestaurant});

  factory RestaurantsData.fromJson(Map<String, dynamic> json) {
    List<Category> restaurantsList = [];
    if (json['restaurants'] != null) {
      var list = json['restaurants'] as List;
      if (list != null) {
        restaurantsList = list.map((i) => Category.fromJson(i)).toList();
      }
    }

    return RestaurantsData(
      restaurants: json['restaurants'] == null ? null : restaurantsList,
      singleRestaurant: json["single_restaurant"] == null ? null : Restaurant.fromJson(json['single_restaurant']),

    );
  }
}
