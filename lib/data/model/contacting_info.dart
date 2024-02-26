class ContactingInfo {
  String? lat;
  String? lang;
  String? phone;
  String? email;
  String? facebook;
  String? twitter;
  String? instagram;
  String? youtube;

  ContactingInfo({
    this.lang,
    this.lat,
    this.phone,
    this.email,
    this.facebook,
    this.twitter,
    this.instagram,
    this.youtube,
  });

  factory ContactingInfo.fromJson(Map<String, dynamic> json) {
    return ContactingInfo(
      lat: json['lat'] == null ? null : json['lat'],
      lang: json['lang'] == null ? null : json['lang'],
      phone: json['phone'] == null ? null : json['phone'],
      email: json['email'] == null ? null : json['email'],
      facebook: json['facebook'] == null ? null : json['facebook'],
      twitter: json['twitter'] == null ? null : json['twitter'],
      instagram: json['instagram'] == null ? null : json['instagram'],
      youtube: json['youtube'] == null ? null : json['youtube'],
    );
  }
}
