import 'complaint.dart';

class ComplaintDetailsData {
  final Complaint? complaint;

  ComplaintDetailsData({this.complaint});

  factory ComplaintDetailsData.fromJson(Map<String, dynamic> json) {
    return ComplaintDetailsData(
      complaint: json['complaint'] == null
          ? null
          : Complaint.fromJson(json['complaint']),
    );
  }
}
