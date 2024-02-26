class AvailableRoomView {
  int? id;
  String? name;
  double? room_price;
  double? room_guest_price;

  AvailableRoomView({
    this.id,
    this.name,
    this.room_price,
    this.room_guest_price,
  });

  factory AvailableRoomView.fromJson(Map<String, dynamic> json) {
    return AvailableRoomView(
      id: json['id'] == null ? null : json['id'],
      name: json['name'] == null ? null : json['name'],
      room_price: json['room_price'] == null ? null : json['room_price'],
      room_guest_price: json['room_guest_price'] == null ? null : json['room_guest_price'],
    );
  }
}
