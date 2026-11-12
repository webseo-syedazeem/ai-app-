import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class PersonalizeScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const PersonalizeScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onFinish,
  });

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  late final TextEditingController _ctrl;
  late String _tone;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.appState.user.helperContext.isEmpty
          ? 'Help me stay on top of work, remember appointments and organize errands.'
          : widget.appState.user.helperContext,
    );
    _tone = widget.appState.user.preferredTone;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tones = [
      (key: 'friendly', label: 'Friendly', icon: AppIconType.heart),
      (key: 'professional', label: 'Professional', icon: AppIconType.briefcase),
      (key: 'concise', label: 'Concise', icon: AppIconType.sparkle),
    ];

    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
            ),
            const OnboardingStepper(activeStep: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 16, 25, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowText('PERSONALIZE · 2 OF 2'),
                    const SizedBox(height: 14),
                    const HeroHeading(
                      plainLine: 'How can I',
                      emphasizedLine: 'help you?',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tell your assistant what you usually need help with.',
                      style: AppTheme.inter(
                        size: 13.5,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 166,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.fieldBorder),
                        boxShadow: AppShadows.choose,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              maxLines: 5,
                              maxLength: 300,
                              onChanged: (_) => setState(() {}),
                              style: AppTheme.inter(
                                size: 13,
                                color: const Color(0xFF5C5F76),
                                height: 1.65,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${_ctrl.text.length} / 300',
                              style: AppTheme.inter(
                                size: 10,
                                color: const Color(0xFFA5A5B5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'PREFERRED TONE'),
                    Row(
                      children: [
                        for (int i = 0; i < tones.length; i++) ...[
                          if (i > 0) const SizedBox(width: 9),
                          Expanded(
                            child: BouncyTap(
                              onTap: () => setState(() => _tone = tones[i].key),
                              pressedScale: 0.95,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                height: 92,
                                decoration: BoxDecoration(
                                  gradient: _tone == tones[i].key
                                      ? AppGradients.softLavCard
                                      : null,
                                  color: _tone == tones[i].key
                                      ? null
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _tone == tones[i].key
                                        ? const Color(0xFF9EA8FA)
                                        : AppColors.cardBorder,
                                    width: _tone == tones[i].key ? 1.4 : 1.0,
                                  ),
                                  boxShadow: _tone == tones[i].key
                                      ? AppShadows.softCard
                                      : AppShadows.choose,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TileIconBox(
                                      icon: tones[i].icon,
                                      tone: _tone == tones[i].key
                                          ? TileTone.indigo
                                          : TileTone.neutral,
                                      size: 36,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tones[i].label,
                                      style: AppTheme.inter(
                                        size: 12,
                                        weight: FontWeight.w700,
                                        color: _tone == tones[i].key
                                            ? AppColors.indigoPick
                                            : const Color(0xFF686B82),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 22),
                    PremiumCard(
                      soft: true,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const AppVectorIcon(
                            AppIconType.shieldCheck,
                            size: 20,
                            color: AppColors.indigo,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Change these anytime in Settings.',
                              style: AppTheme.inter(
                                size: 11,
                                color: const Color(0xFF646A87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 24),
              child: PrimaryButton(
                label: 'Finish setup',
                onTap: () async {
                  await widget.appState.completePersonalization(
                    contextNote: _ctrl.text,
                    tone: _tone,
                  );
                  widget.onFinish();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
