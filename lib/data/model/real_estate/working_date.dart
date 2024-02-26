class WorkingDate {
  final String? name;
  final String? value;

  WorkingDate({
    this.name,
    this.value,
  });

  factory WorkingDate.fromJson(Map<String, dynamic> json) {
    return WorkingDate(
      name: json['name'] == null ? null : json['name'],
      value: json['value'] == null ? null : json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "value": this.value,
    };
  }
}