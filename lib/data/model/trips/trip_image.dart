class TripImage {
  String? original;
  String? small;
  String? medium;

  TripImage({
    this.small,
    this.medium,
    this.original,
  });

  factory TripImage.fromJson(Map<String, dynamic> json) {
    return TripImage(
      small: json['small'] == null ? null : json['small'],
      medium: json['medium'] == null ? null : json['medium'],
      original: json['original'] == null ? null : json['original'],
    );
  }
}
