import '../gallery_data.dart';

class ShuttlePackage {
  String? name;
  String? price;
  String? message;

  ShuttlePackage({this.name, this.price, this.message});

  ShuttlePackage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['message'] = this.message;
    return data;
  }
}
