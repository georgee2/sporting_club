

class OtherMembers {
  final String? name;
  final String? message;

  OtherMembers({this.name, this.message,});
  factory OtherMembers.fromJson(Map<String, dynamic> json) {

    return OtherMembers(
      name: json['name'] == null ? null : json['name'],
      message: json['message'] == null ? null : json['message'],
    );
  }
}
