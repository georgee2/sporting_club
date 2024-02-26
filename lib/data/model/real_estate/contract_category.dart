import 'contract_sub_category.dart';

class ContractCategory {
  final String? id;
  final String? name;
  final List<ContractSubCategory>? subCategories;

  ContractCategory({
    this.id,
    this.name,
    this.subCategories,
  });

  factory ContractCategory.fromJson(Map<String, dynamic> json) {
    List<ContractSubCategory> subCategoriesList = [];
    if (json['subCatogries'] != null) {
      var list = json['subCatogries'] as List;
      if (list != null) {
        subCategoriesList = list.map((i) => ContractSubCategory.fromJson(i)).toList();
      }
    }
    return ContractCategory(
      id: json['id'] == null ? null : json['id'].toString(),
      name: json['name'] == null ? null : json['name'],
      subCategories: json['subCatogries'] == null ? null : subCategoriesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "subCatogries": this.subCategories,
    };
  }
}