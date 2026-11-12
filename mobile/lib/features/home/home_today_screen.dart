import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
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

  String _formattedHeaderDate() {
    const weekdays = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String _greetingLine() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = appState.tasks.where((t) => t.section == 'today').toList();
    final todayDoneCount = todayTasks.where((t) => t.completed).length;
    final activeGoals = appState.goals.where((g) => !g.isCompleted).length;
    final nextRem = appState.reminders.where((r) => !r.completed).toList();

    if (todayTasks.isEmpty && appState.upcomingRemindersCount == 0) {
      return EmptyStatesScreen(
        onBack: () => onSwitchTab(1),
        onCreateFirstTask: () => _showAddTaskSheet(context),
        onSpeakReminder: onOpenVoice,
        onSwitchTab: onSwitchTab,
      );
    }

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 0, onTap: onSwitchTab),
      floatingOverlay: Positioned(
        left: 20,
        right: 20,
        bottom: 88 + MediaQuery.of(context).padding.bottom,
        child: FloatingBob(
          amplitude: 2.2,
          duration: const Duration(milliseconds: 3000),
          child: BouncyTap(
            onTap: onOpenVoice,
            pressedScale: 0.975,
            child: Container(
              constraints: const BoxConstraints(minHeight: 68),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: AppGradients.voiceFloat,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x28FFFFFF)),
                boxShadow: AppShadows.voiceFloat,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppGradients.accentIndigo,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x445E6EF7),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppVectorIcon(AppIconType.mic, size: 21, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture a thought',
                          style: AppTheme.inter(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to speak with your assistant',
                          style: AppTheme.inter(
                            size: 11,
                            color: const Color(0xFFC4C9F5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    child: const AppVectorIcon(
                      AppIconType.arrowRight,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 185),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 16, 23, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: StaggeredReveal(
                        index: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                EyebrowText(_formattedHeaderDate()),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.tileEmerald,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5.5,
                                        height: 5.5,
                                        decoration: const BoxDecoration(
                                          color: AppColors.greenSuccess,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        appState.backendConnected ? 'SYNCED' : 'AI READY',
                                        style: AppTheme.inter(
                                          size: 8.5,
                                          weight: FontWeight.w800,
                                          color: AppColors.greenText,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            HeroHeading(
                              plainLine: _greetingLine(),
                              emphasizedLine: '${appState.user.fullName}. ',
                              size: 35,
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
                                size: 13.5,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        BouncyTap(
                          onTap: () => _showBriefingSheet(context),
                          pressedScale: 0.9,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.cardBorder),
                                  boxShadow: AppShadows.choose,
                                ),
                                child: const Center(
                                  child: AppVectorIcon(AppIconType.bell, size: 20),
                                ),
                              ),
                              if (appState.pendingTodayTasksCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.indigo,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.bgTop, width: 1.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        BouncyTap(
                          onTap: onOpenSettings,
                          pressedScale: 0.9,
                          child: Container(
                            width: 42,
                            height: 42,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: AppGradients.accentIndigo,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x285365DF),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
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
                                    size: 16,
                                    weight: FontWeight.w800,
                                    color: AppColors.avatarText,
                                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 22),
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
                              badgeText: '$todayDoneCount/${todayTasks.length} done',
                              onTap: () => onSwitchTab(1),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _SummaryBox(
                              primary: false,
                              icon: AppIconType.bell,
                              count: appState.upcomingRemindersCount.toString().padLeft(2, '0'),
                              label: 'Upcoming reminder',
                              badgeText: nextRem.isEmpty ? 'All clear' : nextRem.first.title,
                              onTap: onOpenReminders,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaggeredReveal(
                      index: 2,
                      child: BouncyTap(
                        onTap: () => _showForgettingDialog(context),
                        pressedScale: 0.98,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          decoration: BoxDecoration(
                            gradient: AppGradients.darkAiCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x26FFFFFF)),
                            boxShadow: AppShadows.voiceFloat,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accentIndigo,
                                  borderRadius: BorderRadius.circular(13),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x455D6DF7),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: AppVectorIcon(
                                    AppIconType.sparkle,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI DAILY INSIGHT',
                                      style: AppTheme.inter(
                                        size: 9.5,
                                        weight: FontWeight.w800,
                                        color: const Color(0xFF9EA9FF),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'What am I forgetting?',
                                      style: AppTheme.inter(
                                        size: 14.5,
                                        weight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Check overdue tasks, dates & reminders',
                                      style: AppTheme.inter(
                                        size: 11,
                                        color: const Color(0xFFC1C5E4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: AppVectorIcon(
                                    AppIconType.chevronRight,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        child: todayTasks.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  children: [
                                    const AppVectorIcon(
                                      AppIconType.checkCircle,
                                      size: 18,
                                      color: AppColors.greenSuccess,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'All tasks for today are cleared.',
                                        style: AppTheme.inter(size: 12, color: AppColors.subText),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showAddTaskSheet(context),
                                      child: Text(
                                        '+ Add',
                                        style: AppTheme.inter(
                                          size: 11.5,
                                          weight: FontWeight.w700,
                                          color: AppColors.indigo,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < todayTasks.length; i++) ...[
                                    if (i > 0) const Divider(height: 1, color: AppColors.divider),
                                    _HomeTaskRow(
                                      task: todayTasks[i],
                                      onToggle: () => appState.toggleTask(todayTasks[i].id),
                                      onMore: () => _showTaskMenu(context, todayTasks[i]),
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _BentoShortcutCard(
                                  icon: AppIconType.shoppingCart,
                                  tone: TileTone.emerald,
                                  title: 'Shopping list',
                                  subtitle: '${appState.pendingShoppingCount} items left',
                                  onTap: () => onSwitchTab(3),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: _BentoShortcutCard(
                                  icon: AppIconType.brain,
                                  tone: TileTone.violet,
                                  title: 'Saved memories',
                                  subtitle: '${appState.memories.length} details kept',
                                  onTap: () => onSwitchTab(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Row(
                            children: [
                              Expanded(
                                child: _BentoShortcutCard(
                                  icon: AppIconType.checkCircle,
                                  tone: TileTone.indigo,
                                  title: 'Your goals',
                                  subtitle: '$activeGoals active now',
                                  onTap: onOpenGoals,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: _BentoShortcutCard(
                                  icon: AppIconType.sparkle,
                                  tone: TileTone.amber,
                                  title: 'Brain dump review',
                                  subtitle: 'Organize voice notes',
                                  onTap: onOpenBrainDump,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'MORE WORKFLOWS & BRIEFINGS'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      child: Column(
                        children: [
                          _ShortcutRow(
                            icon: AppIconType.bell,
                            tone: TileTone.amber,
                            title: 'Reminders & notifications',
                            subtitle: '${appState.upcomingRemindersCount} upcoming scheduled',
                            onTap: onOpenReminders,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.bookmark,
                            tone: TileTone.indigo,
                            title: 'Keep for later',
                            subtitle: '${appState.keepForLaterItems.length} thoughts in inbox',
                            onTap: onOpenKeepForLater,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.heart,
                            tone: TileTone.rose,
                            title: 'My affirmations',
                            subtitle: '${appState.affirmations.length} saved notes',
                            onTap: onOpenAffirmations,
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'PHASE 2 PREVIEWS'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      child: Column(
                        children: [
                          _ShortcutRow(
                            icon: AppIconType.wallet,
                            tone: TileTone.emerald,
                            title: 'Smart budgeting',
                            subtitle: 'Phase 2 · Rs. ${appState.totalBudgetSpent} spent',
                            onTap: onOpenBudgeting,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.star,
                            tone: TileTone.indigo,
                            title: 'Productivity insights',
                            subtitle: 'Phase 2 · Weekly momentum score',
                            onTap: onOpenProductivity,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ShortcutRow(
                            icon: AppIconType.mail,
                            tone: TileTone.violet,
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

  void _showTaskMenu(BuildContext context, TaskModel task) {
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowText('TASK ACTIONS'),
          const SizedBox(height: 6),
          Text(task.title, style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          SheetActionRow(
            icon: AppIconType.checkCircle,
            title: task.completed ? 'Mark as pending' : 'Mark as completed',
            onTap: () {
              appState.toggleTask(task.id);
              Navigator.pop(sheetCtx);
            },
          ),
          SheetActionRow(
            icon: AppIconType.calendar,
            title: 'Move to tomorrow',
            subtitle: 'Shift due date to tomorrow 10:00 AM',
            onTap: () {
              appState.editTask(
                task.id,
                subtitle: 'Tomorrow · 10:00 AM',
                section: 'upcoming',
              );
              Navigator.pop(sheetCtx);
              showAppToast(context, 'Moved "${task.title}" to tomorrow');
            },
          ),
          SheetActionRow(
            icon: AppIconType.editPen,
            title: 'Edit task title',
            onTap: () {
              Navigator.pop(sheetCtx);
              _showEditTaskSheet(context, task);
            },
          ),
          SheetActionRow(
            icon: AppIconType.trash,
            title: 'Delete task',
            color: const Color(0xFFC24656),
            onTap: () {
              appState.deleteTask(task.id);
              Navigator.pop(sheetCtx);
              showAppToast(context, 'Deleted "${task.title}"');
            },
          ),
        ],
      ),
    );
  }

  void _showEditTaskSheet(BuildContext context, TaskModel task) {
    final ctrl = TextEditingController(text: task.title);
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit task', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: ctrl,
            label: 'Task title',
            hint: 'Enter task...',
            autofocus: true,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save changes',
            onTap: () {
              if (ctrl.text.trim().isNotEmpty) {
                appState.editTask(task.id, title: ctrl.text.trim());
              }
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  void _showForgettingDialog(BuildContext context) {
    final summary = appState.buildWhatAmIForgettingSummary();
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowText('PROACTIVE CHECK'),
          const SizedBox(height: 8),
          Text(
            'What am I forgetting?',
            style: AppTheme.inter(size: 22, weight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.softLav,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              summary,
              style: AppTheme.inter(size: 13, color: AppColors.navy, height: 1.6),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Open Assistant Chat',
            onTap: () {
              Navigator.pop(sheetCtx);
              onSwitchTab(2);
            },
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Listen aloud',
            secondary: true,
            trailingIcon: AppIconType.mic,
            onTap: () => appState.voice.speak(summary),
          ),
        ],
      ),
    );
  }

  void _showBriefingSheet(BuildContext context) {
    final unfinished = appState.tasks.where((t) => !t.completed && t.section == 'today').length;
    final briefingText = appState.buildMorningBriefingText();
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowText('MORNING & EVENING BRIEFING'),
          const SizedBox(height: 8),
          Text(
            '${_greetingLine()} ${appState.user.fullName}!',
            style: AppTheme.inter(size: 22, weight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softLav,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '• $unfinished tasks due today\n• ${appState.upcomingRemindersCount} upcoming reminders\n• ${appState.pendingShoppingCount} items on shopping list',
              style: AppTheme.inter(size: 13, color: AppColors.navy, height: 1.65),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Listen to briefing',
            secondary: true,
            trailingIcon: AppIconType.mic,
            onTap: () => appState.voice.speak(briefingText),
          ),
          if (unfinished > 0) ...[
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Move $unfinished unfinished tasks to tomorrow',
              onTap: () async {
                final moved = await appState.moveTodayUnfinishedToTomorrow();
                if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                if (context.mounted) {
                  showAppToast(context, 'Moved $moved tasks to tomorrow');
                }
              },
            ),
          ],
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'View all reminders',
            secondary: true,
            onTap: () {
              Navigator.pop(sheetCtx);
              onOpenReminders();
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New task', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: ctrl,
            label: 'What needs to get done?',
            hint: 'e.g. Send client proposal',
            autofocus: true,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Add task',
            trailingIcon: AppIconType.plus,
            onTap: () {
              if (ctrl.text.trim().isNotEmpty) {
                appState.addTask(ctrl.text.trim());
                Navigator.pop(sheetCtx);
                showAppToast(context, 'Task added to today');
              }
            },
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
  final String badgeText;
  final VoidCallback onTap;

  const _SummaryBox({
    required this.primary,
    required this.icon,
    required this.count,
    required this.label,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        constraints: const BoxConstraints(minHeight: 136),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: primary ? AppGradients.softLavCard : null,
          color: primary ? null : AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: primary ? AppColors.softLavBorder : AppColors.cardBorder,
          ),
          boxShadow: primary ? AppShadows.softCard : AppShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TileIconBox(
                  icon: icon,
                  tone: primary ? TileTone.indigo : TileTone.amber,
                  size: 34,
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary ? Colors.white.withValues(alpha: 0.72) : AppColors.chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.inter(
                        size: 9.5,
                        weight: FontWeight.w700,
                        color: primary ? AppColors.indigoText : AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                count,
                key: ValueKey(count),
                style: AppTheme.inter(
                  size: 36,
                  weight: FontWeight.w900,
                  color: AppColors.navy,
                  letterSpacing: -1.4,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.inter(
                size: 12.5,
                weight: FontWeight.w800,
                color: primary ? AppColors.indigoText : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoShortcutCard extends StatelessWidget {
  final AppIconType icon;
  final TileTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BentoShortcutCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        constraints: const BoxConstraints(minHeight: 108),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TileIconBox(icon: icon, tone: tone, size: 36),
                const AppVectorIcon(
                  AppIconType.chevronRight,
                  size: 15,
                  color: Color(0xFF9396A8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.inter(size: 14, weight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.inter(size: 11.5, weight: FontWeight.w600, color: AppColors.subText),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTaskRow extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onMore;

  const _HomeTaskRow({
    required this.task,
    required this.onToggle,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isHigh = task.priority == 'high' && !task.completed;
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SquareCheck(checked: task.completed, onTap: onToggle),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: AppTheme.inter(
                            size: 14,
                            weight: FontWeight.w800,
                            color: task.completed ? const Color(0xFFA0A0AE) : AppColors.navy,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isHigh) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tileRose,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'HIGH',
                            style: AppTheme.inter(
                              size: 8.5,
                              weight: FontWeight.w800,
                              color: AppColors.roseAccent,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.subtitle,
                    style: AppTheme.inter(size: 11.5, color: AppColors.subText),
                  ),
                ],
              ),
            ),
          ),
          BouncyTap(
            onTap: onMore,
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
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final AppIconType icon;
  final TileTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShortcutRow({
    required this.icon,
    this.tone = TileTone.neutral,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            TileIconBox(icon: icon, tone: tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.inter(size: 14, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTheme.inter(size: 11.5, weight: FontWeight.w500, color: AppColors.subText),
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
