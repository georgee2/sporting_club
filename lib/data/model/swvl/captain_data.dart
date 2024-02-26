import 'package:sporting_club/data/model/swvl/ride_rating_data.dart';

class Captain {
  String? sId;
  String? name;
  String? phone;
  RatingData? ratingData;
  String? picture;
  String? phoneRegionCode;

  Captain(
      {this.sId,
        this.name,
        this.phone,
        this.ratingData,
        this.picture,
        this.phoneRegionCode});

  Captain.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    phone = json['phone'];
    ratingData = json['rating_data'] != null
        ? new RatingData.fromJson(json['rating_data'])
        : null;
    picture = json['picture'];
    phoneRegionCode = json['phone_region_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['phone'] = this.phone;
    if (this.ratingData != null) {
      data['rating_data'] = this.ratingData!.toJson();
    }
    data['picture'] = this.picture;
    data['phone_region_code'] = this.phoneRegionCode;
    return data;
  }
}


