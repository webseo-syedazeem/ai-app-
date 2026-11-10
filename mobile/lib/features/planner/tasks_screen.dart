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

  @override
  Widget build(BuildContext context) {
    final all = widget.appState.tasks;
    final todayList = all.where((t) => t.section == 'today').toList();
    final upcomingList = all.where((t) => t.section != 'today').toList();

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 1, onTap: widget.onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: const AppBrandMark(size: 31),
              title: 'Tasks',
              right: GestureDetector(
                onTap: () => _showAddTaskModal(context),
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
                    if (_filter == 'all' || _filter == 'today') ...[
                      const StaggeredReveal(index: 1, child: SectionLabelRow(label: 'TODAY · NOV 10')),
                      StaggeredReveal(
                        index: 2,
                        child: _TaskGroupCard(
                          items: todayList,
                          onToggle: widget.appState.toggleTask,
                          onDelete: widget.appState.deleteTask,
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
                          onDelete: widget.appState.deleteTask,
                        ),
                      ),
                    ],
                    const StaggeredReveal(
                      index: 5,
                      child: MiniBanner(
                        icon: AppIconType.checkCircle,
                        iconColor: AppColors.greenSuccess,
                        text: 'One task completed yesterday. Keep it going!',
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

  void _showAddTaskModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    String section = 'today';
    String priority = 'normal';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text('Add task', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Task title'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppChip(
                    label: 'Today',
                    active: section == 'today',
                    onTap: () => setModalState(() => section = 'today'),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: 'Upcoming',
                    active: section == 'upcoming',
                    onTap: () => setModalState(() => section = 'upcoming'),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: 'High',
                    active: priority == 'high',
                    onTap: () => setModalState(
                        () => priority = priority == 'high' ? 'normal' : 'high'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  widget.appState.addTask(
                    titleCtrl.text.trim(),
                    subtitle: section == 'today' ? 'Today · 5:00 PM' : 'Tomorrow · 10:00 AM',
                    section: section,
                    priority: priority,
                  );
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

class _TaskGroupCard extends StatelessWidget {
  final List<TaskModel> items;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  const _TaskGroupCard({
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
          'No tasks in this view.',
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
                            items[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            items[i].priority == 'high' && !items[i].subtitle.contains('High')
                                ? '${items[i].subtitle} · High priority'
                                : items[i].subtitle,
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
