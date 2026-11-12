import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class MemoryScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<int> onSwitchTab;

  const MemoryScreen({
    super.key,
    required this.appState,
    required this.onSwitchTab,
  });

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  String _category = 'all';
  String _query = '';

  AppIconType _iconFor(String kind) {
    switch (kind) {
      case 'calendar':
        return AppIconType.calendar;
      case 'briefcase':
        return AppIconType.briefcase;
      case 'user':
        return AppIconType.user;
      default:
        return AppIconType.noteLines;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.appState.memories.where((m) {
      final matchesCat = _category == 'all' || m.category == _category;
      final q = _query.trim().toLowerCase();
      final matchesQ = q.isEmpty ||
          m.title.toLowerCase().contains(q) ||
          m.content.toLowerCase().contains(q) ||
          m.subtitle.toLowerCase().contains(q);
      return matchesCat && matchesQ;
    }).toList();

    final importantDates = filtered.where((m) => m.category == 'dates').toList();
    final peopleAndNotes = filtered.where((m) => m.category != 'dates').toList();

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 4, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: const AppBrandMark(size: 33),
              title: 'Your memories',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddMemory(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Your life,',
                      emphasizedLine: 'remembered.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Only the details you choose to save.',
                      style: AppTheme.inter(size: 13.5, color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.fieldBorder),
                        boxShadow: AppShadows.choose,
                      ),
                      child: Row(
                        children: [
                          const AppVectorIcon(
                            AppIconType.search,
                            size: 19,
                            color: Color(0xFF8C8E9E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              style: AppTheme.inter(size: 13.5, weight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Search your memories',
                                hintStyle: AppTheme.inter(
                                  size: 13,
                                  color: const Color(0xFF9A9BA9),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in const [
                            ('all', 'All'),
                            ('people', 'People'),
                            ('dates', 'Dates'),
                            ('preferences', 'Preferences'),
                          ]) ...[
                            AppChip(
                              label: c.$2,
                              active: _category == c.$1,
                              onTap: () => setState(() => _category = c.$1),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: PremiumCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _query.trim().isEmpty
                                ? 'No saved memories yet. Tap + to remember something important.'
                                : 'No memories matching "$_query".',
                            style: AppTheme.inter(size: 12, color: AppColors.subText),
                          ),
                        ),
                      ),
                    if (importantDates.isNotEmpty) ...[
                      const StaggeredReveal(index: 1, child: SectionLabelRow(label: 'IMPORTANT DATES')),
                      StaggeredReveal(
                        index: 2,
                        child: _MemoryCard(
                          items: importantDates,
                          iconFor: _iconFor,
                          onMore: (mem) => _showEditMemory(context, mem),
                        ),
                      ),
                    ],
                    if (peopleAndNotes.isNotEmpty) ...[
                      const StaggeredReveal(index: 3, child: SectionLabelRow(label: 'PEOPLE & NOTES')),
                      StaggeredReveal(
                        index: 4,
                        child: _MemoryCard(
                          items: peopleAndNotes,
                          iconFor: _iconFor,
                          onMore: (mem) => _showEditMemory(context, mem),
                        ),
                      ),
                    ],
                    const StaggeredReveal(
                      index: 5,
                      child: MiniBanner(
                        icon: AppIconType.shieldCheck,
                        iconColor: AppColors.indigo,
                        text: 'You can edit or delete any saved memory.',
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

  void _showEditMemory(BuildContext context, MemoryModel mem) {
    final titleCtrl = TextEditingController(text: mem.title);
    final subCtrl = TextEditingController(text: mem.subtitle);
    String category = mem.category;
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit or forget memory', style: AppTheme.inter(size: 19, weight: FontWeight.w800)),
            const SizedBox(height: 14),
            PremiumSheetField(
              controller: titleCtrl,
              label: 'Memory',
              hint: 'e.g. Sister’s birthday',
            ),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: subCtrl,
              label: 'Details / date',
              hint: 'e.g. December 18 · Saved by you',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                for (final c in const ['dates', 'people', 'preferences'])
                  AppChip(
                    label: c[0].toUpperCase() + c.substring(1),
                    active: category == c,
                    onTap: () => setModalState(() => category = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save memory',
              onTap: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  widget.appState.editMemory(
                    mem.id,
                    title: titleCtrl.text.trim(),
                    content: subCtrl.text.trim().isEmpty
                        ? titleCtrl.text.trim()
                        : subCtrl.text.trim(),
                    category: category,
                    subtitle: subCtrl.text.trim(),
                  );
                }
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Forget this memory',
              secondary: true,
              trailingIcon: AppIconType.trash,
              onTap: () {
                widget.appState.deleteMemory(mem.id);
                Navigator.pop(ctx);
                showAppToast(context, 'Forgot "${mem.title}"');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemory(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    String category = 'dates';
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Save memory', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 14),
            PremiumSheetField(
              controller: titleCtrl,
              label: 'What should I remember?',
              hint: 'e.g. Sister’s birthday',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            PremiumSheetField(
              controller: subCtrl,
              label: 'Date or note',
              hint: 'e.g. December 18 · Saved by you',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                for (final c in const ['dates', 'people', 'preferences'])
                  AppChip(
                    label: c[0].toUpperCase() + c.substring(1),
                    active: category == c,
                    onTap: () => setModalState(() => category = c),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save to Memory',
              trailingIcon: AppIconType.plus,
              onTap: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  widget.appState.addMemory(
                    titleCtrl.text.trim(),
                    subCtrl.text.trim().isEmpty ? titleCtrl.text.trim() : subCtrl.text.trim(),
                    category: category,
                    subtitle: subCtrl.text.trim().isEmpty
                        ? 'Saved by you'
                        : subCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  showAppToast(context, 'Saved to Memory');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final List<MemoryModel> items;
  final AppIconType Function(String) iconFor;
  final ValueChanged<MemoryModel> onMore;

  const _MemoryCard({
    required this.items,
    required this.iconFor,
    required this.onMore,
  });

  TileTone _toneFor(String kind) {
    switch (kind) {
      case 'calendar':
        return TileTone.amber;
      case 'briefcase':
        return TileTone.indigo;
      case 'user':
        return TileTone.violet;
      default:
        return TileTone.emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            BouncyTap(
              onTap: () => onMore(items[i]),
              pressedScale: 0.985,
              child: Container(
                constraints: const BoxConstraints(minHeight: 66),
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    TileIconBox(
                      icon: iconFor(items[i].iconKind),
                      tone: _toneFor(items[i].iconKind),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.inter(size: 14, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(6),
                      child: AppVectorIcon(
                        AppIconType.moreDots,
                        size: 18,
                        color: Color(0xFF74788C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
