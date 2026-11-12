import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class AffirmationsScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;

  const AffirmationsScreen({
    super.key,
    required this.appState,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: onBack,
              ),
              title: 'My affirmations',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showAddAffirmation(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowText('THINGS I SAY TO MYSELF'),
                    const SizedBox(height: 14),
                    const HeroHeading(
                      plainLine: 'Remember your',
                      emphasizedLine: 'own words.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Keep promises and encouraging thoughts close.',
                      style: AppTheme.inter(size: 13.5, color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 20),
                    if (appState.affirmations.isEmpty)
                      PremiumCard(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          'No affirmations saved yet. Tap below to write one.',
                          style: AppTheme.inter(size: 12.5, color: AppColors.mutedText),
                        ),
                      ),
                    for (int i = 0; i < appState.affirmations.length; i++)
                      StaggeredReveal(
                        index: i + 1,
                        child: PremiumCard(
                          gradient: i == 0 ? AppGradients.softLavCard : null,
                          onTap: () => _showAffirmationActions(context, appState.affirmations[i]),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? Colors.white.withValues(alpha: 0.72)
                                      : AppColors.tileBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'AFFIRMATION',
                                  style: AppTheme.inter(
                                    size: 8.5,
                                    weight: FontWeight.w800,
                                    color: AppColors.indigoText,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '“${appState.affirmations[i].quote}”',
                                style: AppTheme.inter(
                                  size: 19.5,
                                  weight: FontWeight.w800,
                                  height: 1.45,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const AppVectorIcon(
                                    AppIconType.calendar,
                                    size: 16,
                                    color: Color(0xFF83879E),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      appState.affirmations[i].savedLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.inter(
                                        size: 11.5,
                                        weight: FontWeight.w600,
                                        color: const Color(0xFF7B7F98),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BouncyTap(
                                    onTap: () {
                                      appState.voice.speak(appState.affirmations[i].quote);
                                      showAppToast(context, 'Speaking affirmation aloud');
                                    },
                                    pressedScale: 0.92,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: i == 0
                                            ? Colors.white.withValues(alpha: 0.75)
                                            : AppColors.tileBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const AppVectorIcon(
                                            AppIconType.mic,
                                            size: 13,
                                            color: AppColors.indigo,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Listen',
                                            style: AppTheme.inter(
                                              size: 10.5,
                                              weight: FontWeight.w700,
                                              color: AppColors.indigo,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () =>
                                        _showAffirmationActions(context, appState.affirmations[i]),
                                    behavior: HitTestBehavior.opaque,
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: AppVectorIcon(
                                        AppIconType.moreDots,
                                        size: 16,
                                        color: Color(0xFF74788C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SectionLabelRow(label: 'YOUR REMINDERS'),
                    StaggeredReveal(
                      index: appState.affirmations.length + 1,
                      child: PremiumCard(
                        onTap: () => _showScheduleSheet(context),
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
                                      'Revisit affirmations',
                                      style: AppTheme.inter(size: 12.3, weight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      appState.affirmationReminderLabel,
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
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 24),
              child: PrimaryButton(
                label: 'Add affirmation',
                trailingIcon: AppIconType.plus,
                onTap: () => _showAddAffirmation(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAffirmationActions(BuildContext context, AffirmationModel item) {
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.quote,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.inter(size: 16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          SheetActionRow(
            icon: AppIconType.mic,
            title: 'Listen aloud',
            subtitle: 'Play this affirmation with voice synthesis',
            color: AppColors.indigo,
            onTap: () {
              Navigator.pop(ctx);
              appState.voice.speak(item.quote);
              showAppToast(context, 'Speaking affirmation aloud');
            },
          ),
          SheetActionRow(
            icon: AppIconType.editPen,
            title: 'Edit wording',
            subtitle: 'Refine this promise',
            onTap: () {
              Navigator.pop(ctx);
              _showEditAffirmation(context, item);
            },
          ),
          SheetActionRow(
            icon: AppIconType.trash,
            title: 'Delete affirmation',
            subtitle: 'Remove from your list',
            color: const Color(0xFFD65A5A),
            onTap: () {
              Navigator.pop(ctx);
              appState.deleteAffirmation(item.id);
              showAppToast(context, 'Affirmation removed');
            },
          ),
        ],
      ),
    );
  }

  void _showEditAffirmation(BuildContext context, AffirmationModel item) {
    final ctrl = TextEditingController(text: item.quote);
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit affirmation', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: ctrl,
            label: 'Affirmation quote',
            hint: 'Write an encouraging promise...',
            maxLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save changes',
            onTap: () {
              final next = ctrl.text.trim();
              if (next.isEmpty) return;
              appState.editAffirmation(item.id, next);
              Navigator.pop(ctx);
              showAppToast(context, 'Affirmation updated');
            },
          ),
        ],
      ),
    );
  }

  void _showScheduleSheet(BuildContext context) {
    const schedules = [
      ('Daily · 8:30 AM', 'Morning check-in reminder'),
      ('Weekly · Sunday 9:00 AM', 'Weekend reflection nudge'),
      ('No reminder scheduled', 'Turn off scheduled affirmation nudges'),
    ];
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revisit affirmations', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Pick a gentle schedule to reread your own words.',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          for (final s in schedules)
            SheetActionRow(
              icon: appState.affirmationReminderLabel == s.$1
                  ? AppIconType.checkCircle
                  : AppIconType.bell,
              title: s.$1,
              subtitle: s.$2,
              color: appState.affirmationReminderLabel == s.$1
                  ? AppColors.indigo
                  : AppColors.navy,
              onTap: () async {
                await appState.scheduleAffirmationReminder(s.$1);
                if (s.$1 != 'No reminder scheduled') {
                  await appState.addReminder('Revisit affirmations', displayTime: s.$1);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  showAppToast(
                    context,
                    s.$1 == 'No reminder scheduled'
                        ? 'Affirmation reminder paused'
                        : 'Scheduled: ${s.$1}',
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _showAddAffirmation(BuildContext context) {
    final ctrl = TextEditingController();
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add affirmation', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: ctrl,
            label: 'Your affirmation',
            hint: 'Write an encouraging promise to yourself...',
            maxLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save affirmation',
            onTap: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              appState.addAffirmation(text);
              Navigator.pop(ctx);
              showAppToast(context, 'Affirmation saved');
            },
          ),
        ],
      ),
    );
  }
}
