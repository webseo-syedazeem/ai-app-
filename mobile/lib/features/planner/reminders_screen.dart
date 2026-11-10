import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
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
              left: GestureDetector(
                onTap: widget.onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Reminders',
              right: GestureDetector(
                onTap: () => _showAddReminder(context),
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
                      plainLine: 'Never miss',
                      emphasizedLine: 'a moment.',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        AppChip(
                          label: 'Upcoming',
                          active: !_showCompleted,
                          onTap: () => setState(() => _showCompleted = false),
                        ),
                        const SizedBox(width: 8),
                        AppChip(
                          label: 'Completed',
                          active: _showCompleted,
                          onTap: () => setState(() => _showCompleted = true),
                        ),
                      ],
                    ),
                    if (tomorrow.isNotEmpty) ...[
                      const SectionLabelRow(label: 'TOMORROW'),
                      _ReminderCard(
                        items: tomorrow,
                        blueFirst: true,
                        iconFor: _iconFor,
                        onToggle: widget.appState.toggleReminder,
                      ),
                    ],
                    if (thisWeek.isNotEmpty) ...[
                      const SectionLabelRow(label: 'THIS WEEK'),
                      _ReminderCard(
                        items: thisWeek,
                        blueFirst: false,
                        iconFor: _iconFor,
                        onToggle: widget.appState.toggleReminder,
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
                      onTap: () => widget.appState.updatePreferences(
                        pushEnabled: !widget.appState.user.pushNotificationsEnabled,
                      ),
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
                    const MiniBanner(
                      icon: AppIconType.clock,
                      iconColor: AppColors.indigo,
                      text: 'Reminder times use your selected timezone.',
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

  void _showAddReminder(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('New reminder', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Call Ali at 5 PM'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                widget.appState.addReminder(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final List<ReminderModel> items;
  final bool blueFirst;
  final AppIconType Function(String) iconFor;
  final ValueChanged<String> onToggle;

  const _ReminderCard({
    required this.items,
    required this.blueFirst,
    required this.iconFor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            GestureDetector(
              onTap: () => onToggle(items[i].id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 62),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    TileIconBox(
                      icon: iconFor(items[i].iconKind),
                      blue: blueFirst && i == 0,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            style: AppTheme.inter(
                              size: 12.3,
                              weight: FontWeight.w700,
                              decoration: items[i].completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].displayTime,
                            style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                          ),
                        ],
                      ),
                    ),
                    const AppVectorIcon(
                      AppIconType.moreDots,
                      size: 18,
                      color: Color(0xFF74788C),
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
