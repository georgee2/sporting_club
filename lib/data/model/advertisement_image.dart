class AdvertisementImage {
  final String? title;
  final String? link;
  final String? large;
  final String? small;

  AdvertisementImage({
    this.title,
    this.link,
    this.large,
    this.small,
  });

  factory AdvertisementImage.fromJson(Map<String, dynamic> json) {
    return AdvertisementImage(
      title: json['title'] == null ? null : json['title'],
      link: json['link'] == null ? null : json['link'],
      large: json['large'] == null ? null : json['large'],
      small: json['small'] == null ? null : json['small'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": this.title,
      "link": this.link,
      "large": this.large,
      "small": this.small,
    };
  }
}
