import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class ShoppingScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback onOpenVoice;

  const ShoppingScreen({
    super.key,
    required this.appState,
    required this.onSwitchTab,
    required this.onOpenVoice,
  });

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  bool _boughtTab = false;

  @override
  Widget build(BuildContext context) {
    final all = widget.appState.shoppingItems;
    final toBuy = all.where((s) => !s.completed).toList();
    final bought = all.where((s) => s.completed).toList();

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 3, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: const AppBrandMark(size: 31),
              title: 'Shopping list',
              right: GestureDetector(
                onTap: () => _showAddItemDialog(context),
                child: const AppVectorIcon(AppIconType.plus, size: 21),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Pick up',
                      emphasizedLine: 'the essentials.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${all.length} items · ${toBuy.length} left to buy',
                      style: AppTheme.inter(
                        size: 13.5,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppChip(
                          label: 'To buy · ${toBuy.length}',
                          active: !_boughtTab,
                          onTap: () => setState(() => _boughtTab = false),
                        ),
                        AppChip(
                          label: 'Bought · ${bought.length}',
                          active: _boughtTab,
                          onTap: () => setState(() => _boughtTab = true),
                        ),
                      ],
                    ),
                    if (!_boughtTab) ...[
                      const StaggeredReveal(index: 1, child: SectionLabelRow(label: 'TO BUY')),
                      StaggeredReveal(
                        index: 2,
                        child: _ShoppingCard(
                          items: toBuy,
                          onToggle: widget.appState.toggleShopping,
                          onDelete: widget.appState.deleteShoppingItem,
                        ),
                      ),
                    ],
                    if (bought.isNotEmpty) ...[
                      const StaggeredReveal(index: 3, child: SectionLabelRow(label: 'ALREADY IN THE BAG')),
                      StaggeredReveal(
                        index: 4,
                        child: _ShoppingCard(
                          items: bought,
                          onToggle: widget.appState.toggleShopping,
                          onDelete: widget.appState.deleteShoppingItem,
                        ),
                      ),
                    ],
                    StaggeredReveal(
                      index: 5,
                      child: BouncyTap(
                        onTap: widget.onOpenVoice,
                        pressedScale: 0.98,
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: AppColors.softLav,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.softLavBorder),
                        ),
                        child: Row(
                          children: [
                            const AppVectorIcon(
                              AppIconType.mic,
                              size: 21,
                              color: AppColors.indigo,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add by speaking',
                                    style: AppTheme.inter(size: 11.5, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '“Add rice, bananas and coffee.”',
                                    style: AppTheme.inter(
                                      size: 9.5,
                                      color: const Color(0xFF8286A4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const AppVectorIcon(
                              AppIconType.chevronRight,
                              size: 16,
                              color: AppColors.navy,
                            ),
                          ],
                        ),
                      ),
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

  void _showAddItemDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Add shopping item', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Toothpaste'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                widget.appState.addShoppingItem(ctrl.text.trim(), category: 'General');
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  final List<ShoppingItemModel> items;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  const _ShoppingCard({
    required this.items,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Text(
          'All picked up!',
          style: AppTheme.inter(size: 12, color: AppColors.subText),
        ),
      );
    }

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            Container(
              constraints: const BoxConstraints(minHeight: 58),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SquareCheck(
                    checked: items[i].completed,
                    onTap: () => onToggle(items[i].id),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggle(items[i].id),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].item,
                            style: AppTheme.inter(
                              size: 12,
                              weight: FontWeight.w700,
                              color: items[i].completed
                                  ? const Color(0xFFA5A5B0)
                                  : AppColors.navy,
                              decoration: items[i].completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].completed ? 'Checked off' : items[i].category,
                            style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onDelete(items[i].id),
                    child: const AppVectorIcon(
                      AppIconType.moreDots,
                      size: 19,
                      color: Color(0xFFA8A8B7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
