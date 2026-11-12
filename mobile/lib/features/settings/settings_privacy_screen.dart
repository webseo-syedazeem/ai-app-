import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class SettingsPrivacyScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback? onLogOut;

  const SettingsPrivacyScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
    this.onLogOut,
  });

  @override
  Widget build(BuildContext context) {
    final toneLabel = appState.user.preferredTone[0].toUpperCase() +
        appState.user.preferredTone.substring(1);

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 4, onTap: onSwitchTab),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: onBack,
              ),
              title: 'Profile & settings',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumCard(
                      soft: true,
                      onTap: () => _editNameSheet(context),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accentIndigo,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: AppShadows.softCard,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.avatarBg,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      appState.user.fullName.isNotEmpty
                                          ? appState.user.fullName[0].toUpperCase()
                                          : 'A',
                                      style: AppTheme.inter(
                                        size: 26,
                                        weight: FontWeight.w800,
                                        color: AppColors.avatarText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            appState.user.fullName,
                                            style: AppTheme.inter(size: 19, weight: FontWeight.w800),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.accentIndigo,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            appState.user.plan.toUpperCase(),
                                            style: AppTheme.inter(
                                              size: 9,
                                              weight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      appState.user.email,
                                      style: AppTheme.inter(
                                        size: 12,
                                        color: AppColors.subText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Center(
                                  child: AppVectorIcon(AppIconType.editPen, size: 17),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.68),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${appState.user.aiCredits} AI actions left',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.inter(
                                      size: 11.5,
                                      weight: FontWeight.w700,
                                      color: AppColors.indigoText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    appState.backendConnected ? 'Cloud synced' : 'Local mode',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.inter(
                                      size: 11,
                                      weight: FontWeight.w600,
                                      color: AppColors.greenText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'PREFERENCES'),
                    StaggeredReveal(
                      index: 0,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Column(
                          children: [
                            _SettingsRow(
                              icon: AppIconType.user,
                              tone: TileTone.indigo,
                              title: 'Assistant tone',
                              subtitle: toneLabel,
                              onTap: () => _pickToneSheet(context),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _SettingsRow(
                              icon: AppIconType.bell,
                              tone: TileTone.amber,
                              title: 'Notifications',
                              subtitle: appState.user.pushNotificationsEnabled
                                  ? 'Active · reminders & briefings'
                                  : 'Notifications paused',
                              onTap: () {
                                final next = !appState.user.pushNotificationsEnabled;
                                appState.updatePreferences(pushEnabled: next);
                                showAppToast(
                                  context,
                                  next
                                      ? 'Push notifications enabled'
                                      : 'Notifications paused',
                                );
                              },
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _SettingsRow(
                              icon: AppIconType.clock,
                              tone: TileTone.emerald,
                              title: 'Time zone',
                              subtitle: appState.user.timezone,
                              onTap: () => _pickTimezone(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'PRIVACY & DATA'),
                    StaggeredReveal(
                      index: 1,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Column(
                          children: [
                            _SettingsRow(
                              icon: AppIconType.brain,
                              tone: TileTone.violet,
                              title: 'Manage saved memories',
                              subtitle: 'View, edit or delete (${appState.memories.length})',
                              onTap: () => onSwitchTab(4),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _SettingsRow(
                              icon: AppIconType.shieldCheck,
                              tone: TileTone.emerald,
                              title: 'Privacy & data',
                              subtitle: 'Export or clear saved memories',
                              onTap: () => _showExportSheet(context),
                            ),
                            const Divider(height: 1, color: AppColors.divider),
                            _SettingsRow(
                              icon: AppIconType.trash,
                              tone: TileTone.rose,
                              title: 'Delete my data',
                              subtitle: 'Permanent deletion request',
                              onTap: () => _confirmDeleteAll(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionLabelRow(label: 'ACCOUNT'),
                    StaggeredReveal(
                      index: 2,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: _SettingsRow(
                          icon: AppIconType.settingsGear,
                          tone: TileTone.indigo,
                          title: 'Account details',
                          subtitle:
                              '${appState.user.plan.toUpperCase()} plan · ${appState.user.aiCredits} AI actions left',
                          onTap: () => _showPlanAndUsageSheet(context),
                        ),
                      ),
                    ),
                    StaggeredReveal(
                      index: 3,
                      child: PremiumCard(
                        onTap: () => _confirmLogOut(context),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 62),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const TileIconBox(
                                icon: AppIconType.logOut,
                                tone: TileTone.rose,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Log out',
                                      style: AppTheme.inter(
                                        size: 14.5,
                                        weight: FontWeight.w800,
                                        color: AppColors.roseAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Sign out of ${appState.user.email}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.inter(
                                        size: 11.5,
                                        color: AppColors.subText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const AppVectorIcon(
                                AppIconType.chevronRight,
                                size: 17,
                                color: AppColors.roseAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'AI Daily Helper · v1.0.0',
                        style: AppTheme.inter(
                          size: 11,
                          color: const Color(0xFFA8A8B7),
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
    );
  }

  void _pickToneSheet(BuildContext context) {
    const tones = [
      ('friendly', 'Friendly', 'Warm, encouraging & conversational'),
      ('professional', 'Professional', 'Clear, structured & direct'),
      ('concise', 'Concise', 'Short, crisp confirmations'),
    ];
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assistant tone', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Choose how your AI speaks and summarizes your day.',
            style: AppTheme.inter(size: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          for (final t in tones)
            SheetActionRow(
              icon: appState.user.preferredTone == t.$1
                  ? AppIconType.checkCircle
                  : AppIconType.sparkle,
              title: t.$2,
              subtitle: t.$3,
              color: appState.user.preferredTone == t.$1
                  ? AppColors.indigo
                  : AppColors.navy,
              onTap: () {
                appState.updatePreferences(tone: t.$1);
                Navigator.pop(ctx);
                showAppToast(context, 'Assistant tone set to ${t.$2}');
              },
            ),
        ],
      ),
    );
  }

  void _editNameSheet(BuildContext context) {
    final ctrl = TextEditingController(text: appState.user.fullName);
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update profile name', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: ctrl,
            label: 'Your name',
            hint: 'e.g. Azeem',
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save name',
            onTap: () {
              final next = ctrl.text.trim();
              if (next.isNotEmpty) {
                appState.updatePreferences(fullName: next);
                Navigator.pop(ctx);
                showAppToast(context, 'Profile name updated to $next');
              }
            },
          ),
        ],
      ),
    );
  }

  void _pickTimezone(BuildContext context) {
    const zones = [
      'Asia/Karachi',
      'UTC',
      'Asia/Dubai',
      'Europe/London',
      'America/New_York',
      'America/Los_Angeles',
    ];
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select time zone', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final z in zones)
            SheetActionRow(
              icon: appState.user.timezone == z ? AppIconType.checkCircle : AppIconType.clock,
              title: z,
              color: appState.user.timezone == z ? AppColors.indigo : AppColors.navy,
              onTap: () {
                appState.updatePreferences(timezone: z);
                Navigator.pop(ctx);
                showAppToast(context, 'Time zone set to $z');
              },
            ),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    final jsonText = appState.exportAllDataJson();
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your data export', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Copy JSON export',
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: jsonText));
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                showAppToast(context, 'Copied full data export to clipboard');
              }
            },
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Clear all saved memories',
            secondary: true,
            onTap: () {
              appState.clearAllMemories();
              Navigator.pop(ctx);
              showAppToast(context, 'All saved memories cleared');
            },
          ),
        ],
      ),
    );
  }

  void _confirmLogOut(BuildContext context) {
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TileIconBox(
                icon: AppIconType.logOut,
                tone: TileTone.rose,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Log out of account?',
                  style: AppTheme.inter(size: 18, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'You will be signed out and returned to the welcome screen. Your saved tasks, reminders, and memories stay safe on this device.',
            style: AppTheme.inter(size: 13, color: AppColors.mutedText, height: 1.5),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Log out',
            trailingIcon: AppIconType.logOut,
            onTap: () {
              Navigator.pop(ctx);
              onLogOut?.call();
              showAppToast(context, 'Signed out successfully');
            },
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Stay signed in',
            secondary: true,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delete all data?', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'This permanently removes your saved memories, tasks, reminders, goals, and shopping list items from this device.',
            style: AppTheme.inter(size: 13, color: AppColors.mutedText, height: 1.5),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Delete all my data',
            onTap: () async {
              await appState.deleteAllMyData();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                showAppToast(context, 'All local assistant data deleted');
              }
            },
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Keep my data',
            secondary: true,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showPlanAndUsageSheet(BuildContext context) {
    final urlCtrl = TextEditingController(text: appState.backendUrl);
    final maxCredits = switch (appState.user.plan) {
      'pro' => 3000,
      'plus' => 1000,
      _ => 150,
    };
    final maxVoiceMinutes = switch (appState.user.plan) {
      'pro' => 500,
      'plus' => 120,
      _ => 15,
    };
    final voiceMinsLeft =
        (maxVoiceMinutes - (appState.user.voiceSecondsUsed / 60).floor()).clamp(0, maxVoiceMinutes);
    final creditRatio = (appState.user.aiCredits / maxCredits).clamp(0.0, 1.0);
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan & Vercel API', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Backend: ${appState.backendConnected ? 'Connected (Vercel + MongoDB)' : 'Local Offline Mode'}',
            style: AppTheme.inter(size: 11.5, color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${appState.user.aiCredits} AI actions left',
                      style: AppTheme.inter(size: 12.5, weight: FontWeight.w700),
                    ),
                    Text(
                      '$voiceMinsLeft voice mins left',
                      style: AppTheme.inter(size: 11, color: AppColors.subText),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: creditRatio,
                    minHeight: 7,
                    backgroundColor: AppColors.barTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: urlCtrl,
            label: 'Vercel API Base URL',
            hint: 'https://your-app.vercel.app/api',
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Connect backend URL',
            secondary: true,
            onTap: () async {
              await appState.setBackendUrl(urlCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                showAppToast(
                  context,
                  appState.backendConnected
                      ? 'Connected to Vercel API'
                      : 'Saved URL (running in local mode)',
                );
              }
            },
          ),
          const SizedBox(height: 14),
          for (final p in const [
            ('free', 'Free — \$0', '5 AI actions/day · 5 voice interactions/day'),
            ('plus', 'Plus — \$4.99/mo (Recommended)', 'Up to 1,000 AI actions/mo · 120 voice mins'),
            ('pro', 'Pro — \$9.99/mo', 'Up to 3,000 AI actions/mo · 500 voice mins'),
          ])
            SheetActionRow(
              icon: appState.user.plan == p.$1
                  ? AppIconType.checkCircle
                  : AppIconType.sparkle,
              title: p.$2,
              subtitle: p.$3,
              color: appState.user.plan == p.$1 ? AppColors.indigo : AppColors.navy,
              onTap: () {
                appState.updatePreferences(plan: p.$1);
                Navigator.pop(ctx);
                showAppToast(context, 'Switched to ${p.$1.toUpperCase()} plan');
              },
            ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final AppIconType icon;
  final TileTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    this.tone = TileTone.neutral,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            TileIconBox(icon: icon, tone: tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTheme.inter(size: 11.5, color: AppColors.subText)),
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
    );
  }
}
