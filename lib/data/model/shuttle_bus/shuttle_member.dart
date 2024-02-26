


class ShuttleMembersData {
  final List<ShuttleMember>? followMembers;

  ShuttleMembersData({this.followMembers});
  factory ShuttleMembersData.fromJson(Map<String, dynamic> json) {
    List<ShuttleMember> followMembers = [];
    if(json['data'] != null){
      var list = json['data']  as List;
      if (list != null){
        followMembers = list.map((i) => ShuttleMember.fromJson(i)).toList();
      }
    }
    return ShuttleMembersData(
      followMembers: json['data'] == null ? null : followMembers,
    );
  }
}
class ShuttleMember {
  String? name;
  String? memberId;
  bool? login;

  ShuttleMember({this.name, this.memberId, this.login});

  ShuttleMember.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    memberId = json['member_id'];
    login = json['login']==null?false: json['login']=="true"?true:false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['member_id'] = this.memberId;
    data['login'] = this.login;
    return data;
  }
}
