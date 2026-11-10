import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class BrainDumpReviewScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final VoidCallback onSaved;

  const BrainDumpReviewScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final taskItems = appState.brainDumpDrafts.where((d) => d.kind == 'task').toList();
    final reminderItems = appState.brainDumpDrafts.where((d) => d.kind == 'reminder').toList();
    final shoppingItems = appState.brainDumpDrafts.where((d) => d.kind == 'shopping').toList();
    final selectedCount = appState.brainDumpDrafts.where((d) => d.selected).length;

    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Review your voice note',
              right: GestureDetector(
                onTap: () => _showAddBrainDumpModal(context),
                child: const AppVectorIcon(AppIconType.editPen, size: 20),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowText('READY FOR REVIEW'),
                    const SizedBox(height: 14),
                    const HeroHeading(
                      plainLine: 'Thoughts,',
                      emphasizedLine: 'organized.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'I found ${appState.brainDumpDrafts.length} possible actions. Check everything before saving.',
                      style: AppTheme.inter(
                        size: 13.5,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (taskItems.isNotEmpty)
                      StaggeredReveal(
                        index: 1,
                        child: PremiumCard(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                          child: Column(
                            children: [
                              _GroupHead(
                                icon: AppIconType.checkCircle,
                                title: 'Tasks',
                                countLabel: '${taskItems.length} items',
                              ),
                              for (int i = 0; i < taskItems.length; i++) ...[
                                if (i > 0) const Divider(height: 1, color: AppColors.divider),
                                _DraftCheckRow(
                                  title: taskItems[i].title,
                                  subtitle: taskItems[i].subtitle,
                                  selected: taskItems[i].selected,
                                  onTap: () => appState.toggleBrainDumpItem(taskItems[i].id),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (reminderItems.isNotEmpty)
                      StaggeredReveal(
                        index: 2,
                        child: PremiumCard(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                          child: Column(
                            children: [
                              _GroupHead(
                                icon: AppIconType.bell,
                                title: 'Reminders',
                                countLabel: '${reminderItems.length} item',
                              ),
                              for (int i = 0; i < reminderItems.length; i++) ...[
                                if (i > 0) const Divider(height: 1, color: AppColors.divider),
                                _DraftCheckRow(
                                  title: reminderItems[i].title,
                                  subtitle: reminderItems[i].subtitle,
                                  selected: reminderItems[i].selected,
                                  onTap: () => appState.toggleBrainDumpItem(reminderItems[i].id),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (shoppingItems.isNotEmpty)
                      StaggeredReveal(
                        index: 3,
                        child: PremiumCard(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _GroupHead(
                                icon: AppIconType.shoppingCart,
                                title: 'Shopping',
                                countLabel: '${shoppingItems.length} items',
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: [
                                  for (final s in shoppingItems)
                                    AppChip(
                                      label: s.title,
                                      active: s.selected,
                                      onTap: () => appState.toggleBrainDumpItem(s.id),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAddBrainDumpModal(context),
                        child: Container(
                          width: 112,
                          height: 47,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDFDEE7)),
                          ),
                          child: Center(
                            child: Text(
                              'Edit details',
                              style: AppTheme.inter(size: 11.5, weight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await appState.saveSelectedBrainDumpActions();
                            onSaved();
                          },
                          child: Container(
                            height: 47,
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppShadows.button,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Save $selectedCount actions',
                                  style: AppTheme.inter(
                                    size: 11.5,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const AppVectorIcon(
                                  AppIconType.arrowRight,
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
                  const SizedBox(height: 8),
                  Text(
                    'Nothing is saved until you confirm.',
                    style: AppTheme.inter(size: 9.5, color: const Color(0xFF9394A2)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBrainDumpModal(BuildContext context) {
    final ctrl = TextEditingController(
      text: appState.lastBrainDumpTranscript.isEmpty
          ? 'Prepare the project update tomorrow, email the meeting notes Friday, call Ali tomorrow at 5 PM, buy eggs, bread and detergent'
          : appState.lastBrainDumpTranscript,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Brain Dump Text', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Speak or type multiple things at once...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await appState.processVoiceBrainDump(ctrl.text);
            },
            child: const Text('Re-organize'),
          ),
        ],
      ),
    );
  }
}

class _GroupHead extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String countLabel;

  const _GroupHead({
    required this.icon,
    required this.title,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AppVectorIcon(icon, size: 22, color: AppColors.indigo),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTheme.inter(size: 13, weight: FontWeight.w700),
            ),
          ),
          Text(
            countLabel,
            style: AppTheme.inter(size: 10.5, color: const Color(0xFFA1A2AF)),
          ),
        ],
      ),
    );
  }
}

class _DraftCheckRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DraftCheckRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SquareCheck(checked: selected, onTap: onTap),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 11.8, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTheme.inter(size: 10, color: AppColors.subText)),
                ],
              ),
            ),
            const AppVectorIcon(
              AppIconType.moreDots,
              size: 18,
              color: Color(0xFFA8A8B7),
            ),
          ],
        ),
      ),
    );
  }
}
