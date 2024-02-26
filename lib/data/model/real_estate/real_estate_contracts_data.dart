import 'contract_category.dart';

class RealEstateContractsData {
  final List<ContractCategory>? categories;

  RealEstateContractsData({
    this.categories,
  });

  factory RealEstateContractsData.fromJson(Map<String, dynamic> json) {
    List<ContractCategory> categoriesList = [];
    if (json['categories'] != null) {
      var list = json['categories'] as List;
      if (list != null) {
        categoriesList = list.map((i) => ContractCategory.fromJson(i)).toList();
      }
    }

    return RealEstateContractsData(
      categories: json['categories'] == null ? null : categoriesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "categories": this.categories,
    };
  }
}
