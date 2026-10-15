import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';

class PrimaryMarketLoan {
  static final MAX_FUNDING_AMOUNT = 5000;
  double tenor;
  double returnAmount;
  String productName;
  double loanAmount;
  double lenderXIRR;
  String frequency;
  String contract;
  String category;
  double alreadyCommitedAmount;

  bool isAddedToCart;
  double fundedAmount;
  double alreadyFundedAmount;
  String customerName;

  PrimaryMarketLoan(
      {this.tenor = 0,
      this.returnAmount = 0,
      this.productName = "",
      this.loanAmount = 0,
      this.lenderXIRR = 0,
      this.frequency = "",
      this.contract = "",
      this.category = "",
      this.alreadyCommitedAmount = 0,
      this.isAddedToCart = false,
      this.fundedAmount = 0,
      this.alreadyFundedAmount = 0,
      this.customerName = ''});

  //use to check if user already made a fiunding of 5000 to this loan
  double getAlreadyFunded() {
    var amount = 0.0;
    amount = (alreadyCommitedAmount / loanAmount);
    if (amount > 1) return 1;
    return amount;
  }

  double getCommittedPercentage() {
    var amount = 0.0;
    amount = (alreadyCommitedAmount / loanAmount) * 100;
    if (amount > 100) return 100;
    return amount;
  }

  factory PrimaryMarketLoan.fromJson(Map<String, dynamic> json) {
    return PrimaryMarketLoan(
      tenor: json['tenor'] ?? 0,
      returnAmount: json['returnAmount'] ?? 0,
      productName: json['productName'] ?? "",
      loanAmount: json['loanAmount'] ?? 0,
      lenderXIRR: json['lenderXIRR'] ?? 0,
      frequency: json['frequency'] ?? "",
      contract: json['contract'] ?? "",
      category: Utils.getLoanCategory(json['category'] ?? ""),
      alreadyCommitedAmount: json['alreadyCommitedAmount'] ?? 0,
      // alreadyFundedAmount: 1000
      alreadyFundedAmount: json['alreadyFundedAmount'] ?? 0,
      customerName: json['customerName'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenor'] = this.tenor;
    data['returnAmount'] = this.returnAmount;
    data['productName'] = this.productName;
    data['loanAmount'] = this.loanAmount;
    data['lenderXIRR'] = this.lenderXIRR;
    data['frequency'] = this.frequency;
    data['contract'] = this.contract;
    data['category'] = this.category;
    data['alreadyCommitedAmount'] = this.alreadyCommitedAmount;
    data['alreadyFundedAmount'] = this.alreadyFundedAmount;
    data['customerName'] = this.customerName;
    return data;
  }

  @override
  String toString() {
    return contract;
  }

  @override
  bool operator ==(Object other) {
    return contract == other.toString();
  }

  double getRemainingUserFundingAmount() {
    if (getRequiredFunding() <= MAX_FUNDING_AMOUNT) {
      return getRequiredFunding() - alreadyFundedAmount;
    } else {
      return MAX_FUNDING_AMOUNT - alreadyFundedAmount;
    }
  }

  double getRequiredFunding() {
    return loanAmount - alreadyCommitedAmount;
  }

  bool isAllowToFund() {
    final amount = getRemainingUserFundingAmount();

    if (amount <= 0) {
      return false;
    } else {
      return true;
    }
  }

  String? getAllowFundMessage(double requireAmount) {
    var amount = 0.0;

    if (requireAmount > loanAmount - alreadyCommitedAmount) {
      return "your funding amount can’t be greater than the required loan amount!";
    } else if (requireAmount > MAX_FUNDING_AMOUNT) {
      return "Please do not lend more than ₹ 5,000 for a diversified portfolio.";
    } else {
      return null;
    }
  }

  bool alreadyFunded() {
    return alreadyFundedAmount > 0;
  }

  bool isMaxFunded() {
    return alreadyFundedAmount == MAX_FUNDING_AMOUNT;
  }
}

class LoanOverViewDetail {
  double totalLoanAmount;
  int numberOfLoan;

  LoanOverViewDetail({
    this.totalLoanAmount = 0,
    this.numberOfLoan = 0,
  });

  factory LoanOverViewDetail.fromJson(Map<String, dynamic> json) {
    return LoanOverViewDetail(
      totalLoanAmount: (json['totalLoanAmount'] as num?)?.toDouble() ?? 0.0,
      numberOfLoan: json['numberOfLoan'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalLoanAmount'] = this.totalLoanAmount;
    data['numberOfLoan'] = this.numberOfLoan;
    return data;
  }
}
