import 'package:peerbridge/utils/extensions.dart';

class StepsData {
  String kyc;
  String mip;
  String authorizedSignatory;
  String nominee;
  String fundTransfer;
  String sip;
  String autoInvestment;

  StepsData(
      {this.kyc = "0",
      this.mip = "0",
      this.authorizedSignatory = "0",
      this.nominee = "0",
      this.fundTransfer = "0",
      this.sip = "0",
      this.autoInvestment = "0"});

  factory StepsData.fromJson(Map<String, dynamic> json) {
    return StepsData(
      kyc: (json['kyc'] ?? "0").toString().removeSpace(),
      mip: (json['mip'] ?? "0").toString().removeSpace(),
      authorizedSignatory:
          (json['authorizedSignatory'] ?? "0").toString().removeSpace(),
      nominee: (json['nominee'] ?? "0").toString().removeSpace(),
      fundTransfer: (json['fundTransfer'] ?? "0").toString().removeSpace(),
      sip: (json['sip'] ?? "0").toString().removeSpace(),
      autoInvestment: (json['autoInvestment'] ?? "0").toString().removeSpace(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kyc'] = this.kyc;
    data['mip'] = this.mip;
    data['authorizedSignatory'] = this.authorizedSignatory;
    data['nominee'] = this.nominee;
    data['fundTransfer'] = this.fundTransfer;
    data['sip'] = this.sip;
    data['autoInvestment'] = this.autoInvestment;
    return data;
  }

  List<String> getStatusList() {
    return [
      this.fundTransfer,
      this.authorizedSignatory,
      this.kyc,
      this.autoInvestment,
      this.mip,
      this.sip,
      this.nominee,
    ];
  }
}
