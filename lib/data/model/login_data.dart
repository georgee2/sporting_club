import 'package:sporting_club/data/model/user.dart';

class LoginData {
  final String? token;
  final String? refresh_token;
  final User? user;
  List<String>? interests;

  LoginData({this.token, this.refresh_token, this.user, this.interests});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    List<String> interestsList = [];
    if (json['interest'] != null) {
      interestsList = new List<String>.from(json['interest']);
    }
    return LoginData(
      token: json['token'] == null ? null : json['token'],
      refresh_token:
          json['refresh_token'] == null ? null : json['refresh_token'],
      user: json["user"] == null ? null : User.fromJson(json['user']),
      interests: json['interest'] == null ? null : interestsList,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "token": this.token,
      "refresh_token": this.refresh_token,
      "user": this.user?.toJson(),
      "interests": this.interests,
    };
  }


}
