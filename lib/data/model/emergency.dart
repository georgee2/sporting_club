class Emergency {
  String? clinic;
  String? security;
  String? golfCar;

  Emergency({
    this.clinic,
    this.security,
    this.golfCar,
  });

  factory Emergency.fromJson(Map<String, dynamic> json) {
    return Emergency(
      clinic: json['clinic'] == null ? null : json['clinic'],
      security: json['security'] == null ? null : json['security'],
      golfCar: json['golf_car'] == null ? null : json['golf_car'],
    );
  }
}
