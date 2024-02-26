import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';

import '../../../ui/sos/helper/extensions/user_fields_extension.dart';

class EmergencyCategory{
  String? name;
  String? slug;
  int? id;
  String? categoryIcon;

  EmergencyCategory(
      {
        this.name,
        this.id,
        this.slug,
        this.categoryIcon,
      });

  EmergencyCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    id = json['id'];
    slug = json['slug'];
    categoryIcon = json['image'];
    // categoryIcon=  EmergencyCategoryExtension.getCategoryType(slug??"").categoryIcon;
  }

}