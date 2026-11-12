import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/models/models.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class AiChatScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback onOpenVoice;
  final VoidCallback onOpenBrainDump;

  const AiChatScreen({
    super.key,
    required this.appState,
    required this.onBack,
    required this.onSwitchTab,
    required this.onOpenVoice,
    required this.onOpenBrainDump,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    setState(() {});
    await widget.appState.sendChatMessage(text);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showAssistantMenu() {
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowText('ASSISTANT TOOLS'),
          const SizedBox(height: 6),
          Text('Quick actions', style: AppTheme.inter(size: 19, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          SheetActionRow(
            icon: AppIconType.sparkle,
            title: 'Open Brain Dump review',
            subtitle: 'Organize multi-item voice notes before saving',
            onTap: () {
              Navigator.pop(sheetCtx);
              widget.onOpenBrainDump();
            },
          ),
          SheetActionRow(
            icon: AppIconType.bell,
            title: 'What am I forgetting?',
            subtitle: 'Ask AI to scan overdue tasks & reminders',
            onTap: () {
              Navigator.pop(sheetCtx);
              _send('What am I forgetting?');
            },
          ),
          SheetActionRow(
            icon: AppIconType.mic,
            title: 'Read morning briefing aloud',
            subtitle: 'Listen via text-to-speech',
            onTap: () {
              Navigator.pop(sheetCtx);
              widget.appState.voice.speak(widget.appState.buildMorningBriefingText());
            },
          ),
          SheetActionRow(
            icon: AppIconType.trash,
            title: 'Clear conversation',
            color: const Color(0xFFC24656),
            onTap: () async {
              await widget.appState.clearChat();
              if (sheetCtx.mounted) Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  void _editPendingReminder(ChatMessageModel msg) {
    final action = msg.pendingAction;
    if (action == null) return;
    final titleCtrl = TextEditingController(text: action.title);
    final timeCtrl = TextEditingController(text: action.displayTime);
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit reminder details', style: AppTheme.inter(size: 19, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: titleCtrl,
            label: 'Title',
            hint: 'Call Ali',
            autofocus: true,
          ),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: timeCtrl,
            label: 'When',
            hint: 'Tomorrow · 5:00 PM',
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Update reminder card',
            onTap: () {
              widget.appState.updatePendingChatAction(
                msg.id,
                title: titleCtrl.text.isEmpty ? action.title : titleCtrl.text,
                displayTime: timeCtrl.text.isEmpty ? action.displayTime : timeCtrl.text,
              );
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hasTyped = _inputCtrl.text.trim().isNotEmpty;

    return WarmScaffold(
      bottomNav: AppBottomNav(currentIndex: 2, onTap: widget.onSwitchTab),
      floatingOverlay: Positioned(
        left: 20,
        right: 20,
        bottom: 85 + bottomPad,
        child: Container(
          padding: const EdgeInsets.fromLTRB(17, 6, 8, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFFE4E4EA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A191720),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _send,
                  style: AppTheme.inter(size: 12, color: AppColors.navy),
                  decoration: InputDecoration(
                    hintText: 'Ask or tell me anything...',
                    hintStyle: AppTheme.inter(size: 11.5, color: const Color(0xFFA5A5B1)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              BouncyTap(
                onTap: () {
                  if (hasTyped) {
                    _send(_inputCtrl.text);
                  } else {
                    widget.onOpenVoice();
                  }
                },
                pressedScale: 0.9,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: AppVectorIcon(
                        hasTyped ? AppIconType.arrowRight : AppIconType.mic,
                        key: ValueKey(hasTyped),
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
              title: 'Your assistant',
              right: AppHeaderIconBtn(
                icon: AppIconType.moreDots,
                onTap: _showAssistantMenu,
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(21, 12, 21, 165),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 26),
                      child: Text(
                        'TODAY · 10:42 AM',
                        style: AppTheme.inter(
                          size: 10,
                          weight: FontWeight.w600,
                          color: const Color(0xFF9B9DAD),
                        ),
                      ),
                    ),
                  ),
                  if (widget.appState.chatMessages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          const AppBrandMark(size: 54),
                          const SizedBox(height: 14),
                          Text(
                            'Ask me to add tasks, set reminders, save memories, or organize your day.',
                            textAlign: TextAlign.center,
                            style: AppTheme.inter(
                              size: 12.5,
                              color: AppColors.mutedText,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (int i = 0; i < widget.appState.chatMessages.length; i++) ...[
                    if (widget.appState.chatMessages[i].isUser)
                      StaggeredReveal(
                        index: i,
                        offset: const Offset(16, 6),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 295),
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              gradient: AppGradients.accentIndigo,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(6),
                              ),
                              boxShadow: AppShadows.softCard,
                            ),
                            child: Text(
                              widget.appState.chatMessages[i].text,
                              style: AppTheme.inter(
                                size: 13.5,
                                weight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      StaggeredReveal(
                        index: i,
                        offset: const Offset(-14, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: Row(
                                children: [
                                  const AppBrandMark(size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Daily Helper',
                                    style: AppTheme.inter(size: 11.5, weight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 300),
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  border: Border.all(color: AppColors.cardBorder),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                    bottomLeft: Radius.circular(6),
                                  ),
                                  boxShadow: AppShadows.choose,
                                ),
                                child: Text(
                                  widget.appState.chatMessages[i].text,
                                  style: AppTheme.inter(
                                    size: 13.5,
                                    color: AppColors.navy,
                                    height: 1.55,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.appState.chatMessages[i].pendingAction != null)
                              _ReminderConfirmationCard(
                                action: widget.appState.chatMessages[i].pendingAction!,
                                onEdit: () => _editPendingReminder(widget.appState.chatMessages[i]),
                                onConfirm: () {
                                  widget.appState.confirmPendingChatAction(
                                      widget.appState.chatMessages[i].id);
                                  showAppToast(context, 'Reminder confirmed & scheduled');
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  if (widget.appState.isAiThinking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          const AppBrandMark(size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Thinking...',
                            style: AppTheme.inter(
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      AppChip(
                        label: 'What’s due today?',
                        onTap: () => _send('What’s due today?'),
                      ),
                      AppChip(
                        label: 'Add to shopping',
                        onTap: () => _send('Add milk and coffee to shopping'),
                      ),
                      AppChip(
                        label: 'What am I forgetting?',
                        onTap: () => _send('What am I forgetting?'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderConfirmationCard extends StatelessWidget {
  final ChatPendingAction action;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  const _ReminderConfirmationCard({
    required this.action,
    required this.onEdit,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TileIconBox(icon: AppIconType.bell, tone: TileTone.indigo, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: AppTheme.inter(size: 14.5, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.displayTime,
                      style: AppTheme.inter(
                        size: 12,
                        weight: FontWeight.w600,
                        color: AppColors.indigoText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.tileNeutral,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Timezone: ${action.timezone}',
                        style: AppTheme.inter(size: 10.5, color: AppColors.subText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: action.confirmed ? null : onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.tileNeutral,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    action.confirmed ? 'Saved' : 'Edit',
                    style: AppTheme.inter(
                      size: 11.5,
                      color: action.confirmed ? AppColors.greenText : AppColors.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: BouncyTap(
                  onTap: action.confirmed ? null : onConfirm,
                  pressedScale: 0.94,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: action.confirmed ? null : AppGradients.accentIndigo,
                      color: action.confirmed ? AppColors.tileEmerald : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: action.confirmed ? null : AppShadows.softCard,
                    ),
                    child: Text(
                      action.confirmed ? 'Confirmed ✓' : 'Confirm reminder →',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.inter(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: action.confirmed ? AppColors.greenText : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
