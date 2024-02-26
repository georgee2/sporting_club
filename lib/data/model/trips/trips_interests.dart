class TripsInterest {
  final String? value;
  final String? name;
  bool? selected;

  TripsInterest({
    this.value,
    this.name,
    this.selected,
  });

  factory TripsInterest.fromJson(Map<String, dynamic> json) {
    return TripsInterest(
      value: json['value'] == null ? null : json['value'],
      name: json['name'] == null ? null : json['name'],
      selected: json['selected'] == null ? null : json['selected'],
    );
  }

}
