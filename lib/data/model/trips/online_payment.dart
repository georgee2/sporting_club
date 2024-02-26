class OnlinePayment {
  String? iframeUrl;
  String? extendedExpireTime;
  String? iframe_url;

  OnlinePayment({this.iframeUrl, this.extendedExpireTime,this.iframe_url});

  factory OnlinePayment.fromJson(Map<String, dynamic> json) {
    return OnlinePayment(
      iframeUrl: json['iframeUrl'] == null ? null : json['iframeUrl'],
      iframe_url: json['iframe_url'] == null ? null : json['iframe_url'],

      extendedExpireTime: json['extendedExpireTime'] == null
          ? null
          : json['extendedExpireTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "iframeUrl": this.iframeUrl,
      "iframe_url": this.iframe_url,

      "extendedExpireTime": this.extendedExpireTime,
    };
  }
}
