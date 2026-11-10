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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
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
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
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
              GestureDetector(
                onTap: () {
                  if (_inputCtrl.text.trim().isNotEmpty) {
                    _send(_inputCtrl.text);
                  } else {
                    widget.onOpenVoice();
                  }
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppVectorIcon(
                      AppIconType.mic,
                      size: 19,
                      color: Colors.white,
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
              left: GestureDetector(
                onTap: widget.onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Your assistant',
              right: GestureDetector(
                onTap: widget.onOpenBrainDump,
                child: const AppVectorIcon(AppIconType.moreDots, size: 21),
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
                  for (int i = 0; i < widget.appState.chatMessages.length; i++) ...[
                    if (widget.appState.chatMessages[i].isUser)
                      StaggeredReveal(
                        index: i,
                        offset: const Offset(16, 6),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 285),
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                            decoration: const BoxDecoration(
                              color: Color(0xFF5F72F3),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              widget.appState.chatMessages[i].text,
                              style: AppTheme.inter(
                                size: 12,
                                color: Colors.white,
                                height: 1.6,
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
                                  const AppBrandMark(size: 22),
                                  const SizedBox(width: 7),
                                  Text(
                                    'AI Daily Helper',
                                    style: AppTheme.inter(size: 10.5, weight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 285),
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  border: Border.all(color: AppColors.cardBorder),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  widget.appState.chatMessages[i].text,
                                  style: AppTheme.inter(
                                    size: 12,
                                    color: AppColors.navy,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.appState.chatMessages[i].pendingAction != null)
                              _ReminderConfirmationCard(
                                action: widget.appState.chatMessages[i].pendingAction!,
                                onConfirm: () => widget.appState
                                    .confirmPendingChatAction(widget.appState.chatMessages[i].id),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
  final VoidCallback onConfirm;

  const _ReminderConfirmationCard({
    required this.action,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppVectorIcon(AppIconType.bell, size: 22, color: AppColors.indigo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: AppTheme.inter(size: 13, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.displayTime,
                      style: AppTheme.inter(size: 10.5, color: const Color(0xFF8F90A1)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Timezone: ${action.timezone}',
                      style: AppTheme.inter(size: 10.5, color: const Color(0xFF8F90A1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                action.confirmed ? 'Saved' : 'Edit',
                style: AppTheme.inter(
                  size: 11,
                  color: action.confirmed ? AppColors.greenText : const Color(0xFF888B9B),
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 18),
              GestureDetector(
                onTap: action.confirmed ? null : onConfirm,
                child: Text(
                  action.confirmed ? 'Confirmed ✓' : 'Confirm reminder →',
                  style: AppTheme.inter(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: action.confirmed ? AppColors.greenText : AppColors.indigo,
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
