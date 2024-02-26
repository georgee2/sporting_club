class Category {
  String? id;
  String? name;
  List<Category>? subCategories;
  final bool? selected;

  Category({this.id, this.name, this.subCategories, this.selected});

  factory Category.fromJson(Map<String, dynamic> json) {
    List<Category> subCategoriesList = [];
    if (json['subCategories'] != null) {
      var list = json['subCategories'] as List;
      if (list != null) {
        subCategoriesList = list.map((i) => Category.fromJson(i)).toList();
      }
    }
    return Category(
        id: json['id'] == null ? null : json['id'],
        name: json['title'] == null ? null : json['title'],
        selected: json['selected'] == null ? false : json['selected'],
        subCategories:
            json["subCategories"] == null ? null : subCategoriesList);
  }
}
