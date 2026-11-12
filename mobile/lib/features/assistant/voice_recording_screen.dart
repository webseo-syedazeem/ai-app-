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
  int _seconds = 0;
  bool _paused = false;
  bool _brainDumpMode = false;
  bool _submitting = false;
  bool _micAvailable = true;
  double _soundLevel = 0.0;
  String _committedPrefix = '';
  String _currentSegment = '';
  String _micWarning = '';

  String get _transcript {
    final a = _committedPrefix.trim();
    final b = _currentSegment.trim();
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    if (b.toLowerCase().startsWith(a.toLowerCase())) return b;
    return '$a $b';
  }

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
    if (!mounted || _paused || _submitting) return;
    final ok = await widget.appState.voice.startListening(
      onTranscript: (text) {
        if (!mounted) return;
        setState(() {
          _micAvailable = true;
          _micWarning = '';
          _currentSegment = text;
        });
      },
      onSoundLevel: (db) {
        if (!mounted) return;
        // Android dB usually ranges roughly from -2 to +10.
        final normalized = ((db + 2.0) / 12.0).clamp(0.0, 1.0);
        setState(() => _soundLevel = normalized);
      },
      onStatus: (status) {
        if (!mounted || _paused || _submitting) return;
        if (status == 'done' || status == 'notListening') {
          if (_currentSegment.trim().isNotEmpty) {
            _committedPrefix = _transcript;
            _currentSegment = '';
          }
        }
      },
      onError: (msg) {
        if (!mounted) return;
        final lower = msg.toLowerCase();
        if (lower.contains('permission') || lower.contains('unavailable')) {
          setState(() {
            _micAvailable = false;
            _micWarning = 'Allow microphone permission or tap Edit note to type.';
          });
        }
      },
    );
    if (!ok && mounted) {
      setState(() {
        _micAvailable = false;
        _micWarning = 'Voice recognition unavailable — tap Edit note or Retry mic.';
      });
    }
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_paused && !_submitting) {
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

  Future<void> _togglePause() async {
    if (_submitting) return;
    if (!_paused) {
      setState(() {
        _paused = true;
        _soundLevel = 0.0;
        _committedPrefix = _transcript;
        _currentSegment = '';
      });
      await widget.appState.voice.stopListening();
    } else {
      setState(() {
        _paused = false;
        _micWarning = '';
      });
      await _beginStt();
    }
  }

  Future<void> _stopAndSubmit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await widget.appState.voice.stopListening();
    // Allow platform speech engine a brief moment to flush final recognition words.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final text = _transcript.trim();
    if (text.isEmpty) {
      setState(() => _submitting = false);
      showAppToast(context, 'No voice captured yet — speak clearly or tap Edit note.');
      if (!_paused) {
        _beginStt();
      }
      return;
    }

    final looksLikeBrainDump =
        _brainDumpMode || text.split(RegExp(r',|\band\b|\baur\b', caseSensitive: false)).length >= 3;
    if (looksLikeBrainDump) {
      await widget.appState.processVoiceBrainDump(text);
      widget.onCompleteBrainDump(text);
    } else {
      widget.onCompleteSingle(text);
    }
  }

  void _switchMode(bool brainDump) {
    setState(() => _brainDumpMode = brainDump);
  }

  void _editTranscript() {
    final ctrl = TextEditingController(text: _transcript);
    showPremiumSheet(
      context: context,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit voice note', style: AppTheme.inter(size: 19, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          PremiumSheetField(
            controller: ctrl,
            label: 'Transcript',
            hint: 'Speak or type your command / brain dump...',
            maxLines: 4,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Update transcript',
            onTap: () {
              setState(() {
                _committedPrefix = ctrl.text.trim();
                _currentSegment = '';
              });
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      dark: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BouncyTap(
                    onTap: widget.onClose,
                    pressedScale: 0.88,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: AppGradients.accentIndigo,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: AppVectorIcon(
                                  AppIconType.sparkle,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Daily Helper',
                              style: AppTheme.inter(
                                size: 14.5,
                                weight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  BouncyTap(
                    onTap: _editTranscript,
                    pressedScale: 0.88,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                      ),
                      child: const Center(
                        child: AppVectorIcon(
                          AppIconType.editPen,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DarkModePill(
                        label: 'Quick command',
                        icon: AppIconType.mic,
                        active: !_brainDumpMode,
                        onTap: () => _switchMode(false),
                      ),
                      const SizedBox(width: 4),
                      _DarkModePill(
                        label: 'Brain dump',
                        icon: AppIconType.sparkle,
                        active: _brainDumpMode,
                        onTap: () => _switchMode(true),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5365DF).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8C9AFF).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _paused ? const Color(0xFFF6B759) : const Color(0xFF4CE5B1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _paused
                                ? const Color(0x66F6B759)
                                : const Color(0x884CE5B1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _brainDumpMode ? 'BRAIN DUMP CAPTURE' : 'VOICE CAPTURE',
                      style: AppTheme.inter(
                        size: 10,
                        weight: FontWeight.w800,
                        color: const Color(0xFFD5DAFF),
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: AppTheme.inter(
                    size: 40,
                    weight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.4,
                    height: 1.05,
                  ),
                  children: [
                    TextSpan(
                      text: _submitting
                          ? 'Organizing'
                          : _paused
                              ? 'Paused'
                              : 'Listening',
                    ),
                    const TextSpan(
                      text: '...',
                      style: TextStyle(color: Color(0xFF8491FF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              BouncyTap(
                onTap: _editTranscript,
                pressedScale: 0.985,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.065),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                      width: 1.1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 3,
                            height: 44,
                            margin: const EdgeInsets.only(top: 2, right: 12),
                            decoration: BoxDecoration(
                              gradient: AppGradients.accentIndigo,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _transcript.isNotEmpty
                                  ? '“$_transcript”'
                                  : (_micWarning.isNotEmpty
                                      ? _micWarning
                                      : (_brainDumpMode
                                          ? 'Speak naturally — tasks, reminders & shopping...'
                                          : 'Speak clearly now — e.g. "Remind me to call Ali at 5 PM"')),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.inter(
                                size: _transcript.isNotEmpty ? 15 : 13.5,
                                weight: _transcript.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                                color: _transcript.isNotEmpty
                                    ? Colors.white.withValues(alpha: 0.95)
                                    : (_micWarning.isNotEmpty
                                        ? const Color(0xFFF6B759)
                                        : Colors.white.withValues(alpha: 0.62)),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!_micAvailable) ...[
                            BouncyTap(
                              onTap: () {
                                setState(() {
                                  _paused = false;
                                  _micWarning = '';
                                });
                                _beginStt();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6B759).withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Retry mic',
                                  style: AppTheme.inter(
                                    size: 10.5,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFFF6B759),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppVectorIcon(
                                  AppIconType.editPen,
                                  size: 12,
                                  strokeWidth: 2.3,
                                  color: Color(0xFFC5CBFF),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Edit note',
                                  style: AppTheme.inter(
                                    size: 10.5,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFFC5CBFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 118,
                child: AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (_, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_baseHeights.length, (i) {
                        final liveBoost = _soundLevel > 0.05 ? _soundLevel * 0.42 : 0.0;
                        final factor = _paused
                            ? 0.42
                            : (0.58 +
                                    liveBoost +
                                    0.32 *
                                        math.sin(_waveCtrl.value * math.pi * 2 + i * 0.45).abs())
                                .clamp(0.35, 1.15);
                        return Container(
                          width: 4.5,
                          height: (_baseHeights[i] * 0.85 * factor).clamp(10.0, 118.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2.2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFC1C9FF),
                                Color(0xFF6B7CFF),
                                Color(0xFF4B5AE0),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _submitting
                          ? 'ORGANIZING'
                          : _paused
                              ? 'PAUSED'
                              : 'REC',
                      style: AppTheme.inter(
                        size: 10,
                        weight: FontWeight.w800,
                        color: _paused ? const Color(0xFFF6B759) : const Color(0xFF8E9BFF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimer(_seconds),
                      style: AppTheme.inter(
                        size: 16,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StudioCircleButton(
                      icon: _paused ? AppIconType.mic : AppIconType.pause,
                      label: _paused ? 'Resume' : 'Pause',
                      onTap: _togglePause,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BouncyTap(
                          onTap: _stopAndSubmit,
                          pressedScale: 0.92,
                          child: AmbientPulseHalo(
                            color: const Color(0x4D6D7EFF),
                            maxScale: 1.28,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                gradient: AppGradients.accentIndigo,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x555869F5),
                                    blurRadius: 24,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _submitting
                                    ? const SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.8,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check_rounded,
                                        size: 34,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _brainDumpMode ? 'Organize' : 'Send',
                          style: AppTheme.inter(
                            size: 11.5,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    _StudioCircleButton(
                      icon: AppIconType.trash,
                      label: 'Cancel',
                      onTap: widget.onClose,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your thoughts stay private. Review before saving.',
                style: AppTheme.inter(size: 11, color: const Color(0xFF9396B5)),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioCircleButton extends StatelessWidget {
  final AppIconType icon;
  final String label;
  final VoidCallback onTap;

  const _StudioCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BouncyTap(
          onTap: onTap,
          pressedScale: 0.9,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Center(
              child: AppVectorIcon(
                icon,
                size: 22,
                strokeWidth: 2.3,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.inter(
            size: 11,
            weight: FontWeight.w600,
            color: const Color(0xFFB5B8D8),
          ),
        ),
      ],
    );
  }
}

class _DarkModePill extends StatelessWidget {
  final String label;
  final AppIconType icon;
  final bool active;
  final VoidCallback onTap;

  const _DarkModePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.accentIndigo : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x3D5466EA),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppVectorIcon(
              icon,
              size: 13.5,
              strokeWidth: 2.4,
              color: active ? Colors.white : const Color(0xFFB3B6D6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.inter(
                size: 11.5,
                weight: FontWeight.w800,
                color: active ? Colors.white : const Color(0xFFB3B6D6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
