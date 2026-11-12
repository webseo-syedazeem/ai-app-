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
              left: const AppBrandMark(size: 33),
              title: 'Shopping list',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddItemSheet(context),
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
                    const SizedBox(height: 16),
                    PremiumCard(
                      soft: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'BASKET PROGRESS',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.inter(
                                    size: 9.5,
                                    weight: FontWeight.w800,
                                    color: AppColors.indigoText,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${bought.length} of ${all.length} picked up',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.inter(
                                    size: 11.5,
                                    weight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: all.isEmpty ? 0 : bought.length / all.length,
                              minHeight: 7,
                              backgroundColor: Colors.white.withValues(alpha: 0.75),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(AppColors.greenSuccess),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_boughtTab) ...[
                      const StaggeredReveal(index: 1, child: SectionLabelRow(label: 'TO BUY')),
                      StaggeredReveal(
                        index: 2,
                        child: _ShoppingCard(
                          items: toBuy,
                          onToggle: widget.appState.toggleShopping,
                          onMore: (item) => _showItemMenu(context, item),
                        ),
                      ),
                    ],
                    if (bought.isNotEmpty) ...[
                      StaggeredReveal(
                        index: 3,
                        child: SectionLabelRow(
                          label: 'ALREADY IN THE BAG',
                          actionText: 'Clear bought',
                          onAction: () {
                            widget.appState.clearBoughtShopping();
                            showAppToast(context, 'Cleared bought items');
                          },
                        ),
                      ),
                      StaggeredReveal(
                        index: 4,
                        child: _ShoppingCard(
                          items: bought,
                          onToggle: widget.appState.toggleShopping,
                          onMore: (item) => _showItemMenu(context, item),
                        ),
                      ),
                    ],
                    StaggeredReveal(
                      index: 5,
                      child: BouncyTap(
                        onTap: widget.onOpenVoice,
                        pressedScale: 0.98,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            gradient: AppGradients.darkAiCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x26FFFFFF)),
                            boxShadow: AppShadows.voiceFloat,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accentIndigo,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: AppVectorIcon(
                                    AppIconType.mic,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add by speaking',
                                      style: AppTheme.inter(
                                        size: 14,
                                        weight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '“Add rice, bananas and coffee.”',
                                      style: AppTheme.inter(
                                        size: 11.5,
                                        color: const Color(0xFFC1C5E4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const AppVectorIcon(
                                AppIconType.chevronRight,
                                size: 17,
                                color: Colors.white,
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

  void _showItemMenu(BuildContext context, ShoppingItemModel item) {
    final nameCtrl = TextEditingController(text: item.item);
    String cat = item.category;
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit shopping item', style: AppTheme.inter(size: 19, weight: FontWeight.w800)),
            const SizedBox(height: 14),
            PremiumSheetField(
              controller: nameCtrl,
              label: 'Item name',
              hint: 'e.g. Toothpaste',
            ),
            const SizedBox(height: 12),
            Text('Category', style: AppTheme.inter(size: 11, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in const [
                  'Dairy & essentials',
                  'Bakery',
                  'Household',
                  'Personal care',
                  'Produce',
                  'General',
                ])
                  AppChip(
                    label: c,
                    active: cat == c,
                    onTap: () => setModalState(() => cat = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save changes',
              onTap: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  widget.appState.editShoppingItem(
                    item.id,
                    item: nameCtrl.text.trim(),
                    category: cat,
                  );
                }
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Remove item',
              secondary: true,
              trailingIcon: AppIconType.trash,
              onTap: () {
                widget.appState.deleteShoppingItem(item.id);
                Navigator.pop(ctx);
                showAppToast(context, 'Removed "${item.item}"');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    final ctrl = TextEditingController();
    String category = 'General';
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add shopping item', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 14),
            PremiumSheetField(
              controller: ctrl,
              label: 'Item name',
              hint: 'e.g. Toothpaste',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in const [
                  'Dairy & essentials',
                  'Bakery',
                  'Household',
                  'Personal care',
                  'General',
                ])
                  AppChip(
                    label: c,
                    active: category == c,
                    onTap: () => setModalState(() => category = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Add to list',
              trailingIcon: AppIconType.plus,
              onTap: () {
                if (ctrl.text.trim().isNotEmpty) {
                  widget.appState.addShoppingItem(ctrl.text.trim(), category: category);
                  Navigator.pop(ctx);
                  showAppToast(context, 'Added "${ctrl.text.trim()}"');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  final List<ShoppingItemModel> items;
  final ValueChanged<String> onToggle;
  final ValueChanged<ShoppingItemModel> onMore;

  const _ShoppingCard({
    required this.items,
    required this.onToggle,
    required this.onMore,
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            Container(
              constraints: const BoxConstraints(minHeight: 62),
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  SquareCheck(
                    checked: items[i].completed,
                    onTap: () => onToggle(items[i].id),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggle(items[i].id),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: AppTheme.inter(
                              size: 14,
                              weight: FontWeight.w700,
                              color: items[i].completed
                                  ? const Color(0xFFA0A0AE)
                                  : AppColors.navy,
                              decoration: items[i].completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            child: Text(items[i].item),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].completed ? 'Checked off' : items[i].category,
                            style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  BouncyTap(
                    onTap: () => onMore(items[i]),
                    pressedScale: 0.85,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: AppVectorIcon(
                        AppIconType.moreDots,
                        size: 19,
                        color: Color(0xFF9092A4),
                      ),
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
