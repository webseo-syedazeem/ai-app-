import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class VoiceRecordingScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onClose;
  final ValueChanged<String> onCompleteSingle;
  final ValueChanged<String> onCompleteBrainDump;

  const VoiceRecordingScreen({
    super.key,
    required this.appState,
    required this.onClose,
    required this.onCompleteSingle,
    required this.onCompleteBrainDump,
  });

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen>
    with SingleTickerProviderStateMixin {
  static const List<double> _baseHeights = [
    14, 28, 21, 38, 59, 35, 51, 80, 96, 54, 35, 67, 105,
    135, 91, 65, 42, 96, 71, 40, 27, 59, 77, 36, 22, 13,
  ];

  late final AnimationController _waveCtrl;
  Timer? _clockTimer;
  int _seconds = 7;
  bool _paused = false;
  bool _brainDumpMode = false;
  String _transcript = 'Remind me to call Ali tomorrow at 5 PM.';

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (AppMotion.enableAmbientLoops) {
      _waveCtrl.repeat(reverse: true);
    }
    _startClock();
    _beginStt();
  }

  Future<void> _beginStt() async {
    await widget.appState.voice.startListening(
      onTranscript: (text) {
        if (mounted && text.trim().isNotEmpty) {
          setState(() => _transcript = text);
        }
      },
    );
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_paused) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _waveCtrl.dispose();
    widget.appState.voice.stopListening();
    super.dispose();
  }

  String _formatTimer(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _stopAndSubmit() async {
    await widget.appState.voice.stopListening();
    final text = _transcript.trim();
    final looksLikeBrainDump =
        _brainDumpMode || text.split(RegExp(r',|\band\b|\baur\b', caseSensitive: false)).length >= 3;
    if (looksLikeBrainDump) {
      await widget.appState.processVoiceBrainDump(text);
      widget.onCompleteBrainDump(text);
    } else {
      widget.onCompleteSingle(text);
    }
  }

  void _showModeOrEditMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice Capture Mode',
              style: AppTheme.inter(size: 16, weight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Single action / reminder',
                  style: AppTheme.inter(size: 13, color: Colors.white)),
              subtitle: Text('“Remind me to call Ali tomorrow at 5 PM.”',
                  style: AppTheme.inter(size: 11, color: AppColors.voiceMuted)),
              onTap: () {
                setState(() {
                  _brainDumpMode = false;
                  _transcript = 'Remind me to call Ali tomorrow at 5 PM.';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Brain Dump mode (multi-task organizer)',
                  style: AppTheme.inter(size: 13, color: Colors.white)),
              subtitle: Text(
                '“Prepare the project update tomorrow, email the meeting notes Friday, call Ali tomorrow at 5 PM, buy eggs, bread and detergent.”',
                style: AppTheme.inter(size: 11, color: AppColors.voiceMuted),
              ),
              onTap: () {
                setState(() {
                  _brainDumpMode = true;
                  _transcript =
                      'Prepare the project update tomorrow, email the meeting notes Friday, call Ali tomorrow at 5 PM, buy eggs, bread and detergent';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      dark: true,
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: widget.onClose,
                        child: const Text(
                          '×',
                          style: TextStyle(color: Colors.white, fontSize: 28, height: 1),
                        ),
                      ),
                      Text(
                        'AI Daily Helper',
                        style: AppTheme.inter(
                          size: 13.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showModeOrEditMenu,
                        child: const AppVectorIcon(
                          AppIconType.moreDots,
                          size: 22,
                          color: Color(0xFFECEBFF),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8F98FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x336973FF), spreadRadius: 5),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _brainDumpMode ? 'BRAIN DUMP CAPTURE' : 'VOICE CAPTURE',
                        style: AppTheme.inter(
                          size: 9.5,
                          weight: FontWeight.w700,
                          color: const Color(0xFFBDC3FF),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text.rich(
                    TextSpan(
                      style: AppTheme.inter(
                        size: 38,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                      children: [
                        TextSpan(text: _paused ? 'Paused' : 'Listening'),
                        const TextSpan(
                          text: '...',
                          style: TextStyle(color: Color(0xFF8491FF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '“$_transcript”',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.inter(
                      size: 14,
                      color: AppColors.voiceSubtext,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 46),
                  SizedBox(
                    height: 150,
                    child: AnimatedBuilder(
                      animation: _waveCtrl,
                      builder: (_, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_baseHeights.length, (i) {
                            final factor = _paused
                                ? 0.55
                                : 0.72 +
                                    0.35 *
                                        math.sin(_waveCtrl.value * math.pi * 2 + i * 0.45)
                                            .abs();
                            return Container(
                              width: 4,
                              height: (_baseHeights[i] * factor).clamp(10.0, 145.0),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFF9BA8FF), Color(0xFF5D70F3)],
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x33697DFA), blurRadius: 7),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _formatTimer(_seconds),
                    style: AppTheme.inter(
                      size: 25,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _paused ? 'paused' : 'recording',
                    style: AppTheme.inter(size: 10.5, color: AppColors.voiceMuted),
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _paused = !_paused),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: AppColors.voiceActionBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: AppVectorIcon(
                                AppIconType.pause,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        BouncyTap(
                          onTap: _stopAndSubmit,
                          pressedScale: 0.92,
                          child: AmbientPulseHalo(
                            color: const Color(0x448491FF),
                            maxScale: 1.32,
                            child: Container(
                              width: 71,
                              height: 71,
                              decoration: const BoxDecoration(
                                color: AppColors.voiceStopBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.stop_rounded,
                                  size: 30,
                                  color: AppColors.voiceStopIcon,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: AppColors.voiceActionBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: AppVectorIcon(
                                AppIconType.trash,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Your thoughts are private. Review before saving.',
                    style: AppTheme.inter(size: 10, color: const Color(0xFF9A9CB9)),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
