import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
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
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: onBack,
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
                    StaggeredReveal(
                      index: 0,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final next = !appState.weeklyEmailSummary;
                                appState.updateEmailReportPrefs(weekly: next);
                                showAppToast(
                                  context,
                                  next
                                      ? 'Weekly summary emails enabled'
                                      : 'Weekly summary emails paused',
                                );
                              },
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
                                              style: AppTheme.inter(
                                                  size: 12.3, weight: FontWeight.w700)),
                                          const SizedBox(height: 3),
                                          Text('Every Sunday · 7:00 PM',
                                              style: AppTheme.inter(
                                                  size: 10.5, color: AppColors.subText)),
                                        ],
                                      ),
                                    ),
                                    AnimatedScale(
                                      scale: appState.weeklyEmailSummary ? 1.05 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: AppVectorIcon(
                                        AppIconType.checkCircle,
                                        size: 18,
                                        color: appState.weeklyEmailSummary
                                            ? AppColors.indigo
                                            : const Color(0xFFB8B9C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            GestureDetector(
                              onTap: () {
                                final next = !appState.monthlyEmailReview;
                                appState.updateEmailReportPrefs(monthly: next);
                                showAppToast(
                                  context,
                                  next
                                      ? 'Monthly review emails enabled'
                                      : 'Monthly review emails paused',
                                );
                              },
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
                                              style: AppTheme.inter(
                                                  size: 12.3, weight: FontWeight.w700)),
                                          const SizedBox(height: 3),
                                          Text('First day of each month',
                                              style: AppTheme.inter(
                                                  size: 10.5, color: AppColors.subText)),
                                        ],
                                      ),
                                    ),
                                    AnimatedScale(
                                      scale: appState.monthlyEmailReview ? 1.05 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: AppVectorIcon(
                                        AppIconType.checkCircle,
                                        size: 18,
                                        color: appState.monthlyEmailReview
                                            ? AppColors.indigo
                                            : const Color(0xFFB8B9C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'EXAMPLE REPORT'),
                    StaggeredReveal(
                      index: 1,
                      child: PremiumCard(
                        onTap: () => _showPreviewSheet(context),
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
                              children: [
                                _ReportStat(
                                  value: appState.tasks
                                      .where((t) => t.completed)
                                      .length
                                      .toString()
                                      .padLeft(2, '0'),
                                  label: 'Tasks done',
                                ),
                                _ReportStat(
                                  value: appState.goals
                                      .where((g) => g.isCompleted)
                                      .length
                                      .toString()
                                      .padLeft(2, '0'),
                                  label: 'Goals met',
                                ),
                                _ReportStat(
                                  value: appState.reminders
                                      .where((r) => !r.completed)
                                      .length
                                      .toString()
                                      .padLeft(2, '0'),
                                  label: 'Upcoming',
                                ),
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
                    ),
                    StaggeredReveal(
                      index: 2,
                      child: PremiumCard(
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
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: appState.emailReportsEnabled
                        ? 'Email reports enabled ✓'
                        : 'Enable email reports',
                    onTap: () {
                      final next = !appState.emailReportsEnabled;
                      appState.updateEmailReportPrefs(enabled: next);
                      showAppToast(
                        context,
                        next
                            ? 'Weekly & monthly email reports enabled'
                            : 'Email reports paused',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Send digest email now',
                    secondary: true,
                    onTap: () async {
                      final result = await appState.sendTestEmailReport();
                      if (!context.mounted) return;
                      final sent = result['sent'] == true;
                      final recipient = result['recipient']?.toString() ?? appState.user.email;
                      final reason = result['reason']?.toString();
                      showAppToast(
                        context,
                        sent
                            ? 'Live digest sent to $recipient'
                            : reason ?? 'Email provider key needed on server to deliver emails.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreviewSheet(BuildContext context) {
    final completed = appState.tasks.where((t) => t.completed).length;
    final upcoming = appState.reminders.where((r) => !r.completed).length;
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sample weekly digest', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Prepared for ${appState.user.fullName} (${appState.user.email}) · Sent ${appState.weeklyEmailSummary ? 'every Sunday 7:00 PM' : 'when weekly digest is enabled'}',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '• $completed tasks completed\n• $upcoming upcoming reminders scheduled\n• ${appState.memories.length} memories actively tracked',
              style: AppTheme.inter(size: 12.5, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Close preview',
            secondary: true,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
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
