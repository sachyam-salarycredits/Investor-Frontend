import 'package:peerbridge/modules/onboardingSteps/models/auto_invest_category_model.dart';

class AutoInvestDetail {
  String? customerId;
  double? totalAmount;
  double? conservetiveRisk;
  double? moderateRisk;
  double? highRisk;
  bool? enable;
  String? flag;

  AutoInvestDetail(
      {this.customerId,
      this.totalAmount,
      this.conservetiveRisk,
      this.moderateRisk,
      this.highRisk,
      this.enable,
      this.flag});

  AutoInvestDetail.fromJson(Map<String, dynamic> json) {
    customerId = json['customerId'] == null ? null : json['customerId'];
    totalAmount = json['totalAmount'] == null
        ? null
        : (json['totalAmount'] as num?)?.toDouble();
    conservetiveRisk = json['conservetiveRisk'] == null
        ? null
        : (json['conservetiveRisk'] as num?)?.toDouble();
    moderateRisk = json['moderateRisk'] == null
        ? null
        : (json['moderateRisk'] as num?)?.toDouble();
    highRisk = json['highRisk'] == null
        ? null
        : (json['highRisk'] as num?)?.toDouble();
    enable = parseAutoInvestBool(json['enable']) ?? true;
    flag = json['flag']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerId'] = this.customerId;
    data['totalAmount'] = this.totalAmount;
    data['conservetiveRisk'] = this.conservetiveRisk;
    data['moderateRisk'] = this.moderateRisk;
    data['highRisk'] = this.highRisk;
    data['enable'] = this.enable;
    data['flag'] = this.flag;
    return data;
  }
}
