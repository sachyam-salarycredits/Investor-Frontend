class AccountTransaction {
  final int id;
  final bool isCredit;
  final String kind;
  final String title;
  final double amount;
  final double? balanceAfter;
  final String? loanId;
  final String reference;
  final DateTime? createdAt;

  AccountTransaction({
    required this.id,
    required this.isCredit,
    required this.kind,
    required this.title,
    required this.amount,
    required this.balanceAfter,
    required this.loanId,
    required this.reference,
    required this.createdAt,
  });

  bool get isEmi => kind == 'EMI';

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    final loanId = json['loanId']?.toString() ?? '';
    return AccountTransaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      isCredit: json['direction'] == 'CREDIT',
      kind: json['kind']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      loanId: loanId.isEmpty ? null : loanId,
      reference: json['reference']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class StatementEmailResult {
  final bool success;
  final String message;

  StatementEmailResult({required this.success, required this.message});
}

class AccountTransactions {
  final double availableBalance;
  final double totalCredits;
  final double totalDebits;
  final List<AccountTransaction> entries;

  AccountTransactions({
    required this.availableBalance,
    required this.totalCredits,
    required this.totalDebits,
    required this.entries,
  });

  factory AccountTransactions.fromJson(Map<String, dynamic> json) {
    final rows = json['entries'] as List? ?? const [];
    return AccountTransactions(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0,
      totalDebits: (json['totalDebits'] as num?)?.toDouble() ?? 0,
      entries: rows
          .whereType<Map>()
          .map((row) =>
              AccountTransaction.fromJson(Map<String, dynamic>.from(row)))
          .toList(),
    );
  }
}
