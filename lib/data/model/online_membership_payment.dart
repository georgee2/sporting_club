class OnlineMembershipPayment {

  String? iframe_url;

  OnlineMembershipPayment({this.iframe_url});

  factory OnlineMembershipPayment.fromJson(Map<String, dynamic> json) {
    return OnlineMembershipPayment(
      iframe_url: json['iframe_url'] == null ? null : json['iframe_url'],


    );
  }

  Map<String, dynamic> toJson() {
    return {
      "iframe_url": this.iframe_url,

    };
  }
}
