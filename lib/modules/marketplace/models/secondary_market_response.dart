// To parse this JSON data, do
//
//     final secondaryMarketResponse = secondaryMarketResponseFromJson(jsonString);

import 'dart:convert';

import 'package:peerbridge/modules/marketplace/models/primary_market_loan.dart';
import 'package:peerbridge/modules/marketplace/models/secondary_market_loan.dart';

SecondaryMarketResponse secondaryMarketResponseFromJson(String str) =>
    SecondaryMarketResponse.fromJson(json.decode(str));

String secondaryMarketResponseToJson(SecondaryMarketResponse data) =>
    json.encode(data.toJson());

class SecondaryMarketResponse {
  SecondaryMarketResponse({
    this.statusCode,
    this.message,
    this.data,
  });

  String? statusCode;
  String? message;
  Data? data;

  factory SecondaryMarketResponse.fromJson(Map<String, dynamic> json) =>
      SecondaryMarketResponse(
        statusCode: json["statusCode"] == null ? null : json["statusCode"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode == null ? null : statusCode,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class Data {
  Data({
    this.secondaryMarketData = const [],
    this.overViewDetail,
  });

  List<SecondaryMarketLoan> secondaryMarketData;
  LoanOverViewDetail? overViewDetail;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        secondaryMarketData: json["secondaryMarketData"] == null
            ? List.empty(growable: true)
            : List<SecondaryMarketLoan>.from(
                json["secondaryMarketData"]
                    .map((x) => SecondaryMarketLoan.fromJson(x)),
              ),
        overViewDetail: json["loanAmountAndSize"] == null
            ? null
            : LoanOverViewDetail.fromJson(json["loanAmountAndSize"]),
      );

  Map<String, dynamic> toJson() => {
        "secondaryMarketData": secondaryMarketData == null
            ? null
            : List<dynamic>.from(secondaryMarketData.map((x) => x.toJson())),
        "loanAmountAndSize": overViewDetail,
      };
}
