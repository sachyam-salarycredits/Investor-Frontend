import 'package:peerbridge/utils/utils.dart';

class PrimaryLoanDetails {
  FinancialDetails? financialDetails;
  ActiveLoans? activeLoans;
  BorrowerDetails? aboutBorrower;

  PrimaryLoanDetails({
    this.financialDetails,
    this.activeLoans,
    this.aboutBorrower,
  });

  factory PrimaryLoanDetails.fromJson(Map<String, dynamic> json) =>
      PrimaryLoanDetails(
        financialDetails: json["financialDetails"] == null
            ? FinancialDetails()
            : FinancialDetails.fromJson(json["financialDetails"]),
        activeLoans: json["activeLoans"] == null
            ? ActiveLoans.fromJson({})
            : ActiveLoans.fromJson(json["activeLoans"]),
        aboutBorrower: BorrowerDetails.fromJson(
          (json["aboutBorrower"] ?? json["borrowerDetails"] ?? {})
              as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
        "financialDetails":
            financialDetails == null ? null : financialDetails?.toJson(),
        "activeLoans": activeLoans == null ? null : activeLoans?.toJson(),
        "aboutBorrower": aboutBorrower == null ? null : aboutBorrower?.toJson(),
      };
}

class ActiveLoans {
  ActiveLoanDetail? personalLoan;
  ActiveLoanDetail? otherLoan;
  ActiveLoanDetail? homeLoan;
  ActiveLoanDetail? goldLoan;
  ActiveLoanDetail? creditCards;

  ActiveLoans({
    this.personalLoan,
    this.otherLoan,
    this.homeLoan,
    this.goldLoan,
    this.creditCards,
  });

  factory ActiveLoans.fromJson(Map<String, dynamic> json) => ActiveLoans(
        personalLoan: json["personalLoan"] == null
            ? ActiveLoanDetail()
            : ActiveLoanDetail.fromJson(json["personalLoan"]),
        otherLoan: json["otherLoan"] == null
            ? ActiveLoanDetail()
            : ActiveLoanDetail.fromJson(json["otherLoan"]),
        homeLoan: json["homeLoan"] == null
            ? ActiveLoanDetail()
            : ActiveLoanDetail.fromJson(json["homeLoan"]),
        goldLoan: json["goldLoan"] == null
            ? ActiveLoanDetail()
            : ActiveLoanDetail.fromJson(json["goldLoan"]),
        creditCards: json["creditCards"] == null
            ? ActiveLoanDetail()
            : ActiveLoanDetail.fromJson(json["creditCards"]),
      );

  Map<String, dynamic> toJson() => {
        "personalLoan":
            personalLoan == null ? ActiveLoanDetail() : personalLoan?.toJson(),
        "otherLoan":
            otherLoan == null ? ActiveLoanDetail() : otherLoan?.toJson(),
        "homeLoan": homeLoan == null ? ActiveLoanDetail() : homeLoan?.toJson(),
        "goldLoan": goldLoan == null ? ActiveLoanDetail() : goldLoan?.toJson(),
        "creditCards":
            creditCards == null ? ActiveLoanDetail() : creditCards?.toJson(),
      };
}

class ActiveLoanDetail {
  String pos;
  int numberLoan;

  ActiveLoanDetail({
    this.pos = "N/A",
    this.numberLoan = 0,
  });

  factory ActiveLoanDetail.fromJson(Map<String, dynamic> json) =>
      ActiveLoanDetail(
        pos: json["pos"] ?? "N/A",
        numberLoan: json["numberLoan"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "pos": pos,
        "numberLoan": numberLoan,
      };
}

class FinancialDetails {
  String vintageInBureauMonths;
  String monexoRating;
  String mobileAppDownload;
  String digitalBankVerification;
  String debtServiceRatio;
  String currentNetSalary;
  String bureauScore;

  FinancialDetails({
    this.vintageInBureauMonths = "0",
    this.monexoRating = "-",
    this.mobileAppDownload = "-",
    this.digitalBankVerification = "-",
    this.debtServiceRatio = "0",
    this.currentNetSalary = "0",
    this.bureauScore = "-",
  });

  factory FinancialDetails.fromJson(Map<String, dynamic> json) =>
      FinancialDetails(
        vintageInBureauMonths: json["vintageInBureauMonths"] ?? "0",
        monexoRating: Utils.getLoanCategory(json["monexoRating"] ?? ""),
        mobileAppDownload: json["mobileAppDownload"] ?? "-",
        digitalBankVerification: json["digitalBankVerification"] ?? "-",
        debtServiceRatio: json["debtServiceRatio"] ?? "0",
        currentNetSalary: json["currentNetSalary"] ?? "0",
        bureauScore: json["bureauScore"] ?? "-",
      );

  Map<String, dynamic> toJson() => {
        "vintageInBureauMonths": vintageInBureauMonths,
        "monexoRating": monexoRating,
        "mobileAppDownload": mobileAppDownload,
        "digitalBankVerification": digitalBankVerification,
        "debtServiceRatio": debtServiceRatio,
        "currentNetSalary": currentNetSalary,
        "bureauScore": bureauScore,
      };
}

class BorrowerDetails {
  String state;
  String role;
  String gender;
  String employementType;
  String age;

  BorrowerDetails({
    this.state = "-",
    this.role = "-",
    this.gender = "-",
    this.employementType = "-",
    this.age = "0",
  });

  factory BorrowerDetails.fromJson(Map<String, dynamic> json) =>
      BorrowerDetails(
        state: json["state"] ?? json["city"] ?? "-",
        role: json["role"] ?? json["occupation"] ?? "-",
        gender: json["gender"] ?? "-",
        employementType:
            json["employementType"] ?? json["customerType"] ?? "-",
        age: (json["age"] ?? json["ageBand"] ?? "0").toString(),
      );

  Map<String, dynamic> toJson() => {
        "state": state,
        "role": role,
        "gender": gender,
        "employementType": employementType,
        "age": age,
      };
}
