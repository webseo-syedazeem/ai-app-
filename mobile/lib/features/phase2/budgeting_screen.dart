import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class BudgetingScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const BudgetingScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
  });

  int _spentFor(String category) {
    return appState.expenses
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .fold<int>(0, (s, e) => s + e.amount);
  }

  String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final spent = appState.totalBudgetSpent;
    final limit = appState.monthlyBudgetLimit;
    final ratio = (spent / (limit == 0 ? 1 : limit)).clamp(0.0, 1.0);

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Smart budgeting',
              right: GestureDetector(
                onTap: () => _showAddExpense(context),
                child: const AppVectorIcon(AppIconType.plus, size: 21),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Phase2Pill(),
                    const SizedBox(height: 12),
                    const HeroHeading(
                      plainLine: 'Know where',
                      emphasizedLine: 'money goes.',
                    ),
                    const SizedBox(height: 16),
                    PremiumCard(
                      soft: true,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOVEMBER BUDGET',
                            style: AppTheme.inter(
                              size: 10,
                              weight: FontWeight.w800,
                              color: const Color(0xFF7F87B1),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Rs. ${_fmt(limit)}',
                            style: AppTheme.inter(size: 28, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rs. ${_fmt(spent)} spent of Rs. ${_fmt(limit)}',
                            style: AppTheme.inter(
                              size: 11.5,
                              color: const Color(0xFF8588A9),
                            ),
                          ),
                          const SizedBox(height: 18),
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
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'BY CATEGORY'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          _BudgetCategoryRow(
                            icon: AppIconType.shoppingCart,
                            title: 'Groceries',
                            subtitle: 'Rs. ${_fmt(_spentFor('Groceries'))} spent',
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _BudgetCategoryRow(
                            icon: AppIconType.wallet,
                            title: 'Bills',
                            subtitle: 'Rs. ${_fmt(_spentFor('Bills'))} spent',
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _BudgetCategoryRow(
                            icon: AppIconType.heart,
                            title: 'Personal',
                            subtitle: 'Rs. ${_fmt(_spentFor('Personal'))} spent',
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'QUICK ACTIONS'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showAddExpense(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 62),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const TileIconBox(icon: AppIconType.plus),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Record an expense',
                                            style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                                        const SizedBox(height: 3),
                                        Text('“Spent Rs. 750 on lunch”',
                                            style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                                      ],
                                    ),
                                  ),
                                  const AppVectorIcon(
                                      AppIconType.chevronRight, size: 17, color: Color(0xFF74788C)),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          GestureDetector(
                            onTap: () => appState.addExpense('Monthly Internet', 2500, 'Bills'),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 62),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const TileIconBox(icon: AppIconType.refresh),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Use last month’s template',
                                            style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                                        const SizedBox(height: 3),
                                        Text('Start with previous entries',
                                            style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                                      ],
                                    ),
                                  ),
                                  const AppVectorIcon(
                                      AppIconType.chevronRight, size: 17, color: Color(0xFF74788C)),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  void _showAddExpense(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Lunch');
    final amtCtrl = TextEditingController(text: '750');
    String cat = 'Personal';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text('Record expense', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Title')),
              const SizedBox(height: 8),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Amount (Rs.)'),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  for (final c in const ['Groceries', 'Bills', 'Personal'])
                    AppChip(
                      label: c,
                      active: cat == c,
                      onTap: () => setModalState(() => cat = c),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amtCtrl.text.trim()) ?? 0;
                if (amount > 0) {
                  appState.addExpense(titleCtrl.text.trim(), amount, cat);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryRow extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String subtitle;

  const _BudgetCategoryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const AppVectorIcon(AppIconType.moreDots, size: 18, color: Color(0xFF74788C)),
        ],
      ),
    );
  }
}
