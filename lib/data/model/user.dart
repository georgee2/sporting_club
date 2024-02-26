import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class User {
  String? display_name;
  final String? user_email;
   var id;
  final String? user_login;
  final String? first_name;
  final String? last_name;
  final String? user_name;
  final String? phone;
  final int? membership_no;
  final String? user_login_before;
  String? notification_sound;
  String? notification_status;
  String? national_id;
  var user_photo;
  final bool? isDoctor;
  final bool? isMember;
  User(
      {this.first_name,
      this.last_name,
      this.display_name,
      this.user_name,
      this.user_email,
      this.id,
      this.user_login,
      this.phone,
      this.membership_no,
      this.user_login_before,
      this.notification_sound,
      this.notification_status,
      this.national_id,
      this.user_photo,
      this.isDoctor,
        this.isMember
      });

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
      first_name: json['first_name'] == null ? null : json['first_name'],
      last_name: json['last_name'] == null ? null : json['last_name'],
      user_name: json['user_name'] == null ? null : json['user_name'],
      display_name: json['display_name'] == null ? null : json['display_name'],
      national_id: json['national_id'] == null ? "" : json['national_id'],
      user_email: json['user_email'] == null ? null : json['user_email'],
      id: json['ID'] == null ? null : json['ID'],
      user_login: json['user_login'] == null ? null : json['user_login'],
      phone: json['phone'] == null ? null : json['phone'],
      membership_no:
          json['membership_no'] == null ? null : json['membership_no'],
      user_login_before:
          json['user_login_before'] == null ? null : json['user_login_before'],
      notification_sound: json['notification_sound'] == null
          ? null
          : json['notification_sound'],
      notification_status: json['notification_status'] == null
          ? null
          : json['notification_status'],
      user_photo: json['user_photo'] == null
          ? null
          :json['user_photo'] ,
      isDoctor:  ( json['is_doctor'] is String) ?json['is_doctor'] == "1" :json['is_doctor'] ,
      isMember:  ( json['is_member'] is String) ?json['is_member'] == "1" :json['is_member'] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": this.first_name,
      "last_name": this.last_name,
      "user_name": this.user_name,
      "display_name": this.display_name,
      "user_email": this.user_email,
      "national_id": this.national_id,
      "ID": this.id,
      "phone": this.phone,
      "user_login": this.user_login,
      "membership_no": this.membership_no,
      "user_login_before": this.user_login_before,
      "notification_status": this.notification_status,
      "notification_sound": this.notification_sound,
      "user_photo": this.user_photo,
      "is_doctor": this.isDoctor,
      "is_member": this.isMember,
    };
  }

  User copyWith({

    bool? isDoctor,
    bool? isMember,
  }) {
    return User(
      first_name: first_name,
      last_name: last_name,
      user_name: user_name,
      display_name: display_name,
      national_id: national_id,
      user_email: user_email,
      id: id,
      user_login:user_login,
      phone: phone,
      membership_no:
      membership_no,
      user_login_before:
      user_login_before,
      notification_sound:notification_sound,
      notification_status:notification_status,
      user_photo: user_photo ,
      isDoctor: isDoctor ?? this.isDoctor,
      isMember: isMember??this.isMember,
    );
  }
}
