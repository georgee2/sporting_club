class Complaint {
  int? id;
  String? date;
  String? content;
  String? complaint_status;
  String? administrative_name;
  String? image_url;
  String? complaint_comment;

  Complaint(
      {this.id,
      this.date,
      this.content,
      this.complaint_status,
      this.administrative_name,
      this.image_url, this.complaint_comment});

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['complaint_id'] == null ? null : json['complaint_id'],
      date: json['date'] == null ? null : json['date'],
      content: json['content'] == null ? null : json['content'],
      administrative_name: json['administrative_name'] == null
          ? null
          : json['administrative_name'],
      complaint_status:
          json['complaint_status'] == null ? null : json['complaint_status'],
      image_url: json['image_url'] == null ? null : json['image_url'],
      complaint_comment: json['complaint_comment'] == "" ? "" : json['complaint_comment'],
    );
  }
}
