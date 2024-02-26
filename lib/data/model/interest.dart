class Interest {
  final String? id;
  final String? title;
  bool? selected;

  final List<Interest>? subCategories;

  Interest({this.id, this.title, this.selected, this.subCategories});

  factory Interest.fromJson(Map<String, dynamic> json) {
    List<Interest> subCategories = [];
    if (json['subCategories'] != null) {
      var list = json['subCategories'] as List;
      if (list != null) {
        subCategories = list.map((i) => Interest.fromJson(i)).toList();
      }
    }
    return Interest(
      id: json['id'] == null ? null : json['id'].toString(),
      title: json['title'] == null ? null : json['title'],
      selected: json['selected'] == null ? false : json['selected'],
      subCategories: json['subCategories'] == null ? null : subCategories,
    );
  }
}
