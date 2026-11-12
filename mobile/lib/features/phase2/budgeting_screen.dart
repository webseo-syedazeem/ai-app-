import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class BudgetingScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const BudgetingScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
  });

  @override
  State<BudgetingScreen> createState() => _BudgetingScreenState();
}

class _BudgetingScreenState extends State<BudgetingScreen> {
  // 0 = Daily, 1 = Monthly (default for continuity), 2 = Total & Folders
  int _mode = 1;
  int _prevMode = 1;

  AppState get appState => widget.appState;

  void _selectMode(int next) {
    if (next == _mode) return;
    setState(() {
      _prevMode = _mode;
      _mode = next;
    });
  }

  int _spentFor(String category, {String? period}) {
    return appState.expenses
        .where((e) =>
            e.category.toLowerCase() == category.toLowerCase() &&
            (period == null || e.period == period))
        .fold<int>(0, (s, e) => s + e.amount);
  }

  String _fmt(int n) {
    final neg = n < 0;
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return neg ? '-$buf' : buf.toString();
  }

  String _currentMonthHeader() {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[DateTime.now().month - 1]} BUDGET';
  }

  TileTone _toneFromName(String tone) {
    return switch (tone) {
      'emerald' => TileTone.emerald,
      'amber' => TileTone.amber,
      'rose' => TileTone.rose,
      _ => TileTone.indigo,
    };
  }

  AppIconType _iconForFolder(String period, String tone) {
    if (period == 'daily') return AppIconType.clock;
    if (tone == 'amber') return AppIconType.calendar;
    if (tone == 'rose') return AppIconType.heart;
    return AppIconType.bookmark;
  }

  @override
  Widget build(BuildContext context) {
    final defaultPeriod = _mode == 0 ? 'daily' : 'monthly';
    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
              title: 'Smart budgeting',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _mode == 2
                    ? _showCreateFolderSheet(context)
                    : _showAddExpense(context, initialPeriod: defaultPeriod),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 6, 25, 6),
              child: _BudgetModeSwitcher(
                activeIndex: _mode,
                onChanged: _selectMode,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Phase2Pill(),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey('heading_$_mode'),
                        child: switch (_mode) {
                          0 => const HeroHeading(
                              plainLine: 'Track your',
                              emphasizedLine: 'daily spending.',
                            ),
                          2 => const HeroHeading(
                              plainLine: 'Totals &',
                              emphasizedLine: 'smart folders.',
                            ),
                          _ => const HeroHeading(
                              plainLine: 'Know where',
                              emphasizedLine: 'money goes.',
                            ),
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 340),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        final dir = _mode >= _prevMode ? 0.06 : -0.06;
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(dir, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey('body_$_mode'),
                        child: switch (_mode) {
                          0 => _buildPeriodDashboard(context, isDaily: true),
                          2 => _buildTotalAndFoldersView(context),
                          _ => _buildPeriodDashboard(context, isDaily: false),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodDashboard(BuildContext context, {required bool isDaily}) {
    final period = isDaily ? 'daily' : 'monthly';
    final periodItems = isDaily ? appState.dailyExpenses : appState.monthlyExpenses;
    final spent = isDaily ? appState.dailyBudgetSpent : appState.monthlyBudgetSpent;
    final limit = isDaily ? appState.dailyBudgetLimit : appState.monthlyBudgetLimit;
    final ratio = (spent / (limit == 0 ? 1 : limit)).clamp(0.0, 1.0);
    final header = isDaily ? 'TODAY’S DAILY SPENDING' : _currentMonthHeader();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredReveal(
          index: 0,
          child: PremiumCard(
            soft: true,
            onTap: () => _showEditBudgetLimit(context, isDaily: isDaily),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      header,
                      style: AppTheme.inter(
                        size: 10,
                        weight: FontWeight.w800,
                        color: const Color(0xFF7F87B1),
                        letterSpacing: 1,
                      ),
                    ),
                    const AppVectorIcon(
                      AppIconType.editPen,
                      size: 14,
                      color: Color(0xFF7F87B1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _AnimatedRsCounter(
                          amount: limit,
                          formatter: _fmt,
                          style: AppTheme.inter(size: 28, weight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: limit >= spent ? AppColors.tileEmerald : AppColors.tileRose,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        limit >= spent
                            ? 'Rs. ${_fmt(limit - spent)} left'
                            : 'Over Rs. ${_fmt(spent - limit)}',
                        style: AppTheme.inter(
                          size: 10.5,
                          weight: FontWeight.w700,
                          color: limit >= spent ? AppColors.greenText : AppColors.roseAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs. ${_fmt(spent)} spent of Rs. ${_fmt(limit)} (${periodItems.length} ${periodItems.length == 1 ? 'entry' : 'entries'})',
                  style: AppTheme.inter(
                    size: 12,
                    weight: FontWeight.w600,
                    color: const Color(0xFF6B7094),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (_, c) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: ratio),
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, _) => Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.barTrack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: c.maxWidth * val,
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: AppGradients.progressFill,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniPillAction(
                        icon: AppIconType.bookmark,
                        label: 'Save to folder',
                        onTap: () => _showSaveSummaryToFolder(
                          context,
                          defaultTitle: isDaily ? 'Daily spending total' : 'Monthly spending total',
                          defaultAmount: spent > 0 ? spent : 500,
                          period: period,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniPillAction(
                        icon: AppIconType.sparkle,
                        label: 'View calculation',
                        onTap: () => _selectMode(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionLabelRow(label: 'BY CATEGORY'),
        StaggeredReveal(
          index: 1,
          child: PremiumCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                _BudgetCategoryRow(
                  icon: AppIconType.shoppingCart,
                  tone: TileTone.emerald,
                  title: 'Groceries',
                  subtitle: 'Rs. ${_fmt(_spentFor('Groceries', period: period))} spent',
                  ratio: limit == 0
                      ? 0
                      : (_spentFor('Groceries', period: period) / limit).clamp(0.0, 1.0),
                  barColor: AppColors.greenSuccess,
                  onTap: () => _showCategorySheet(context, 'Groceries', period: period),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _BudgetCategoryRow(
                  icon: AppIconType.wallet,
                  tone: TileTone.amber,
                  title: 'Bills',
                  subtitle: 'Rs. ${_fmt(_spentFor('Bills', period: period))} spent',
                  ratio: limit == 0
                      ? 0
                      : (_spentFor('Bills', period: period) / limit).clamp(0.0, 1.0),
                  barColor: AppColors.amberAccent,
                  onTap: () => _showCategorySheet(context, 'Bills', period: period),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _BudgetCategoryRow(
                  icon: AppIconType.heart,
                  tone: TileTone.rose,
                  title: 'Personal',
                  subtitle: 'Rs. ${_fmt(_spentFor('Personal', period: period))} spent',
                  ratio: limit == 0
                      ? 0
                      : (_spentFor('Personal', period: period) / limit).clamp(0.0, 1.0),
                  barColor: AppColors.roseAccent,
                  onTap: () => _showCategorySheet(context, 'Personal', period: period),
                ),
              ],
            ),
          ),
        ),
        if (periodItems.isNotEmpty) ...[
          SectionLabelRow(label: isDaily ? 'TODAY’S LOG' : 'MONTHLY ENTRIES'),
          StaggeredReveal(
            index: 2,
            child: PremiumCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  for (int i = 0; i < periodItems.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.divider),
                    _ExpenseRow(
                      item: periodItems[i],
                      fmt: _fmt,
                      onDelete: () {
                        final title = periodItems[i].title;
                        appState.deleteExpense(periodItems[i].id);
                        showAppToast(context, 'Removed “$title”');
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SectionLabelRow(label: 'QUICK ACTIONS'),
        StaggeredReveal(
          index: 3,
          child: PremiumCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                _QuickActionRow(
                  icon: AppIconType.plus,
                  title: isDaily ? 'Record daily expense' : 'Record an expense',
                  subtitle: isDaily ? '“Spent Rs. 450 on coffee”' : '“Spent Rs. 750 on lunch”',
                  onTap: () => _showAddExpense(context, initialPeriod: period),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _QuickActionRow(
                  icon: AppIconType.refresh,
                  title: isDaily ? 'Add daily coffee & snacks' : 'Use last month’s template',
                  subtitle: isDaily
                      ? 'Quick add everyday Rs. 500 spend'
                      : 'Start with previous entries',
                  onTap: () {
                    if (isDaily) {
                      appState.addExpense('Daily tea & snacks', 500, 'Personal', period: 'daily');
                      showAppToast(context, 'Added Daily tea & snacks (Rs. 500)');
                    } else {
                      appState.addExpense('Monthly Internet', 2500, 'Bills', period: 'monthly');
                      showAppToast(context, 'Added Monthly Internet (Rs. 2,500) to Bills');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAndFoldersView(BuildContext context) {
    final dailySpent = appState.dailyBudgetSpent;
    final monthlySpent = appState.monthlyBudgetSpent;
    final grandTotal = appState.totalBudgetSpent;
    final budgetCap = appState.monthlyBudgetLimit;
    final remaining = budgetCap - grandTotal;
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final safePerDay = remaining > 0 ? (remaining / daysLeft).round() : 0;
    final dailyPct = grandTotal == 0 ? 0.5 : (dailySpent / grandTotal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grand Total Calculation Card
        StaggeredReveal(
          index: 0,
          child: PremiumCard(
            soft: true,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL CALCULATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.inter(
                          size: 10,
                          weight: FontWeight.w800,
                          color: const Color(0xFF7F87B1),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: remaining >= 0 ? AppColors.tileEmerald : AppColors.tileRose,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          remaining >= 0
                              ? 'Rs. ${_fmt(remaining)} left'
                              : 'Over Rs. ${_fmt(remaining.abs())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(
                            size: 10,
                            weight: FontWeight.w700,
                            color: remaining >= 0 ? AppColors.greenText : AppColors.roseAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _AnimatedRsCounter(
                    amount: grandTotal,
                    formatter: _fmt,
                    style: AppTheme.inter(size: 31, weight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Combined spending across ${appState.expenses.length} total entries',
                  style: AppTheme.inter(size: 11.5, color: const Color(0xFF6B7094)),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _CalcLine(
                        label: 'Daily spending (${appState.dailyExpenses.length})',
                        value: 'Rs. ${_fmt(dailySpent)}',
                        dotColor: AppColors.greenSuccess,
                      ),
                      const SizedBox(height: 7),
                      _CalcLine(
                        label: '+ Monthly spending (${appState.monthlyExpenses.length})',
                        value: 'Rs. ${_fmt(monthlySpent)}',
                        dotColor: AppColors.indigoEm,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: AppColors.divider),
                      ),
                      _CalcLine(
                        label: '= Combined Total',
                        value: 'Rs. ${_fmt(grandTotal)}',
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (_, c) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: dailyPct),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 8,
                        color: AppColors.indigoEm,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: c.maxWidth * val,
                            height: 8,
                            color: AppColors.greenSuccess,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily ${(dailyPct * 100).round()}%',
                      style: AppTheme.inter(
                        size: 10.5,
                        weight: FontWeight.w700,
                        color: AppColors.greenText,
                      ),
                    ),
                    Text(
                      'Monthly ${(100 - (dailyPct * 100).round())}%',
                      style: AppTheme.inter(
                        size: 10.5,
                        weight: FontWeight.w700,
                        color: AppColors.indigoEm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        title: 'Safe daily allowance',
                        value: 'Rs. ${_fmt(safePerDay)}/day',
                        sub: '$daysLeft days left',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        title: 'Daily limit pace',
                        value: 'Rs. ${_fmt(appState.dailyBudgetLimit)}/day',
                        sub: 'Goal cap',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniPillAction(
                        icon: AppIconType.bookmark,
                        label: 'Save to folder',
                        primary: true,
                        onTap: () => _showSaveSummaryToFolder(
                          context,
                          defaultTitle: 'Combined budget total',
                          defaultAmount: grandTotal > 0 ? grandTotal : 1000,
                          period: 'monthly',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniPillAction(
                        icon: AppIconType.sparkle,
                        label: 'Quick calculator',
                        onTap: () => _showQuickCalculatorSheet(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SectionLabelRow(
          label: 'SAVED FOLDERS & REMINDERS',
          actionText: '+ New folder',
          onAction: () => _showCreateFolderSheet(context),
        ),
        if (appState.budgetFolders.isEmpty)
          StaggeredReveal(
            index: 1,
            child: PremiumCard(
              padding: const EdgeInsets.all(18),
              onTap: () => _showCreateFolderSheet(context),
              child: Row(
                children: [
                  const TileIconBox(icon: AppIconType.bookmark, tone: TileTone.indigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create your first budget folder',
                          style: AppTheme.inter(size: 13, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Group daily or monthly calculations and attach reminders.',
                          style: AppTheme.inter(size: 11, color: AppColors.subText),
                        ),
                      ],
                    ),
                  ),
                  const AppVectorIcon(AppIconType.plus, size: 18, color: AppColors.indigoEm),
                ],
              ),
            ),
          ),
        for (int i = 0; i < appState.budgetFolders.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StaggeredReveal(
              index: i + 1,
              child: _FolderCard(
                folder: appState.budgetFolders[i],
                itemsCount: appState.expensesInFolder(appState.budgetFolders[i].id).length,
                totalAmount: appState.folderTotal(appState.budgetFolders[i].id),
                fmt: _fmt,
                tone: _toneFromName(appState.budgetFolders[i].tone),
                icon: _iconForFolder(
                  appState.budgetFolders[i].period,
                  appState.budgetFolders[i].tone,
                ),
                onTap: () => _showFolderDetailSheet(context, appState.budgetFolders[i]),
                onSetReminder: () => _showFolderReminderSheet(context, appState.budgetFolders[i]),
              ),
            ),
          ),
      ],
    );
  }

  void _showEditBudgetLimit(BuildContext context, {required bool isDaily}) {
    final current = isDaily ? appState.dailyBudgetLimit : appState.monthlyBudgetLimit;
    final limitCtrl = TextEditingController(text: current.toString());
    final presets = isDaily ? const [1000, 2000, 3500] : const [30000, 50000, 75000];
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDaily ? 'Daily spending limit' : 'Monthly budget limit',
            style: AppTheme.inter(size: 18, weight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: limitCtrl,
            label: 'Budget limit (Rs.)',
            hint: isDaily ? 'e.g. 2000' : 'e.g. 50000',
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final preset in presets)
                AppChip(
                  label: 'Rs. ${_fmt(preset)}',
                  active: false,
                  onTap: () => limitCtrl.text = preset.toString(),
                ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Update limit',
            onTap: () {
              final next = int.tryParse(limitCtrl.text.trim()) ?? 0;
              if (next > 0) {
                if (isDaily) {
                  appState.setDailyBudgetLimit(next);
                } else {
                  appState.setMonthlyBudgetLimit(next);
                }
                Navigator.pop(ctx);
                showAppToast(
                  context,
                  '${isDaily ? 'Daily' : 'Monthly'} budget set to Rs. ${_fmt(next)}',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context, String category, {String? period}) {
    final items = appState.expenses
        .where((e) =>
            e.category.toLowerCase() == category.toLowerCase() &&
            (period == null || e.period == period))
        .toList();
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$category expenses', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Rs. ${_fmt(_spentFor(category, period: period))} spent (${period ?? 'all'})',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'No expenses recorded in $category yet.',
                style: AppTheme.inter(size: 12.5, color: AppColors.mutedText),
              ),
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTheme.inter(size: 13.5, weight: FontWeight.w700)),
                        Text(
                          'Rs. ${_fmt(item.amount)}${item.folderName != null ? ' · Folder: ${item.folderName}' : ''}',
                          style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      appState.deleteExpense(item.id);
                      Navigator.pop(ctx);
                      showAppToast(context, 'Removed “${item.title}”');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: AppVectorIcon(
                        AppIconType.trash,
                        size: 17,
                        color: Color(0xFFD65A5A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Add $category expense',
            onTap: () {
              Navigator.pop(ctx);
              _showAddExpense(
                context,
                initialCategory: category,
                initialPeriod: period ?? 'monthly',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddExpense(
    BuildContext context, {
    String initialCategory = 'Personal',
    String initialPeriod = 'monthly',
    String? initialFolderId,
  }) {
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String cat = initialCategory;
    String period = initialPeriod;
    String? selectedFolderId = initialFolderId;

    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record expense', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                AppChip(
                  label: 'Daily',
                  active: period == 'daily',
                  onTap: () => setModalState(() => period = 'daily'),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: 'Monthly',
                  active: period == 'monthly',
                  onTap: () => setModalState(() => period = 'monthly'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: titleCtrl,
              label: 'What did you spend on?',
              hint: 'e.g. Fresh groceries or lunch',
              autofocus: true,
            ),
            const SizedBox(height: 10),
            PremiumSheetField(
              controller: amtCtrl,
              label: 'Amount (Rs.)',
              hint: 'e.g. 750',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in const ['Groceries', 'Bills', 'Personal'])
                  AppChip(
                    label: c,
                    active: cat == c,
                    onTap: () => setModalState(() => cat = c),
                  ),
              ],
            ),
            if (appState.budgetFolders.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Save in folder (optional)',
                style: AppTheme.inter(size: 11.5, weight: FontWeight.w700, color: AppColors.mutedText),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppChip(
                    label: 'No folder',
                    active: selectedFolderId == null,
                    onTap: () => setModalState(() => selectedFolderId = null),
                  ),
                  for (final f in appState.budgetFolders)
                    AppChip(
                      label: f.name,
                      active: selectedFolderId == f.id,
                      onTap: () => setModalState(() => selectedFolderId = f.id),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save ${period == 'daily' ? 'daily' : 'monthly'} expense',
              onTap: () {
                final title = titleCtrl.text.trim().isEmpty ? '$cat expense' : titleCtrl.text.trim();
                final amount = int.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amount <= 0) return;
                String? folderName;
                if (selectedFolderId != null) {
                  final match = appState.budgetFolders.where((f) => f.id == selectedFolderId);
                  if (match.isNotEmpty) folderName = match.first.name;
                }
                appState.addExpense(
                  title,
                  amount,
                  cat,
                  period: period,
                  folderId: selectedFolderId,
                  folderName: folderName,
                );
                Navigator.pop(ctx);
                showAppToast(
                  context,
                  'Saved Rs. ${_fmt(amount)} ($period${folderName != null ? ' · $folderName' : ''})',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveSummaryToFolder(
    BuildContext context, {
    required String defaultTitle,
    required int defaultAmount,
    required String period,
  }) {
    final labelCtrl = TextEditingController(text: defaultTitle);
    final amtCtrl = TextEditingController(text: defaultAmount.toString());
    final newFolderCtrl = TextEditingController();
    String? selectedFolderId =
        appState.budgetFolders.isNotEmpty ? appState.budgetFolders.first.id : null;
    bool createNew = appState.budgetFolders.isEmpty;
    bool alsoRemind = true;

    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Save calculation to folder', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Store this calculated total inside a folder and set an optional reminder.',
              style: AppTheme.inter(size: 12, color: AppColors.mutedText),
            ),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: labelCtrl,
              label: 'Calculation title',
              hint: 'e.g. Monthly house total',
            ),
            const SizedBox(height: 10),
            PremiumSheetField(
              controller: amtCtrl,
              label: 'Calculated amount (Rs.)',
              hint: 'e.g. 15500',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            if (appState.budgetFolders.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in appState.budgetFolders)
                    AppChip(
                      label: f.name,
                      active: !createNew && selectedFolderId == f.id,
                      onTap: () => setModalState(() {
                        createNew = false;
                        selectedFolderId = f.id;
                      }),
                    ),
                  AppChip(
                    label: '+ New folder',
                    active: createNew,
                    onTap: () => setModalState(() => createNew = true),
                  ),
                ],
              ),
            if (createNew) ...[
              const SizedBox(height: 10),
              PremiumSheetField(
                controller: newFolderCtrl,
                label: 'New folder name',
                hint: 'e.g. Family Utilities',
                autofocus: true,
              ),
            ],
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setModalState(() => alsoRemind = !alsoRemind),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  SquareCheck(checked: alsoRemind, onTap: () => setModalState(() => alsoRemind = !alsoRemind)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Remind me tomorrow at 9:00 AM',
                      style: AppTheme.inter(size: 12.5, weight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save to folder',
              onTap: () async {
                final amount = int.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amount <= 0) return;
                BudgetFolderModel folder;
                if (createNew || selectedFolderId == null) {
                  final fname = newFolderCtrl.text.trim().isEmpty
                      ? 'Saved Budgets'
                      : newFolderCtrl.text.trim();
                  folder = await appState.createBudgetFolder(fname, period: period);
                } else {
                  folder = appState.budgetFolders.firstWhere((f) => f.id == selectedFolderId);
                }
                final title = labelCtrl.text.trim().isEmpty ? defaultTitle : labelCtrl.text.trim();
                await appState.addExpense(
                  title,
                  amount,
                  'Bills',
                  period: period,
                  folderId: folder.id,
                  folderName: folder.name,
                );
                if (alsoRemind) {
                  final tomorrow = DateTime.now().add(const Duration(days: 1));
                  final when = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
                  await appState.setFolderReminder(folder.id, 'Tomorrow · 9:00 AM', when);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  showAppToast(
                    context,
                    'Saved Rs. ${_fmt(amount)} to ${folder.name}${alsoRemind ? ' with reminder' : ''}',
                  );
                }
                _selectMode(2);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    String period = 'all';
    String tone = 'indigo';
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New budget folder', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: nameCtrl,
              label: 'Folder name',
              hint: 'e.g. Monthly House Bills',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Folder type',
              style: AppTheme.inter(size: 11.5, weight: FontWeight.w700, color: AppColors.mutedText),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in const [('daily', 'Daily'), ('monthly', 'Monthly'), ('all', 'Combined')])
                  AppChip(
                    label: p.$2,
                    active: period == p.$1,
                    onTap: () => setModalState(() => period = p.$1),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Accent color',
              style: AppTheme.inter(size: 11.5, weight: FontWeight.w700, color: AppColors.mutedText),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final t in const [('indigo', 'Indigo'), ('emerald', 'Green'), ('amber', 'Amber'), ('rose', 'Rose')])
                  AppChip(
                    label: t.$2,
                    active: tone == t.$1,
                    onTap: () => setModalState(() => tone = t.$1),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Create folder',
              onTap: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                await appState.createBudgetFolder(name, period: period, tone: tone);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) showAppToast(context, 'Created folder “$name”');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderDetailSheet(BuildContext context, BudgetFolderModel folder) {
    final items = appState.expensesInFolder(folder.id);
    final total = appState.folderTotal(folder.id);
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TileIconBox(
                icon: _iconForFolder(folder.period, folder.tone),
                tone: _toneFromName(folder.tone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folder.name, style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
                    Text(
                      'Total: Rs. ${_fmt(total)} · ${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: AppTheme.inter(size: 12, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  appState.deleteBudgetFolder(folder.id);
                  Navigator.pop(ctx);
                  showAppToast(context, 'Deleted folder “${folder.name}”');
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: AppVectorIcon(AppIconType.trash, size: 18, color: Color(0xFFD65A5A)),
                ),
              ),
            ],
          ),
          if (folder.reminderLabel != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tileEmerald,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppVectorIcon(AppIconType.bell, size: 14, color: AppColors.greenText),
                  const SizedBox(width: 6),
                  Text(
                    'Reminder: ${folder.reminderLabel}',
                    style: AppTheme.inter(size: 11.5, weight: FontWeight.w700, color: AppColors.greenText),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'No expenses saved in this folder yet.',
                style: AppTheme.inter(size: 12.5, color: AppColors.mutedText),
              ),
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTheme.inter(size: 13.5, weight: FontWeight.w700)),
                        Text(
                          'Rs. ${_fmt(item.amount)} · ${item.period == 'daily' ? 'Daily' : 'Monthly'} · ${item.category}',
                          style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      appState.deleteExpense(item.id);
                      Navigator.pop(ctx);
                      showAppToast(context, 'Removed “${item.title}”');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: AppVectorIcon(AppIconType.trash, size: 16, color: Color(0xFFD65A5A)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniPillAction(
                  icon: AppIconType.bell,
                  label: folder.reminderLabel == null ? 'Set reminder' : 'Edit reminder',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showFolderReminderSheet(context, folder);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniPillAction(
                  icon: AppIconType.plus,
                  label: 'Add to folder',
                  primary: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddExpense(
                      context,
                      initialPeriod: folder.period == 'daily' ? 'daily' : 'monthly',
                      initialFolderId: folder.id,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFolderReminderSheet(BuildContext context, BudgetFolderModel folder) {
    final now = DateTime.now();
    final options = <(String, DateTime)>[
      ('Today · 8:00 PM', DateTime(now.year, now.month, now.day, 20, 0)),
      (
        'Tomorrow · 9:00 AM',
        DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 1))
      ),
      (
        'Weekly · Friday 5:00 PM',
        DateTime(now.year, now.month, now.day, 17, 0).add(const Duration(days: 7))
      ),
      (
        '1st of next month · 10:00 AM',
        DateTime(now.year, now.month + 1, 1, 10, 0)
      ),
    ];
    final customCtrl = TextEditingController();

    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remind me about “${folder.name}”', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Schedules a real device reminder synced to your Reminders list.',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          for (final opt in options)
            SheetActionRow(
              icon: AppIconType.bell,
              title: opt.$1,
              onTap: () async {
                await appState.setFolderReminder(folder.id, opt.$1, opt.$2);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  showAppToast(context, 'Reminder set for ${folder.name} (${opt.$1})');
                }
              },
            ),
          const SizedBox(height: 4),
          PremiumSheetField(
            controller: customCtrl,
            label: 'Or custom note & time',
            hint: 'e.g. Every Sunday at 6:00 PM',
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Save custom reminder',
            onTap: () async {
              final label = customCtrl.text.trim().isEmpty
                  ? 'Tomorrow · 9:00 AM'
                  : customCtrl.text.trim();
              final when = DateTime.now().add(const Duration(days: 1));
              await appState.setFolderReminder(folder.id, label, when);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) showAppToast(context, 'Reminder saved ($label)');
            },
          ),
        ],
      ),
    );
  }

  void _showQuickCalculatorSheet(BuildContext context) {
    final extraCtrl = TextEditingController(text: '0');
    bool includeDaily = true;
    bool includeMonthly = true;

    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => ValueListenableBuilder<TextEditingValue>(
          valueListenable: extraCtrl,
          builder: (_, _, _) {
            final daily = includeDaily ? appState.dailyBudgetSpent : 0;
            final monthly = includeMonthly ? appState.monthlyBudgetSpent : 0;
            final extra = int.tryParse(extraCtrl.text.trim()) ?? 0;
            final total = daily + monthly + extra;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget Calculator', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Combine daily, monthly, and extra amounts cleanly.',
                  style: AppTheme.inter(size: 12, color: AppColors.mutedText),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CALCULATED TOTAL',
                        style: AppTheme.inter(
                          size: 10,
                          weight: FontWeight.w800,
                          color: AppColors.mutedText,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _AnimatedRsCounter(
                        amount: total,
                        formatter: _fmt,
                        style: AppTheme.inter(size: 26, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(
                      label: 'Daily (Rs. ${_fmt(appState.dailyBudgetSpent)})',
                      active: includeDaily,
                      onTap: () => setModalState(() => includeDaily = !includeDaily),
                    ),
                    AppChip(
                      label: 'Monthly (Rs. ${_fmt(appState.monthlyBudgetSpent)})',
                      active: includeMonthly,
                      onTap: () => setModalState(() => includeMonthly = !includeMonthly),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PremiumSheetField(
                  controller: extraCtrl,
                  label: 'Add extra amount (Rs.)',
                  hint: 'e.g. 1500',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save Rs. ${_fmt(total)} to folder',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSaveSummaryToFolder(
                      context,
                      defaultTitle: 'Calculated budget batch',
                      defaultAmount: total > 0 ? total : 500,
                      period: includeDaily && !includeMonthly ? 'daily' : 'monthly',
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BudgetModeSwitcher extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const _BudgetModeSwitcher({
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily', 'Monthly', 'Total & Folders'];
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder, width: 1.15),
        boxShadow: AppShadows.choose,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / 3;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: slotWidth * activeIndex,
                top: 0,
                bottom: 0,
                width: slotWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryBtn,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: AppShadows.button,
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTheme.inter(
                              size: 11.8,
                              weight: FontWeight.w700,
                              color: activeIndex == i ? Colors.white : AppColors.mutedText,
                            ),
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedRsCounter extends StatelessWidget {
  final int amount;
  final String Function(int) formatter;
  final TextStyle style;

  const _AnimatedRsCounter({
    required this.amount,
    required this.formatter,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount.toDouble()),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (_, val, _) => Text('Rs. ${formatter(val.round())}', style: style),
    );
  }
}

class _MiniPillAction extends StatelessWidget {
  final AppIconType icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _MiniPillAction({
    required this.icon,
    required this.label,
    this.primary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: primary ? AppGradients.primaryBtn : null,
          color: primary ? null : AppColors.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: primary ? const Color(0x28FFFFFF) : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppVectorIcon(
              icon,
              size: 14,
              color: primary ? Colors.white : AppColors.indigoEm,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.inter(
                  size: 11.2,
                  weight: FontWeight.w700,
                  color: primary ? Colors.white : AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? dotColor;
  final bool bold;

  const _CalcLine({
    required this.label,
    required this.value,
    this.dotColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.inter(
                    size: 12,
                    weight: bold ? FontWeight.w800 : FontWeight.w600,
                    color: bold ? AppColors.navy : AppColors.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTheme.inter(
            size: bold ? 13 : 12,
            weight: FontWeight.w800,
            color: bold ? AppColors.indigoEm : AppColors.navy,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String sub;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTheme.inter(size: 13.5, weight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(sub, style: AppTheme.inter(size: 10, color: AppColors.indigoEm, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final BudgetFolderModel folder;
  final int itemsCount;
  final int totalAmount;
  final String Function(int) fmt;
  final TileTone tone;
  final AppIconType icon;
  final VoidCallback onTap;
  final VoidCallback onSetReminder;

  const _FolderCard({
    required this.folder,
    required this.itemsCount,
    required this.totalAmount,
    required this.fmt,
    required this.tone,
    required this.icon,
    required this.onTap,
    required this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final hasReminder = folder.reminderLabel != null && folder.reminderLabel!.isNotEmpty;
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TileIconBox(icon: icon, tone: tone),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folder.name, style: AppTheme.inter(size: 13.5, weight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      '$itemsCount ${itemsCount == 1 ? 'item' : 'items'} · ${folder.period == 'daily' ? 'Daily folder' : folder.period == 'monthly' ? 'Monthly folder' : 'Combined folder'}',
                      style: AppTheme.inter(size: 11, color: AppColors.subText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${fmt(totalAmount)}',
                    style: AppTheme.inter(size: 14, weight: FontWeight.w800, color: AppColors.navy),
                  ),
                  const SizedBox(height: 2),
                  const AppVectorIcon(AppIconType.chevronRight, size: 15, color: Color(0xFF74788C)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: BouncyTap(
                  onTap: onSetReminder,
                  pressedScale: 0.94,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasReminder ? AppColors.tileEmerald : AppColors.tileBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppVectorIcon(
                          AppIconType.bell,
                          size: 12.5,
                          color: hasReminder ? AppColors.greenText : AppColors.indigoEm,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            hasReminder ? 'Remind: ${folder.reminderLabel}' : 'Set reminder',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.inter(
                              size: 10.8,
                              weight: FontWeight.w700,
                              color: hasReminder ? AppColors.greenText : AppColors.indigoEm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Open',
                style: AppTheme.inter(size: 10.5, color: AppColors.subText, weight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final ExpenseModel item;
  final String Function(int) fmt;
  final VoidCallback onDelete;

  const _ExpenseRow({
    required this.item,
    required this.fmt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          TileIconBox(
            icon: item.period == 'daily' ? AppIconType.clock : AppIconType.wallet,
            tone: item.period == 'daily' ? TileTone.emerald : TileTone.indigo,
            size: 36,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTheme.inter(size: 12.5, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${item.category}${item.folderName != null ? ' · Folder: ${item.folderName}' : ''}',
                  style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                ),
              ],
            ),
          ),
          Text('Rs. ${fmt(item.amount)}', style: AppTheme.inter(size: 12.5, weight: FontWeight.w700)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: AppVectorIcon(AppIconType.trash, size: 15, color: Color(0xFFD65A5A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            TileIconBox(icon: icon),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                ],
              ),
            ),
            const AppVectorIcon(
              AppIconType.chevronRight,
              size: 17,
              color: Color(0xFF74788C),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryRow extends StatelessWidget {
  final AppIconType icon;
  final TileTone tone;
  final String title;
  final String subtitle;
  final double ratio;
  final Color barColor;
  final VoidCallback onTap;

  const _BudgetCategoryRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.ratio,
    required this.barColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.985,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            TileIconBox(icon: icon, tone: tone),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(size: 12.5, weight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.inter(size: 11, color: AppColors.mutedText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (_, c) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: ratio),
                      duration: const Duration(milliseconds: 560),
                      curve: Curves.easeOutCubic,
                      builder: (_, val, _) => Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.barTrack,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: c.maxWidth * val,
                            height: 5,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const AppVectorIcon(
              AppIconType.moreDots,
              size: 17,
              color: Color(0xFF74788C),
            ),
          ],
        ),
      ),
    );
  }
}
