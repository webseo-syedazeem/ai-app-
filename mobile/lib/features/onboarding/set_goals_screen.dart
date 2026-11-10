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
      title: 'Work & productivity',
      subtitle: 'Deadlines, tasks and meetings',
    ),
    (
      key: 'health',
      icon: AppIconType.heart,
      title: 'Health & habits',
      subtitle: 'Feel better, one day at a time',
    ),
    (
      key: 'shopping',
      icon: AppIconType.shoppingCart,
      title: 'Shopping & errands',
      subtitle: 'Lists and things to pick up',
    ),
    (
      key: 'learning',
      icon: AppIconType.book,
      title: 'Learning',
      subtitle: 'Build useful new skills',
    ),
    (
      key: 'personal',
      icon: AppIconType.user,
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
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
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
                        size: 13.5,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (int i = 0; i < _options.length; i++)
                      StaggeredReveal(
                        index: i + 1,
                        child: BouncyTap(
                          onTap: () => appState.toggleFocusArea(_options[i].key),
                          pressedScale: 0.98,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            constraints: const BoxConstraints(minHeight: 70),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: appState.user.focusAreas.contains(_options[i].key)
                                    ? const Color(0xFFC5CAF2)
                                    : AppColors.fieldBorder,
                              ),
                              boxShadow: AppShadows.choose,
                            ),
                            child: Row(
                              children: [
                                AppVectorIcon(
                                  _options[i].icon,
                                  size: 21,
                                  color: const Color(0xFF5769CD),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _options[i].title,
                                        style: AppTheme.inter(
                                          size: 12.5,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _options[i].subtitle,
                                        style: AppTheme.inter(
                                          size: 10.5,
                                          color: const Color(0xFF9D9EAC),
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
