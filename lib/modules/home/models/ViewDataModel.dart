import 'package:peerbridge/modules/home/models/ViewRiskDataModel.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ViewDataModel {
  ViewDataModel({
    this.data,
    this.sfLogs,
  });

  ViewDataModel.fromJson(dynamic json) {
    data = json['data'] != null ? ViewData.fromJson(json['data']) : null;
    sfLogs = json['sfLogs'];
  }
  ViewData? data;
  dynamic? sfLogs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['sfLogs'] = sfLogs;
    return map;
  }
}

class ViewData {
  ViewData(
      {this.tenureData,
      this.statusCode,
      this.risk,
      this.remainingTenureData,
      this.message,
      this.interestRateList,
      this.delinquencyList});

  ViewData.fromJson(dynamic json) {
    if (json['tenureData'] != null) {
      tenureData = [];
      json['tenureData'].forEach((v) {
        tenureData?.add(RemainingTenureData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    risk = json['risk'] != null ? Risk.fromJson(json['risk']) : null;
    if (json['remainingTenureData'] != null) {
      remainingTenureData = [];
      json['remainingTenureData'].forEach((v) {
        remainingTenureData?.add(RemainingTenureData.fromJson(v));
      });
    }
    message = json['message'];
    if (json['interestRateList'] != null) {
      interestRateList = [];
      json['interestRateList'].forEach((v) {
        interestRateList?.add(InterestRateList.fromJson(v));
      });
    }
    if (json['deliquencyList'] != null) {
      delinquencyList = [];
      json['deliquencyList'].forEach((v) {
        delinquencyList?.add(DelinquencyList.fromJson(v));
      });
    }
  }
  List<RemainingTenureData>? tenureData;
  int? statusCode;
  Risk? risk;
  List<RemainingTenureData>? remainingTenureData;
  String? message;
  List<InterestRateList>? interestRateList;
  List<DelinquencyList>? delinquencyList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (tenureData != null) {
      map['tenureData'] = tenureData?.map((v) => v.toJson()).toList();
    }
    map['statusCode'] = statusCode;
    if (risk != null) {
      map['risk'] = risk?.toJson();
    }
    if (remainingTenureData != null) {
      map['remainingTenureData'] =
          remainingTenureData?.map((v) => v.toJson()).toList();
    }
    map['message'] = message;
    if (interestRateList != null) {
      map['interestRateList'] =
          interestRateList?.map((v) => v.toJson()).toList();
    }
    if (delinquencyList != null) {
      map['deliquencyList'] = delinquencyList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Attributes {
  Attributes({
    this.type,
    this.url,
  });

  Attributes.fromJson(dynamic json) {
    type = json['type'];
    url = json['url'];
  }
  String? type;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['url'] = url;
    return map;
  }
}

class Conservative {
  Conservative({
    this.investOrderList,
  });

  Conservative.fromJson(dynamic json) {
    if (json['investOrderList'] != null) {
      investOrderList = [];
      json['investOrderList'].forEach((v) {
        investOrderList?.add(InvestOrderList.fromJson(v));
      });
    }
  }
  List<InvestOrderList>? investOrderList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (investOrderList != null) {
      map['investOrderList'] = investOrderList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LoanLoanR {
  LoanLoanR({
    this.attributes,
    this.id,
    this.loanNumberOfInstallmentsC,
    this.loanNumberOfDaysOverdueC,
    this.slxirrc,
    this.remainingEMIC,
  });

  LoanLoanR.fromJson(dynamic json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    loanNumberOfInstallmentsC = json['loan__Number_of_Installments__c'];
    loanNumberOfDaysOverdueC = json['loan__Number_of_Days_Overdue__c'];
    slxirrc = json['SL_XIRR__c'];
    remainingEMIC = json['Remaining_EMI__c'];
  }
  Attributes? attributes;
  String? id;
  int? loanNumberOfInstallmentsC;
  int? loanNumberOfDaysOverdueC;
  double? slxirrc;
  int? remainingEMIC;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (attributes != null) {
      map['attributes'] = attributes?.toJson();
    }
    map['Id'] = id;
    map['loan__Number_of_Installments__c'] = loanNumberOfInstallmentsC;
    map['loan__Number_of_Days_Overdue__c'] = loanNumberOfDaysOverdueC;
    map['SL_XIRR__c'] = slxirrc;
    map['Remaining_EMI__c'] = remainingEMIC;
    return map;
  }
}

class InterestRateList {
  InterestRateList({
    this.xirr,
    this.startDate,
    this.name,
    this.investmentAmount,
    this.interestRateonLoanRange,
    this.interestRateonLoan,
    this.contractId,
    this.status,
  });

  InterestRateList.fromJson(dynamic json) {
    xirr = json['XIRR'];
    startDate = json['startDate'];
    name = json['name'];
    investmentAmount = json['investmentAmount'];
    interestRateonLoanRange = json['interestRateonLoanRange'];
    interestRateonLoan = json['interestRateonLoan'];
    contractId = json['contractId'];
    status = json['status'];
  }
  double? xirr;
  String? startDate;
  String? name;
  double? investmentAmount;
  String? interestRateonLoanRange;
  double? interestRateonLoan;
  String? contractId;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['XIRR'] = xirr;
    map['startDate'] = startDate;
    map['name'] = name;
    map['investmentAmount'] = investmentAmount;
    map['interestRateonLoanRange'] = interestRateonLoanRange;
    map['interestRateonLoan'] = interestRateonLoan;
    map['contractId'] = contractId;
    map['status'] = status;
    return map;
  }
}

class InvestOrderList {
  InvestOrderList({
    this.attributes,
    this.peerCreditBandAllocationC,
    this.id,
    this.name,
    this.loanInvestorStartDateC,
    this.loanInvestmentAmountC,
    this.borrowerNameC,
    this.loanRemainingInvestmentAmountC,
    this.loanLoanC,
    this.loanStatusC,
    this.loanCertificateRateC,
    this.loanLoanR,
  });

  InvestOrderList.fromJson(dynamic json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    peerCreditBandAllocationC = json['peer__Credit_Band_Allocation__c'];
    id = json['Id'];
    name = json['Name'];
    loanInvestorStartDateC = json['loan__Investor_Start_Date__c'];
    loanInvestmentAmountC = json['loan__Investment_Amount__c'];
    borrowerNameC = json['Borrower_Name__c'];
    loanRemainingInvestmentAmountC =
        json['loan__Remaining_Investment_Amount__c'];
    loanLoanC = json['loan__Loan__c'];
    loanStatusC = json['loan__Status__c'];
    loanCertificateRateC = json['loan__Certificate_Rate__c'];
    loanLoanR = json['loan__Loan__r'] != null
        ? LoanLoanR.fromJson(json['loan__Loan__r'])
        : null;
  }
  Attributes? attributes;
  String? peerCreditBandAllocationC;
  String? id;
  String? name;
  String? loanInvestorStartDateC;
  double? loanInvestmentAmountC;
  String? borrowerNameC;
  double? loanRemainingInvestmentAmountC;
  String? loanLoanC;
  String? loanStatusC;
  double? loanCertificateRateC;
  LoanLoanR? loanLoanR;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (attributes != null) {
      map['attributes'] = attributes?.toJson();
    }
    map['peer__Credit_Band_Allocation__c'] = peerCreditBandAllocationC;
    map['Id'] = id;
    map['Name'] = name;
    map['loan__Investor_Start_Date__c'] = loanInvestorStartDateC;
    map['loan__Investment_Amount__c'] = loanInvestmentAmountC;
    map['Borrower_Name__c'] = borrowerNameC;
    map['loan__Remaining_Investment_Amount__c'] =
        loanRemainingInvestmentAmountC;
    map['loan__Loan__c'] = loanLoanC;
    map['loan__Status__c'] = loanStatusC;
    map['loan__Certificate_Rate__c'] = loanCertificateRateC;
    if (loanLoanR != null) {
      map['loan__Loan__r'] = loanLoanR?.toJson();
    }
    return map;
  }
}

class RemainingTenureData {
  RemainingTenureData({
    this.xirr,
    this.totalTerm,
    this.termCategory,
    this.status,
    this.startDate,
    this.remainingTerm,
    this.remainingAmount,
    this.name,
    this.contractId,
    this.amount,
  });

  RemainingTenureData.fromJson(dynamic json) {
    xirr = json['XIRR'];
    totalTerm = json['totalTerm'];
    termCategory = json['termCategory'];
    status = json['status'];
    startDate = json['startDate'];
    remainingTerm = json['remainingTerm'];
    remainingAmount = json['remainingAmount'];
    name = json['name'];
    contractId = json['contractId'];
    amount = json['amount'];
  }
  double? xirr;
  dynamic? totalTerm;
  String? termCategory;
  String? status;
  String? startDate;
  int? remainingTerm;
  double? remainingAmount;
  String? name;
  String? contractId;
  double? amount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['XIRR'] = xirr;
    map['totalTerm'] = totalTerm;
    map['termCategory'] = termCategory;
    map['status'] = status;
    map['startDate'] = startDate;
    map['remainingTerm'] = remainingTerm;
    map['remainingAmount'] = remainingAmount;
    map['name'] = name;
    map['contractId'] = contractId;
    map['amount'] = amount;
    return map;
  }
}

class Risk {
  Risk({
    this.medium,
    this.high,
    this.conservative,
  });

  Risk.fromJson(dynamic json) {
    conservative = json['conservative'] != null
        ? Conservative.fromJson(json['conservative'])
        : null;
    medium =
        json['medium'] != null ? Conservative.fromJson(json['medium']) : null;
    high = json['high'] != null ? Conservative.fromJson(json['high']) : null;
  }
  Conservative? medium;
  Conservative? high;
  Conservative? conservative;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (medium != null) {
      map['medium'] = medium?.toJson();
    }
    if (high != null) {
      map['high'] = high?.toJson();
    }
    if (conservative != null) {
      map['conservative'] = conservative?.toJson();
    }
    return map;
  }
}

class DelinquencyList {
  DelinquencyList(
      {this.xirr,
      this.startDate,
      this.name,
      this.investmentAmount,
      this.deliquentRange,
      this.deliquentDays,
      this.contractId,
      this.status});

  DelinquencyList.fromJson(dynamic json) {
    xirr = json['XIRR'];
    startDate = json['startDate'];
    name = json['name'];
    investmentAmount = json['investmentAmount'];
    deliquentRange = json['deliquentRange'];
    deliquentDays = json['deliquentDays'];
    contractId = json['contractId'];
    status = json['status'];
  }
  double? xirr;
  String? startDate;
  String? name;
  double? investmentAmount;
  String? deliquentRange;
  int? deliquentDays;
  String? contractId;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['XIRR'] = xirr;
    map['startDate'] = startDate;
    map['name'] = name;
    map['investmentAmount'] = investmentAmount;
    map['deliquentRange'] = deliquentRange;
    map['deliquentDays'] = deliquentDays;
    map['contractId'] = contractId;
    map['status'] = status;
    return map;
  }
}
