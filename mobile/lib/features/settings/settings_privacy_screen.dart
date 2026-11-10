import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class SettingsPrivacyScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;

  const SettingsPrivacyScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
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
              left: GestureDetector(
                onTap: onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Profile & settings',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.avatarBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                appState.user.fullName.isNotEmpty
                                    ? appState.user.fullName[0].toUpperCase()
                                    : 'A',
                                style: AppTheme.inter(
                                  size: 25,
                                  weight: FontWeight.w800,
                                  color: AppColors.avatarText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.user.fullName,
                                  style: AppTheme.inter(size: 18, weight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Personal account',
                                  style: AppTheme.inter(
                                    size: 11.5,
                                    color: const Color(0xFF9294A4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _editNameDialog(context),
                            child: const AppVectorIcon(AppIconType.editPen, size: 19),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'PREFERENCES'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: AppIconType.user,
                            title: 'Assistant tone',
                            subtitle: toneLabel,
                            onTap: () => _cycleTone(),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _SettingsRow(
                            icon: AppIconType.bell,
                            title: 'Notifications',
                            subtitle: appState.user.pushNotificationsEnabled
                                ? 'Manage permissions'
                                : 'Notifications paused',
                            onTap: () => appState.updatePreferences(
                              pushEnabled: !appState.user.pushNotificationsEnabled,
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _SettingsRow(
                            icon: AppIconType.clock,
                            title: 'Time zone',
                            subtitle: appState.user.timezone,
                            onTap: () => _pickTimezone(context),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'PRIVACY & DATA'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: AppIconType.brain,
                            title: 'Manage saved memories',
                            subtitle: 'View, edit or delete',
                            onTap: () => onSwitchTab(4),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _SettingsRow(
                            icon: AppIconType.shieldCheck,
                            title: 'Privacy & data',
                            subtitle: 'Control your information',
                            onTap: () => _showExportSheet(context),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _SettingsRow(
                            icon: AppIconType.trash,
                            title: 'Delete my data',
                            subtitle: 'Permanent deletion request',
                            onTap: () => _confirmDeleteAll(context),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabelRow(label: 'ACCOUNT'),
                    PremiumCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: _SettingsRow(
                        icon: AppIconType.settingsGear,
                        title: 'Account details',
                        subtitle:
                            '${appState.user.plan.toUpperCase()} plan · ${appState.user.aiCredits} AI actions left',
                        onTap: () => _showPlanAndUsageSheet(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'AI Daily Helper · Concept UI v1.1',
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

  void _cycleTone() {
    const order = ['friendly', 'professional', 'concise'];
    final next = order[(order.indexOf(appState.user.preferredTone) + 1) % order.length];
    appState.updatePreferences(tone: next);
  }

  void _editNameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: appState.user.fullName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Update name', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                appState.updatePreferences(fullName: ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pickTimezone(BuildContext context) {
    const zones = ['Asia/Karachi', 'UTC', 'Asia/Dubai', 'Europe/London', 'America/New_York'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          for (final z in zones)
            ListTile(
              title: Text(z, style: AppTheme.inter(size: 13, weight: FontWeight.w600)),
              trailing: appState.user.timezone == z
                  ? const AppVectorIcon(AppIconType.checkMark, size: 18, color: AppColors.indigo)
                  : null,
              onTap: () {
                appState.updatePreferences(timezone: z);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    final jsonText = appState.exportAllDataJson();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Data Export', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(12),
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
              label: 'Clear all saved memories',
              secondary: true,
              onTap: () {
                appState.clearAllMemories();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete my data?', style: AppTheme.inter(size: 16, weight: FontWeight.w800)),
        content: Text(
          'This permanently deletes all your saved memories, tasks, reminders, and shopping items.',
          style: AppTheme.inter(size: 12.5, color: AppColors.mutedText),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await appState.deleteAllMyData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
  }

  void _showPlanAndUsageSheet(BuildContext context) {
    final urlCtrl = TextEditingController(text: appState.backendUrl);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            22, 22, 22, 22 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan & Vercel API', style: AppTheme.inter(size: 18, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Backend (Vercel + MongoDB): ${appState.backendConnected ? 'Connected' : 'Local Offline Mode'}',
              style: AppTheme.inter(size: 11.5, color: AppColors.mutedText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              style: AppTheme.inter(size: 12),
              decoration: InputDecoration(
                labelText: 'Vercel API Base URL',
                hintText: 'https://your-app.vercel.app/api',
                suffixIcon: TextButton(
                  onPressed: () async {
                    await appState.setBackendUrl(urlCtrl.text);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Connect'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final p in const [
              ('free', 'Free — \$0', '5 AI actions/day · 5 voice interactions/day'),
              ('plus', 'Plus — \$4.99/mo (Recommended)', 'Up to 1,000 AI actions/mo · 120 voice mins'),
              ('pro', 'Pro — \$9.99/mo', 'Up to 3,000 AI actions/mo · 500 voice mins'),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p.$2, style: AppTheme.inter(size: 13, weight: FontWeight.w700)),
                subtitle: Text(p.$3, style: AppTheme.inter(size: 11, color: AppColors.subText)),
                trailing: appState.user.plan == p.$1
                    ? const AppVectorIcon(AppIconType.checkCircle, size: 20, color: AppColors.indigo)
                    : null,
                onTap: () {
                  appState.updatePreferences(plan: p.$1);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            TileIconBox(icon: icon),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.inter(size: 12.3, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTheme.inter(size: 10.5, color: AppColors.subText)),
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
