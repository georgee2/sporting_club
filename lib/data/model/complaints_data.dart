import 'complaint.dart';

class ComplaintsData {
  final List<Complaint>? complaints;

  ComplaintsData({this.complaints});

  factory ComplaintsData.fromJson(Map<String, dynamic> json) {
    List<Complaint> complaintsList = [];
    if (json['posts'] != null) {
      var list = json['posts'] as List;
      if (list != null) {
        complaintsList = list.map((i) => Complaint.fromJson(i)).toList();
      }
    }

    return ComplaintsData(
      complaints: json['posts'] == null ? null : complaintsList,
    );
  }
}
