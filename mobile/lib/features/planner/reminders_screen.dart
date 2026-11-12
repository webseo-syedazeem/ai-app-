import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class RemindersScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const RemindersScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _showCompleted = false;

  AppIconType _iconFor(String kind) {
    switch (kind) {
      case 'calendar':
        return AppIconType.calendar;
      case 'briefcase':
        return AppIconType.briefcase;
      default:
        return AppIconType.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.appState.reminders
        .where((r) => r.completed == _showCompleted)
        .toList();
    final tomorrow = filtered.where((r) => r.section == 'tomorrow').toList();
    final thisWeek = filtered.where((r) => r.section != 'tomorrow').toList();

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 1, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
              title: 'Reminders',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddReminder(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Never miss',
                      emphasizedLine: 'a moment.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppChip(
                          label: 'Upcoming',
                          active: !_showCompleted,
                          onTap: () => setState(() => _showCompleted = false),
                        ),
                        AppChip(
                          label: 'Completed',
                          active: _showCompleted,
                          onTap: () => setState(() => _showCompleted = true),
                        ),
                      ],
                    ),
                    if (tomorrow.isNotEmpty) ...[
                      const StaggeredReveal(index: 1, child: SectionLabelRow(label: 'TOMORROW')),
                      StaggeredReveal(
                        index: 2,
                        child: _ReminderCard(
                          items: tomorrow,
                          blueFirst: true,
                          iconFor: _iconFor,
                          onToggle: widget.appState.toggleReminder,
                          onMore: (rem) => _showReminderMenu(context, rem),
                        ),
                      ),
                    ],
                    if (thisWeek.isNotEmpty) ...[
                      const StaggeredReveal(index: 3, child: SectionLabelRow(label: 'THIS WEEK')),
                      StaggeredReveal(
                        index: 4,
                        child: _ReminderCard(
                          items: thisWeek,
                          blueFirst: false,
                          iconFor: _iconFor,
                          onToggle: widget.appState.toggleReminder,
                          onMore: (rem) => _showReminderMenu(context, rem),
                        ),
                      ),
                    ],
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: PremiumCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _showCompleted
                                ? 'No completed reminders yet.'
                                : 'No upcoming reminders.',
                            style: AppTheme.inter(size: 12, color: AppColors.subText),
                          ),
                        ),
                      ),
                    const SectionLabelRow(label: 'NOTIFICATION SETTINGS'),
                    PremiumCard(
                      onTap: () {
                        final next = !widget.appState.user.pushNotificationsEnabled;
                        widget.appState.updatePreferences(pushEnabled: next);
                        showAppToast(
                          context,
                          next ? 'Push notifications enabled' : 'Push notifications paused',
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 58),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const TileIconBox(icon: AppIconType.bell),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Push notifications',
                                    style: AppTheme.inter(size: 12.3, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.appState.user.pushNotificationsEnabled
                                        ? 'Enabled on this device'
                                        : 'Paused on this device',
                                    style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                                  ),
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
                    ),
                    MiniBanner(
                      icon: AppIconType.clock,
                      iconColor: AppColors.indigo,
                      text:
                          'Reminder times use your selected timezone (${widget.appState.user.timezone}).',
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

  void _showReminderMenu(BuildContext context, ReminderModel rem) {
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowText('REMINDER OPTIONS'),
          const SizedBox(height: 6),
          Text(rem.title, style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          SheetActionRow(
            icon: AppIconType.checkCircle,
            title: rem.completed ? 'Mark as upcoming' : 'Mark as completed',
            onTap: () {
              widget.appState.toggleReminder(rem.id);
              Navigator.pop(sheetCtx);
            },
          ),
          SheetActionRow(
            icon: AppIconType.editPen,
            title: 'Edit reminder',
            onTap: () {
              Navigator.pop(sheetCtx);
              _showEditReminder(context, rem);
            },
          ),
          SheetActionRow(
            icon: AppIconType.trash,
            title: 'Delete reminder',
            color: const Color(0xFFC24656),
            onTap: () {
              widget.appState.deleteReminder(rem.id);
              Navigator.pop(sheetCtx);
              showAppToast(context, 'Deleted "${rem.title}"');
            },
          ),
        ],
      ),
    );
  }

  void _showEditReminder(BuildContext context, ReminderModel rem) {
    final titleCtrl = TextEditingController(text: rem.title);
    final timeCtrl = TextEditingController(text: rem.displayTime);
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit reminder', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: titleCtrl,
            label: 'Reminder',
            hint: 'Call Ali',
            autofocus: true,
          ),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: timeCtrl,
            label: 'When',
            hint: 'Tomorrow · 5:00 PM',
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save changes',
            onTap: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                widget.appState.editReminder(
                  rem.id,
                  title: titleCtrl.text.trim(),
                  displayTime: timeCtrl.text.trim(),
                );
              }
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  void _showAddReminder(BuildContext context) {
    final ctrl = TextEditingController();
    String selectedTime = 'Tomorrow · 5:00 PM';
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New reminder', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 14),
            PremiumSheetField(
              controller: ctrl,
              label: 'What should I remind you about?',
              hint: 'e.g. Call Ali',
              autofocus: true,
            ),
            const SizedBox(height: 14),
            Text('When', style: AppTheme.inter(size: 11, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in const [
                  'Today · 6:00 PM',
                  'Tomorrow · 5:00 PM',
                  'Friday · 11:00 AM',
                ])
                  AppChip(
                    label: t,
                    active: selectedTime == t,
                    onTap: () => setModalState(() => selectedTime = t),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save reminder',
              trailingIcon: AppIconType.plus,
              onTap: () {
                if (ctrl.text.trim().isNotEmpty) {
                  widget.appState.addReminder(
                    ctrl.text.trim(),
                    displayTime: selectedTime,
                  );
                  Navigator.pop(ctx);
                  showAppToast(context, 'Reminder scheduled for $selectedTime');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final List<ReminderModel> items;
  final bool blueFirst;
  final AppIconType Function(String) iconFor;
  final ValueChanged<String> onToggle;
  final ValueChanged<ReminderModel> onMore;

  const _ReminderCard({
    required this.items,
    required this.blueFirst,
    required this.iconFor,
    required this.onToggle,
    required this.onMore,
  });

  TileTone _toneFor(String kind, int index) {
    if (kind == 'calendar') return TileTone.amber;
    if (kind == 'briefcase') return TileTone.violet;
    return (blueFirst && index == 0) ? TileTone.indigo : TileTone.amber;
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            GestureDetector(
              onTap: () => onToggle(items[i].id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 66),
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    TileIconBox(
                      icon: iconFor(items[i].iconKind),
                      tone: _toneFor(items[i].iconKind, i),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: AppTheme.inter(
                              size: 14,
                              weight: FontWeight.w700,
                              color: items[i].completed ? const Color(0xFFA0A0AE) : AppColors.navy,
                              decoration: items[i].completed ? TextDecoration.lineThrough : null,
                            ),
                            child: Text(items[i].title),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].displayTime,
                            style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                          ),
                        ],
                      ),
                    ),
                    BouncyTap(
                      onTap: () => onMore(items[i]),
                      pressedScale: 0.85,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: AppVectorIcon(
                          AppIconType.moreDots,
                          size: 18,
                          color: Color(0xFF74788C),
                        ),
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
