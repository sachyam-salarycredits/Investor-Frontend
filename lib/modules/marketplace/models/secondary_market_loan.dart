// To parse this JSON data, do
//
//     final secondaryMarketLoan = secondaryMarketLoanFromJson(jsonString);

import 'dart:convert';

import 'package:peerbridge/utils/utils.dart';

SecondaryMarketLoan secondaryMarketLoanFromJson(String str) =>
    SecondaryMarketLoan.fromJson(json.decode(str));

String secondaryMarketLoanToJson(SecondaryMarketLoan data) =>
    json.encode(data.toJson());

class SecondaryMarketLoan {
  SecondaryMarketLoan(
      {this.tenorRemaining = 0,
      this.tenorCompleted = 0,
      this.status = "",
      this.startDate,
      this.sellingPrice = 0.0,
      this.remainingDays = 0,
      this.rating = '',
      this.lastPaymentDate,
      this.investorId = "",
      this.interestRate = 0.0,
      this.frequency = "",
      this.endDate,
      this.contract = "",
      this.buyersYield = 0.0,
      this.emi = 0.0,
      this.isAddedToCart = false,
      this.fundedAmount = 0.0,
      this.alreadyFunded = false,
      this.customerName = ''});

  double tenorRemaining;
  double tenorCompleted;
  String status;
  String? startDate;
  double sellingPrice;
  int? remainingDays;
  String? rating;
  String? lastPaymentDate;
  String investorId;
  double interestRate;
  String frequency;
  String? endDate;
  String contract;
  double? buyersYield;
  double? emi;
  bool isAddedToCart;
  double fundedAmount;
  bool alreadyFunded;
  String customerName;

  factory SecondaryMarketLoan.fromJson(Map<String, dynamic> json) =>
      SecondaryMarketLoan(
        tenorRemaining:
            json["tenorRemaining"] == null ? 0 : json["tenorRemaining"],
        tenorCompleted:
            json["tenorCompleted"] == null ? 0 : json["tenorCompleted"],
        status: json["status"] == null ? '' : json["status"],
        startDate: json["startDate"] == null ? null : json["startDate"],
        sellingPrice: json["sellingPrice"] == null ? 0.0 : json["sellingPrice"],
        fundedAmount: json["sellingPrice"] == null ? 0.0 : json["sellingPrice"],
        remainingDays:
            json["remainingDays"] == null ? null : json["remainingDays"],
        rating: json["rating"] == null
            ? null
            : Utils.getLoanCategory(json["rating"] ?? ""),
        lastPaymentDate:
            json["lastPaymentDate"] == null ? null : json["lastPaymentDate"],
        investorId: json["investorId"] == null ? "" : json["investorId"],
        interestRate: json["interestRate"] == null
            ? 0.0
            : json["interestRate"].toDouble(),

        frequency: json["frequency"] == null ? '' : json["frequency"],
        endDate: json["endDate"] == null ? null : json["endDate"],
        contract: json["contract"] == null ? '' : json["contract"],
        buyersYield:
            json["buyersYield"] == null ? null : json["buyersYield"].toDouble(),
        emi: json["EMI"] == null ? null : json["EMI"].toDouble(),
        customerName: json["customerName"] == null ? '' : json["customerName"],
        // isAddedToCart:
        //     json["isAddedToCart"] == null ? null : json["isAddedToCart"],
        // fundedAmount:
        //     json["fundedAmount"] == null ? null : json["fundedAmount"],
        // alreadyFunded:
        //     json["alreadyFunded"] == null ? null : json["alreadyFunded"],
      );

  Map<String, dynamic> toJson() => {
        "tenorRemaining": tenorRemaining,
        "tenorCompleted": tenorCompleted,
        "status": status,
        "sellingPrice": sellingPrice,
        "remainingDays": remainingDays,
        "rating": rating,
        "investorId": investorId,
        "interestRate": interestRate,
        "frequency": frequency,
        "contract": contract,
        "buyersYield": buyersYield,
        "EMI": emi,
        "isAddedToCart": isAddedToCart,
        "fundedAmount": fundedAmount,
        "alreadyFunded": alreadyFunded,
        "customerName": customerName,
      };

  @override
  String toString() {
    return investorId;
  }

  @override
  bool operator ==(Object other) {
    return investorId == other.toString();
  }

  String remainingDaysStr() {
    if (remainingDays == null || remainingDays == 0) {
      return '';
    }
    if (remainingDays == 1) {
      return 'Last Day';
    } else {
      return '$remainingDays Days remaining';
    }
  }
}
