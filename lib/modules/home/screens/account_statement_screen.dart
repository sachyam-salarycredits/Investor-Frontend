import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:peerbridge/modules/marketplace/models/account_transactions.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:provider/provider.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({Key? key}) : super(key: key);

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  AccountTransactions? _data;
  bool _loading = true;
  int _tab = 0;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _load(includeStatements: true);
  }

  Future<void> _load({bool includeStatements = false}) async {
    final provider = context.read<AppStateProvider>();
    final transactions =
        provider.getAccountTransactions(from: _from, to: _to);
    if (includeStatements) {
      final results = await Future.wait<dynamic>([
        transactions,
        provider.getStatement(),
      ]);
      if (!mounted) return;
      setState(() {
        _data = results.first as AccountTransactions?;
        _loading = false;
      });
      return;
    }
    final data = await transactions;
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  void _openFilter() {
    showPbBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _DateFilterSheet(
        from: _from,
        to: _to,
        onApply: (from, to) {
          Navigator.of(sheetContext).pop();
          setState(() {
            _from = from;
            _to = to;
          });
          _load();
        },
      ),
    );
  }

  List<AccountTransaction> get _visibleEntries {
    final entries = _data?.entries ?? const <AccountTransaction>[];
    if (_tab == 1) return entries.where((e) => e.isCredit).toList();
    if (_tab == 2) return entries.where((e) => !e.isCredit).toList();
    return entries;
  }

  static String _rupees(double value) {
    final digits = value == value.truncateToDouble() ? 0 : 2;
    return '₹${value.commaAddedValue(digit: digits)}';
  }

  static int _currentFyEnd() {
    final now = DateTime.now();
    return now.month >= 4 ? now.year + 1 : now.year;
  }

  List<int> _statementYears() {
    final years = context
        .read<AppStateProvider>()
        .statementList
        .map((s) => int.tryParse(s.year.trim()) ?? 0)
        .where((y) => y > 0)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years.isEmpty ? [_currentFyEnd()] : years;
  }

  void _openEmailSheet({int? year}) {
    final provider = context.read<AppStateProvider>();
    final email = provider.userDetails?.profileDetails?.email ?? '';
    showPbBottomSheet<void>(
      context: context,
      builder: (_) => _EmailStatementSheet(
        email: email,
        years: _statementYears(),
        initialYear: year,
        onSend: (fyEnd) => provider.emailStatement(year: fyEnd),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PbPageHeader(
        title: 'Account statement',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            onPressed: _openEmailSheet,
            tooltip: 'Email statement',
            icon: const Icon(Icons.mail_outline_rounded, color: Colors.white),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green))
          : RefreshIndicator(
              color: AppColors.green,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
                children: [
                  _centered(_content()),
                ],
              ),
            ),
    );
  }

  Widget _centered(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }

  Widget _content() {
    final data = _data;
    final entries = _visibleEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BalanceCard(
          amount: _rupees(data?.availableBalance ?? Utils.availableAmount),
          month: DateFormat('MMM yyyy').format(DateTime.now()),
        ),
        const SizedBox(height: 14),
        const _AlertsCard(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SummaryTile(
                label: 'Total credits',
                value: '+${_rupees(data?.totalCredits ?? 0)}',
                positive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryTile(
                label: 'Total debits',
                value: '−${_rupees(data?.totalDebits ?? 0)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SegmentedTabs(
          tabs: const [
            SegmentedTab('All'),
            SegmentedTab('Credit'),
            SegmentedTab('Debit'),
          ],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 18),
        _filterButton(),
        const SizedBox(height: 16),
        _transactionsHeader(entries),
        const SizedBox(height: 12),
        if (data == null)
          const PbEmptyState(
            icon: Icons.cloud_off_rounded,
            message: 'We could not load your transactions. Pull to retry.',
          )
        else if (entries.isEmpty)
          PbEmptyState(
            icon: Icons.receipt_long_outlined,
            message: _from != null || _to != null
                ? 'No transactions in this date range.'
                : 'No transactions to show yet.',
          )
        else
          PbCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, thickness: 1, color: AppColors.line),
                  _TransactionRow(entry: entries[i], amount: _rupees),
                ],
              ],
            ),
          ),
        const SizedBox(height: 26),
        _statementsSection(),
      ],
    );
  }

  Widget _filterButton() {
    final hasRange = _from != null || _to != null;
    final range = [
      if (_from != null) DateFormat('d MMM yyyy').format(_from!),
      if (_to != null) DateFormat('d MMM yyyy').format(_to!),
    ].join(' - ');
    return Row(
      children: [
        InkWell(
          onTap: _openFilter,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter',
                  style: AppTextStyles.medium(
                    15,
                    color: hasRange ? AppColors.green : AppColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: hasRange ? AppColors.green : AppColors.greenDeep,
                ),
              ],
            ),
          ),
        ),
        if (hasRange) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              range,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.medium(12, color: AppColors.green),
            ),
          ),
        ],
      ],
    );
  }

  Widget _transactionsHeader(List<AccountTransaction> entries) {
    final latest = entries.isNotEmpty ? entries.first.createdAt : null;
    final period = _from != null || _to != null
        ? [
            if (_from != null) DateFormat('d MMM yyyy').format(_from!),
            if (_to != null) DateFormat('d MMM yyyy').format(_to!),
          ].join(' - ')
        : latest == null
            ? null
            : '${DateFormat('MMMM yyyy').format(latest)} and earlier';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transactions', style: AppTextStyles.semiBold(17)),
              if (period != null) ...[
                const SizedBox(height: 3),
                Text(period, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        Text(
          '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
          style: AppTextStyles.medium(12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _statementsSection() {
    final years = _statementYears();
    final statements = context.read<AppStateProvider>().statementList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Yearly statements', style: AppTextStyles.semiBold(17)),
        const SizedBox(height: 3),
        Text('Download or email a statement for any financial year',
            style: AppTextStyles.caption),
        const SizedBox(height: 12),
        PbCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < years.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, thickness: 1, color: AppColors.line),
                _StatementRow(
                  fyEnd: years[i],
                  onDownload: () {
                    final match = statements.where(
                        (s) => int.tryParse(s.year.trim()) == years[i]);
                    final url =
                        match.isEmpty ? '' : (match.first.statementUrl ?? '');
                    if (url.isEmpty) {
                      Utils.showToast(
                          msg: 'No statement available for this year yet');
                    } else {
                      Utils.launchURL(url);
                    }
                  },
                  onEmail: () => _openEmailSheet(year: years[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _fyLabel(int fyEnd) => 'FY ${fyEnd - 1}–${fyEnd.toString().substring(2)}';

class _DateFilterSheet extends StatefulWidget {
  final DateTime? from;
  final DateTime? to;
  final void Function(DateTime? from, DateTime? to) onApply;

  const _DateFilterSheet({
    required this.from,
    required this.to,
    required this.onApply,
  });

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.from;
    _to = widget.to;
  }

  Future<void> _pick({required bool isFrom}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = isFrom ? (_from ?? _to ?? today) : (_to ?? _from ?? today);
    final first = isFrom ? DateTime(2018) : (_from ?? DateTime(2018));
    final last = isFrom ? (_to ?? today) : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first)
          ? first
          : (initial.isAfter(last) ? last : initial),
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.green,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      final day = DateTime(picked.year, picked.month, picked.day);
      if (isFrom) {
        _from = day;
      } else {
        _to = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter', style: AppTextStyles.semiBold(18)),
          const SizedBox(height: 4),
          Text(
            'Choose a from and to date',
            style: AppTextStyles.regular(13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'From',
            value: _from == null
                ? 'Start date'
                : DateFormat('d MMM yyyy').format(_from!),
            onTap: () => _pick(isFrom: true),
          ),
          const SizedBox(height: 10),
          _DateField(
            label: 'To',
            value: _to == null
                ? 'End date'
                : DateFormat('d MMM yyyy').format(_to!),
            onTap: () => _pick(isFrom: false),
          ),
          const SizedBox(height: 18),
          PbPrimaryButton(
            label: 'Apply',
            onPressed: () => widget.onApply(_from, _to),
          ),
          if (_from != null || _to != null)
            TextButton(
              onPressed: () => widget.onApply(null, null),
              child: Text(
                'Clear dates',
                style: AppTextStyles.medium(14, color: AppColors.green),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.regular(11, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.medium(14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String amount;
  final String month;

  const _BalanceCard({required this.amount, required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Available balance',
                  style: AppTextStyles.regular(13,
                      color: Colors.white.withOpacity(0.78)),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(month,
                        style:
                            AppTextStyles.medium(11.5, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: AppTextStyles.semiBold(32, color: Colors.white)
                  .copyWith(letterSpacing: -0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PbIconTile(
            icon: Icons.notifications_active_outlined,
            background: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EMI alerts are on',
                    style: AppTextStyles.semiBold(13.5,
                        color: AppColors.greenDeep)),
                const SizedBox(height: 3),
                Text(
                  'Every EMI credit appears here with its loan ID, and '
                  'you\'ll get an email when it lands.',
                  style: AppTextStyles.regular(12, color: AppColors.forest)
                      .copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final AccountTransaction entry;
  final String Function(double) amount;

  const _TransactionRow({required this.entry, required this.amount});

  IconData get _icon {
    switch (entry.kind) {
      case 'EMI':
        return Icons.payments_outlined;
      case 'FUNDS_ADDED':
        return Icons.account_balance_wallet_outlined;
      case 'INVESTMENT':
        return Icons.trending_up_rounded;
      case 'WITHDRAWAL':
        return Icons.north_east_rounded;
      default:
        return Icons.swap_vert_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = entry.createdAt;
    final date = created == null ? '' : DateFormat('d MMM yyyy').format(created);
    final time = created == null ? '' : DateFormat('h:mm a').format(created);
    final subtitle = [
      if (entry.loanId != null) entry.loanId!,
      if (date.isNotEmpty) date,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PbIconTile(
            icon: _icon,
            size: 40,
            background: entry.isCredit ? AppColors.mint : AppColors.goldSoft,
            color: entry.isCredit ? AppColors.green : AppColors.goldDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(14),
                      ),
                    ),
                    if (entry.isEmi) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('EMI',
                            style: AppTextStyles.semiBold(9.5,
                                color: AppColors.green)),
                      ),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(12, color: AppColors.ink),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Ref: ${entry.reference}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular(11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.isCredit ? '+' : '−'}${amount(entry.amount)}',
                style: AppTextStyles.semiBold(14,
                    color: entry.isCredit ? AppColors.green : AppColors.ink),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(time,
                    style: AppTextStyles.regular(11, color: AppColors.muted)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatementRow extends StatelessWidget {
  final int fyEnd;
  final VoidCallback onDownload;
  final VoidCallback onEmail;

  const _StatementRow({
    required this.fyEnd,
    required this.onDownload,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
      child: Row(
        children: [
          const PbIconTile(icon: Icons.description_outlined, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fyLabel(fyEnd), style: AppTextStyles.semiBold(13.5)),
                const SizedBox(height: 2),
                Text('1 Apr ${fyEnd - 1} – 31 Mar $fyEnd',
                    style: AppTextStyles.regular(11, color: AppColors.muted)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
            tooltip: 'Download',
            icon: const Icon(Icons.download_rounded,
                size: 20, color: AppColors.green),
          ),
          IconButton(
            onPressed: onEmail,
            tooltip: 'Email statement',
            icon: const Icon(Icons.mail_outline_rounded,
                size: 20, color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

class _EmailStatementSheet extends StatefulWidget {
  final String email;
  final List<int> years;
  final int? initialYear;
  final Future<StatementEmailResult> Function(int fyEnd) onSend;

  const _EmailStatementSheet({
    required this.email,
    required this.years,
    required this.onSend,
    this.initialYear,
  });

  @override
  State<_EmailStatementSheet> createState() => _EmailStatementSheetState();
}

class _EmailStatementSheetState extends State<_EmailStatementSheet> {
  late int _year = widget.initialYear ?? widget.years.first;
  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    final result = await widget.onSend(_year);
    if (!mounted) return;
    setState(() => _sending = false);
    if (result.success) {
      Navigator.of(context).pop();
      Utils.showToast(
        msg: result.message.isNotEmpty
            ? result.message
            : 'Statement sent to ${widget.email}',
        bgColor: AppColors.greenDeep,
      );
    } else {
      Utils.showToast(
        msg: result.message.isNotEmpty
            ? result.message
            : 'Could not send the statement. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEmail = widget.email.trim().isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PbSheetTitle(
            eyebrow: 'Account statement',
            title: 'Email statement',
            subtitle: 'We\'ll send it as a CSV attachment',
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Financial year',
                    style: AppTextStyles.medium(12, color: AppColors.muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final year in widget.years)
                      ChoiceChip(
                        label: Text(_fyLabel(year)),
                        selected: _year == year,
                        onSelected: (_) => setState(() => _year = year),
                        selectedColor: AppColors.mint,
                        backgroundColor: AppColors.metricSurface,
                        side: BorderSide(
                          color: _year == year
                              ? AppColors.green
                              : AppColors.line,
                        ),
                        labelStyle: AppTextStyles.medium(12.5,
                            color: _year == year
                                ? AppColors.green
                                : AppColors.ink),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mintSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alternate_email_rounded,
                          size: 18, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hasEmail
                              ? widget.email
                              : 'Add an email address to your profile first',
                          style: AppTextStyles.medium(13,
                              color:
                                  hasEmail ? AppColors.ink : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PbPrimaryButton(
                  label: 'Send statement',
                  trailingIcon: Icons.send_rounded,
                  isLoading: _sending,
                  onPressed: hasEmail ? _send : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
