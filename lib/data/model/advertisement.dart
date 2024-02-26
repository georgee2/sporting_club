import 'advertisement_image.dart';

class Advertisement {
  final String? image_duration;
  final String? date_from;
  final String? date_to;
  final List<AdvertisementImage>? images;

  Advertisement({
    this.image_duration,
    this.date_from,
    this.date_to,
    this.images,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    List<AdvertisementImage> imagesList = [];
    if (json['images'] != null) {
      var list = json['images'] as List;
      if (list != null) {
        imagesList = list.map((i) => AdvertisementImage.fromJson(i)).toList();
      }
    }
    return Advertisement(
      image_duration:
          json['image_duration'] == null ? null : json['image_duration'],
      date_from: json['date_from'] == null ? null : json['date_from'],
      date_to: json['date_to'] == null ? null : json['date_to'],
      images: json['images'] == null ? null : imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "image_duration": this.image_duration,
      "date_from": this.date_from,
      "date_to": this.date_to,
      "images": this.images,
    };
  }
}
