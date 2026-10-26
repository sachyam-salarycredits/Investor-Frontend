class PortfolioSummary {
  PortfolioSummary({
    this.active,
    this.closed,
    this.monthRepayment,
  });

  PortfolioSectionSummary? active;
  PortfolioSectionSummary? closed;
  MonthRepayment? monthRepayment;

  factory PortfolioSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PortfolioSummary();
    return PortfolioSummary(
      active: json['active'] != null
          ? PortfolioSectionSummary.fromJson(json['active'])
          : null,
      closed: json['closed'] != null
          ? PortfolioSectionSummary.fromJson(json['closed'])
          : null,
    );
  }
}

class PortfolioSectionSummary {
  PortfolioSectionSummary({
    this.loanCount = 0,
    this.totalInvested = 0,
    this.totalReturn = 0,
    this.interestEarned = 0,
    this.principalReceived = 0,
    this.principalOutstanding = 0,
    this.percentageEarned = 0,
    this.platformFee = 0,
    this.interestSpread = 0,
    this.absoluteReturnPercent = 0,
    this.annualizedNetReturn = 0,
    this.health = 'NO_DATA',
    this.healthLabel = 'No loans',
  });

  int loanCount;
  int totalInvested;
  int totalReturn;
  int interestEarned;
  int principalReceived;
  int principalOutstanding;
  double percentageEarned;
  double platformFee;
  double interestSpread;
  double absoluteReturnPercent;
  double annualizedNetReturn;
  String health;
  String healthLabel;

  factory PortfolioSectionSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSectionSummary(
      loanCount: _asInt(json['loanCount']),
      totalInvested: _asInt(json['totalInvested']),
      totalReturn: _asInt(json['totalReturn']),
      interestEarned: _asInt(json['interestEarned']),
      principalReceived: _asInt(json['principalReceived']),
      principalOutstanding: _asInt(json['principalOutstanding']),
      percentageEarned: _asDouble(json['percentageEarned']),
      platformFee: _asDouble(json['platformFee']),
      interestSpread: _asDouble(json['interestSpread']),
      absoluteReturnPercent: _asDouble(json['absoluteReturnPercent']),
      annualizedNetReturn: _asDouble(json['annualizedNetReturn']),
      health: json['health']?.toString() ?? 'NO_DATA',
      healthLabel: json['healthLabel']?.toString() ?? 'No loans',
    );
  }
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

class MonthRepayment {
  MonthRepayment({
    this.periodLabel = '',
    this.principalReceived = 0,
    this.interestReceived = 0,
    this.totalReceived = 0,
    this.due = 0,
    this.stillToCome = 0,
  });

  String periodLabel;
  int principalReceived;
  int interestReceived;
  int totalReceived;
  int due;
  int stillToCome;

  factory MonthRepayment.fromJson(Map<String, dynamic> json) {
    return MonthRepayment(
      periodLabel: json['periodLabel']?.toString() ?? '',
      principalReceived: _asInt(json['principalReceived']),
      interestReceived: _asInt(json['interestReceived']),
      totalReceived: _asInt(json['totalReceived']),
      due: _asInt(json['due']),
      stillToCome: _asInt(json['stillToCome']),
    );
  }
}
