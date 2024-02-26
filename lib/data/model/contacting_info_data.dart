import 'contacting_info.dart';

class ContactingInfoData {
  final ContactingInfo? contact_us;

  ContactingInfoData({this.contact_us});

  factory ContactingInfoData.fromJson(Map<String, dynamic> json) {
    return ContactingInfoData(
      contact_us: json['contact_us'] == null
          ? null
          : ContactingInfo.fromJson(json['contact_us']),
    );
  }
}
