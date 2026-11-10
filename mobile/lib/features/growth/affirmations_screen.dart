import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
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
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'My affirmations',
              right: GestureDetector(
                onTap: () => _showAddAffirmation(context),
                child: const AppVectorIcon(AppIconType.plus, size: 21),
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
                    for (int i = 0; i < appState.affirmations.length; i++)
                      StaggeredReveal(
                        index: i + 1,
                        child: PremiumCard(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.affirmations[i].quote,
                                style: AppTheme.inter(
                                  size: 19,
                                  weight: FontWeight.w700,
                                  height: 1.5,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const AppVectorIcon(
                                    AppIconType.calendar,
                                    size: 17,
                                    color: Color(0xFF9498AC),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    appState.affirmations[i].savedLabel,
                                    style: AppTheme.inter(
                                      size: 10.5,
                                      color: const Color(0xFF9498AC),
                                    ),
                                  ),
                                  const Spacer(),
                                  const AppVectorIcon(
                                    AppIconType.moreDots,
                                    size: 16,
                                    color: Color(0xFF9498AC),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SectionLabelRow(label: 'YOUR REMINDERS'),
                    PremiumCard(
                      onTap: () => appState.addReminder(
                        'Revisit affirmations',
                        displayTime: 'Tomorrow · 8:30 AM',
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
                                    'Revisit affirmations',
                                    style: AppTheme.inter(size: 12.3, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'No reminder scheduled',
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

  void _showAddAffirmation(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Add affirmation', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Write an encouraging promise...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                appState.addAffirmation(ctrl.text.trim());
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
