import 'package:sporting_club/data/model/trips/trip_room_type.dart';

class TripPrice {
  double? price;
  int? type;
  TripRoomType? room_type;
  TripRoomType? room_view;
  TripRoomType? seat_type;

  TripPrice({
    this.price,
    this.type,
    this.room_type,
    this.room_view,
    this.seat_type,
  });

  factory TripPrice.fromJson(Map<String, dynamic> json) {
    return TripPrice(
      price: json['price'] == null ? null : json['price'],
      type: json['type'] == null ? null : json['type'],
      room_type: json["room_type"] == null
          ? null
          : TripRoomType.fromJson(json['room_type']),
      room_view: json["room_view"] == null
          ? null
          : TripRoomType.fromJson(json['room_view']),
      seat_type: json["seat_type"] == null
          ? null
          : TripRoomType.fromJson(json['seat_type']),
    );
  }
}
