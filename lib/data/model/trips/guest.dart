class Guest {
   String? name;
   String? nationalId;
   String? birthdate;

  Guest({
    this.name,
    this.nationalId,
    this.birthdate,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      name: json['name'] == null ? null : json['name'],
      nationalId: json['nationalId'] == null ? null : json['nationalId'],
      birthdate: json['birthdate'] == null ? null : json['birthdate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "nationalId": this.nationalId,
      "birthdate": this.birthdate,
    };
  }
}
