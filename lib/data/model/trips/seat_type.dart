class SeatType {
  int? id;
  String? name;
  double? type_price;
  String? childName;

  SeatType({
    this.id,
    this.name,
    this.type_price,
    this.childName
  });

  factory SeatType.fromJson(Map<String, dynamic> json) {
    return SeatType(
      id: json['id'] == null ? null : json['id'],
      name: json['name'] == null ? null : json['name'],
      type_price: json['type_price'] == null ? null : json['type_price'],
      childName: json['child_name'] == null ? null : json['child_name'],
    );
  }
}
