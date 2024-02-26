


class FollowMembersData {
  final List<FollowMembers>? followMembers;

  FollowMembersData({this.followMembers});
  factory FollowMembersData.fromJson(Map<String, dynamic> json) {
    List<FollowMembers> followMembers = [];
    if(json['data'] != null){
      var list = json['data']  as List;
      if (list != null){
        followMembers = list.map((i) => FollowMembers.fromJson(i)).toList();
      }
    }
    return FollowMembersData(
      followMembers: json['data'] == null ? null : followMembers,
    );
  }
}
class FollowMembers {
  final String? clubId;
  final String? name;
  final String? birthdate;
  final bool? current_user_login;
  final bool? accept_age;
  final bool? user_active;
  final bool? book_before;

  FollowMembers({this.clubId ,this.name, this.birthdate, this.current_user_login, this.accept_age, this.user_active,this.book_before});
  factory FollowMembers.fromJson(Map<String, dynamic> json) {

    return FollowMembers(
      clubId: json['clubId'] == null ? null : json['clubId'],
      name: json['name'] == null ? null : json['name'],
      birthdate: json['birthdate'] == null ? null : json['birthdate'],
      current_user_login: json['current_user_login'] == null ? false : json['current_user_login'],
      accept_age: json['accept_age'] == null ? false : json['accept_age'],
      user_active: json['user_active'] == null ? false : json['user_active'],
      book_before: json['book_before'] == null ? false : json['book_before'],
    );
  }
}
