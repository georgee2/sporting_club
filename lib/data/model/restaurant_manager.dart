class RestaurantManager {
  String? phone;
  String? name;

  RestaurantManager({this.phone, this.name});

  factory RestaurantManager.fromJson(Map<String, dynamic> json) {
    return RestaurantManager(
      phone: json['phone'] == null ? null : json['phone'],
      name: json['name'] == null ? null : json['name'],
    );
  }
}
