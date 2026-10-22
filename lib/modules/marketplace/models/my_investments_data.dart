class MyInvestmentsResponse {
  MyInvestmentsResponse({
    this.loanList = const [],
    this.count = 0,
    this.page = 1,
    this.hasMore = false,
  });

  List<MyInvestmentLoan> loanList;
  int count;
  int page;
  bool hasMore;

  factory MyInvestmentsResponse.fromJson(Map<String, dynamic> json) =>
      MyInvestmentsResponse(
        loanList: json["loanList"] == null
            ? []
            : List<MyInvestmentLoan>.from(
                json["loanList"].map((x) => MyInvestmentLoan.fromJson(x))),
        count: json["count"] == null ? 0 : (json["count"] as num).toInt(),
        page: json["page"] == null ? 1 : (json["page"] as num).toInt(),
        hasMore: json["hasMore"] == true,
      );
}

class MyInvestmentLoan {
  MyInvestmentLoan({
    this.contractId,
    this.borrowerName,
    this.productName,
    this.investedAmount,
    this.principalOutstanding,
    this.interestReceived,
    this.principalReceived,
    this.interestRate,
    this.tenor,
    this.status,
    this.marketType,
    this.investedDate,
    this.monexoRating,
  });

  String? contractId;
  String? borrowerName;
  String? productName;
  int? investedAmount;
  int? principalOutstanding;
  int? interestReceived;
  int? principalReceived;
  double? interestRate;
  int? tenor;
  String? status;
  String? marketType;
  String? investedDate;
  String? monexoRating;

  factory MyInvestmentLoan.fromJson(Map<String, dynamic> json) =>
      MyInvestmentLoan(
        contractId: json["contractId"]?.toString(),
        borrowerName: json["borrowerName"]?.toString(),
        productName: json["productName"]?.toString(),
        investedAmount: _asInt(json["investedAmount"]),
        principalOutstanding: _asInt(json["principalOutstanding"]),
        interestReceived: _asInt(json["interestReceived"]),
        principalReceived: _asInt(json["principalReceived"]),
        interestRate: _asDouble(json["interestRate"]),
        tenor: _asInt(json["tenor"]),
        status: json["status"]?.toString(),
        marketType: json["marketType"]?.toString(),
        investedDate: json["investedDate"]?.toString(),
        monexoRating: json["monexoRating"]?.toString(),
      );
}

class MyInvestmentDetail {
  MyInvestmentDetail({
    this.contractId,
    this.borrowerName,
    this.productName,
    this.status,
    this.marketType,
    this.investedDate,
    this.investedAmount,
    this.aboutBorrower,
    this.financialDetails,
    this.aboutInvestmentOrder,
    this.repayments = const [],
  });

  String? contractId;
  String? borrowerName;
  String? productName;
  String? status;
  String? marketType;
  String? investedDate;
  int? investedAmount;
  Map<String, dynamic>? aboutBorrower;
  Map<String, dynamic>? financialDetails;
  Map<String, dynamic>? aboutInvestmentOrder;
  List<Map<String, dynamic>> repayments;

  factory MyInvestmentDetail.fromJson(Map<String, dynamic> json) =>
      MyInvestmentDetail(
        contractId: json["contractId"]?.toString(),
        borrowerName: json["borrowerName"]?.toString(),
        productName: json["productName"]?.toString(),
        status: json["status"]?.toString(),
        marketType: json["marketType"]?.toString(),
        investedDate: json["investedDate"]?.toString(),
        investedAmount: _asInt(json["investedAmount"]),
        aboutBorrower: json["aboutBorrower"] is Map
            ? Map<String, dynamic>.from(json["aboutBorrower"])
            : null,
        financialDetails: json["financialDetails"] is Map
            ? Map<String, dynamic>.from(json["financialDetails"])
            : null,
        aboutInvestmentOrder: json["aboutInvestmentOrder"] is Map
            ? Map<String, dynamic>.from(json["aboutInvestmentOrder"])
            : null,
        repayments: json["repayments"] is List
            ? List<Map<String, dynamic>>.from(
                json["repayments"].map((e) => Map<String, dynamic>.from(e)))
            : [],
      );
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
