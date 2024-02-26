import 'advertisement.dart';

class AdvertisementData {
  final String? name;
  final List<Advertisement>? data;

  AdvertisementData({
    this.name,
    this.data,
  });

  factory AdvertisementData.fromJson(Map<String, dynamic> json) {
    List<Advertisement> adsList = [];
    if (json['data'] != null) {
      var list = json['data'] as List;
      if (list != null) {
        adsList = list.map((i) => Advertisement.fromJson(i)).toList();
      }
    }
    return AdvertisementData(
      name: json['name'] == null ? null : json['name'],
      data: json['data'] == null ? null : adsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "data": this.data,
    };
  }
}
