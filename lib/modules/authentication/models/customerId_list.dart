import 'package:peerbridge/utils/extensions.dart';

class CustomerIdDetail {
  String? customerId;
  String? fullName;
  String? email;
  String? panId;

  CustomerIdDetail({
    this.customerId,
    this.fullName,
    this.email,
    this.panId,
  });

  CustomerIdDetail.fromJson(Map<String, dynamic> json) {
    customerId = json['customerId'] == null ? null : json['customerId'];
    fullName = json['fullName'] == null
        ? null
        : json[
            'fullName']; //(json["fullName"] ?? "").toString().capitalizeFirstofEach;
    email = json['email'] == null ? null : json['email'];
    panId = json['panId'] == null ? null : json['panId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerId'] = this.customerId;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['panId'] = this.panId;
    return data;
  }
}
