import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/data/model/user_data.dart';

class UserUpdateData {
  final UserData? user;
  final bool? updated;
  UserUpdateData({
    this.user,
    this.updated,
  });

  factory UserUpdateData.fromJson(Map<String, dynamic> json) {
    return UserUpdateData(
      user: json["user"] == null ? null : UserData.fromJson(json['user']),
      updated: json["updated"] == null ? false : json["updated"],
    );
  }
}
