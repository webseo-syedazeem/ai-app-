import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class SetYourGoalsScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const SetYourGoalsScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onContinue,
  });

  static const _options = [
    (
      key: 'work',
      icon: AppIconType.briefcase,
      tone: TileTone.indigo,
      title: 'Work & productivity',
      subtitle: 'Deadlines, tasks and meetings',
    ),
    (
      key: 'health',
      icon: AppIconType.heart,
      tone: TileTone.rose,
      title: 'Health & habits',
      subtitle: 'Feel better, one day at a time',
    ),
    (
      key: 'shopping',
      icon: AppIconType.shoppingCart,
      tone: TileTone.emerald,
      title: 'Shopping & errands',
      subtitle: 'Lists and things to pick up',
    ),
    (
      key: 'learning',
      icon: AppIconType.book,
      tone: TileTone.amber,
      title: 'Learning',
      subtitle: 'Build useful new skills',
    ),
    (
      key: 'personal',
      icon: AppIconType.user,
      tone: TileTone.violet,
      title: 'Personal life',
      subtitle: 'Important dates and little details',
    ),
  ];

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
            ),
            const OnboardingStepper(activeStep: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 16, 25, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowText('PERSONALIZE · 1 OF 2'),
                    const SizedBox(height: 14),
                    const HeroHeading(
                      plainLine: 'What matters',
                      emphasizedLine: 'most to you?',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select the areas you’d like help keeping on track.',
                      style: AppTheme.inter(
                        size: 14,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (int i = 0; i < _options.length; i++)
                      StaggeredReveal(
                        index: i + 1,
                        child: BouncyTap(
                          onTap: () => appState.toggleFocusArea(_options[i].key),
                          pressedScale: 0.98,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            constraints: const BoxConstraints(minHeight: 74),
                            margin: const EdgeInsets.only(bottom: 11),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: appState.user.focusAreas.contains(_options[i].key)
                                  ? AppGradients.softLavCard
                                  : null,
                              color: appState.user.focusAreas.contains(_options[i].key)
                                  ? null
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: appState.user.focusAreas.contains(_options[i].key)
                                    ? const Color(0xFF9EA8FA)
                                    : AppColors.cardBorder,
                                width: appState.user.focusAreas.contains(_options[i].key)
                                    ? 1.4
                                    : 1.0,
                              ),
                              boxShadow: appState.user.focusAreas.contains(_options[i].key)
                                  ? AppShadows.softCard
                                  : AppShadows.choose,
                            ),
                            child: Row(
                              children: [
                                TileIconBox(
                                  icon: _options[i].icon,
                                  tone: _options[i].tone,
                                  size: 42,
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _options[i].title,
                                        style: AppTheme.inter(
                                          size: 14,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _options[i].subtitle,
                                        style: AppTheme.inter(
                                          size: 11.5,
                                          color: AppColors.subText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SquareCheck(
                                  checked: appState.user.focusAreas.contains(_options[i].key),
                                  onTap: () => appState.toggleFocusArea(_options[i].key),
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
              child: PrimaryButton(label: 'Continue', onTap: onContinue),
            ),
          ],
        ),
      ),
    );
  }
}
