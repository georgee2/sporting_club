import 'package:sporting_club/data/model/review.dart';

class ReviewData {
  final Review? review;

  ReviewData({this.review});

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      review: json["comment"] == null ? null : Review.fromJson(json['comment']),
    );
  }
}
