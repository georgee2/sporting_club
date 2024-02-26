class RestaurantImage {
  String? large;
  String? small;

  RestaurantImage({this.large, this.small});

  factory RestaurantImage.fromJson(Map<String, dynamic> json) {
    return RestaurantImage(
      large: json['large'] == null ? null : json['large'],
      small: json['small'] == null ? null : json['small'],
    );
  }
}
