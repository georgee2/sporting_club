class Review {
  final String? comment_content;
  final String? rate;
  final String? image;
  int? comment;

  Review({
    this.comment_content,
    this.rate,
    this.image,
    this.comment
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rate: json['rate'] == null ? null : json['rate'],
      comment_content: json['comment_content'] == null ? null : json['comment_content'],
      image: json['image'] == null ? null : json['image'],
      comment: json['comment'] == null ? null : json['comment'],
    );
  }

}
