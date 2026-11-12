import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _entranceCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..forward();
    _logoScale = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack);
    _logoFade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);

    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      child: GestureDetector(
        onTap: widget.onFinished,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AmbientPulseHalo(
                          color: const Color(0x337186FF),
                          maxScale: 1.55,
                          child: Container(
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.indigo.withValues(alpha: 0.22),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/branding/app_logo.png',
                                width: 116,
                                height: 116,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const AppBrandMark(size: 116),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    StaggeredReveal(
                      index: 1,
                      baseDelay: const Duration(milliseconds: 140),
                      child: Text(
                        'AI Daily Helper',
                        style: AppTheme.inter(
                          size: 31,
                          weight: FontWeight.w800,
                          color: AppColors.navy,
                          letterSpacing: -1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    StaggeredReveal(
                      index: 2,
                      baseDelay: const Duration(milliseconds: 140),
                      child: Text(
                        'Remember more. Do more.',
                        style: AppTheme.inter(
                          size: 12,
                          weight: FontWeight.w500,
                          color: const Color(0xFF8B8790),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 52,
                child: StaggeredReveal(
                  index: 3,
                  child: PagerDots(activeIndex: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
