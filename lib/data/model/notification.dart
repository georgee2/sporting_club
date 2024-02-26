class NotificationModel {
  String? id;
  String? message;
  String? date;
  String? status;
  String? icon;
  String? post_id;
  String? image;
  String? link_data;
  String? message_title;
  String? sosName;
  String? category;
  String? location;
  String? phone;
  var sosId;
  var sosAccept;
  var sosUnique;
  NotificationModel({
    this.message,
    this.date,
    this.status,
    this.icon,
    this.id,
    this.post_id,
    this.link_data,
    this.image,
    this.message_title,
    this.sosName,
    this.category,
    this.location,
    this.phone,
    this.sosId ,
    this.sosAccept,
    this.sosUnique,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'] == null ? null : json['message'],
      date: json['date'] == null ? null : json['date'],
      status: json['status'] == null ? null : json['status'],
      icon: json["icon"] == null ? null : json['icon'],
      image: json["icon"] == null ? null : json['image'],
      link_data: json["icon"] == null ? null : json['link_data'],
      message_title:json["icon"] == null ? null : json['message_title'],
      id: json["id"] == null ? null : json['id'],
      post_id: json["post_id"] == null ? null : json['post_id'],
      sosName: json["sos_name"] == null ? null : json['sos_name'],
      category: json["category"] == null ? null : json['category'],
      location: json["location"] == null ? null : json['location'],
      phone: json["phone"] == null ? null : json['phone'],
      sosId: json["sos_id"] == null ? null : json['sos_id'],
      sosAccept: json["sos_accept"] == null ? null : json['sos_accept'],
      sosUnique: json["sos_unique"] == null ? null : json['sos_unique'],
    );
  }
}
