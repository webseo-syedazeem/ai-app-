import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class EmailReportsScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;

  const EmailReportsScreen({
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
              title: 'Email reports',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Phase2Pill(),
                    const SizedBox(height: 12),
                    const HeroHeading(
                      plainLine: 'A little perspective,',
                      emphasizedLine: 'every week.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get a clear overview of your activity by email. Only with your permission.',
                      style: AppTheme.inter(
                        size: 13.5,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => appState.updateEmailReportPrefs(
                              weekly: !appState.weeklyEmailSummary,
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 62),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const TileIconBox(icon: AppIconType.mail, blue: true),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Weekly summary',
                                            style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                                        const SizedBox(height: 3),
                                        Text('Every Sunday · 7:00 PM',
                                            style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                                      ],
                                    ),
                                  ),
                                  AppVectorIcon(
                                    AppIconType.checkCircle,
                                    size: 18,
                                    color: appState.weeklyEmailSummary
                                        ? AppColors.indigo
                                        : const Color(0xFFB8B9C7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          GestureDetector(
                            onTap: () => appState.updateEmailReportPrefs(
                              monthly: !appState.monthlyEmailReview,
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 62),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const TileIconBox(icon: AppIconType.calendar),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Monthly review',
                                            style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                                        const SizedBox(height: 3),
                                        Text('First day of each month',
                                            style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
                                      ],
                                    ),
                                  ),
                                  AppVectorIcon(
                                    AppIconType.checkCircle,
                                    size: 18,
                                    color: appState.monthlyEmailReview
                                        ? AppColors.indigo
                                        : const Color(0xFFB8B9C7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'EXAMPLE REPORT'),
                    PremiumCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'YOUR WEEK IN REVIEW',
                            style: AppTheme.inter(
                              size: 10,
                              weight: FontWeight.w800,
                              color: const Color(0xFF6779DE),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _ReportStat(value: '12', label: 'Tasks done'),
                              _ReportStat(value: '03', label: 'Goals met'),
                              _ReportStat(value: '02', label: 'Upcoming'),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F3FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'You made steady progress this week. Keep your momentum going.',
                              style: AppTheme.inter(
                                size: 12,
                                color: const Color(0xFF777B96),
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              'Opt in to emails anytime. Unsubscribe in one tap.',
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
                label: appState.emailReportsEnabled
                    ? 'Email reports enabled ✓'
                    : 'Enable email reports',
                onTap: () => appState.updateEmailReportPrefs(
                  enabled: !appState.emailReportsEnabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  final String value;
  final String label;
  const _ReportStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.inter(size: 27, weight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(label, style: AppTheme.inter(size: 10, color: const Color(0xFF9C9CAE))),
      ],
    );
  }
}
