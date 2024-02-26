class Box {
  final String? boxNum;
  final String? boxPrice;

  Box({
    this.boxNum,
    this.boxPrice,
  });

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      boxNum: json['box_num'] == null ? null : json['box_num'],
      boxPrice: json['box_price'] == null ? null : json['box_price'].toString(),
    );
  }
}
