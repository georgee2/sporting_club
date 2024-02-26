class ContractSubCategory {
  final String? id;
  final String? name;

  ContractSubCategory({
    this.id,
    this.name,
  });

  factory ContractSubCategory.fromJson(Map<String, dynamic> json) {
    return ContractSubCategory(
      id: json['id'] == null ? null : json['id'].toString(),
      name: json['name'] == null ? null : json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
    };
  }
}