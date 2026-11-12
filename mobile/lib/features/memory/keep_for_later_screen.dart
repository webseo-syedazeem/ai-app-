import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class KeepForLaterScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;

  const KeepForLaterScreen({
    super.key,
    required this.appState,
    required this.onBack,
  });

  @override
  State<KeepForLaterScreen> createState() => _KeepForLaterScreenState();
}

class _KeepForLaterScreenState extends State<KeepForLaterScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.appState.keepForLaterItems.where((k) {
      if (_query.trim().isEmpty) return true;
      return k.title.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
              title: 'Keep for later',
              right: AppHeaderIconBtn(
                icon: AppIconType.plus,
                accent: true,
                onTap: () => _showCaptureModal(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Catch it now.',
                      emphasizedLine: 'Decide later.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A safe place for thoughts you don’t want to lose.',
                      style: AppTheme.inter(size: 13.5, color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.fieldBorder),
                        boxShadow: AppShadows.choose,
                      ),
                      child: Row(
                        children: [
                          const AppVectorIcon(
                            AppIconType.search,
                            size: 19,
                            color: Color(0xFF9D9DA9),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              style: AppTheme.inter(size: 12),
                              decoration: InputDecoration(
                                hintText: 'Search saved ideas',
                                hintStyle: AppTheme.inter(
                                  size: 11.5,
                                  color: const Color(0xFF9D9DA9),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StaggeredReveal(
                      index: 1,
                      child: SectionLabelRow(label: 'YOUR INBOX · ${items.length} ITEMS'),
                    ),
                    StaggeredReveal(
                      index: 2,
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: items.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: Text(
                                  'Your inbox is clear.',
                                  style: AppTheme.inter(size: 12, color: AppColors.subText),
                                ),
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < items.length; i++) ...[
                                    if (i > 0)
                                      const Divider(height: 1, color: AppColors.divider),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: AppVectorIcon(
                                              AppIconType.bookmark,
                                              size: 19,
                                              color: AppColors.indigo,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  items[i].title,
                                                  style: AppTheme.inter(
                                                    size: 12.2,
                                                    weight: FontWeight.w700,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  items[i].capturedLabel,
                                                  style: AppTheme.inter(
                                                    size: 10,
                                                    color: const Color(0xFF999BAB),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    BouncyTap(
                                                      onTap: () async {
                                                        await widget.appState
                                                            .moveKeepToMemories(items[i].id);
                                                        if (context.mounted) {
                                                          showAppToast(
                                                            context,
                                                            'Moved to Memories',
                                                          );
                                                        }
                                                      },
                                                      pressedScale: 0.95,
                                                      child: Text(
                                                        'Move to Memories →',
                                                        style: AppTheme.inter(
                                                          size: 10.5,
                                                          weight: FontWeight.w700,
                                                          color: AppColors.indigo,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    BouncyTap(
                                                      onTap: () => widget.appState
                                                          .deleteKeepForLater(items[i].id),
                                                      pressedScale: 0.85,
                                                      child: const AppVectorIcon(
                                                        AppIconType.trash,
                                                        size: 15,
                                                        color: Color(0xFFA8A8B7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                    StaggeredReveal(
                      index: 3,
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
                                'Moving something to Memory requires your approval.',
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
              child: PrimaryButton(
                label: 'Capture a thought',
                trailingIcon: AppIconType.plus,
                onTap: () => _showCaptureModal(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaptureModal(BuildContext context) {
    final ctrl = TextEditingController();
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Capture a thought', style: AppTheme.inter(size: 20, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: ctrl,
            label: 'Thought or idea',
            hint: 'Save any idea for later...',
            maxLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save to inbox',
            trailingIcon: AppIconType.plus,
            onTap: () {
              if (ctrl.text.trim().isNotEmpty) {
                widget.appState.addKeepForLater(ctrl.text.trim());
                Navigator.pop(sheetCtx);
                showAppToast(context, 'Captured for later');
              }
            },
          ),
        ],
      ),
    );
  }
}
