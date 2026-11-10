import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';
import 'empty_states_screen.dart';

class HomeTodayScreen extends StatelessWidget {
  final AppState appState;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback onOpenVoice;
  final VoidCallback onOpenReminders;
  final VoidCallback onOpenGoals;
  final VoidCallback onOpenKeepForLater;
  final VoidCallback onOpenAffirmations;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenBrainDump;
  final VoidCallback onOpenBudgeting;
  final VoidCallback onOpenProductivity;
  final VoidCallback onOpenEmailReports;

  const HomeTodayScreen({
    super.key,
    required this.appState,
    required this.onSwitchTab,
    required this.onOpenVoice,
    required this.onOpenReminders,
    required this.onOpenGoals,
    required this.onOpenKeepForLater,
    required this.onOpenAffirmations,
    required this.onOpenSettings,
    required this.onOpenBrainDump,
    required this.onOpenBudgeting,
    required this.onOpenProductivity,
    required this.onOpenEmailReports,
  });

  @override
  Widget build(BuildContext context) {
    final todayTasks = appState.tasks.where((t) => t.section == 'today').toList();

    if (todayTasks.isEmpty && appState.upcomingRemindersCount == 0) {
      return EmptyStatesScreen(
        onBack: () {},
        onCreateFirstTask: () => _showAddTaskDialog(context),
        onSpeakReminder: onOpenVoice,
        onSwitchTab: onSwitchTab,
      );
    }

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: onSwitchTab),
      floatingOverlay: Positioned(
        left: 23,
        right: 23,
        bottom: 86 + MediaQuery.of(context).padding.bottom,
        child: FloatingBob(
          amplitude: 2.5,
          duration: const Duration(milliseconds: 3000),
          child: BouncyTap(
            onTap: onOpenVoice,
            pressedScale: 0.975,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                gradient: AppGradients.voiceFloat,
                borderRadius: BorderRadius.circular(17),
                boxShadow: AppShadows.voiceFloat,
              ),
              child: Row(
                children: [
                  const AppVectorIcon(AppIconType.mic, size: 24, color: Colors.white),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture a thought',
                          style: AppTheme.inter(
                            size: 12.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tap to speak with your assistant',
                          style: AppTheme.inter(
                            size: 9.5,
                            color: const Color(0xFFC4C9F5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppVectorIcon(AppIconType.arrowRight, size: 17, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EyebrowText('TUESDAY, NOV 10'),
                          const SizedBox(height: 10),
                          HeroHeading(
                            plainLine: 'Good morning,',
                            emphasizedLine: '${appState.user.fullName}. ',
                            size: 36,
                            trailing: const Text(
                              '✳',
                              style: TextStyle(
                                color: AppColors.starAmber,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Here’s what’s on your plate today.',
                            style: AppTheme.inter(
                              size: 12,
                              color: const Color(0xFF818397),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showBriefingSheet(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEEE8E1)),
                            ),
                            child: const Center(
                              child: AppVectorIcon(AppIconType.bell, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onOpenSettings,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.avatarBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                appState.user.fullName.isNotEmpty
                                    ? appState.user.fullName[0].toUpperCase()
                                    : 'A',
                                style: AppTheme.inter(
                                  size: 15,
                                  weight: FontWeight.w800,
                                  color: AppColors.avatarText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaggeredReveal(
                      index: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryBox(
                              primary: true,
                              icon: AppIconType.checkCircle,
                              count: appState.pendingTodayTasksCount.toString().padLeft(2, '0'),
                              label: 'Due today',
                              onTap: () => onSwitchTab(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryBox(
                              primary: false,
                              icon: AppIconType.bell,
                              count: appState.upcomingRemindersCount.toString().padLeft(2, '0'),
                              label: 'Upcoming reminder',
                              onTap: onOpenReminders,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StaggeredReveal(
                      index: 2,
                      child: SectionLabelRow(
                        label: 'YOUR DAY',
                        actionText: 'See all →',
                        onAction: () => onSwitchTab(1),
                      ),
                    ),
                    StaggeredReveal(
                      index: 3,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            for (int i = 0; i < todayTasks.length; i++) ...[
                              if (i > 0) const Divider(height: 1, color: AppColors.divider),
                              _HomeTaskRow(
                                taskTitle: todayTasks[i].title,
                                taskSub: todayTasks[i].subtitle,
                                done: todayTasks[i].completed,
                                onToggle: () => appState.toggleTask(todayTasks[i].id),
                                onMore: () => appState.deleteTask(todayTasks[i].id),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const StaggeredReveal(
                      index: 4,
                      child: SectionLabelRow(label: 'LITTLE THINGS, HANDLED'),
                    ),
                    StaggeredReveal(
                      index: 5,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            _ShortcutRow(
                              icon: AppIconType.shoppingCart,
                              title: 'Shopping list',
                              subtitle: '${appState.pendingShoppingCount} things to pick up',
                              onTap: () => onSwitchTab(3),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _ShortcutRow(
                              icon: AppIconType.checkCircle,
                              title: 'Your goals',
                              subtitle: '${appState.goals.where((g) => !g.isCompleted).length} active this week',
                              onTap: onOpenGoals,
                            ),
                          ],
                        ),
                      ),
                    ),
                    StaggeredReveal(
                      index: 6,
                      child: BouncyTap(
                        onTap: () => _showForgettingDialog(context),
                        pressedScale: 0.98,
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softLav,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.softLavBorder),
                        ),
                        child: Row(
                          children: [
                            const AppVectorIcon(
                              AppIconType.sparkle,
                              size: 20,
                              color: Color(0xFF6678F3),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'What am I forgetting?',
                                    style: AppTheme.inter(size: 11.5, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Check what needs your attention.',
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
                              size: 18,
                              color: AppColors.navy,
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),
                    const SectionLabelRow(label: 'MORE WORKFLOWS & BRIEFINGS'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          _ShortcutRow(
                            icon: AppIconType.bell,
                            title: 'Reminders & notifications',
                            subtitle: '${appState.upcomingRemindersCount} upcoming scheduled',
                            onTap: onOpenReminders,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.bookmark,
                            title: 'Keep for later',
                            subtitle: '${appState.keepForLaterItems.length} thoughts in inbox',
                            onTap: onOpenKeepForLater,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.heart,
                            title: 'My affirmations',
                            subtitle: '${appState.affirmations.length} saved notes',
                            onTap: onOpenAffirmations,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.sparkle,
                            title: 'Brain dump review',
                            subtitle: 'Organize voice notes before saving',
                            onTap: onOpenBrainDump,
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'PHASE 2 PREVIEWS'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          _ShortcutRow(
                            icon: AppIconType.wallet,
                            title: 'Smart budgeting',
                            subtitle: 'Phase 2 · Rs. ${appState.totalBudgetSpent} spent',
                            onTap: onOpenBudgeting,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.star,
                            title: 'Productivity insights',
                            subtitle: 'Phase 2 · Weekly momentum score',
                            onTap: onOpenProductivity,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.mail,
                            title: 'Email reports',
                            subtitle: 'Phase 2 · Weekly summary digest',
                            onTap: onOpenEmailReports,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgettingDialog(BuildContext context) {
    final summary = appState.buildWhatAmIForgettingSummary();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('PROACTIVE CHECK'),
            const SizedBox(height: 8),
            Text(
              'What am I forgetting?',
              style: AppTheme.inter(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: AppTheme.inter(size: 13.5, color: AppColors.mutedText, height: 1.6),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Open Assistant Chat',
              onTap: () {
                Navigator.pop(context);
                onSwitchTab(2);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBriefingSheet(BuildContext context) {
    final unfinished = appState.tasks.where((t) => !t.completed && t.section == 'today').length;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('MORNING & EVENING BRIEFING'),
            const SizedBox(height: 8),
            Text(
              'Good morning, ${appState.user.fullName}!',
              style: AppTheme.inter(size: 20, weight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              '• $unfinished tasks due today\n• ${appState.upcomingRemindersCount} upcoming reminders\n• ${appState.pendingShoppingCount} items on shopping list',
              style: AppTheme.inter(size: 13, color: AppColors.mutedText, height: 1.6),
            ),
            if (unfinished > 0) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Move $unfinished unfinished tasks to tomorrow',
                onTap: () async {
                  await appState.moveTodayUnfinishedToTomorrow();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'View all reminders',
              secondary: true,
              onTap: () {
                Navigator.pop(context);
                onOpenReminders();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('New task', style: AppTheme.inter(size: 17, weight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Send client proposal'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                appState.addTask(ctrl.text.trim());
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

class _SummaryBox extends StatelessWidget {
  final bool primary;
  final AppIconType icon;
  final String count;
  final String label;
  final VoidCallback onTap;

  const _SummaryBox({
    required this.primary,
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        constraints: const BoxConstraints(minHeight: 127),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primary ? AppColors.softLav : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary ? AppColors.softLavBorder : AppColors.cardBorder,
          ),
          boxShadow: primary
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0A362820),
                    blurRadius: 15,
                    offset: Offset(0, 7),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppVectorIcon(icon, size: 23, color: const Color(0xFF5B70F2)),
            const SizedBox(height: 8),
            Text(
              count,
              style: AppTheme.inter(
                size: 32,
                weight: FontWeight.w800,
                color: const Color(0xFF211F31),
                letterSpacing: -1.0,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTheme.inter(
                size: 10.5,
                weight: FontWeight.w700,
                color: const Color(0xFF777B99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTaskRow extends StatelessWidget {
  final String taskTitle;
  final String taskSub;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onMore;

  const _HomeTaskRow({
    required this.taskTitle,
    required this.taskSub,
    required this.done,
    required this.onToggle,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SquareCheck(checked: done, onTap: onToggle),
          const SizedBox(width: 11),
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.inter(
                      size: 12,
                      weight: FontWeight.w700,
                      color: done ? const Color(0xFFA5A5B0) : AppColors.navy,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    taskSub,
                    style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onMore,
            child: const AppVectorIcon(
              AppIconType.moreDots,
              size: 19,
              color: Color(0xFFA8A8B7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShortcutRow({
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
                  Text(
                    title,
                    style: AppTheme.inter(size: 12.3, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
    );
  }
}
