import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class TasksScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<int> onSwitchTab;

  const TasksScreen({
    super.key,
    required this.appState,
    required this.onSwitchTab,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all'; // 'all' | 'today' | 'upcoming'

  String _todayLabel() {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final now = DateTime.now();
    return 'TODAY · ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.appState.tasks;
    final todayList = all.where((t) => t.section == 'today').toList();
    final upcomingList = all.where((t) => t.section != 'today').toList();
    final completedCount = all.where((t) => t.completed).length;

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 1, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: const AppBrandMark(size: 33),
              title: 'Tasks',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddTaskSheet(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Keep moving',
                      emphasizedLine: 'forward.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Small steps add up. You’ve got this.',
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
                          label: 'All · ${all.length}',
                          active: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all'),
                        ),
                        AppChip(
                          label: 'Today · ${todayList.length}',
                          active: _filter == 'today',
                          onTap: () => setState(() => _filter = 'today'),
                        ),
                        AppChip(
                          label: 'Upcoming · ${upcomingList.length}',
                          active: _filter == 'upcoming',
                          onTap: () => setState(() => _filter = 'upcoming'),
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
                                  'DAILY PROGRESS',
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
                                  '$completedCount of ${all.length} done',
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
                              value: all.isEmpty ? 0 : completedCount / all.length,
                              minHeight: 7,
                              backgroundColor: Colors.white.withValues(alpha: 0.75),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_filter == 'all' || _filter == 'today') ...[
                      StaggeredReveal(
                        index: 1,
                        child: SectionLabelRow(label: _todayLabel()),
                      ),
                      StaggeredReveal(
                        index: 2,
                        child: _TaskGroupCard(
                          items: todayList,
                          onToggle: widget.appState.toggleTask,
                          onMore: (task) => _showTaskMenu(context, task),
                        ),
                      ),
                    ],
                    if (_filter == 'all' || _filter == 'upcoming') ...[
                      const StaggeredReveal(index: 3, child: SectionLabelRow(label: 'COMING UP')),
                      StaggeredReveal(
                        index: 4,
                        child: _TaskGroupCard(
                          items: upcomingList,
                          onToggle: widget.appState.toggleTask,
                          onMore: (task) => _showTaskMenu(context, task),
                        ),
                      ),
                    ],
                    StaggeredReveal(
                      index: 5,
                      child: MiniBanner(
                        icon: AppIconType.checkCircle,
                        iconColor: AppColors.greenSuccess,
                        text: completedCount > 0
                            ? '$completedCount ${completedCount == 1 ? 'task' : 'tasks'} completed! Keep the momentum going.'
                            : 'One task completed yesterday. Keep it going!',
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

  void _showTaskMenu(BuildContext context, TaskModel task) {
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowText('TASK OPTIONS'),
          const SizedBox(height: 6),
          Text(task.title, style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          SheetActionRow(
            icon: AppIconType.checkCircle,
            title: task.completed ? 'Mark as pending' : 'Mark as completed',
            onTap: () {
              widget.appState.toggleTask(task.id);
              Navigator.pop(sheetCtx);
            },
          ),
          SheetActionRow(
            icon: AppIconType.calendar,
            title: task.section == 'today' ? 'Move to Upcoming' : 'Move to Today',
            onTap: () {
              final nextSec = task.section == 'today' ? 'upcoming' : 'today';
              widget.appState.editTask(
                task.id,
                section: nextSec,
                subtitle: nextSec == 'today' ? 'Today · 5:00 PM' : 'Tomorrow · 10:00 AM',
              );
              Navigator.pop(sheetCtx);
            },
          ),
          SheetActionRow(
            icon: AppIconType.star,
            title: task.priority == 'high' ? 'Set normal priority' : 'Mark high priority',
            onTap: () {
              widget.appState.editTask(
                task.id,
                priority: task.priority == 'high' ? 'normal' : 'high',
              );
              Navigator.pop(sheetCtx);
            },
          ),
          SheetActionRow(
            icon: AppIconType.editPen,
            title: 'Edit title',
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
              widget.appState.deleteTask(task.id);
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
            hint: 'Task title',
            autofocus: true,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save changes',
            onTap: () {
              if (ctrl.text.trim().isNotEmpty) {
                widget.appState.editTask(task.id, title: ctrl.text.trim());
              }
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    String section = 'today';
    String priority = 'normal';
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add task', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 14),
            PremiumSheetField(
              controller: titleCtrl,
              label: 'Task title',
              hint: 'e.g. Deliver website to client',
              autofocus: true,
            ),
            const SizedBox(height: 14),
            Text('Schedule & priority', style: AppTheme.inter(size: 11, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip(
                  label: 'Today',
                  active: section == 'today',
                  onTap: () => setModalState(() => section = 'today'),
                ),
                AppChip(
                  label: 'Upcoming',
                  active: section == 'upcoming',
                  onTap: () => setModalState(() => section = 'upcoming'),
                ),
                AppChip(
                  label: 'High priority',
                  active: priority == 'high',
                  onTap: () => setModalState(
                      () => priority = priority == 'high' ? 'normal' : 'high'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save task',
              trailingIcon: AppIconType.plus,
              onTap: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  widget.appState.addTask(
                    titleCtrl.text.trim(),
                    subtitle: section == 'today' ? 'Today · 5:00 PM' : 'Tomorrow · 10:00 AM',
                    section: section,
                    priority: priority,
                  );
                  Navigator.pop(ctx);
                  showAppToast(context, 'Task added');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskGroupCard extends StatelessWidget {
  final List<TaskModel> items;
  final ValueChanged<String> onToggle;
  final ValueChanged<TaskModel> onMore;

  const _TaskGroupCard({
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
          'No tasks in this view.',
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
              constraints: const BoxConstraints(minHeight: 64),
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
                          Row(
                            children: [
                              Flexible(
                                child: AnimatedDefaultTextStyle(
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
                                  child: Text(
                                    items[i].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (items[i].priority == 'high' && !items[i].completed) ...[
                                const SizedBox(width: 7),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            items[i].subtitle,
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
