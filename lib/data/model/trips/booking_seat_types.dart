class BookingSeatTypes {
  int? seatType;
String? name;
  BookingSeatTypes({this.seatType, this.name});

  factory BookingSeatTypes.fromJson(Map<String, dynamic> json) {
    return BookingSeatTypes(
      seatType: json['seatType'] == null ? null : json['seatType'],
      name: json['name'] == null ? null : json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "seatType": this.seatType,
      "name": this.name,
    };
  }
}
