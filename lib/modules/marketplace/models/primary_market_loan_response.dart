// To parse this JSON data, do
//
//     final primaryMarketLoanResponse = primaryMarketLoanResponseFromJson(jsonString);

import 'dart:convert';

import 'package:peerbridge/modules/marketplace/models/primary_market_loan.dart';

PrimaryMarketLoanResponse primaryMarketLoanResponseFromJson(String str) =>
    PrimaryMarketLoanResponse.fromJson(json.decode(str));

String primaryMarketLoanResponseToJson(PrimaryMarketLoanResponse data) =>
    json.encode(data.toJson());

class PrimaryMarketLoanResponse {
  PrimaryMarketLoanResponse({
    this.productNames = const [],
    this.loanList = const [],
    this.loanAmountAndSize,
  });

  List<String> productNames;
  List<PrimaryMarketLoan> loanList;
  LoanOverViewDetail? loanAmountAndSize;

  factory PrimaryMarketLoanResponse.fromJson(Map<String, dynamic> json) =>
      PrimaryMarketLoanResponse(
        productNames: json["productNames"] == null
            ? []
            : List<String>.from(json["productNames"].map((x) => x)),
        loanList: json["loanList"] == null
            ? []
            : List<PrimaryMarketLoan>.from(
                json["loanList"].map((x) => PrimaryMarketLoan.fromJson(x))),
        loanAmountAndSize: json["loanAmountAndSize"] == null
            ? LoanOverViewDetail()
            : LoanOverViewDetail.fromJson(json["loanAmountAndSize"]),
      );

  Map<String, dynamic> toJson() => {
        "productNames": List<dynamic>.from(productNames.map((x) => x)),
        "loanList": List<dynamic>.from(loanList.map((x) => x.toJson())),
      };
}
