class Locker {
  final String? lockerLocation;
  final String? lockerNum;
  final String? lockerPrice;
  Locker({
    this.lockerLocation,
    this.lockerNum,
    this.lockerPrice,
  });

  factory Locker.fromJson(Map<String, dynamic> json) {
    return Locker(
      lockerLocation:
          json['locker_location'] == null ? null : json['locker_location'],
      lockerNum: json['locker_num'] == null ? null : json['locker_num'],
      lockerPrice:
          json['locker_price'] == null ? null : json['locker_price'].toString(),
    );
  }
}
