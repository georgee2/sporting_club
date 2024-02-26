class Badge {

  final String? carnumber;
  final String? value;
   bool? selected =false ;

  Badge({
    this.carnumber,
    this.value,
    this.selected,


  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      carnumber: json['carnumber'] == null ? null : json['carnumber'],
      value: json['value'] == null ? null : json['value'],
      selected: json['selected'] == null ? false : json['selected'],

    );
  }
}
