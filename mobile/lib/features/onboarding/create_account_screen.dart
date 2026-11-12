import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class CreateAccountScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final bool initialSignInMode;
  final VoidCallback onBack;
  final Future<String?> Function(String name, String email, String password) onCreate;
  final Future<String?> Function(String email, String password)? onSignIn;
  final Future<String?> Function(String email)? onForgotPassword;

  const CreateAccountScreen({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    this.initialSignInMode = false,
    required this.onBack,
    required this.onCreate,
    this.onSignIn,
    this.onForgotPassword,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _passCtrl = TextEditingController();

  late final AnimationController _shakeCtrl;

  late bool _isSignIn;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignIn = widget.initialSignInMode;
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final p = _passCtrl.text;
    if (p.isEmpty) return 0.0;
    double score = 0.0;
    if (p.length >= 6) score += 0.35;
    if (p.length >= 10) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p) || RegExp(r'[0-9]').hasMatch(p)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score += 0.2;
    return score.clamp(0.15, 1.0);
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s == 0) return '';
    if (s < 0.45) return 'Weak · add 6+ characters';
    if (s < 0.8) return 'Good · add a number or symbol';
    return 'Strong password';
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s < 0.45) return AppColors.roseAccent;
    if (s < 0.8) return AppColors.amberAccent;
    return AppColors.greenSuccess;
  }

  void _triggerError(String msg) {
    setState(() => _errorMessage = msg);
    _shakeCtrl.forward(from: 0);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (!_isSignIn && name.isEmpty) {
      _triggerError('Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _triggerError('Please enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      _triggerError('Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _submitting = true;
    });

    final String? err;
    if (_isSignIn && widget.onSignIn != null) {
      err = await widget.onSignIn!(email, pass);
    } else {
      err = await widget.onCreate(name.isEmpty ? 'Azeem' : name, email, pass);
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null && err.isNotEmpty) {
      _triggerError(err);
    }
  }

  Future<void> _socialContinue(String provider) async {
    if (_submitting) return;
    setState(() {
      _errorMessage = null;
      _submitting = true;
    });

    final email = _emailCtrl.text.trim().isNotEmpty
        ? _emailCtrl.text.trim()
        : 'azeem@example.com';
    final name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Azeem';
    showAppToast(context, 'Connected with $provider');
    if (_isSignIn && widget.onSignIn != null) {
      await widget.onSignIn!(email, '');
    } else {
      await widget.onCreate(name, email, '');
    }
    if (mounted) setState(() => _submitting = false);
  }

  void _showForgotPasswordSheet() {
    final resetCtrl = TextEditingController(text: _emailCtrl.text.trim());
    showPremiumSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TileIconBox(
                icon: AppIconType.lock,
                tone: TileTone.indigo,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reset password',
                  style: AppTheme.inter(size: 19, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Enter the email linked to your account and we will send a sign-in recovery link.',
            style: AppTheme.inter(size: 13, color: AppColors.mutedText, height: 1.5),
          ),
          const SizedBox(height: 14),
          PremiumSheetField(
            controller: resetCtrl,
            label: 'Email address',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Send recovery link',
            onTap: () async {
              final target = resetCtrl.text.trim();
              if (!target.contains('@')) return;
              Navigator.pop(ctx);
              final msg = widget.onForgotPassword != null
                  ? await widget.onForgotPassword!(target)
                  : null;
              if (mounted) {
                showAppToast(context, msg ?? 'Recovery link sent to $target');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: AppHeaderIconBtn(
                icon: AppIconType.chevronLeft,
                onTap: widget.onBack,
              ),
              title: _isSignIn ? 'Sign in' : 'Create account',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(23, 8, 23, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaggeredReveal(
                      index: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder, width: 1.2),
                          boxShadow: AppShadows.choose,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _AuthModeSegment(
                                label: 'Sign up',
                                active: !_isSignIn,
                                onTap: () => setState(() {
                                  _isSignIn = false;
                                  _errorMessage = null;
                                }),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _AuthModeSegment(
                                label: 'Log in',
                                active: _isSignIn,
                                onTap: () => setState(() {
                                  _isSignIn = true;
                                  _errorMessage = null;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StaggeredReveal(
                      index: 1,
                      child: Row(
                        children: [
                          FloatingBob(
                            amplitude: 2.0,
                            duration: const Duration(milliseconds: 2800),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppGradients.softLavCard,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppColors.softLavBorder,
                                  width: 1.2,
                                ),
                                boxShadow: AppShadows.softCard,
                              ),
                              child: const Center(
                                child: AppBrandMark(size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI DAILY HELPER',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.inter(
                                    size: 11,
                                    weight: FontWeight.w800,
                                    color: AppColors.indigo,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Remember more. Do more.',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.inter(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    StaggeredReveal(
                      index: 1,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          key: ValueKey(_isSignIn),
                          child: HeroHeading(
                            plainLine: _isSignIn ? 'Welcome back,' : 'Make space for',
                            emphasizedLine: _isSignIn ? 'let’s get started.' : 'what matters.',
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StaggeredReveal(
                      index: 2,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          key: ValueKey('sub_$_isSignIn'),
                          child: Text(
                            _isSignIn
                                ? 'Pick up right where you left off with your AI assistant.'
                                : 'Your plans, reminders and memories stay yours.',
                            style: AppTheme.inter(
                              size: 13.5,
                              color: AppColors.mutedText,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    StaggeredReveal(
                      index: 3,
                      child: AnimatedBuilder(
                        animation: _shakeCtrl,
                        builder: (ctx, child) {
                          final dx = math.sin(_shakeCtrl.value * math.pi * 4) *
                              (1.0 - _shakeCtrl.value) *
                              10.0;
                          return Transform.translate(offset: Offset(dx, 0), child: child);
                        },
                        child: PremiumCard(
                          padding: const EdgeInsets.all(16),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!_isSignIn) ...[
                                  const _FieldLabel('Full name'),
                                  _AuthTextField(
                                    controller: _nameCtrl,
                                    hint: 'Your full name',
                                    icon: AppIconType.user,
                                    onChanged: (_) {
                                      if (_errorMessage != null) {
                                        setState(() => _errorMessage = null);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                const _FieldLabel('Email address'),
                                _AuthTextField(
                                  controller: _emailCtrl,
                                  hint: 'name@example.com',
                                  icon: AppIconType.mail,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (_errorMessage != null) {
                                      setState(() => _errorMessage = null);
                                    }
                                  },
                                ),
                                const SizedBox(height: 14),
                                const _FieldLabel('Password'),
                                _AuthTextField(
                                  controller: _passCtrl,
                                  hint: '••••••••••••',
                                  icon: AppIconType.lock,
                                  obscure: _obscurePassword,
                                  onChanged: (_) => setState(() {
                                    if (_errorMessage != null) _errorMessage = null;
                                  }),
                                  trailing: GestureDetector(
                                    onTap: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 19,
                                        color: const Color(0xFF7B7D8F),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_isSignIn && _passCtrl.text.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: _passwordStrength),
                                      duration: const Duration(milliseconds: 240),
                                      builder: (_, val, _) => LinearProgressIndicator(
                                        value: val,
                                        minHeight: 5,
                                        backgroundColor: AppColors.barTrack,
                                        valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _strengthLabel,
                                    style: AppTheme.inter(
                                      size: 11,
                                      weight: FontWeight.w700,
                                      color: _strengthColor,
                                    ),
                                  ),
                                ],
                                if (_isSignIn) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _rememberMe = !_rememberMe),
                                          behavior: HitTestBehavior.opaque,
                                          child: Row(
                                            children: [
                                              SquareCheck(
                                                checked: _rememberMe,
                                                onTap: () =>
                                                    setState(() => _rememberMe = !_rememberMe),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  'Keep me signed in',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTheme.inter(
                                                    size: 12,
                                                    weight: FontWeight.w600,
                                                    color: AppColors.mutedText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      BouncyTap(
                                        onTap: _showForgotPasswordSheet,
                                        pressedScale: 0.94,
                                        child: Text(
                                          'Forgot password?',
                                          style: AppTheme.inter(
                                            size: 12,
                                            weight: FontWeight.w800,
                                            color: AppColors.indigo,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: AppColors.tileRose,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTheme.inter(
                                        size: 11.5,
                                        weight: FontWeight.w700,
                                        color: AppColors.roseAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    StaggeredReveal(
                      index: 4,
                      child: Row(
                        children: [
                          const AppVectorIcon(
                            AppIconType.shieldCheck,
                            size: 18,
                            color: AppColors.indigo,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Private, encrypted and always under your control.',
                              style: AppTheme.inter(
                                size: 11.5,
                                weight: FontWeight.w600,
                                color: AppColors.subText,
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
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 20),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _submitting
                        ? (_isSignIn ? 'Signing in...' : 'Creating account...')
                        : (_isSignIn ? 'Sign in' : 'Create account'),
                    onTap: _submit,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: AppTheme.inter(
                              size: 11,
                              weight: FontWeight.w600,
                              color: AppColors.subText,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          badge: const _GoogleMark(),
                          onTap: () => _socialContinue('Google'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          badge: const Icon(
                            Icons.apple_rounded,
                            size: 20,
                            color: AppColors.navy,
                          ),
                          onTap: () => _socialContinue('Apple'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isSignIn = !_isSignIn;
                      _errorMessage = null;
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: Text.rich(
                      TextSpan(
                        style: AppTheme.inter(size: 12, color: AppColors.mutedText),
                        children: [
                          TextSpan(
                            text: _isSignIn
                                ? 'New to AI Daily Helper? '
                                : 'Already have an account? ',
                          ),
                          TextSpan(
                            text: _isSignIn ? 'Sign up' : 'Log in',
                            style: AppTheme.inter(
                              size: 12,
                              weight: FontWeight.w800,
                              color: AppColors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _AuthModeSegment extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _AuthModeSegment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 40,
        decoration: BoxDecoration(
          gradient: active ? AppGradients.accentIndigo : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? AppShadows.softCard : null,
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTheme.inter(
              size: 13,
              weight: FontWeight.w800,
              color: active ? Colors.white : AppColors.mutedText,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: AppTheme.inter(size: 12.5, weight: FontWeight.w800),
      ),
    );
  }
}

class _AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final AppIconType icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.trailing,
  });

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _focused ? Colors.white : AppColors.bgTop,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.indigo : AppColors.fieldBorder,
          width: _focused ? 1.6 : 1.1,
        ),
        boxShadow: _focused
            ? const [
                BoxShadow(
                  color: Color(0x20475BE0),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AppVectorIcon(
            widget.icon,
            size: 19,
            strokeWidth: 2.3,
            color: _focused ? AppColors.indigo : const Color(0xFF7B7D8F),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              focusNode: _focus,
              controller: widget.controller,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              style: AppTheme.inter(
                size: 14,
                color: AppColors.navy,
                weight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTheme.inter(
                  size: 13.5,
                  color: const Color(0xFF9C9DAA),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ?widget.trailing,
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget badge;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: AppShadows.choose,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badge,
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.inter(size: 13, weight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(17),
      painter: _GoogleMarkPainter(),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    const stroke = 3.0;
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawArc(
      rect,
      -0.35,
      1.65,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawArc(
      rect,
      1.3,
      1.4,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawArc(
      rect,
      2.7,
      1.05,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawArc(
      rect,
      3.75,
      1.85,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r + 1.2, c.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = stroke - 0.3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
