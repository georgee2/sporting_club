import 'package:sporting_club/data/model/restaurant_image.dart';
import 'package:sporting_club/data/model/restaurant_manager.dart';

import 'gallery_data.dart';

class Restaurant {
  int? id;
  String? name;
  String? description;
  String? location;
  String? available_for_birthdays;
  String? suitable_for_kids;
  List<RestaurantImage>? menus;
  List<RestaurantManager>? managers;
  String? comment_id;
  final List<GalleryData>? post_gallery;

  Restaurant({
    this.id,
    this.name,
    this.description,
    this.location,
    this.available_for_birthdays,
    this.suitable_for_kids,
    this.managers,
    this.menus,
    this.comment_id,
    this.post_gallery

  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    List<RestaurantManager> managersList = [];
    if (json['mangers'] != null) {
      var list = json['mangers'] as List;
      if (list != null) {
        managersList = list.map((i) => RestaurantManager.fromJson(i)).toList();
      }
    }

    List<RestaurantImage> imagesList = [];
    if (json['menus'] != null) {
      var list = json['menus'] as List;
      if (list != null) {
        imagesList = list.map((i) => RestaurantImage.fromJson(i)).toList();
      }
    }
    List<GalleryData> postGallery = [];
    if (json['post_gallery'] != null) {
      var list = json['post_gallery'] as List;
      if (list != null) {
        postGallery = list.map((i) => GalleryData.fromJson(i)).toList();
      }
    }
    return Restaurant(
      id: json['id'] == null ? null : json['id'],
      name: json['name'] == null ? null : json['name'],
      description: json['description'] == null ? null : json['description'],
      location: json['location'] == null ? null : json['location'],
      comment_id: json['comment_id'] == null ? null : json['comment_id'],
      available_for_birthdays: json['available_for_birthdays'] == null
          ? null
          : json['available_for_birthdays'],
      suitable_for_kids:
          json['suitable_for_kids'] == null ? null : json['suitable_for_kids'],
      menus: json['menus'] == null ? null : imagesList,
      managers: json['mangers'] == null ? null : managersList,
      post_gallery: json['post_gallery'] == null ? null : postGallery,
    );
  }
}
